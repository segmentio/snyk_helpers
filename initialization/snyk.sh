#!/bin/bash

[ -z "$SNYK_TOKEN" ] && { echo "Set 'context: snyk' in your .circleci/config.yml workflow"; exit 1; }

LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/snyk/snyk/releases/latest)
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
BINARY_URL="https://github.com/snyk/snyk/releases/download/$LATEST_VERSION/snyk-linux"

curl -sL "$BINARY_URL" -o snyk
[ ! -f snyk ] && { echo "Snyk failed to download!"; exit 0; }
chmod +x snyk

severity_threshold="${severity_threshold:-low}" # by default show all vulns
fail_on="${fail_on:-never}" # by default never fail (backwards compatibility)
debug="${debug:-false}" # debug output is messy

if [[ "${fail_on}" = "never" ]]; then
  fail_on=all
  NEVER_FAIL=true 
fi

flags=(
  "--severity-threshold=$severity_threshold"
  "--fail-on=$fail_on"
  "--org=$org"
)

monitor_flags=(
  "--org=$org"
)

if [[ $debug =~ (true|on|1) ]] ; then
  flags+=( "-d" )
  monitor_flags+=( "-d" )
fi

# suppresses errors w/ snyk monitor (which shouldn't have any)
./snyk monitor ${monitor_flags[@]} || true

echo "~~~ Running Snyk tests"
./snyk test ${flags[@]}

if [[ "${NEVER_FAIL}" = true ]]; then
  exit 0;
fi
