#!/bin/bash

docker run -it -v $PWD:/app -u $(id -u ${USER}):$(id -g ${USER}) -t symfony
