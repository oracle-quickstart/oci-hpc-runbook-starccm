#!/bin/bash -v

# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

# Mount share drive
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo systemctl stop firewalld
sudo mount $2:/mnt/share /mnt/share

#Add ip to the iplist
ssh -oStrictHostKeyChecking=no $2 'echo '$1' >>~/iplist.txt'

# Change the LC_CTYPE variable
echo export LC_CTYPE="en_US.UTF-8" >> ~/.bashrc