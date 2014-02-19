#!/bin/bash --login

# Runs the rails/rails test suite.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

cd repositories/rails_rails

rvm use 2.0.0@rails_rails

# This repository bundles 7 independently released gems. We test
# 6 of them independently but do not test activerecord at all due
# to its complexity w.r.t. DBMS dependencies (we'd have to install
# about a dozen of different DBMS and test against each one to
# fully test the entire gem).
find -regex ".*/\(test/abstract_unit\|test/config\).rb" -type f -exec sed -i {} -e "1irequire 'simplecov'\nSimpleCov.start\n" \;

cd actionmailer
bundle exec rake test
echo -e "\n==> rails/rails actionmailer Test Coverage:"
cat coverage/.last_run.json
cd ..

cd actionpack
bundle exec rake test
echo -e "\n==> rails/rails actionpack Test Coverage:"
cat coverage/.last_run.json
cd ..

cd actionview
git checkout test/abstract_unit.rb
echo "require 'abstract_unit'" > test/action_pack_unit.rb
find . -regex "./test/.*_unit.rb" -type f -exec sed -i {} -e "1iunless defined?(SimpleCov)\n  require 'simplecov'\n  SimpleCov.start\n  SimpleCov.command_name '{}'\nend\n" \;
find test/actionpack -name "*_test.rb" -exec sed -i "s/abstract_unit/action_pack_unit/" {} \;
bundle exec rake test
echo -e "\n==> rails/rails actionview Test Coverage:"
cat coverage/.last_run.json
cd ..

cd activemodel
bundle exec rake test
echo -e "\n==> rails/rails activemodel Test Coverage:"
cat coverage/.last_run.json
cd ..

cd activesupport
bundle exec rake test
echo -e "\n==> rails/rails activesupport Test Coverage:"
cat coverage/.last_run.json
cd ..

cd ../..