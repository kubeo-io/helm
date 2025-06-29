# Collection of Kubeo Helm Charts

## List of Helm Charts

| Template name | Description | Values.yaml tips |
|---|---|---|
| ioops-template | Main template | [Configure](Configure.md) |
| ioops-job | Job-only template | |

## Test templates

```bash
./helm-chart-tests.sh chart test/values
```

## Helm Tips

1) Installing Helm:

[Check the latest instructions to install Helm](https://helm.sh/docs/intro/install/)

1) Testing a template:

```bash
cd chart
helm lint chart-name
```

The output should contain:

```bash
1 chart(s) linted, 0 chart(s) failed
```

1) Customizing and deploying:

TIP: --app-version refers to the container image version in the container registry. --version refers to this Chart version, and they may not be the same.

```bash
helm package --app-version=1.0.0 --version=1.0.0 . -d /tmp
helm upgrade -i --wait release-name /tmp/chart-name-1.0.0.tgz \
    --set nameOverride=other-release-name
```

You can also pass your custom values.yaml file:

```bash
helm package --app-version=1.0.0 --version=1.0.0 . -d /tmp
helm upgrade -i --wait release-name /tmp/chart-name-1.0.0.tgz -f /path/to/values.yaml
```

1) Verifying deployment:

```bash
helm list
```