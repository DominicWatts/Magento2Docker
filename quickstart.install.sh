#!/usr/bin/bash

echo "Quickstart Start"

if [ ! -f composer.env ]; then 
   echo "Missing composer tokens"
   echo "  cp composer.env.sample composer.env" 
   echo "and then edit credentials"
   exit 99; 
fi 

cp composer/auth.sample.json composer/auth.json

cp newrelic/newrelic.sample.ini newrelic/newrelic.ini

echo "Token files are in place"

echo "Fetching files"

curl -LJO https://github.com/DominicWatts/magento2-mirror/archive/2.3.3.tar.gz

echo "Unzipping files"

tar -zxvf magento2-mirror-2.3.3.tar.gz magento2-mirror-2.3.3

mkdir magento

mv magento2-mirror-2.3.3/* magento

rm magento2-mirror-2.3.3 -rf

rm magento2-mirror-2.3.3.tar.gz

mkdir magento/var

mkdir magento/var/log

touch magento/var/log/cron.log

echo "Installing"

docker-compose pull

docker-compose run --rm cli magento-installer

echo "Starting docker"

docker-compose up -d

echo "Quickstart Finish"