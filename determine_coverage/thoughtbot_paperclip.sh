#!/bin/bash --login

# Runs the thoughtbot/paperclip test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/thoughtbot_paperclip

rvm use 2.0.thoughtbot_paperclip

if ! grep "SimpleCov.start" test/helper.rb; then
  sed -i test/helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

bundle exec rake clean test cucumber

echo -e "\n==> thoughtbot/paperclip Test Coverage:"
cat coverage/.last_run.json

cd ../..