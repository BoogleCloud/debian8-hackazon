#!/bin/bash
#
# This script will attempt to download and install Openvas9 from source
#
# Check for root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
fi

# Customize passwords in this file
source /tmp/resources/passwordsrc

echo -e "$VAGRANT_PASS\n$VAGRANT_PASS" | passwd vagrant
echo -e "$ROOT_PASS\n$ROOT_PASS" | passwd root

# Followed instructions per
# https://www.debiantutorials.com/how-to-install-mysql-server-5-6-or-5-7/
wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb

# Set up for non-interactive
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password $MYSQL_ROOT_PASS"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password $MYSQL_ROOT_PASS"
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-codename select jessie'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-distro select debian'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-url string http://repo.mysql.com/apt'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-preview select '
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-product select Ok'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-5.6'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-tools select '
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/unsupported-platform select abort'

dpkg -i mysql-apt-config_0.8.9-1_all.deb
apt-get update
apt-get -y install apache2 git mysql-community-server libapache2-mod-php5 php5-mysql

cd /var/www
git clone https://github.com/rapid7/hackazon.git

cd /var/www/hackazon
php composer.phar self-update
php composer.phar install -o --prefer-dist
echo "127.0.0.1 hackazon.lc" >> /etc/hosts

mv /tmp/resources/001-hackazon.conf /etc/apache2/sites-available
rm -f /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/001-hackazon.conf /etc/apache2/sites-enabled/001-hackazon.conf

chown -R www-data:www-data /var/www/hackazon

a2enmod rewrite
systemctl restart apache2

# Set up the local creds to use
echo "[client]" >> ~/.my.cnf
echo "user=root" >> ~/.my.cnf
echo "password=$MYSQL_ROOT_PASS" >> ~/.my.cnf
chmod 600 ~/.my.cnf
mysql -h "localhost" <<< "CREATE database hackazon;"
mysql -h "localhost" <<< "GRANT ALL ON hackazon.* TO hackazon@'localhost' IDENTIFIED BY '$MYSQL_HKZ_PASS';"

cp /var/www/hackazon/assets/config/db.sample.php /var/www/hackazon/assets/config/db.php
sed -ie "s/yourdbpass/$MYSQL_HKZ_PASS/" /var/www/hackazon/assets/config/db.php
chown -R www-data:www-data /var/www/hackazon


# TODO Email config with sendmail
# default hackazon command is: /usr/sbin/sendmail -bs


IP_ADDR=$(ip addr show dev eth0 | grep inet | cut -f 6 -d ' ' | cut -f 1 -d '/')
echo "Hackazon setup complete, go to http://$IP_ADDR/install to finalize install"
echo "Select 'use existing password' for database setup"