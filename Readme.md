# OpenVPN config File Generator
Some years ago I had a situation in which needed to generate several certificates through EASYCERT for OPENVPN, the particular of this situation was the people who would install and use this certificate had a little knowledge about how to install the OVPN file, certificate file and the key file (3 files) in the OpenVPN software in their laptops. I needed to simplify this issue or would have headaches supporting all this user. 

Then researching in internet, I could be able to see that OVPN file can content the certificates and the key in PEM (base64) format embedded on it. And with this idea was born this script.

# The Script

You have to have the certificate (.crt file) and the key (.key) generated a prior with EASYRSA anb placed in `/etc/openvpn/easy-rsa/pki/private` `/etc/openvpn/easy-rsa/pki/issued`, also have the Certificate of Authority in `/etc/openvpn/server/ca.crt`.

Then...

Path to directories where the cert, keys and the final OVPN file will be:
```
OUTDIR="/etc/openvpn/ovpn-client"
KEYDIR="/etc/openvpn/easy-rsa/pki/private"
CRTDIR="/etc/openvpn/easy-rsa/pki/issued"
CA_FILE="/etc/openvpn/server/ca.crt"
```
Variables `REMOTE` and `PORT` store the name and port of OpenVPN Server: 
```
SUFIJO=openvpn
REMOTE=$SUFIJO".domain.com"
PORT=1194
```
This is the parameters that OpenvPN client will use for connect:
```
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
```
Function that concatenate OPTIONS (Above), the Certificate of Authority ($CA_FILE), the User Certificate ($CRTDIR/$1.crt) and the User Key ($KEYDIR/$1.key). All the concatenates only proceed if the file OVPN does not exist.
```
ovpn(){
    OVPN=$OUTDIR/$1-$SUFIJO.ovpn
    if [ ! -f $OVPN ]; then
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
        echo "$OVPN Generated"
     else
        echo "$OVPN Exists"          
    fi
}
```
Here the script create destination directorio and for each `.crt` file in `$CRTDIR`, it calls the function `ovpn()` to generate the respective OVPN files:
```
if [ ! -d $OUTDIR ]; then
    mkdir $OUTDIR
fi
for i in $(ls $CRTDIR/*.crt)
    do
	    f=$(basename $i .crt)
        ovpn $f
    done

```

