#!/bin/bash


function print_green {
  echo -e "\e[32m${1}\e[0m"
}

print_green 'Clean Apt'
sudo apt-get -y autoremove aptitude
sudo aptitude clean
sudo aptitude autoclean

print_green 'Remove SSH keys'
[ -f /home/ubuntu/.ssh/authorized_keys ] && rm /home/ubuntu/.ssh/authorized_keys

print_green 'Cleanup bash history'
unset HISTFILE
[ -f /root/.bash_history ] && sudo rm /root/.bash_history
[ -f /home/ubuntu/.bash_history ] && sudo rm /home/ubuntu/.bash_history

print_green 'AMI cleanup complete!'
exit 0
