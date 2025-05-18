#!/bin/bash

echo "Resetting UFW and setting default policies..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Allowing inbound rules..."
sudo ufw allow in 22/tcp
sudo ufw allow in 8000/tcp
sudo ufw allow in 8000/udp

# Inbound Cloudflare ports
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
  sudo ufw allow in $port/tcp
done

echo "Allowing essential outbound rules..."
sudo ufw allow out 80/tcp
sudo ufw allow out 443/tcp

# Cloudflare outbound
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
  sudo ufw allow out $port/tcp
done

echo "Blocking torrent ports..."
sudo ufw deny out 6881:6889/tcp
sudo ufw deny out 6881:6889/udp
sudo ufw deny out 6969/tcp
sudo ufw deny out 51413
sudo ufw deny out 1337/tcp
sudo ufw deny out 2710/tcp
sudo ufw deny out 49152:65535/tcp  
sudo ufw deny out 49152:65535/udp
sudo ufw deny out 10000:65535/udp
sudo ufw deny out 1024:65535/udp
sudo ufw deny out 6880:6999/tcp
sudo ufw deny out 6880:6999/udp

echo "Allowing messaging & media apps..."
sudo ufw allow out 443/udp
sudo ufw allow out 3478/udp
sudo ufw allow out 19302/udp
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

echo "Allowing gaming ports..."
sudo ufw allow out 27000:27100/udp
sudo ufw allow out 5000:6000/udp

echo "Allowing outbound for service on port 8000..."
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

echo "Enabling UFW..."
sudo ufw --force enable
sudo ufw status numbered
