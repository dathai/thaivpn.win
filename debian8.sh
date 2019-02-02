#!/bin/bash

# go to root
cd

# Install Command
apt-get -y install ufw
apt-get -y install sudo

# Install Pritunl
echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" > /etc/apt/sources.list.d/mongodb-org-3.2.list
echo "deb http://repo.pritunl.com/stable/apt jessie main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 42F3E95A2C4F08279C4960ADD68FA50FEA312927
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-get -y update
apt-get -y upgrade
apt-get install pritunl mongodb-org
systemctl start mongod pritunl
systemctl enable mongod pritunl

# Install Squid
apt-get -y install squid3
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig
wget -q -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/squid.conf" 
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid3/squid.conf;
service squid3 restart

# Install Web Server
apt-get -y install nginx php5-fpm php5-cli
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by DRCYBER </pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# Install Vnstat
apt-get -y install vnstat
vnstat -u -i eth0
sudo chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# Install Vnstat GUI
cd /home/vps/public_html/
wget https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);


# Enable Firewall
sudo ufw allow 22,80,81,222,443,8080,9700,60000,1194/tcp
sudo ufw allow 22,80,81,222,443,8080,9700,60000,1194/udp
sudo yes | ufw enable

#FIGlet In Linux
sudo apt-get install figlet
yum install figlet

# About
clear
echo "Script Pritunl Auto Install"
figlet "THAIVPN.WIN"
echo "-Pritunl"
echo "-MongoDB"
echo "-Squid Proxy Port 80,3128,8080"
echo "MOD THAIVPN.WIN 2020"
echo "TimeZone   :  Bangkok"
echo "Pritunl    :  https://$MYIP"
echo "Please Copy Code Go To Installer"
pritunl setup-key
echo "pritunl default-password"
sudo pritunl default-password
