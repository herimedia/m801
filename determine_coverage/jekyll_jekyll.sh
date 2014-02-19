#!/bin/bash --login

# Runs the jekyll/jekyll test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/jekyll_jekyll

rvm use 2.0.0@jekyll_jekyll

if ! grep "SimpleCov.start" test/helper.rb; then
  sed -i test/helper.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

if ! grep "SimpleCov.start" features/support/env.rb; then
  sed -i features/support/env.rb -e "1irequire 'simplecov'\nSimpleCov.start\n"
fi

bundle exec rake test
bundle exec rake features

echo -e "\n==> jekyll/jekyll Test Coverage:"
cat coverage/.last_run.json

cd ../..