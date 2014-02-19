#!/bin/bash --login

# Runs the diaspora/diaspora test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/diaspora_diaspora

rvm use 2.0.0@diaspora_diaspora

if [ ! -f config/database.yml ]; then
  cp config/database.yml.example config/database.yml
fi

if [ ! -f config/diaspora.yml ]; then
  cp config/diaspora.yml.example config/diaspora.yml
fi

if ! grep "SimpleCov.start" spec/spec_helper.rb; then
  sed -i spec/spec_helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

# Cucumber and jasmine tasks can not be run headless (at least
# not out of the box).
RAILS_ENV=test COVERAGE=yes bundle exec rake ci:travis:other

echo -e "\n==> diaspora/diaspora Test Coverage:"
cat coverage/.last_run.json

cd ../..