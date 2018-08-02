#!/bin/ash

ACME_DIR="/root/.acme.sh"
CRON_TASK='1 0 * * * "'$ACME_DIR'"/acme.sh --cron --home "'$ACME_DIR'" > /dev/null'

if [ ! -z "$ECC_CERT" ]
then
    ecc_param=' --keylength '$ECC_CERT
    ecc=' --ecc'
fi

for env in $(echo -n "$DNS_API" | awk -F '|' '{for(i=1;i<=NF;i++){print $i}}')
do
    export $env
done

if [ ! -f "$ACME_DIR/acme.sh" ]
then
    curl https://get.acme.sh | sh

    for domain in $(echo -n "$DOMAIN_LIST" | awk -F '|' '{for(i=1;i<=NF;i++){print $i}}')
    do
        issue_domain=`echo "$domain" | awk -F ',' '{for(i=1;i<=NF;i++){printf " -d " $i}}'`
        
        $ACME_DIR/acme.sh --issue --dns $DNS_PROVIDE$issue_domain$ecc_param
    done
else
    crons=`crontab -l | grep acme`

    if [ -z "$crons" ]; then
        crontab -l > crontemp
        echo "$CRON_TASK" >> crontemp
        crontab crontemp
        rm crontemp
    fi
    
    $ACME_DIR/acme.sh --cron --home $ACME_DIR
fi

if [ ! -f "/root/dhparam/dhparam.pem" -a $DHPARAM -ne 0 ]
then
    mkdir -p /root/dhparam
    openssl dhparam -out /root/dhparam/dhparam.pem $DHPARAM
fi

source $ACME_DIR/acme.sh.env
chmod +x $ACME_DIR/acme.sh

for main_domain in $(acme.sh --list | awk '$1 != "Main_Domain" {print $1}')
do
    mkdir -p /root/certs/$main_domain

    $ACME_DIR/acme.sh --install-cert -d $main_domain \
                  --key-file        /root/certs/$main_domain/key.pem  \
                  --fullchain-file  /root/certs/$main_domain/cert.pem \
                  --reloadcmd       "nginx -s reload" \
                  $ecc
done

exec "$@"
