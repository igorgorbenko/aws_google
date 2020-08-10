#!/bin/sh

cd $1

pip install \
    -r ./requirements.txt \
    -t ./temp/layer/python/lib/python3.7/site-packages/
 
