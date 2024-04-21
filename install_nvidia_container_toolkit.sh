# source :
# https://docs.docker.com/engine/install/debian/#install-using-the-repository
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# https://www.tensorflow.org/install/pip?hl=fr

#!/bin/bash

if ! command -v docker &> /dev/null; then
    echo "Docker will be installed because it is not present in the system."
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi



echo "Installation of Nvidia Toolkit"

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update

apt-get install -y nvidia-container-toolkit

nvidia-ctk runtime configure --runtime=docker

systemctl restart docker



echo "test of the installations:"
#docker pull debian
#docker run --rm --runtime=nvidia --gpus all debian nvidia-smi

docker pull tensorflow/tensorflow:latest-gpu
#docker run --rm --runtime=nvidia --gpus all tensorflow/tensorflow:latest-gpu nvidia-smi 
docker run --rm --runtime=nvidia --gpus all tensorflow/tensorflow:latest-gpu python3 -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000]))); print(tf.config.list_physical_devices('GPU'))"



