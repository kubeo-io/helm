#! /bin/sh

echo "Deploy Helm Chart"

NAMESPACE="$1"
RELEASE_NAME="$2"
CHART_NAME="$3"
ENVIRONMENT="$4"
VALUES_FILENAME="$5"
IMAGE_REPOSITORY="$6"
IMAGE_TAG="$7"

echo "Namespace is: ${NAMESPACE}"
echo "Running pods:"
kubectl get pod -n ${NAMESPACE}
echo ""

echo "Installed releases:"
helm ls -n ${NAMESPACE}
echo ""

echo "Packaging chart..."
if [ -z "${CHART_NAME}" ]; then
    echo "Chart name is not provided. Exiting."
    exit 1
fi 
CHAT_PACKAGE_NAME=$(helm show chart helm/chart/kubeo-app | egrep ^name: | cut -d" " -f2)
CHAT_PACKAGE_VERSION=$(helm show chart helm/chart/kubeo-app | egrep ^version: | cut -d" " -f2)
helm package ${CHART_NAME} --app-version ${IMAGE_TAG} -d .
if [ $? -ne 0 ]; then
    echo "Failed to package the chart."
    exit 1
fi

echo "Chart packaged as: ${CHAT_PACKAGE_NAME}-${CHAT_PACKAGE_VERSION}.tgz"
CHART_LOCATION="./${CHAT_PACKAGE_NAME}-${CHAT_PACKAGE_VERSION}.tgz"
echo "Chart location: ${CHART_LOCATION}"
if [ ! -f "${CHART_LOCATION}" ]; then
    echo "Chart package not found at ${CHART_LOCATION}. Exiting."
    exit 1
fi

#Debug
#helm lint ${{ parameters.chartLocation }}/${{ parameters.chartName }} --values ${{ parameters.valuesFilename }}
#helm template ${{ parameters.chartLocation }}/${{ parameters.chartName }} --values ${{ parameters.valuesFilename }}

echo "Deploying..."
helm upgrade -i --namespace ${NAMESPACE} \
    ${RELEASE_NAME} ${CHART_LOCATION} \
--wait --atomic --timeout 600s --reset-values \
-f release/${ENVIRONMENT}/default.yml \
-f ${VALUES_FILENAME} \
--set image.tag=${IMAGE_TAG} \
--set image.repository=${IMAGE_REPOSITORY}
if [ $? -ne 0 ]; then
    echo "Deployment failed."
    exit 1
fi  
echo "Deployment complete."