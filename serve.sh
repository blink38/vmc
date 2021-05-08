#!/bin/bash

docker run -it -p 8000:8000 -v $PWD:/app -u $(id -u ${USER}):$(id -g ${USER}) -t symfony symfony serve --no-tls
