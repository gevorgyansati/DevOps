#!/bin/bash

apt-get update
apt-get -y install nginx

sudo service enable nginx
sudo echo "V1" >> /var/www/html/index.html
sudo systemctl start nginx.service 