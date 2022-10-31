#!/bin/bash
### cat /etc/openvpn/genkey.sh 
OUTDIR="/etc/openvpn/ovpn-client"
KEYDIR="/etc/openvpn/easy-rsa/pki/private"
CRTDIR="/etc/openvpn/easy-rsa/pki/issued"
SUFIJO=condor1815
REMOTE=$SUFIJO".startdedicated.com"
PORT=1194
CA_FILE="/etc/openvpn/server/ca.crt"

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

if [ ! -d $OUTDIR ]; then
        mkdir $OUTDIR
fi

for i in $(ls $CRTDIR/*.crt)
        do
		f=$(basename $i .crt)
                ovpn $f
                echo "$OVPN generated"
        done



