# Snyk CircleCI Plugin

## Usage

For some languages, such as Go, Snyk requires the installed dependencies folder. As a result we recommend running Snyk at the same time as your other tests. Snyk can be run in parallel as to not increase your build times.

```
- run:
    name: Snyk
    command: curl -sL https://raw.githubusercontent.com/segmentio/snyk_helpers/master/initialization/snyk.sh | sh
    environment:
      SNYK_FAIL_ON: upgradable
      SNYK_SEVERITY_THRESHOLD: high
```

## Help! Snyk failed my build

If Snyk is failing your build that means it has identified a vulnerability that needs to be remediated based on the options specified by your repository's CircleCI pipeline file.
The recommended course of action is to update the affected dependencies. If this isn't possible, continue reading for more options.

### 🚨 Emergency 🚨

If you’re dealing with a SEV and just want Snyk to go away you can always comment out that section of the Buildkite pipeline file.
Just make sure you re-enable it after the service is in a stable state 🙂

### 🚢 Normal Operations 🚢

By default Snyk will not fail any builds. It will only fail builds that have a `SNYK_FAIL_ON` and/or `SNYK_SEVERITY_THRESHOLD` set in the environment variables.

We recommend all repositories start with `SNYK_FAIL_ON: upgradable` and `SNYK_SEVERITY_THRESHOLD: high`, which will fail your build any time there is at least one `Upgradable && High` vulnerability. Security critical repositories are encouraged to set the severity threshold to `medium`.

Before deviating from this guidance please consider the downsides of shipping a product with known
high vulnerabilities to our customers, especially one that can be fixed by upgrading a dependency.

If you have set these options and have decided not to upgrade the vulnerable package, continue reading 😢

### Option 1 (Node only)

1. `npm install -g snyk`
2. Run `snyk wizard` from within your project ([full docs](https://support.snyk.io/hc/en-us/articles/360003851357))
3. Snyk wizard can be used to ignore findings for 30 days
4. This will generate a `.snyk` file which will need to get committed to your repository

### Option 2

In the Snyk plugin options, set `fail-on: never`. This will still report vulnerabilities
to the Snyk SaaS app, but will not fail your builds. Please use this temporarily.

If you have any problems with Snyk, please pop into the #team-appsec Slack channel!

## Options

### `token`

The Snyk API token to use. Defaults to the `$SNYK_TOKEN` environment variable.

### `org`

The Snyk organization slug to use. Defaults to the `$SNYK_ORG` environment variable.

### `severity-threshold`

Only report vulnerabilities of provided level or higher. Matches the behavior of the CLI flag of the same name.
Should be one of `low`, `medium`, `high`.

### `fail-on`

Only fail when there are vulnerabilities that can be fixed. Matches the behavior of the CLI flag of the same name.
Should be one of `all`, `upgradable`, `patchable`, `never`. From the docs:

> Only fail when there are vulnerabilities that can be fixed.
> All fails when there is at least one vulnerability that can be either upgraded or patched.
> Upgradable fails when there is at least one vulnerability that can be upgraded.
> Patchable fails when there is at least one vulnerability that can be patched.
> If vulnerabilities do not have a fix and this option is being used tests will pass.

We added here the `never` option which prevents the plugin from ever returning non-zero.
In this case, the plugin will only report the output of the scan but never fail the step.
