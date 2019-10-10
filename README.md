# Magento 2 Docker

A collection of Docker images for running Magento 2 through nginx and on the command line.

## Quick Start

### Add the following entry to OS hosts file

    127.0.0.1 magento2.docker

### Put the correct tokens into composer.env

    cp composer.env.sample composer.env

### Put the correct tokens into auth.json

    cp composer/auth.sample.json composer/auth.json

### Put the correct tokens into newrelic.ini

    cp newrelic/newrelic.sample.ini newrelic/newrelic.ini

### Create magento folder

    mkdir magento

### Build

    docker-compose up -d

### Install

#### Manually

Download, unzip and install magento from https://magento.com/tech-resources/download

#### Install via wrapper

    docker-compose run --rm li magento-installer

### Create cron log file

    touch magento/var/log/cron.log

### Command line (remove once exit)

    docker-compose run --rm cli

### Magento command via wrapper

    docker-compose run --rm cli magento-command cache:clean
    
### Install extension via wrapper

    docker-compose run --rm cli magento-extension-installer --package-name=dominicwatts/clearstatic Xigen_ClearStatic
    
### Check instances

    docker-compose ps

### Restart instances

    docker-compose restart

### Optional configuring of mailhog

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

A sample `docker-compose.yml` is provided in this repository.

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

Assuming your docker hub repository is `domw/magento2-php`

```

cd php/newrelic/7.1-fpm

docker login

docker build -t domw/magento2-php:7.1-fpm ./

docker push domw/magento2-php:7.1-fpm

```

Then edit `docker-compose.yml` to load your new image

```
fpm:
    hostname: fpm.magento2.docker
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
