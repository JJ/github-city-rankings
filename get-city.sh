#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo "Default is Granada, but filenames will be all wrong"
    echo "Better use ./get-city-sh <city name>"
fi
coffee check-logins.coffee $@
coffee get-details.coffee $@
coffee format-users.coffee $@
mv raw/github-users-stats-$1.json ../top-github-users-data/data/
mv formatted/active-$1.md ../top-github-users-data/formatted/active-Granada.md 
