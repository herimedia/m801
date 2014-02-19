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

  echo -e "\n==> Initializing '$repo'.\n"

  cd $repo

  # Handle some special cases
  case "$repo" in
    publify_publify)
      cp config/database.yml.sqlite config/database.yml
    ;;
  esac

  # Add simplecov gem to requirements if not already present
  if ! egrep "gem\W+simplecov" Gemfile; then
    echo "gem 'simplecov', :require => false" >> Gemfile
  fi

  # Initialize and use a rvm gemset specific to this repository
  # (to ensure we can run tests in true isolation).
  rvm gemset create $repo
  rvm use 2.0.0@$repo

  # Make sure we have an up-to-date bundler
  gem install bundler

  # Install gem dependencies.
  bundle

  # Handle some special cases
  case "$repo" in
    gitlabhq_gitlabhg)
      # Required to run the tests
      if ! egrep "gem\W+phantomjs-binaries" Gemfile; then
	echo "gem 'phantomjs-binaries', :require => false" >> Gemfile
      fi

      # The version loaded by default (0.2.X) has a bug
      # preventing the phantomjs version from being read
      # correctly.
      # @see https://github.com/yaauie/cliver/issues/10
      if ! egrep "gem\W+cliver" Gemfile; then
	echo "gem 'cliver', '>= 0.3', :require => false" >> Gemfile
      fi

      # The originally required version is incompatible
      # with cliver 0.3.
      sed "s/gem 'poltergeist'.*/gem 'poltergeist', '>= 1.5'/" -i Gemfile
    ;;
  esac

  cd ..
done

cd ..