#!/bin/bash

get_new_hostname () {
    read -p 'Enter a new hostname: ' new_hostname
    read -p 'Please enter the same hostname again for confirmation: ' confirmed_hostname
    if [ "$new_hostname" != "$confirmed_hostname" ]; then
        echo "You gave different hostnames. Let's try that again.. "
        get_new_hostname
    fi
    echo "Ok, we will use '$new_hostname' as the new hostname"
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# The below section will change the machines hostname
echo "We will now change the hostname of this machine"
old_hostname=$(head -n 1 /etc/hostname)
get_new_hostname

hostname $new_hostname
sed -i "s/$old_hostname/$new_hostname/g" /etc/hosts
sed -i "s/$old_hostname/$new_hostname/g" /etc/hostname

# The below section will remove SSH host keys (if present) and create new ones
echo "Removing SSH Server keys.."
rm /etc/ssh/ssh_host_*
echo "Keys removed. Generating new ones.."
dpkg-reconfigure openssh-server
echo "New Keys have been generated. SSH will now be restarted for the new keys to take effect.."
systemctl restart ssh
