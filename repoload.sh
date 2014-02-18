#!/bin/bash

# Loads the given github.com repositories into ./repositories
# (cloning if local copies don't yet exist, pulling the latest
#  changes if they do).
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

if [ -a "./repositories" ]; then
  echo -e "==> ./repositories already exists. Overwrite? [no]"
  read OVERWRITE_DIR
else
  OVERWRITE_DIR=yes
fi

if [[ $OVERWRITE_DIR =~ $(echo "(true|yes|1|on)") ]]; then
  rm -rf ./repositories
  mkdir ./repositories
fi

if [ -z "$REPOS" ]; then
  echo -e "==> What repositories are you interested in (user/repo; comma-separated)? [diaspora/diaspora,discourse/discourse,gitlabhq/gitlabhq,jekyll/jekyll,mitchellh/vagrant,plataformatec/devise,publify/publify,rails/rails,thoughtbot/paperclip]"
  read REPOS
  if [ -z "$REPOS" ]; then
    REPOS="diaspora/diaspora,discourse/discourse,gitlabhq/gitlabhq,jekyll/jekyll,mitchellh/vagrant,plataformatec/devise,publify/publify,rails/rails,thoughtbot/paperclip"
  fi
fi
echo -e "==> Cloning '$REPOS' repositories.\n"

cd ./repositories

IFS=',' read -ra REPOS_ARY <<< "$REPOS"

for repo in "${REPOS_ARY[@]}"; do
  flattened_name=`echo "$repo" | sed "s/\//_/g"`

  if [ -d "./$flattened_name" ]; then
    echo -e "\n==> Updating '$repo' in './repositories/$flattened_name'.\n"
    cd "./$flattened_name"
    git pull
    cd ..
  else
    echo -e "\n==> Cloning '$repo' into './repositories/$flattened_name'.\n"
    git clone "https://github.com/$repo.git" "$flattened_name"
  fi
done