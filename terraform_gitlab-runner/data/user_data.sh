#!/bin/bash

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
  -u http://18.222.170.237/ \
  -r xfff5XkMs9RjSdRJQ6zY \
  --executor "docker+machine" \
  --name "gitlab-runner-ec2-spot" \
  --docker-image "centos" \
  --non-interactive

# Pega Token gerado automaticamente pelo registro.
token=$(cat /etc/gitlab-runner/config.toml | grep token | cut -d '"' -f2)

# Adiciona a configuração do Runner (Cache no S3 e Orquestração Ec2 Spot)
cat <<EOF > /etc/gitlab-runner/config.toml
concurrent = 20 
check_interval = 0

[[runners]]
  name = "gitlab-runner-ec2-spot"
  url = "http://18.222.170.237/"
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
      "amazonec2-region=us-east-2",
      "amazonec2-zone=c",
      "amazonec2-vpc-id=vpc-650a3f0d",
      "amazonec2-subnet-id=subnet-9db945d1",
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
sed -i -- 's/\[\[TOKEN\]\]/'"$token"'/g' /etc/gitlab-runner/config.toml

# Instala o service do gitlab-runner
gitlab-runner install --user root || true

# Reinicia gitlab-runner para pegar novas confs
gitlab-runner restart