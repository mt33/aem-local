#!/bin/bash

if [[ "$1" == "author" || "$1" == "publish" ]]; then
    tail -f /opt/aem/$1/crx-quickstart/logs/error.log
else
    echo -e "Specify 'author' or 'publish' as the argument"
fi
