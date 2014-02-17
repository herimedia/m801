#!/bin/bash

# Prompts for GM_DIR, GH_TOKEN, GH_EMAIL, GH_RATELIMIT, REPOS,
# and GM_MEMORY settings. All can be provided as environment
# variables instead. Values given in [] will be used as defaults,
# if nothing is entered in the prompt.
#
# Then writes the gitminer configuration to
# $GM_DIR/m801-config.properties and runs both
# $GM_DIR/gitminer.sh as well as $GM_DIR/repository_loader.sh
# with the provided settings.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

WORKDIR=`pwd`

if [ -z "$GM_DIR" ]; then
  echo -e "==> Where is your gitminer checkout located? [../gitminer]"
  read GM_DIR
  if [ -z "$GM_DIR" ]; then
    GM_DIR="../gitminer"
  fi
fi
echo -e "==> Using '$GM_DIR' as the gitminer checkout location.\n"

if [ -z "$GH_TOKEN" ]; then
  until [ -n "$GH_TOKEN" ]; do
    echo -e "==> What is your github.com auth token?"
    read GH_TOKEN
  done
fi
echo -e "==> Setting '$GH_TOKEN' as your github.com auth token.\n"

if [ -z "$GH_EMAIL" ]; then
  until [ -n "$GH_EMAIL" ]; do
    echo -e "==> What is your github.com email address?"
    read GH_EMAIL
  done
fi
echo -e "==> Setting '$GH_EMAIL' as your github.com email address.\n"

if [ -z "$GH_RATELIMIT" ]; then
  echo -e "==> What is your hourly github.com API rate limit (see http://developer.github.com/v3/#rate-limiting)? [12000]"
  read GH_RATELIMIT
  if [ -z "$GH_RATELIMIT" ]; then
    GH_RATELIMIT="12000"
  fi
fi
echo -e "==> Setting '$GH_RATELIMIT' as your hourly github.com API rate limit.\n"

if [ -z "$REPOS" ]; then
  echo -e "==> What repositories are you interested in (user/repo; comma-separated)? [diaspora/diaspora,discourse/discourse,gitlabhq/gitlabhq,jekyll/jekyll,mitchellh/vagrant,plataformatec/devise,publify/publify,rails/rails,thoughtbot/paperclip]"
  read REPOS
  if [ -z "$REPOS" ]; then
    REPOS="diaspora/diaspora,discourse/discourse,gitlabhq/gitlabhq,jekyll/jekyll,mitchellh/vagrant,plataformatec/devise,publify/publify,rails/rails,thoughtbot/paperclip"
  fi
fi
echo -e "==> Pulling '$REPOS' repositories.\n"

if [ -z "$GM_MEMORY" ]; then
  echo -e "==> How many GB of memory can you dedicate to this task? [15]"
  read GM_MEMORY
  if [ -z "$GM_MEMORY" ]; then
    GM_MEMORY="15"
  fi
fi
echo -e "==> Using up to '$GM_MEMORY'GB memory.\n"

echo -e "==> Writing config to $GM_DIR/m801-config.properties\n"
(
cat <<EOS
net.wagstrom.research.github.token=$GH_TOKEN
net.wagstrom.research.github.email=$GH_EMAIL

net.wagstrom.research.github.dbengine=neo4j
net.wagstrom.research.github.dburl=m801.db

net.wagstrom.research.github.projects=$REPOS

net.wagstrom.research.github.miner.repositories.collaborators=false
net.wagstrom.research.github.miner.repositories.contributor=false
net.wagstrom.research.github.miner.repositories.watchers=false
net.wagstrom.research.github.miner.repositories.users=false
net.wagstrom.research.github.miner.users.events=false
net.wagstrom.research.github.miner.users.gists=false

net.wagstrom.research.github.apiThrottle.maxCalls.v3=$GH_RATELIMIT
net.wagstrom.research.github.refreshTime=30

edu.unl.cse.git.dbengine=neo4j
edu.unl.cse.git.dburl=m801.db
edu.unl.cse.git.repositories=$REPOS
edu.unl.cse.git.repositories.removeAfterLoad=false
EOS
) > $GM_DIR/m801-config.properties

cd $GM_DIR

echo -e "==> Running gitminer (might take days!)…"
echo -e "==> (See $WORKDIR/gitminer.log for non-error output.)"
echo -e "\n\n==> $GM_DIR/gitminer.sh run started @ `date`\n" >> $WORKDIR/gitminer.log
JAVA_OPTIONS="-Xms${GM_MEMORY}g -Xmx${GM_MEMORY}g" ./gitminer.sh -c m801-config.properties >> $WORKDIR/gitminer.log

if [ $? ]; then
  echo -e "\n==> Running repository loader (might take hours!)…"
  echo -e "==> (See $WORKDIR/gitminer.log for non-error output.)"
  echo -e "\n\n==> $GM_DIR/repository_loader.sh run started @ `date`\n" >> $WORKDIR/gitminer.log
  JAVA_OPTIONS="-Xms${GM_MEMORY}g -Xmx${GM_MEMORY}g" ./repository_loader.sh -c m801-config.properties >> $WORKDIR/gitminer.log

  if [ $? ]; then
    echo -e "\n==> Done!"
    cd $WORKDIR
    exit 0
  else
    echo -e "\n==> $GM_DIR/repository_loader.sh failed with exit status $?. Aborting!"
    cd $WORKDIR
    exit 1
  fi
  fi
else
  echo -e "\n==> $GM_DIR/gitminer.sh failed with exit status $?. Aborting!"
  cd $WORKDIR
  exit 1
fi