#!/bin/bash

curl -fsSL https://raw.githubusercontent.com/wgp-2020/GCS/master/xray -o xray && chmod +x ./xray

id=$(./xray uuid)
outKey=$(./xray x25519)
private_key=$(echo "$output" | awk '/Private key:/ {print $NF}')
public_key=$(echo "$output" | awk '/Public key:/ {print $NF}')
short_id=${id##*-}

echo '{
    "inbounds": [
        {
            "port": 22,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "'$id'",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.lovelive-anime.jp:443",
                    "xver": 0,
                    "serverNames": [
                        "www.lovelive-anime.jp"
                    ],
                    "privateKey": "'$private_key'",
                    "shortIds": [
                        "'$short_id'"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}' > config.json

sudo kill $(ps aux | awk '/sshd:.*-p 22/ && !/awk/ {print $2}') && nohup ./xray > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
    echo 'vless://'${id}'@'$(curl -s ifconfig.io)':6000?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.lovelive-anime.jp&fp=chrome&pbk='${public_key}'&sid='${short_id}'&spx=%2F&type=tcp&headerType=none#GoogleCloudShell'
else
