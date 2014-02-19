#!/bin/bash --login

# Runs all scripts from ./determine_coverage which in turn
# execute test suites to determine their code coverage.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

BASEDIR=$(dirname $0)

if [ ! -d "./repositories" ]; then
  echo -e "==> ./repositories doesn't exist. Aborting."
  exit 1
fi

find $BASEDIR/determine_coverage -type f -name "*.sh" | sort | while read script; do
  echo -e "\n==> Calling '$script'.\n"

  $script
done

find repositories -type f -regex ".*/coverage/.last_run.json" -exec bash -c 'echo -e "\n==> {}:" && grep covered_percent {} && echo -e "\n"' \;