#!/bin/bash --login

# Runs the mitchellh/vagrant test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/mitchellh_vagrant

rvm use 2.0.0@mitchellh_vagrant

if ! grep "SimpleCov.start" test/unit/base.rb; then
  sed -i test/unit/base.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

# Acceptance tests are not run as they take hours to complete.
# @see https://github.com/mitchellh/vagrant#acceptance-tests
bundle exec rake test:unit

echo -e "\n==> mitchellh/vagrant Test Coverage:"
cat coverage/.last_run.json

cd ../..