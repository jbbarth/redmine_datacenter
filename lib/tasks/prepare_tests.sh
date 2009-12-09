#!/bin/sh
cd ..
rake db:migrate RAILS_ENV=test
rake db:migrate_plugins RAILS_ENV=test
rake db:fixtures:load RAILS_ENV=test
rake db:fixtures:plugins:load RAILS_ENV=test PLUGIN=redmine_datacenter
rake test:plugins:setup_plugin_fixtures NAME=redmine_datacenter
