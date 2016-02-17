#!/bin/sh
SERVERS=$(nslookup dmsas.sda.sas.junta-andalucia.es | grep Address | awk '{print $3}')

for server in $SERVERS; do
    nc -z -w 1 $server 389
    lastconnection=$?
    if [[ "$lastconnection" == 0 ]]; then
        echo "127.0.0.1 localhost" > /etc/hosts
        echo "$server dmsas.sda.sas.junta-andalucia.es" >> /etc/hosts
        exit
    fi
done
