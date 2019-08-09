#!/bin/bash

start_aem() {
    instance_type="$1"
    echo -e "starting aem $instance_type ..."
    /opt/adobe/aem/$instance_type/crx-quickstart/bin/start
}

start_aem $1