#!/bin/ash

ACME_DIR="/root/.acme.sh"
CRON_TASK='1 0 * * * "'$ACME_DIR'"/acme.sh --cron --home "'$ACME_DIR'" > /dev/null'

issue_domain=`echo "$BLOG_DOMAIN" | awk -F ',' '{for(i=1;i<=NF;i++){printf " -d " $i}}'`
main_domain=`echo "$BLOG_DOMAIN" | awk -F ',' '{printf $1}'`

if [ ! -f "$ACME_DIR/acme.sh" ]; then
    curl https://get.acme.sh | sh

    $ACME_DIR/acme.sh --issue --dns $DNS_PROVIDE$issue_domain
    
    $ACME_DIR/acme.sh --issue --dns $DNS_PROVIDE -d $HOOK_DOMAIN
    
fi

if [ ! -f "/root/certs/dhparam.pem" ]; then
    mkdir -p /root/certs
    openssl dhparam -out /root/certs/dhparam.pem 2048
fi

chmod +x $ACME_DIR/acme.sh

mkdir -p /root/certs/$main_domain

$ACME_DIR/acme.sh --install-cert -d $main_domain \
                  --key-file        /root/certs/$main_domain/key.pem  \
                  --fullchain-file  /root/certs/$main_domain/cert.pem \
                  --reloadcmd       "nginx -s reload"

mkdir -p /root/certs/$HOOK_DOMAIN

$ACME_DIR/acme.sh --install-cert -d $HOOK_DOMAIN \
                  --key-file        /root/certs/$HOOK_DOMAIN/key.pem  \
                  --fullchain-file  /root/certs/$HOOK_DOMAIN/cert.pem \
                  --reloadcmd       "nginx -s reload"

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
