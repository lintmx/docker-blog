#!/bin/ash

ACME_DIR="/root/.acme.sh"
CRON_TASK='1 0 * * * "'$ACME_DIR'"/acme.sh --cron --home "'$ACME_DIR'" > /dev/null'

issue_domain=`echo "$BLOG_DOMAIN" | awk -F ',' '{for(i=1;i<=NF;i++){printf " -d " $i}}'`
main_domain=`echo "$BLOG_DOMAIN" | awk -F ',' '{printf $1}'`

if [ ! -z "$ECC_CERT" ]; then
    ecc_param=' --keylength '$ECC_CERT
    ecc=' --ecc'
fi

if [ ! -f "$ACME_DIR/acme.sh" ]; then
    curl https://get.acme.sh | sh

    $ACME_DIR/acme.sh --issue --dns $DNS_PROVIDE$issue_domain$ecc_param
    
    $ACME_DIR/acme.sh --issue --dns $DNS_PROVIDE -d $HOOK_DOMAIN$ecc_param
    
fi

if [ ! -f "/root/dhparam/dhparam.pem" ]; then
    mkdir -p /root/dhparam
    openssl dhparam -out /root/dhparam/dhparam.pem $DHPARAM
fi

chmod +x $ACME_DIR/acme.sh

mkdir -p /root/certs/$main_domain

$ACME_DIR/acme.sh --install-cert -d $main_domain \
                  --key-file        /root/certs/$main_domain/key.pem  \
                  --fullchain-file  /root/certs/$main_domain/cert.pem \
                  --reloadcmd       "nginx -s reload" \
                  $ecc

mkdir -p /root/certs/$HOOK_DOMAIN

$ACME_DIR/acme.sh --install-cert -d $HOOK_DOMAIN \
                  --key-file        /root/certs/$HOOK_DOMAIN/key.pem  \
                  --fullchain-file  /root/certs/$HOOK_DOMAIN/cert.pem \
                  --reloadcmd       "nginx -s reload" \
                  $ecc

if [ -f "$ACME_DIR/acme.sh" ]; then
    crons=`crontab -l | grep acme`

    if [ -z "$crons" ]; then
        crontab -l > crontemp
        echo "$CRON_TASK" >> crontemp
        crontab crontemp
        rm crontemp
    fi
    
    $ACME_DIR/acme.sh --cron --home $ACME_DIR
fi

exec "$@"
