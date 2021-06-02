#!/bin/bash -v

# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

# Mount share drive
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --remove-interface='eno2' --zone=public 
sudo firewall-cmd --reload
sudo mount $2:/mnt/share /mnt/share

#Set up a VNC session
sudo yum -y groupinstall 'Server with GUI'
sudo yum -y install tigervnc-server mesa-libGL
sudo systemctl set-default graphical.target
sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:0.service
sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:0.service
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo $1 | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
sudo systemctl start vncserver@:0.service
sudo systemctl enable vncserver@:0.service