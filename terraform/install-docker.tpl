#!/bin/sh

yum update -y
yum install -y docker

curl -fsSL "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname
-s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

groupadd docker
usermod -aG docker ec2-user

systemctl enable docker.service
systemctl start docker.service

id ec2-user
docker version
docker-compose version
