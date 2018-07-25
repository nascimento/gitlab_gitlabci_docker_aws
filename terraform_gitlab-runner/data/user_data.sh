#!/bin/bash

# install docker
yum -y install docker
usermod -a -G docker ec2-user
service docker start

# configure runner
cat <<EOF > /etc/gitlab-runner/config.toml
concurrent = 1
check_interval = 0

[[runners]]
  name = "gitlab-ec2-spot"
  url = "http://gitlab-428233952.us-east-2.elb.amazonaws.com/"
  token = "xa6DVjXfELoyBVhVmh1b"
  executor = "docker+machine"
  limit = 20
  [runners.docker]
    image = "centos"
    privileged = true
    disable_cache = true
  [runners.cache]
    Type = "s3"
    BucketName = "gitlabcache"
    BucketLocation = "us-east-2"
    Shared = true
  [runners.machine]
    IdleCount = 1
    IdleTime = 1800
    MaxBuilds = 100
    OffPeakTimezone = "Brazil/Sao_Paulo"
    OffPeakPeriods = [
      "* * 0-8,20-24 * * mon-fri *",
      "* * * * * sat,sun *"
    ]
    OffPeakIdleCount = 0
    OffPeakIdleTime = 1200
    MachineDriver = "amazonec2"
    MachineName = "gitlab-docker-machine-%s"
    MachineOptions = [
      "amazonec2-region=us-east-2",
      "amazonec2-vpc-id=vpc-650a3f0d",
      "amazonec2-subnet-id=subnet-a93dc0e5",
      "amazonec2-use-private-address=true",
      "amazonec2-tags=gitlab-runner",
      "amazonec2-security-group=public",
      "amazonec2-instance-type=t2.medium",
      "amazonec2-request-spot-instance=true",
      "amazonec2-spot-price=0.03",
      "amazonec2-block-duration-minutes=59"
    ]
EOF