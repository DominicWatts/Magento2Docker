#!/usr/bin/bash

echo "Quickstart Start"

cp composer.env.sample composer.env

cp composer/auth.sample.json composer/auth.json

cp newrelic/newrelic.sample.ini newrelic/newrelic.ini

echo "Token files are in place"

mkdir magento

mkdir magento/var

mkdir magento/var/log

touch magento/var/log/cron.log

echo "Folders are in place"

echo "Remember to edit tokens"

echo "Starting docker"

docker-compose pull

docker-compose up -d

echo "MySQL will be unable to connect whilst it initializes structure"

echo "Quickstart Finish"