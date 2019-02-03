#!/bin/bash
# go to root
cd
apt-get update
apt-get install nano
apt-get install wget

wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/sources.list"

wget https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/pritunl16.sh && chmod +x install_pritunl16.sh && ./install_pritunl16.sh

#!/bin/bash
cd
# Change to Time GMT+8
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

#MYIP=$(wget -qO- ipv4.icanhazip.com);

# Install Squid
apt-get -y install squid
systemctl start squid
systemctl enable squid
cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/dathai/thaivpn.win/master/api/squid.conf" 
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid/squid.conf;
systemctl restart squid
clear

MYIP=$(wget -qO- ipv4.icanhazip.com);

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

cd
# Enable Firewall
sudo ufw allow 22,80,81,222,443,3128,8080/tcp
sudo ufw allow 22,80,81,222,443,3128,8080/udp
sudo yes | ufw enable

#FIGlet In Linux
apt-get install figlet
# About
clear
figlet "THAIVPN"
echo "MOD BY THAIVPN.WIN"
echo "-Pritunl"
echo "-MongoDB"
echo "-Squid Proxy Port 8080,3128"
echo "Vnstat  :  http://$MYIP:81/vnstat"
echo "Pritunl :  https://$MYIP"
echo "Login pritunl?"
echo "copy key"
pritunl setup-key
