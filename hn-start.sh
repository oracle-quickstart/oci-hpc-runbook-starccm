#!/bin/bash -v

# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

# Create share directory
sudo mkdir /mnt/share
sudo firewall-cmd --permanent --zone=public --add-service=nfs
# Next line is needed for CentOS base Image
sudo firewall-cmd --remove-interface='eno2' --zone=public 
sudo firewall-cmd --permanent --zone=public --add-source=$1
sudo firewall-cmd --reload
sudo systemctl enable nfs-server.service
sudo systemctl start nfs-server.service
echo y | sudo mkfs -t ext4 /dev/nvme0n1
sudo mount /dev/nvme0n1 /mnt/share
sudo chmod 777 /mnt/share
echo '/mnt/share    10.0.0.0/16(rw)' | sudo tee /etc/exports
sudo exportfs -a

# Change the LC_CTYPE variable
echo export LC_CTYPE="en_US.UTF-8" >> ~/.bashrc
