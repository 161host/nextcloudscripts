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

if ! apt-cache show php8.1 >/dev/null 2>&1; then
    # Add Ondrej's PPA for php8.1
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get update
    
    # Check if the package can now be installed
    if apt-cache show php8.1 >/dev/null 2>&1; then
    else
        echo "Error: php8.1 could not be installed"
        exit 1
    fi

apt install nginx certbot wget unzip bash sed python3-certbot-nginx mariadb-server php8.1 php8.1-cli php8.1-fpm php8.1-zip php8.1-mysql php8.1-opcache php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl libmagickcore-6.q16-3-extra php8.1-imagick logrotate -y

cp /scripts/install/src/immutable.conf /etc/nginx/conf.d/immutable.conf
cp /scripts/install/src/php-handler.conf /etc/nginx/conf.d/php-handler.conf

nginx -t

mount -a

if [ -d /data ]; then
  echo "/data already exists"
else
  echo "Creating /data"
  mkdir /data
fi

if [ -d /webroot ]; then
  echo "/webroot already exists"
else
  echo "Creating /webroot"
  mkdir /webroot
fi

if [ -d /secrets ]; then
  echo "/secrets already exists"
else
  echo "Creating /secrets"
  mkdir /secrets
fi


if [ -d /scripts/data ]; then
  echo "/scripts/data already exists"
else
  echo "Creating /scripts/data"
  mkdir /scripts/data
fi



echo 'alias ncmgmt="bash /scripts/domainmgmt.sh"' >> ~/.bashrc
source ~/.bashrc

read -p "Enter your custom subdomain:  " subdomain


cp /scripts/install/src/subdomain.tmpl /scripts/templates/subdomain
cp /scripts/install/src/creation_sub.sh.tmpl /scripts/creation_sub.sh

sed -i "s/replacewithactualsubdomain/$subdomain/g" /scripts/creation_sub.sh


read -p "Enter the path to the SSL certificate (default: /etc/letsencrypt/live/$subdomain/fullchain.pem): " cert_path
if [ -z "$cert_path" ]; then
    cert_path="/etc/letsencrypt/live/$subdomain/fullchain.pem"
fi

# Ask for the private key path
read -p "Enter the path to the private key (default: /etc/letsencrypt/live/$subdomain/privkey.pem): " key_path
if [ -z "$key_path" ]; then
    key_path="/etc/letsencrypt/live/$subdomain/privkey.pem"
fi

sed -i "s/replacewithfullchain/$cert_path/g" /scripts/templates/subdomain
sed -i "s/replacewithprivatekey/$key_path/g" /scripts/templates/subdomain



cp /scripts/install/src/logrotate /etc/logrotate.d/nextcloud
logrotate -f /etc/logrotate.d/nextcloud

