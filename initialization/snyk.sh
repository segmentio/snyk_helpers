LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/snyk/snyk/releases/latest)
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
BINARY_URL="https://github.com/snyk/snyk/releases/download/$LATEST_VERSION/snyk-linux"

# [ -z "$SNYK_LEVEL" ] && { echo "Set SNYK_LEVEL = 'RPRT' in the CircleCI environment variables settings"; exit 1; }                                                           
[ -z "$SNYK_TOKEN" ] && { echo "Set 'context: snyk' in your .circleci/config.yml workflow"; exit 1; }
[ -z "$SNYK_ORG" ] && { echo "missing SNYK_ORG env var"; exit 1; }

curl -sL "$BINARY_URL" -o snyk-linux

[ ! -f snyk-linux ] && { echo "Snyk failed to download!"; exit 0; }

chmod +x snyk-linux

./snyk-linux test || true # will always pass, but still send results up to Snyk                                                                                                
./snyk-linux monitor || true # suppresses errors w/ snyk monitor (which shouldn't have any)                                                                                    

if [ "$SNYK_LEVEL" = "FLHI" ]; then
    ./snyk-linux test --severity-threshold=high -q
fi
