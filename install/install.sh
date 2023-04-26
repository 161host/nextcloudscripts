#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

# This is just another excuse to not write an ansible role cause it is soo much easier for you to setup. (Yes I'll show myself to the door....)

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


apt update && apt upgrade -y
apt install nginx certbot wget unzip bash sed python3-certbot-nginx mariadb-server php8.1 php8.1-cli php8.1-fpm php8.1-zip php8.1-mysql php8.1-opcache php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl -y

cp /scripts/install/src/immutable.conf /etc/nginx/conf.d/immutable.conf
cp /scripts/install/src/php-handler.conf /etc/nginx/conf.d/php-handler.conf

nginx -t

mkdir /scripts/data

echo 'alias ncmgmt="bash /scripts/domainmgmt.sh"' >> ~/.bashrc
source ~/.bashrc

read -p "Enter your custom subdomain:  " subdomain


cp /scripts/install/src/subdomain.tmpl /scripts/templates/subdomain
cp /scripts/install/src/creation_sub.sh.tmpl /scripts/creation_sub.sh

sed -i "s/replacewithactualsubdomain/$subdomain/g" /scripts/creation_sub.sh
sed -i "s/replacewithactualsubdomain/$subdomain/g" /scripts/templates/subdomain

echo "I'll just expect that your wildcard certificate is here: /etc/letsencrypt/live/$subdomain/"
echo " "
echo "If not. You wanna change that in /scripts/templates/subdomain"
