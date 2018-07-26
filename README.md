Este repositório tem a finalidade de demonstrar como subir um ambiente do Gitlab-CE e GitlabCi utilizando Docker e Aws Spot para provisionamento de infraestrutura.

fork from: github.com/nascimento/gitlab_gitlabci_docker_aws

Baseado na documentação: https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/

# Estrutura do Projeto
## Terraform
###  Modulos
  - terraform_global
    
    Configura a estrutura base (simplificada) na Aws para rodar Gitlab e Gitlab-Runner. 
    
    - vpc
    - subnet 
    - security_group (publico)
    - key_pair

  - terraform_gitlab

    Cria a infraestrutura para rodar o Gitlab, utilizando Docker (Aws Ecs) e Instancias Spot (baixo custo).

    > Importante: O Gitlab instalado aqui não tem backup, portanto é para uso temporário.

    - ec2

  - terraform_gitlab-runner

### Como rodar:
  - Configurar base da Aws
    
    ```bash
    terraform plan 
    terraform apply 
    ```

  - Rodar infraestrutra Gitlab
    
    ```bash
    terraform plan terraform_gitlab
    terraform apply terraform_gitlab
    ```

    Logar no Gitlab com ip publico do log acima com usuario 'root' e senha 'password'.

  - Gerar e Atualizar terraform do Gitlab-Runner com token e url do servidor do Gitlab

  - Rodar infraestrutra Gitlab-Runner
    
    ```bash
    terraform plan terraform_gitlab
    terraform apply terraform_gitlab
    ```

    Logar no Gitlab com ip publico do log acima com usuario 'root' e senha 'password'.