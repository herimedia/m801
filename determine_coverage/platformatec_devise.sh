#!/bin/bash --login

# Runs the platformatec/devise test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/plataformatec_devise

rvm use 2.0.0@plataformatec_devise

if ! grep "SimpleCov.start" test/test_helper.rb; then
  sed -i test/test_helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

bundle exec rake test

echo -e "\n==> platformatec/devise Test Coverage:"
cat coverage/.last_run.json

cd ../..