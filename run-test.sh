#!/bin/bash

#
# Test Helm charts
# Usage:
# helm-chart-tests.sh /path/to/chart-dir /path/to/values-dir
#

failed=0
chart=$1

echo "CHART: ${chart}"

helm lint $chart 1>/dev/null
if [ $? -eq 0 ]; then
    echo "  PASS: Lint"
else
    echo "  FAILED: Lint"
    failed=$((failed + 1))
fi

helm template $chart 1>/dev/null
if [ $? -eq 0 ]; then
    echo "  PASS: Template default values"
else
    echo "  FAILED: Template default values"
    failed=$((failed + 1))
fi

for values in $(ls $2/*.yml)
do
    helm template $chart -f $values 1>/dev/null
    if [ $? -eq 0 ]; then
        echo "  PASS: Template values $values"
    else
        echo "  FAILED: Template values $values"
        failed=$((failed + 1))
    fi
done

exit ${failed}