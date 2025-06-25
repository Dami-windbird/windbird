#!/bin/bash
# 构建镜像
docker build -t windbird:latest .

# 打包镜像
docker save -o /tmp/docker_file/windbird.tar windbird:latest