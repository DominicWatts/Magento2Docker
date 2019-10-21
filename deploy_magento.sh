#!/usr/bin/bash

echo "Deployment Start"

if [ -f deploy.lock ]; then 
   echo "Lock file found.... exiting" 
   exit 99; 
fi 

echo "Adding lock"
touch deploy.lock

cd $checkout

echo "Checking out the latest files from git"
git --work-tree=$checkout --git-dir=$git checkout -f $branch
git --work-tree=$checkout --git-dir=$git reset --hard
find $checkout/ -type f -name '.gitignore' -exec rm -rf {} \;

echo "Fetch DB connection details plus extras"
cp -Rvf $targetDir/app/etc/ $checkout/app/

echo "Remove generated"
rm -rf $checkout/generated/*

echo "Composer"
composer install --prefer-dist -o

echo "Setting permissons" 
chmod -Rvf 777 $checkout &> /dev/null

echo "Rync checkout folder to magento folder" 
rsync --exclude 'node_modules/' --exclude '.git/' --exclude 'wp/' --exclude 'var/' --exclude 'pub/media/' --exclude 'CHANGELOG.md' --exclude 'README.md' --exclude 'robots.txt' --exclude 'sitemap.xml' -azvP $checkout/ $targetDir/

cd ../

echo "Dump composer"
composer dump-autoload

echo "Running upgrade and di compile"
$magento cache:flush
$magento setup:upgrade
$magento setup:di:compile
$magento cache:flush

echo "Building themes" 
$magento setup:static-content:deploy --quiet -f en_GB -j 8 > /dev/null 2>&1 
$magento setup:static-content:deploy --quiet -f en_US -j 8 > /dev/null 2>&1

echo "Removing lock"
rm -rf deploy.lock 

echo "Deployment Finish"

exit 0 