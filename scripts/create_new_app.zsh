#!/usr/bin/env zsh

set -eu

SCRIPT_DIR=$(dirname "$0")

pushd ${SCRIPT_DIR}/../apps/app_generator
./setup.zsh
python3 generate.py $1
popd
