#!/bin/bash
# export PKG_DIR="python"
export PKG_DIR="setup"

# rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}
mkdir -p ${PKG_DIR}
rm -rf ${PKG_DIR}/layer_google_api

echo $(pwd)
echo $(ls -a)

docker run --rm \
    -v $(pwd)/setup:/setup \
    --user $(id -u):$(id -g) -w /temp lambci/lambda:build-python3.7 \
    pip3 install -r /setup/requirements.txt \
        --no-deps -t /setup/layer_google_api/src/python/lib/python3.7/site-packages/


