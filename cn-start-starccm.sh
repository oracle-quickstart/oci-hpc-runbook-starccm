#!/bin/bash -v

# Stop the firewall to allow communication with the nodes
# TODO: find the exact ports to open
sudo systemctl stop firewalld

# Add librairies
sudo yum install -y libSM libX11 libXext libXt

# Disable Hyperthreading
sudo chmod 777 /mnt/share/disable_ht.sh
sudo /mnt/share/disable_ht.sh 0

# Register the headnode as a compute node 
echo $1:36 >> /mnt/share/install/machinelist.txt