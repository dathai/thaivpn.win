#install_pritunl

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 656408E390CFB1F5 && sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && apt-get update && apt-get --assume-yes install pritunl mongodb-org && systemctl start pritunl mongod && systemctl enable pritunl mongod
