#!/bin/bash
### cat /etc/openvpn/genkey.sh 
#
# Path to storage configuration file generated 
#
OUTDIR="/etc/openvpn/ovpn-client"
#
# path to EASYRSA keys and certificates
#
KEYDIR="/etc/openvpn/easy-rsa/pki/private"
CRTDIR="/etc/openvpn/easy-rsa/pki/issued"
CA_FILE="/etc/openvpn/server/ca.crt"
#
# Name server to connect for 
#
SUFIJO=openvpn
REMOTE=$SUFIJO".domain.com"
#
# Openvpn port to connect for
#
PORT=1194
#
# General parameters storage in a OPTIONS variable
#
OPTIONS="client
dev tun
proto udp
remote $REMOTE $PORT
cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
resolv-retry infinite
compress lzo
nobind
persist-key
persist-tun
mute-replay-warnings
verb 3
"
#
# This function create the ovpn config file and put all parameters in it
#
ovpn(){
        OVPN=$OUTDIR/$1-$SUFIJO.ovpn
        echo "$OPTIONS" > $OVPN
        echo "<ca>" >> $OVPN
        cat $CA_FILE >> $OVPN
        echo "</ca>" >> $OVPN
        echo "<cert>" >> $OVPN
        cat $CRTDIR/$1.crt >> $OVPN
        echo "</cert>" >> $OVPN
        echo "<key>" >> $OVPN
        cat $KEYDIR/$1.key >> $OVPN
        echo "</key>" >> $OVPN
}
#
# If not exist output file-config directory, create it
#
if [ ! -d $OUTDIR ]; then
        mkdir $OUTDIR
fi
#
# For each certificate (crt) run the ovpn function and generate
# the config file
#
for i in $(ls $CRTDIR/*.crt)
        do
		f=$(basename $i .crt)
                ovpn $f
                echo "$OVPN generated"
        done
