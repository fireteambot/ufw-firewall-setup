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
sudo ufw allow out 53                       # DNS
sudo ufw allow out 80/tcp                   # HTTP
sudo ufw allow out 443/tcp                  # HTTPS

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
sudo ufw deny out 8999/tcp
sudo ufw deny out 8999/udp
sudo ufw deny out 42069/tcp
sudo ufw deny out 42069/udp
sudo ufw deny out 16881/tcp
sudo ufw deny out 16881/udp
sudo ufw deny out 10000:65535/udp
sudo ufw deny out 49152:65535/udp
sudo ufw deny out 49152:65535/tcp
sudo ufw deny out 6880:6999/tcp
sudo ufw deny out 6880:6999/udp
sudo ufw deny out 1024:65535/udp

echo "Allowing messaging & media apps..."
sudo ufw allow out 443/udp
sudo ufw allow out 3478/udp
sudo ufw allow out 19302/udp
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

echo "Allowing gaming ports..."
# Free Fire
sudo ufw allow out 7000:7500/udp
sudo ufw allow out 10000:12000/udp
sudo ufw allow out 30000:50000/udp

# Blood Strike
sudo ufw allow out 20000:20100/udp
sudo ufw allow out 30000:31000/udp
sudo ufw allow out 50000:51000/udp

# PUBG
sudo ufw allow out 10010:10030/udp
sudo ufw allow out 20000:20100/udp
sudo ufw allow out 1393/tcp

# Call of Duty (Mobile, BO6, Warzone)
sudo ufw allow out 10000:10050/udp
sudo ufw allow out 20000:20500/udp
sudo ufw allow out 3074/udp
sudo ufw allow out 3074/tcp
sudo ufw allow out 27014:27050/tcp

# GTA V RP / FiveM
sudo ufw allow out 30110:30120/udp
sudo ufw allow out 30110:30120/tcp
sudo ufw allow out 30120:30200/udp
sudo ufw allow out 40120:40140/udp

# Sea of Thieves
sudo ufw allow out 30000:40000/udp
sudo ufw allow out 27015:27030/udp
sudo ufw allow out 3074/udp

# Mobile Legends
sudo ufw allow out 30000:30100/udp
sudo ufw allow out 5001:5220/udp

# Minecraft
sudo ufw allow out 25565/tcp
sudo ufw allow out 19132:19133/udp

# Clash of Clans, Clash Royale, Brawl Stars
sudo ufw allow out 9339/tcp

# Doomsday: Last Survivors
sudo ufw allow out 45000:46000/udp

# Delta Force
sudo ufw allow out 3568/udp
sudo ufw allow out 17475/udp
sudo ufw allow out 17475/tcp

# Rivals
sudo ufw allow out 50000:51000/udp

# Valorant
sudo ufw allow out 7000:8000/udp
sudo ufw allow out 8180:8181/tcp
sudo ufw allow out 10000:10010/udp

# Shadow Fight 4
sudo ufw allow out 25000:26000/udp
sudo ufw allow out 9339/tcp

# General game traffic
sudo ufw allow out 5000:6000/udp

echo "Allowing outbound for service on port 8000..."
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

echo "Allowing trusted IP ranges full access..."
for ip in \
  103.72.28.0/22 \
  45.254.148.0/22 \
  45.253.168.0/22 \
  42.186.0.0/16 \
  103.72.36.0/22 \
  103.20.68.0/22 \
  45.253.144.0/22 \
  106.2.122.0/23 \
  106.2.124.0/22 \
  59.111.128.0/17 \
  203.217.164.0/22
do
  sudo ufw allow from $ip proto tcp
  sudo ufw allow from $ip proto udp
done

# WhatsApp Call Fix
sudo ufw allow out 3478/udp
sudo ufw allow out 45395:45400/udp
sudo ufw allow out 50000:60000/udp

echo "Enabling UFW and logging..."
sudo ufw logging on
sudo ufw --force enable
sudo ufw status numbered
