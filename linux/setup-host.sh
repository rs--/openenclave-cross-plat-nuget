#!/bin/bash

# Install LXD.
sudo apt install lxd

# Initialize LXD (the defaults are fine).
echo You may accept the defaults.
sudo lxd init

# Add the current user to the 'lxd' group.
sudo usermod -aG lxd $USER

# Allow mapping the default user inside the LXC containers to the current host
# user.
echo root:$UID:1 | sudo tee -a /etc/subuid /etc/subgid
