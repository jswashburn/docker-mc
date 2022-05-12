#!/bin/bash

# uninstall any old versions of docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# download and run docker installation convenience script
# https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# configure docker to start on boot
# https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot
 sudo systemctl enable docker.service
 sudo systemctl enable containerd.service