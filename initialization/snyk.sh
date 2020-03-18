#!/bin/bash

[ -z "$SNYK_TOKEN" ] && { echo "Set 'context: snyk' in your .circleci/config.yml workflow"; exit 1; }

LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/snyk/snyk/releases/latest)
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
BINARY_URL="https://github.com/snyk/snyk/releases/download/$LATEST_VERSION/snyk-linux"
NEVER_FAIL=false

curl -sL "$BINARY_URL" -o snyk
[ ! -f snyk ] && { echo "Snyk failed to download!"; exit 0; }
chmod +x snyk

org="${SNYK_ORG:-segment-pro}"
severity_threshold="${SNYK_SEVERITY_THRESHOLD:-low}" # by default show all vulns
fail_on="${SNYK_FAIL_ON:-never}" # by default never fail (backwards compatibility)

# "never" is not a valid input, but we make it a valid input to this script, so we
# need to swap it out so that the CLI doesn't complain about "never" not being a thing
if [ "${fail_on}" = "never" ]; then
  fail_on=all
  NEVER_FAIL="true"
fi

# prevent the script from ever exiting non-zero
if [ "${NEVER_FAIL}" = "true" ]; then
  set +e;
fi

# suppresses errors w/ snyk monitor (which shouldn't have any)
./snyk monitor --org="${org}" || true

echo "Running Snyk tests"
./snyk test --severity-threshold="${severity_threshold}" --fail-on="${fail_on}" --org="${org}"

# prevent the script from ever exiting non-zero
if [ "${NEVER_FAIL}" = "true" ]; then
  exit 0;
fi
