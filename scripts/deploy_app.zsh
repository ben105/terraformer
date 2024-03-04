#!/usr/bin/env zsh

set -eu

SCRIPT_DIR=$(dirname "$0")

APP_NAME=$1
TAG=$2

PROJECT_ID="terraformer-415819"
PROJECT_REPO="terraformer-app-repo"

BE_DOCKER_TAG=us-west1-docker.pkg.dev/${PROJECT_ID}/${PROJECT_REPO}/${APP_NAME}-be:${TAG}
FE_DOCKER_TAG=us-west1-docker.pkg.dev/${PROJECT_ID}/${PROJECT_REPO}/${APP_NAME}-fe:${TAG}

pushd ${SCRIPT_DIR}/../apps/${APP_NAME}/backend
docker build -t $BE_DOCKER_TAG .
docker push $BE_DOCKER_TAG
popd

pushd ${SCRIPT_DIR}/../apps/${APP_NAME}/frontend
docker build -t $FE_DOCKER_TAG .
docker push $FE_DOCKER_TAG
popd

mkdir -p ${SCRIPT_DIR}/../releases/${APP_NAME}
pushd ${SCRIPT_DIR}/../releases/${APP_NAME}
echo "${APP_NAME}-be:${TAG}" > "backend.release"
echo "${APP_NAME}-fe:${TAG}" > "frontend.release"
popd

pushd ${SCRIPT_DIR}/../tf
terraform apply -var-file=terraformer.tfvars
popd