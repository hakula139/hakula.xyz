#!/bin/bash
SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $SCRIPT_DIR/..

git pull && git submodule update --recursive --remote
hugo --minify
