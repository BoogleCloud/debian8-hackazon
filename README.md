# Hackazon VM Auto build
Vagrant script for building a VM with [hackazon](https://github.com/rapid7/). Thanks to the Rapid7 team for creating it.

Based on install instructions at https://github.com/rapid7/hackazon/wiki

Needed to use mysql version 5.6 per [hackazon issue 9](https://github.com/rapid7/hackazon/issues/9)

Software versions:
OS: Debian 8 (Jessie)
Apache 2.4
PHP 5.6
MySQL 5.6

## SSH Keys
By default the bootstrap.sh file removes the ability to log in via ssh password for all users. Add an authorized_keys file within the resources directory containing your desired keys.

## Passwords
Passwords are set in the resources/passwordsrc file.