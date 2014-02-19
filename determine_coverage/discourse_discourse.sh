#!/bin/bash --login

# Runs the discourse/discourse test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/discourse_discourse

rvm use 2.0.0@discourse_discourse

echo -e "test:\n  adapter: postgresql\n  username: postgres\n  database: m801_discourse" > config/database.yml

if ! grep "SimpleCov.start" spec/spec_helper.rb; then
  sed -i spec/spec_helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

# qunit tests are not taken into account by simplecov, thus
# don't need to run.
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test DISCOURSE_HOSTNAME=www.example.com bundle exec rake db:migrate
RAILS_ENV=test DISCOURSE_HOSTNAME=www.example.com COVERAGE=yes bundle exec rspec

echo -e "\n==> discourse/discourse Test Coverage:"
cat coverage/.last_run.json

cd ../..