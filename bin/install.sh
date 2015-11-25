#!/bin/sh

set -e

### install gem files.

bundle install --path vendor/bundle

### create secret.yml and application_settings.yml from template file

bundle exec rake nomnichi:install

### migrate DB

bundle exec rake db:migrate
bundle exec rake db:migrate RAILS_ENV=production
