#!/bin/bash

# Add entries to torrc from environment variables formatted like:
# 
# ONION_MYAPP_443=https://myapp.services
# ONION_MYAPP_80=http://myapp.services
#
# Which would append:
#
# HiddenServiceDir /var/lib/tor/MYAPP/
# HiddenServicePort 443 https://myapp.services
# HiddenServicePort 80 http://myapp.services
# 
# to /etc/tor/torrc
echo "" >/etc/tor/torrc

# Retrieve services name (middle value of the variable name)
SERVICES=$(env | sed -n "s/^ONION_\([A-Za-z]\+\)_[0-9]\+=.*/\1/p" | sort -u)

for SERVICE_NAME in $SERVICES
do
    # Format service line to torrc
    echo "HiddenServiceDir /var/lib/tor/$SERVICE_NAME/" >>/etc/tor/torrc

    # Retrieve all ports and endpoints associated with this service
    PORT_ENDPOINT=$(env | sed -n "s/^ONION_${SERVICE_NAME}_\([0-9]\+=.*\)$/\1/p" | sort -n)
    for ENTRY in $PORT_ENDPOINT
    do
        PORT=$(echo "$ENTRY" | cut -d'=' -f1)
        ENDPOINT=$(echo "$ENTRY" | cut -d'=' -f2)

        # If this is a name, convert it to ip
        if [[ "$ENDPOINT" =~ [a-zA-Z] ]]
        then
            ENDPOINT=$(getent hosts "$ENDPOINT" | head -n 1 | awk '{print $1}')
        fi

        # Format port line to torrc
        echo "HiddenServicePort $PORT $ENDPOINT" >>/etc/tor/torrc
    done
    # Give some space
    echo "" >> /etc/tor/torrc
done

# Start tor at the end. It will block container from exiting
tor
