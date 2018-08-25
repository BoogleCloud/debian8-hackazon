#!/usr/bin/env bash

# Check that user is root, exit if not
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

os=$(head -1 /etc/os-release)

# Set up host key for root, put keys in resources/authorized_keys
if [ -s /tmp/resources/authorized_keys ]; then
  mkdir -p /root/.ssh
  cp -f /tmp/resources/authorized_keys /root/.ssh
fi

# Allow root to login with key
sed -i -e 's/^PermitRootLogin (yes|no)$/\#PermitRootLogin no/' /etc/ssh/sshd_config
echo "PermitRootLogin without-password" >> /etc/ssh/sshd_config

# Only allow other users to login with key
sed -i -e 's/^PasswordAuthentication yes$//' /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Install modded bashrc
cp -f /tmp/resources/.bashrc ~/.bashrc

# Set bashrc for non-root users based on OS
if [[ $os =~ .*"Debian".* || $os =~ .*"Kali".* || $os =~ .*"Ubuntu".* ]] ; then
    sed -i -e 's/^PS1="${debian.*$/PS1="${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "/' /etc/skel/.bashrc
elif [[ $os =~ .*"CentOS".* ]] ; then
    echo 'PS1="${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "' >> /etc/skel/.bashrc
fi

# Set up profile for new accounts:
sed -i -e 's/^\#force_color_prompt=yes$/force_color_prompt=yes/' /etc/skel/.bashrc
cat >> /etc/skel/.bashrc <<bashrcadds
alias ll='ls -lh'
alias la='ls -lah'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
bashrcadds

# Setup vimrc
cp -f /tmp/resources/.vimrc /root
cp -f /tmp/resources/.vimrc /etc/skel
