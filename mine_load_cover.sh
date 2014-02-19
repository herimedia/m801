#!/bin/bash --login

# Runs gitmine.sh, repoload.sh, repoinit.sh, and finally
# determine_coverage.sh in order. Thus loads the gitminer data,
# clones the repositories, installs their dependencies, and
# runs their test suites.
#
# Copyright (c) 2014 Niels Ganser, herimedia e.K., Köln.
# (https://herimedia.com)
#
# Under MIT License; see ./LICENSE.

BASEDIR=$(dirname $0)

echo -e "==> Running gitmine.sh"
echo -e "    (this may take days)"
$BASEDIR/gitmine.sh

echo -e "==> Running repoload.sh"
$BASEDIR/repoload.sh

echo -e "==> Running repoinit.sh"
echo -e "    (this may take an hour or so)"
$BASEDIR/repoinit.sh

echo -e "==> Running determine_coverage.sh"
echo -e "    (this may take hours)"
$BASEDIR/determine_coverage.sh