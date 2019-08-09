#!/bin/bash
#
# another option is to wait for the following log entry:
# "org.apache.sling.installer.core.impl.OsgiInstallerImpl Apache Sling OSGi Installer Service stopped."
#
#
WHICH_AEM=
if [[ "$1" == "author" ]]; then
	WHICH_AEM="author"
elif [[ "$1" == "publish" ]]; then
        WHICH_AEM="publish"
elif [[ "$1" == "both" ]]; then
	WHICH_AEM="publish\|author"
else
	echo -e "Specific 'author', 'publish', or 'both' as the argument"
	exit 1
fi

# Check that we can list open files of a given process
if [[ ! $( which lsof 2>/dev/null ) ]]; then
  echo -e "Please install lsof to continue. Exiting."
  exit 1
fi

# $1 process ID of AEM instance
# $2 path to AEM instance
function waitForAemToStop(){
  echo -e "\nPID $1 is AEM instance at $2 ..."

  # call stop script against this instance
  $2/bin/stop

  local pid=$( ps -ef | grep $1 )

  while [[ $pid ]]; do
    sleep 3
    pid=$( ps -ef | grep $1 | grep -v grep )
    echo "   waiting 3s for AEM pid $1 to stop ..."
  done

  echo -e "\nAEM instance at $2 is stopped.\n"
}

function stopAemInstances() {
  local aem_pids=$(ps -ef | grep java | grep "crx-quickstart" | grep "$WHICH_AEM" |awk '{ print $2 }')
  local aem_path=
  while read -r aem_pid; do
    aem_path=$( lsof -p $aem_pid | awk '{ print $9 }' | sort | grep -vE "(fonts|jvm|pipe|socket|tmp|x86|localhost|NAME|locale)" | grep -oE "^.*(publish|author)/crx-quickstart" | sort -u )
    waitForAemToStop $aem_pid $aem_path
  done <<< "${aem_pids}"
}

stopAemInstances
