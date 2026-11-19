#!/bin/bash

#
# Test Helm charts
# Usage:
# run-test.sh /path/to/chart-dir /path/to/values-dir
# Values in /path/to/values-dir/fail/*.yml must fail to render.
# Lines "# expect: <text>" in a values file must appear in its rendered output.
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
    rendered=$(helm template $chart -f $values 2>&1)
    if [ $? -eq 0 ]; then
        echo "  PASS: Template values $values"
    else
        echo "  FAILED: Template values $values"
        failed=$((failed + 1))
        continue
    fi

    # Assertions: lines "# expect: <text>" must appear in the rendered output.
    while IFS= read -r expected; do
        if printf '%s\n' "$rendered" | grep -qF -- "$expected"; then
            echo "  PASS: Expect '$expected' in $values"
        else
            echo "  FAILED: Expect '$expected' in $values"
            failed=$((failed + 1))
        fi
    done < <(sed -n 's/^# expect: //p' $values)
done

# Values in <values-dir>/fail/ MUST fail to render (input validation).
for values in $(ls $2/fail/*.yml 2>/dev/null)
do
    helm template $chart -f $values 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "  PASS: Expected failure $values"
    else
        echo "  FAILED: Expected failure but rendered $values"
        failed=$((failed + 1))
    fi
done

exit ${failed}