#!/bin/bash --login

# Runs the publify/publify test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/publify_publify

rvm use 2.0.0@publify_publify

if [ ! -f config/database.yml ]; then
  cp config/database.yml.mysql config/database.yml
fi

if ! grep "SimpleCov.start" spec/spec_helper.rb; then
  sed -i spec/spec_helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

# There is also a jasmine:ci task testing the JS but JS coverage
# is not taken into account by simplecov and the tests are thus
# not run here.
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=test bundle exec rake

echo -e "\n==> publify/publify Test Coverage:"
cat coverage/.last_run.json

cd ../..