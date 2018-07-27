Este repositório tem a finalidade de demonstrar como subir um ambiente do Gitlab-CE e GitlabCi utilizando Docker e Aws Spot para provisionamento de infraestrutura.

Fork from: github.com/nascimento/gitlab_gitlabci_docker_aws

This repo was based on Gitlab Documentation: https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/

# Project Structure
## Terraform
###  Modules
  - terraform_global
    
    This folder has scripts that creates AWS base infra-structure to Gitlab Server and Runner.
    
    - vpc
    - subnet 
    - security_group (publico)
    - key_pair

  - terraform_gitlab

    This folder has scripts that creates the infra-structure on AWS with Gitlab.

    > Important: The Gitlab Server instaled here has no backup, so do not use this in production.

    Creates:
    - ec2

  - terraform_gitlab-runner

    This folder has scripts that creates the infra-structure on AWS with GItlab-Runner with automatic registering runner on Gitlab Server.

    Creates:
    - Ec2 Spot (t2.small)
    - Ec2 Spot with Docker.
      - Gitlab-Runner automatic creates Docker Servers based on gitlab/config.toml and automaticaly scale it with Docker+Machine.

    > Documentation: https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/

### How to run:

  First, configure your AWS_SECRETS* on ~/.aws/credentials after terraform run.

  > Doc: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli-chap-getting-started.html

  Before, run terraform:
  
  ```bash
  terraform plan 
  terraform apply 
  ```

  Running terraform we will: 
  - Configure based infraestructure on AWS
  - Create an Ec2 instance for Gitlab App
  - Create an Ec2 Spot request to run Gitlab-Runner (This use user-data shell script).

### How to test
  - Access Gitlab Server with public DNS or IP.
  - Push the projeto _project_high_cpu inside this projeto to created gitlab and push changes some times to see the magic happening.

