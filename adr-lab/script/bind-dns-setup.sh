#!/bin/bash

# Update and install bind9
sudo apt update
sudo apt install -y bind9 bind9utils bind9-doc

# Configure Bind DNS
sudo bash -c 'cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders {
        8.8.8.8;
    };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF'

# Forward zone configuration
sudo bash -c 'cat << EOF > /etc/bind/named.conf.local
zone "privatelink.blob.core.windows.net" {
    type forward;
    forwarders {
        10.20.0.164;
    };
};
EOF'

# Restart Bind DNS to apply changes
sudo systemctl restart bind9
