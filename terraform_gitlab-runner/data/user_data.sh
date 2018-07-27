#!/bin/bash

# Configura o TimeZone de SaoPaulo
timedatectl set-timezone America/Sao_Paulo
yum install -y ntp

# Instala o Docker-Machine
base=https://github.com/docker/machine/releases/download/v0.14.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) > /usr/bin/docker-machine &&
  chmod +x /usr/bin/docker-machine

# Cria ID_RSA do Gitlab-Runner
yes | ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""

# Baixa e instala o Gitlab-Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
yum -y install gitlab-runner

# Registra o Gitlab-Runner
mkdir -p /etc/gitlab-runner/
gitlab-ci-multi-runner register -c /etc/gitlab-runner/config.toml \
  -u http://18.222.192.9/ \
  -r FKw8HUvu3yyEHL2XhMyZ \
  --executor "docker+machine" \
  --name "gitlab-runner-ec2-spot" \
  --docker-image "centos" \
  --non-interactive

# Pega Token gerado automaticamente pelo registro.
echo "Pegando token gerado do conf do Gitlab-Runner"
token=$(cat /etc/gitlab-runner/config.toml | grep token | cut -d '"' -f2)

# Adiciona a configuração do Runner (Cache no S3 e Orquestração Ec2 Spot)
echo "Escrevendo o conf do Gitlab-Runner"
cat <<EOF > /etc/gitlab-runner/config.toml
concurrent = 30 
check_interval = 0

[[runners]]
  name = "gitlab-runner-ec2-spot"
  url = "${gitlab_url}"
  token = "[[TOKEN]]"
  executor = "docker+machine"
  limit = 20
  [runners.docker]
    image = "centos"
    privileged = true
    disable_cache = false
    volumes = ["/cache"]
    tls_verify = false
    shm_size = 0
    allowed_images = ["docker.artifactoryci.awsrede.corp/*:*","index.docker.io/v1/*:*"]
  [runners.cache]
    Type = "s3"
    BucketName = "gitlabcache"
    BucketLocation = "us-east-2"
    Shared = true
  [runners.machine]
    IdleCount = 1
    IdleTime = 1800
    MaxBuilds = 100
    OffPeakTimezone = "America/Sao_Paulo"
    OffPeakPeriods = [
      "* * 0-8,20-23 * * mon-fri *",
      "* * * * * sat,sun *"
    ]
    OffPeakIdleCount = 0
    OffPeakIdleTime = 1200
    MachineDriver = "amazonec2"
    MachineName = "gitlab-runner-%s"
    MachineOptions = [
      "amazonec2-region=${region}",
      "amazonec2-zone=${zone}",
      "amazonec2-vpc-id=${vpc_id}",
      "amazonec2-subnet-id=${subnet_id}",
      "amazonec2-use-private-address=true",
      "amazonec2-tags=gitlab-runner",
      "amazonec2-security-group=public",
      "amazonec2-instance-type=c4.large",
      "amazonec2-request-spot-instance=true",
      "amazonec2-spot-price=0.053",
      "amazonec2-block-duration-minutes=60"
    ]
EOF

# Adiciona token no template
echo "Substituindo o token no conf do Gitlab-Runner"
sed -i -- 's/\[\[TOKEN\]\]/'"$(echo $token)"'/g' /etc/gitlab-runner/config.toml 

# Instala o service do gitlab-runner
echo "Instalando serviço do Gitlab-Runner"
gitlab-runner install --user root || true

# Reinicia gitlab-runner para pegar novas confs
echo "Reiniciando Gitlab-Runner"
gitlab-runner restart