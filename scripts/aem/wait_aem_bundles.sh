#!/bin/bash
# Parse command line arguments
HOST=
ERROR=
TIMEOUT=false
getargs() {

    if [[ $# -eq 0 ]]; then
        ERROR="No command line parameters"
        echo $ERROR
        exit -1
    fi

    cur=
    for param in "$@"
    do
        if [[ ! $cur ]]; then
            case $param in
                -help)
                    exit 1
                    ;;
                -timeout)
                    TIMEOUT=true
                    ;;
            *)
               cur=${param}
               ;;
            esac
        else
            if [[ ! $param ]]; then
                echo "Option -${cur} requires an argument." >&2
                ERROR=2
            fi

            case $cur in
                -host)
                    HOST="${param}"
                    ;;
            esac

            cur=
        fi
    done

    if [[ ! $HOST ]]; then
        ERROR="Missing -host command line option"
    fi
}

wait_until_bundles_active() {
    host="$1"  
    bundles_status=
    bundles_active=

    while [ -z "$bundles_active" ]; do
        echo "Polling bundles on host << ${host} >>"
        bundles_status=$( curl --silent --netrc ${host}/system/console/bundles.json | grep -o 'Bundle information: [^,]*\.' )

        if [[ -z $bundles_status ]]; then
            echo "Waiting on bundles ..."
            sleep 5
        else
            echo "Current bundles status: $bundles_status"
            local bundles_active=$( echo $bundles_status | grep -oE 'all [0-9]{1,4} bundles active')
            if [[ -z "$bundles_active" ]]; then
                echo "Bundles are not all active. Sleeping 5s and trying again..."
                sleep 5
            else
                echo "Bundles are all active!"
            fi
        fi
    done
}

getrequiredargs "$@"

if [[ ! -z $ERROR ]]; then
    echo $ERROR
    exit -1
fi

if $TIMEOUT ; then
    timeout 60s bash wait_until_bundles_active ${HOST}
else
    wait_until_bundles_active ${HOST}
fi