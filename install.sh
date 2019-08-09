#!/bin/bash
#
# Run like: /vagrant/scripts/provision-aem.sh author|publish
#

root_dir=/opt/aem
payload_dir=/vagrant/payload
scripts_dir=/vagrant/scripts

aem_quickstart_jar=AEM_6.4_Quickstart.jar
aem_sp=AEM-6.4.4.0-6.4.4.zip
aem_license=license.properties
aem_sp_version=AEM-6.4-Service-Pack-4

function install_aem() {
    aem_type=$1
    
    aem_port=4502
    if [[ "$aem_type" == "publish" ]]; then
        aem_port=4503
    fi
    echo -e "installing aem instance - ${aem_type}\n${LINES}"
    
    # set up folders
    mkdir -p $root_dir/$aem_type

    # unpack the quickstart jar and add the license file
    cd $root_dir/$aem_type
    java -jar $payload_dir/aem/$aem_quickstart_jar -unpack
    cp $payload_dir/aem/$aem_license license.properties

    # backup the start script
    cp crx-quickstart/bin/start crx-quickstart/bin/start.orig

    echo -e "updating the aem $aem_type start script"

    # set the port
    sed -i "s/CQ_PORT=4502/CQ_PORT=$aem_port/g" crx-quickstart/bin/start 

    # set the runmodes
    # todo: pass in optional additional runmodes
    sed -i "s/CQ_RUNMODE='author'/CQ_RUNMODE='${aem_type},nosamplecontent,local'/g" crx-quickstart/bin/start

    # add a local debugger port = N0 where N is the 4-digit aem port
    sed -i "s/-Djava.awt.headless=true/-Djava.awt.headless=true -Xdebug -Xrunjdwp:transport=dt_socket,address=${aem_port}0,suspend=n,server=y/g" crx-quickstart/bin/start

    # start the thing and wait until it's up
    echo -e "starting aem instance, some patience please"
    ./crx-quickstart/bin/start
    $scripts_dir/bundles_wait.sh -host localhost:$aem_port

    # install latest SP
    echo -e "installing $aem_sp"
    curl -u admin:admin -F file=@"${payload_dir}/aem/${aem_sp}" -F name="${aem_sp}" -F force=true -F install=true http://localhost:$aem_port/crx/packmgr/service.jsp

    # enable crxde
    echo -e "enabling crxde"
    curl -s --netrc -F "jcr:primaryType=sling:OsgiConfig" -F "alias=/crx/server" -F "dav.create-absolute-uri=true" -F "dav.create-absolute-uri@TypeHint=Boolean" "http://localhost:${aem_port}/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet"

    echo -e "\nwaiting for the aem service Pack to finish installing..."
    ( tail -f -n0 crx-quickstart/logs/error.log & ) | grep -q "com.adobe.granite.installer.Updater Content Package $aem_sp_version Installed successfully"

    echo -e "finished -- AEM instance overview:\n-----------------------------\n"
    curl -s --netrc "http://localhost:${aem_port}/system/console/status-System%20Properties.json" | grep "run."
    curl -s --netrc "http://localhost:${aem_port}/system/console/status-productinfo.json" | grep -A 1 "Installed Products"
}

function install_reverse_proxy() {
    hostname="$1"
    
    aem_port=4502
    if [[ "$hostname" =~ pub ]]; then
        aem_port=4503
    fi
    
    echo "installing nginx server at $hostname to proxy to $aem_port"
    sudo cp $payload_dir/nginx/aem-reverse-proxy.conf /etc/nginx/conf.d/$hostname.conf
    sudo sed -i "s/YOUR_HOST_NAME/${hostname}/g" /etc/nginx/conf.d/aem-reverse-proxy.conf
    sudo sed -i "s/YOUR_AEM_PORT/${aem_port}/g" /etc/nginx/conf.d/aem-reverse-proxy.conf
    
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

function install_nginx() {
    sudo yum install epel-release -y
    sudo yum install nginx -y
}

function install_jre() {

}

function set_aem_shortcuts() {
    echo "alias start-aem='$scripts_dir/start-aem.sh'" >> ~/.bash_profile
    echo "alias stop-aem='$scripts_dir/stop-aem.sh'" >> ~/.bash_profile
    echo "alias tail-error='$scripts_dir/tail-error.sh'" >> ~/.bash_profile
}

install_jre

install_aem author
install_aem publish

install_nginx

install_reverse_proxy "your-local-aem-author-hostname.dev"
install_reverse_proxy "your-local-aem-publish-hostname.dev"

set_aem_shortcuts