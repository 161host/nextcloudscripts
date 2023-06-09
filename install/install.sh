#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

# This is just another excuse to not write an ansible role cause it is soo much easier for you to setup. (Yes I'll show myself to the door....)

# the whole setup assumes that the user you're using is root. If this isn't the case, well. Search for another script or alter it the way you want. (If it comes out nice, feel free to create a MR)
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
        echo "php8.1 can be installed"
    else
        echo "Error: php8.1 could not be installed"
        exit 1
    fi
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

read -p "Mount Directory (default: /mnt): " mnt_dir
if [ -z "$mnt_dir" ]; then
   mnt_dir="/mnt"
fi

read -p "Data Directory (default: /data): " data_dir
if [ -z "$data_dir" ]; then
    data_dir="/data"
fi

read -p "Webroot Directory (default: /webroot): " webroot_dir
if [ -z "$webroot_dir" ]; then
    webroot_dir="/webroot"
fi

read -p "Secrets Directory (default: /secrets): " secrets_dir
if [ -z "$secrets_dir" ]; then
    secrets_dir="/secrets"
fi

read -p "Nextcloud Log Directory (default: /var/log/nextcloud): " nextcloudlogs_dir
if [ -z "$nextcloudlogs_dir" ]; then
    nextcloudlogs_dir="/var/log/nextcloud"
fi

read -p "Script Data Directory (default: /scripts/data): " scriptsdata_dir
if [ -z "$scriptsdata_dir" ]; then
    scriptsdata_dir="/scripts/data"
fi

echo "Check if directories existing and otherwise create them"
if [ -d $mnt_dir ]; then
  echo "$mnt_dir already exists"
else
  echo "Creating $mnt_dir"
  mkdir $mnt_dir
fi

if [ -d $data_dir ]; then
  echo "$data_dir already exists"
else
  echo "Creating $data_dir"
  mkdir $data_dir
fi

if [ -d $webroot_dir ]; then
  echo "$webroot_dir already exists"
else
  echo "Creating $webroot_dir"
  mkdir $webroot_dir
fi

if [ -d $secrets_dir ]; then
  echo "$secrets_dir already exists"
else
  echo "Creating $secrets_dir"
  mkdir $secrets_dir
fi

if [ -d $nextcloudlogs_dir ]; then
  echo "$nextcloudlogs_dir already exists"
else
  echo "Creating $nextcloudlogs_dir"
  mkdir $nextcloudlogs_dir
fi

if [ -d $scriptsdata_dir ]; then
  echo "$scriptsdata_dir already exists"
else
  echo "Creating $scriptsdata_dir"
  mkdir $scriptsdata_dir
fi

sed -i "s|replacewithmntdir|$mnt_dir|g" /scripts/creation_own.sh
sed -i "s|replacewithmntdir|$mnt_dir|g" /scripts/deletefiles.sh
sed -i "s|replacewithmntdir|$mnt_dir|g" /scripts/reallydelete.sh
sed -i "s|replacewithmntdir|$mnt_dir|g" /scripts/install/src/creation_sub.sh.tmpl

sed -i "s|replacewithdatadir|$data_dir|g" /scripts/creation_own.sh
sed -i "s|replacewithdatadir|$data_dir|g" /scripts/deletefiles.sh
sed -i "s|replacewithdatadir|$data_dir|g" /scripts/reallydelete.sh
sed -i "s|replacewithdatadir|$data_dir|g" /scripts/install/src/creation_sub.sh.tmpl
sed -i "s|replacewithdatadir|$data_dir|g" /scripts/resizenc.sh


sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/creation_own.sh
sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/install/src/creation_sub.sh.tmpl
sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/deletefiles.sh
sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/install/src/subdomain.tmpl
sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/templates/owndomain
sed -i "s|replacewithwebrootdir|$webroot_dir|g" /scripts/reallydelete.sh

sed -i "s|replacewithsecretsdir|$secrets_dir|g" /scripts/creation_own.sh
sed -i "s|replacewithsecretsdir|$secrets_dir|g" /scripts/reallydelete.sh
sed -i "s|replacewithsecretsdir|$secrets_dir|g" /scripts/install/src/creation_sub.sh.tmpl

sed -i "s|replacewithnextcloudlogsdir|$nextcloudlogs_dir|g" /scripts/deletelogs.sh
sed -i "s|replacewithnextcloudlogsdir|$nextcloudlogs_dir|g" /scripts/reallydelete.sh
sed -i "s|replacewithnextcloudlogsdir|$nextcloudlogs_dir|g" /scripts/install/src/logrotate
sed -i "s|replacewithnextcloudlogsdir|$nextcloudlogs_dir|g" /scripts/install/src/subdomain.tmpl
sed -i "s|replacewithnextcloudlogsdir|$nextcloudlogs_dir|g" /scripts/templates/owndomain


sed -i "s|replacewithscriptsdatadir|$scriptsdata_dir|g" /scripts/creation_own.sh
sed -i "s|replacewithscriptsdatadir|$scriptsdata_dir|g" /scripts/deletedb.sh
sed -i "s|replacewithscriptsdatadir|$scriptsdata_dir|g" /scripts/reallydelete.sh
sed -i "s|replacewithscriptsdatadir|$scriptsdata_dir|g" /scripts/install/src/creation_sub.sh.tmpl



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
sed -i "s|replacewithfullchain|$cert_path|g" /scripts/templates/subdomain
sed -i "s|replacewithprivatekey|$key_path|g" /scripts/templates/subdomain


echo "Configure logrotate"
cp /scripts/install/src/logrotate /etc/logrotate.d/nextcloud
logrotate -f /etc/logrotate.d/nextcloud
