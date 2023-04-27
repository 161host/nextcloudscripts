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

os_name=$(lsb_release -si)
os_version=$(lsb_release -sr)

# Check if the operating system is Ubuntu or earlier than Ubuntu 18.04
if [ "$os_name" != "Ubuntu" ] || [ "$(echo "$os_version < 18.04" | bc)" -eq 1 ]; then
    echo "Error: This script is intended for Ubuntu 18.04 or later"
    exit 1
else
    echo "Operating system is $os_name $os_version"
    echo "Lets Continue"
fi

echo "Updating apt Cache & upgrade all packages"
apt update && apt upgrade -y

echo "Check if php8.1 can be installed"
if ! apt-cache show php8.1 >/dev/null 2>&1; then
    echo "Add ppa:ondrej/php for php8.1"
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get update
    
    if apt-cache show php8.1 >/dev/null 2>&1; then
    else
        echo "Error: php8.1 could not be installed"
        exit 1
    fi

echo "Install needed software"
apt install nginx certbot wget unzip bash sed python3-certbot-nginx mariadb-server php8.1 php8.1-cli php8.1-fpm php8.1-zip php8.1-mysql php8.1-opcache php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl libmagickcore-6.q16-3-extra php8.1-imagick logrotate -y

echo "Copy nginx config snippets"
cp /scripts/install/src/immutable.conf /etc/nginx/conf.d/immutable.conf
cp /scripts/install/src/php-handler.conf /etc/nginx/conf.d/php-handler.conf


echo "Test nginx config"
nginx -t

echo "Try to mount everything"
mount -a

echo "Check if directories existing and otherwise create them"
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


echo "Create ncmgmt command"
echo 'alias ncmgmt="bash /scripts/domainmgmt.sh"' >> ~/.bashrc

source ~/.bashrc

echo "Starting the customization part:"

read -p "Enter your custom subdomain:  " subdomain

echo "Copy templates to directories"
cp /scripts/install/src/subdomain.tmpl /scripts/templates/subdomain
cp /scripts/install/src/creation_sub.sh.tmpl /scripts/creation_sub.sh

echo "Place subdomain in the script"
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

echo "Placing the certificate files in the nginx template"
sed -i "s/replacewithfullchain/$cert_path/g" /scripts/templates/subdomain
sed -i "s/replacewithprivatekey/$key_path/g" /scripts/templates/subdomain


echo "Configure logrotate"
cp /scripts/install/src/logrotate /etc/logrotate.d/nextcloud
logrotate -f /etc/logrotate.d/nextcloud

