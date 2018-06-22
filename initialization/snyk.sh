LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/snyk/snyk/releases/latest)
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
BINARY_URL="https://github.com/snyk/snyk/releases/download/$LATEST_VERSION/snyk-linux"

"${SNYK_LEVEL:?Need to set SNYK_LEVEL = 'RPRT' in the CircleCI environment variables settings.}"
"${SNYK_ORG:?Need to set SNYK_ORG = 'segment_pro' in the CircleCI environment variables settings.}"
"${SNYK_TOKEN:?Need to set 'context: snyk' in your .circleci/config.yml workflow.}"

curl -sL "$BINARY_URL" -o snyk-linux
chmod +x snyk-linux

if [ "$SNYK_LEVEL" = "RPRT" ]; then
  ./snyk-linux test --org=$SYNK_ORG || true # will always pass, but still send results up to Snyk
fi

./snyk-linux monitor --org=$SNYK_ORG
