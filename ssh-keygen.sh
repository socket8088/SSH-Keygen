#!/bin/bash
# Autor: Xavi Beltran
# Date: 07/05/2019
# Generate a pair of SSH keys for a Linux user
 
# Verify if the script received the argument
if [ "$#" -ne 1 ]
then
    echo '[-] No user provided!'
    echo '[+] Usage:'
    echo '    /bin/bash ssh-keygen.sh <USER>'
    exit 1 
fi
 
# We save the parameter into a variable
user=$1
 
# Verify if the user exists
if [ $(cat /etc/passwd | awk -F ':' '{print$1}' | grep $user | wc -l) -ne 1 ]
then
    echo '[-] Not valid username!'
    echo '    Exiting...'
    exit 1
fi
 
# Verify if the folder exists
echo '[+] Verify if the user ssh folder exists'
if [ ! -d "/home/$user/.ssh" ]
    then
        echo "[-] SSH folder doesn't exist!"
        # Create the folder
        echo '[+] Creating the user folder'
        mkdir /home/$user/.ssh
        chmod 700 /home/$user/.ssh
        chown $user:$user /home/$user/.ssh
    else
        echo '[+] SSH folder exists'
    fi
 
 
# Everything looks fine, let's generate the keys
echo '[+] Generating the pair of keys'
ssh-keygen -t rsa -b 4096 -f /root/.ssh/$user -q -N ""
 
# Copy the key to the user folder
echo '[+] Copying the keys to the user folder'
cp /root/.ssh/$user.pub /home/$user/.ssh/id_rsa.pub
#cp /root/.ssh/$user /home/$user/.ssh/id_rsa
chmod 600 /root/.ssh/$user
chown $user:$user /root/.ssh/$user
 
# Add the key to the system
echo '[+] Adding new key to SSH authentication agent'
ssh-add /home/$user/.ssh/id_rsa
 
# Add the key to authorized keys
echo '[+] Adding new key to authorized keys'
cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
 
# Change permissions
echo '[+] Changing file permissions'
chmod 600 /home/$user/.ssh/authorized_keys
 
# Change owner of the files
echo '[+] Changing file owner'
chown $user:$user /home/$user/.ssh/*
