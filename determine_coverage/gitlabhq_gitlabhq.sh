#!/bin/bash --login

# Runs the gitlabhq/gitlabhq test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/gitlabhq_gitlabhq

rvm use 2.0.0@gitlabhq_gitlabhq

if [ ! -f config/database.yml ]; then
  cp config/database.yml.mysql config/database.yml
fi

if [ ! -f config/gitlab.yml ]; then
  cp config/gitlab.yml.example config/gitlab.yml
fi

if ! grep "SimpleCov.start" spec/spec_helper.rb; then
  sed -i spec/spec_helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

if ! grep "SimpleCov.start" features/support/env.rb; then
  sed -i features/support/env.rb -e "1irequire 'simplecov'\nSimpleCov.start\nSimpleCov.command_name 'features'\n"
fi

# There is also a jasmine:ci task testing the JS but JS coverage
# is not taken into account by simplecov and the tests are thus
# not run here.
RAILS_ENV=test bundle exec rake db:setup
RAILS_ENV=test bundle exec rake db:seed_fu
RAILS_ENV=test bundle exec rake spinach
RAILS_ENV=test bundle exec rake spec

echo -e "\n==> gitlabhq/gitlabhq Test Coverage:"
cat coverage/.last_run.json

cd ../..