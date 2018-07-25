Este repositório tem a finalidade de demonstrar como subir um ambiente do Gitlab-CE e GitlabCi utilizando Docker e Aws Spot para provisionamento de infraestrutura.


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

    > Importante: O Gitlab instalado aqui não tem storage, portanto é para uso temporário.

    - ecs
    - ec2 spot request

  - terraform_gitlab-runner

### Como rodar:
  - Configurar base da Aws
    
    ```bash
    terraform plan terraform_global
    terraform apply terraform_global
    ```

  - Rodar infraestrutra Gitlab
    
    ```bash
    terraform plan terraform_gitlab
    terraform apply terraform_gitlab
    terraform show terraform.tfstate | grep dns_name 
    ```

    Logar no Gitlab com ip publico do log acima com usuario 'root' e senha 'password'.