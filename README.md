# aem-local

set up a local aem ~~full stack~~ dev env

you need:

* vagrant
* virtualbox
* love and patience

### ssl for nginx reverse proxies:

```
sudo mkdir /etc/ssl/private

sudo chmod 700 /etc/ssl/private

SUBJ="/C=Montreal/ST=QC/O=Org/CN=certname"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "$SUBJ"

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

* https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7
* https://www.shellhacks.com/create-csr-openssl-without-prompt-non-interactive/
