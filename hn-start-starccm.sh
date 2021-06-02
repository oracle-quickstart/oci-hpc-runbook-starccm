#!/bin/bash -v

# Stop the firewall to allow communication with the nodes
# TODO: find the exact ports to open
sudo systemctl stop firewalld

# Add librairies
sudo yum install -y libSM libX11 libXext libXt

# Disable Hyperthreading
sudo chmod 777 /mnt/share/disable_ht.sh
sudo /mnt/share/disable_ht.sh 0

cd /mnt/share

# Download and install STAR-CCM+
mkdir /mnt/share/installsources
cd /mnt/share/
wget $2 -O STARCCMINSTALLER.tar.gz
tar -C /mnt/share/installsources -xf STARCCMINSTALLER.tar.gz

mkdir /mnt/share/install
cd /mnt/share/installsources
cd /mnt/share/installsources/*
./*.sh -i silent -DINSTALLDIR=/mnt/share/install


# Register the headnode as a compute node 
echo $1:36 >> /mnt/share/install/machinelist.txt

# Remove flexlm file that is causing issue if you are using the POD key
rm ~/.flexlmrc

echo done