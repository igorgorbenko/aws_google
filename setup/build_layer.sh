#!/bin/bash
export PKG_DIR="setup"

mkdir -p ${PKG_DIR}
rm -rf ${PKG_DIR}/layer_google_api

docker run --rm \
    -v $(pwd)/setup:/setup \
    --user $(id -u):$(id -g) -w /temp lambci/lambda:build-python3.7 \
    pip3 install --upgrade -r /setup/requirements.txt \
        -t /setup/layer_google_api/src/python/
