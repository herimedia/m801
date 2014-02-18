#!/bin/bash --login

# Creates gemsets for all repositories in ./repositories and
# installs their dependencies using bundler.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

if [ ! -d "./repositories" ]; then
  echo -e "==> ./repositories doesn't exist. Aborting."
  exit 1
fi

cd ./repositories

find . -maxdepth 1 -mindepth 1 -type d | sort | while read repo; do
  IFS='/' read -ra repo <<< "$repo"
  repo=${repo[@]:(-1)}

  echo -e "\n==> Initializing '$repo'?\n"

  cd $repo

  # Handle some special cases
  case "$repo" in
    publify_publify)
      cp config/database.yml.sqlite config/database.yml
    ;;
  esac

  # Add simplecov gem to requirements if not already present
  grep "gem\W+simplecov" Gemfile
  if [ ! $? ]; then
    echo "gem 'simplecov', :require => false" >> Gemfile
  fi

  # Initialize and use a rvm gemset specific to this repository
  # (to ensure we can run tests in true isolation).
  rvm gemset create $repo
  rvm use 2.0.0@$repo

  # Install gem dependencies.
  bundle

  cd ..
done

cd ..