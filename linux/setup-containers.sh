#!/bin/bash

configure_container() {
    CONTAINER_NAME=$1

    # Map the default user inside the LXC container to the current host user.
    lxc config set $1 raw.idmap 'both 1000 1000'

    # Pass the current host user's home directory into the container.
    lxc config device add $1 homedir disk source=$HOME path=$HOME

    # Tell AppArmor that this container is unconfined because the Ansible
    # playbooks require performing system calls such as mount() that AppArmor
    # blocks inside LXC containers by default.
    lxc config set $1 raw.lxc "lxc.apparmor.profile=unconfined"
}

# Initialize the two containers.
lxc init ubuntu:16.04 oepkgxenial
lxc init ubuntu:18.04 oepkgbionic

# Configure them.
configure_container oepkgxenial
configure_container oepkgbionic

# Start them.
lxc start oepkgxenial oepkgbionic
