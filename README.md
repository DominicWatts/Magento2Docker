# Magento 2 Docker

A collection of Docker images for running Magento 2 through nginx and on the command line.

## Quick Start

`quickstart.sh` covers steps 3 through to 8 with default config

### 1 Install

    composer create-project dominicwatts/docker-magento2 ./
    
Or

    git clone git@github.com:DominicWatts/docker-magento2.git ./

### 2 Add the following entry to OS hosts file

    127.0.0.1 magento2.docker

### 3 Put the correct tokens into composer.env

    cp composer.env.sample composer.env
    
Edit composer.env with correct environment variables    

### 4 Put the correct tokens into auth.json

    cp composer/auth.sample.json composer/auth.json

### 5 Put the correct tokens into newrelic.ini

    cp newrelic/newrelic.sample.ini newrelic/newrelic.ini

### 6 Create magento folder

    mkdir magento
    
### 7 Create cron log file

    touch magento/var/log/cron.log    

### 8 Build

    docker-compose up -d

Or using specific config, for example:

    docker-compose -f docker-compose.src.71.yml up -d

    docker-compose -f docker-compose.src.72.yml run --rm cli

    docker-compose -f docker-compose.src.73.yml run --rm cli magento-command

### 9 Install

#### 9. 1 Install Manually

##### Manually 

###### Hypernode

    wget -qO- https://magento.mirror.hypernode.com/releases/magento2-latest.tar.gz | tar xfz -
    
or

    wget -qO- https://magento.mirror.hypernode.com/releases/magento-2.3.4.tar.gz | tar xfz -

###### Download

Download, unzip and install magento from https://magento.com/tech-resources/download

Magento goes inside `./magento`

Then run command line install or web install

##### CLI

     docker-compose run --rm cli magento-command setup:install --admin-firstname Admin --admin-lastname User --admin-email dominic@xigen.co.uk --admin-user admin --admin-password test123 --base-url http://magento2.docker/ --backend-frontname xpanel --db-host db --db-name magento2 --db-user magento2 --db-password magento2 --language en_GB --currency GBP --timezone UTC --use-rewrites 1 --session-save files
     
##### Web

    http://magento2.docker/setup/

#### 9.2 Install via wrapper

    docker-compose run --rm cli magento-installer
    
This will attempt to install via composer if magento folder is empty (time consuming)

## Useful commands

### Command line (remove once exit)

    docker-compose run --rm cli

### Magento command via wrapper

    docker-compose run --rm cli magento-command

    docker-compose run --rm cli magento-command cache:clean
    
### Install extension via wrapper

    docker-compose run --rm cli magento-extension-installer --package-name=dominicwatts/clearstatic Xigen_ClearStatic
    
### Check instances

    docker ps

    docker-compose ps

### Restart instances

    docker-compose restart

## Optional configuring of mailhog

http://magento2.docker:8025

    composer require mageplaza/module-smtp

### Store > Configuration > Mageplaza > SMTP

  -  host: `mail`
  -  port: `1025`
  -  protocol: `none`
  -  authentication: `plain`
  -  username/password: `[blank]`

## Configuration

Configuration is driven through environment variables.  A comprehensive list of the environment variables used can be found in each `Dockerfile` and the commands in each `bin/` directory.

* `PHP_MEMORY_LIMIT` - The memory limit to be set in the `php.ini`
* `UPLOAD_MAX_FILESIZE` - Upload filesize limit for PHP and Nginx
* `MAGENTO_RUN_MODE` - Valid values, as defined in `Magento\Framework\App\State`: `developer`, `production`, `default`.
* `MAGENTO_ROOT` - The directory to which Magento should be installed (defaults to `/var/www/magento`)
* `COMPOSER_GITHUB_TOKEN` - Your [GitHub OAuth token](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens), should it be needed
* `COMPOSER_MAGENTO_USERNAME` - Your Magento Connect public authentication key ([how to get](http://devdocs.magento.com/guides/v2.0/install-gde/prereq/connect-auth.html))
* `COMPOSER_MAGENTO_PASSWORD` - Your Magento Connect private authentication key
* `COMPOSER_BITBUCKET_KEY` - Optional - Your Bitbucket OAuth key ([how to get](https://confluence.atlassian.com/bitbucket/oauth-on-bitbucket-cloud-238027431.html))
* `COMPOSER_BITBUCKET_SECRET` - Optional - Your Bitbucket OAuth secret
* `DEBUG` - Toggles tracing in the bash commands when exectued; nothing to do with Magento`
* `PHP_ENABLE_XDEBUG` - When set to `true` it will include the Xdebug ini file as part of the PHP configuration, turning it on. It's recommended to only switch this on when you need it as it will slow down the application.
* `UPDATE_UID_GID` - If this is set to "true" then the uid and gid of `www-data` will be modified in the container to match the values on the mounted folders.  This seems to be necessary to work around virtualbox issues on OSX.

A series of sample `docker-compose.yml` files are is the repo

## CLI Usage

A number of commands are baked into the image and are available on the `$PATH`. These are:

* `magento-command` - Provides a user-safe wrapper around the `bin/magento` command.
* `magento-installer` - Installs and configures Magento into the directory defined in the `$MAGENTO_ROOT` environment variable.
* `magento-extension-installer` - Installs a Magento 2 extension from the `/extensions/<name>` directory, using symlinks.
* `magerun2` - A user-safe wrapper for `n98-magerun2.phar`, which provides a wider range of useful commands. [Learn more here](https://github.com/netz98/n98-magerun2)

It's recommended that you mount an external folder to `/root/.composer/cache`, otherwise you'll be waiting all day for Magento to download every time the container is booted.

CLI commands can be triggered by running:

    docker-compose run cli magento-installer

Shell access to a CLI container can be triggered by running:

    docker-compose run cli bash

## Sendmail

All images have sendmail installed for emails, however it is not enabled by default. To enable sendmail, use the following environment variable:

    ENABLE_SENDMAIL=true

*Note:* If sendmail has been enabled, make sure the container has a hostname assigned using the `hostname` field in `docker-compose.yml` or `--hostname` parameter for `docker run`. If the container does not have a hostname set, sendmail will attempt to discover the hostname on startup, blocking for a prolonged period of time.

## Implementation Notes

* In order to achieve a sane environment for executing commands in, a `docker-environment` script is included as the `ENTRYPOINT` in the container.

## xdebug Usage

To enable xdebug, you will need to toggle the `PHP_ENABLE_XDEBUG` environment variable to `true` in `global.env`. Then when using docker-compose you will need to restart the fpm container using `docker-compose up -d`, or stopping and starting the container.

## Creating a docker image

### New Relic image

Assuming your docker hub repository is `domw/magento2-php-newrelic`

    cd php/newrelic/7.1-fpm
    
    docker login

    docker build -t domw/magento2-php-newrelic:7.1-fpm ./

    docker push domw/magento2-php-newrelic:7.1-fpm

### Vanilla Image

Assuming your docker hub repository is `domw/magento2-php`

    cd php/src/7.2-fpm
    
    docker login

    docker build -t domw/magento2-php:7.2-fpm ./

    docker push domw/magento2-php:7.2-fpm

### docker-compose

Then edit `docker-compose.yml` to load your new image

```
fpm:
    hostname: magento2.docker
    image: domw/magento2-php:7.1-fpm
    restart: 'always'
    ports:
      - 9000
    links:
      - db
    volumes_from:
      - appdata
    env_file:
      - ./global.env
```

## Elastic Search

```
  search:
    image: elasticsearch:6.8.6
    environment:
      - cluster.name=docker-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - discovery.type=single-node
    volumes:
      - ./elasticsearchdata:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
      - 9300:9300
```

## Elastic Search Monitor

```
  kibana:
    image: elastic/kibana:6.8.6
    links:
      - search
    environment:
      - SERVER_NAME=search:9200
      - ELASTICSEARCH_HOSTS=http://search:9200    
    ports:
      - 5601:5601
```

To configure Magento to use Elasticsearch:

    Log in to the Magento Admin

    Stores > Settings > Configuration > Catalog > Catalog > Catalog Search.

    From the Search Engine list, select the correct Elasticsearch version 6. 
    
    Elasticsearch Server Hostname: search

    Elasticsearch Server Port: 9200


### Debugging

    http://10.10.1.49:9200/

    http://10.10.1.49:9200/_cluster/health

    http://10.10.1.49:9200/_cat/nodes?v&pretty
    
    http://10.10.1.49:9200/_cat/indices?v&pretty
    
Note: search reindex creates magento2_product_1_vx indices

    - magento2_product_1_v1
    - magento2_product_1_v2
    
etc

## New Relic

### Verify daemon

    ps -ef | grep newrelic-daemon

### status

    /etc/init.d/newrelic-daemon status

### start / stop / restart

    /etc/init.d/newrelic-daemon start

    /etc/init.d/newrelic-daemon stop

    /etc/init.d/newrelic-daemon restart

### Config file

    /newrelic/newrelic.ini => /usr/local/etc/php/conf.d/newrelic.ini

### run install

    newrelic-install install
    
### Configure within Magento

Stores > Configuration > General > New Relic Monitoring

## Deployment

This is experimental method to get docker web root up to date with git remote

cd git

git init --bare

Configure remote

    ssh://user@127.0.0.1:22/path/to/remote/git

push branch to remote

### Confirm post-receive hook details

`/git/hooks/post-receive`

#### Test hook

sudo chmod 777 ./magento -R

    Wide open for local development only

sh git/hooks/post-receive

This triggers deploy_magento.sh with variables set in hook

#### If process gets stuck

rm deploy.lock

## Stack Problems

MySQL cannot connect error prior to magento install

    docker-compose down -v

    rm mysql/data -R 
   
    docker-compose up -d

Wait a few mins whilst db initialise

## Useful Alias's

```
alias cli='docker-compose run --rm cli'
alias magento-command='docker-compose run --rm cli magento-command'
alias dcud='docker-compose up -d'
alias dcdv='docker-compose down -v'
alias dreload='docker-compose down -v; docker-compose pull; docker-compose up -d'
alias installer='docker-compose run --rm cli magento-extension-installer'
```
