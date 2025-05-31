#!/bin/bash

echo "=== Resetting UFW and setting base rules ==="
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Basic incoming services
sudo ufw allow in 22/tcp
sudo ufw allow in 8000/tcp
sudo ufw allow in 8000/udp

# Cloudflare inbound ports
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
  sudo ufw allow in $port/tcp
done

# Outbound essentials
sudo ufw allow out 53                      # DNS
sudo ufw allow out 80/tcp                  # HTTP
sudo ufw allow out 443/tcp                 # HTTPS

# Cloudflare outbound
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
  sudo ufw allow out $port/tcp
done

echo "=== Blocking common torrent ports with UFW ==="
# Outbound torrent ports
sudo ufw deny out 6881:6889/tcp
sudo ufw deny out 6881:6889/udp
sudo ufw deny out 51413
sudo ufw deny out 6969/tcp
sudo ufw deny out 1337/tcp
sudo ufw deny out 2710/tcp
sudo ufw deny out 8999
sudo ufw deny out 42069
sudo ufw deny out 16881
sudo ufw deny out 6880:6999

# Inbound torrent ports
sudo ufw deny in 6881:6889
sudo ufw deny in 51413
sudo ufw deny in 6969
sudo ufw deny in 1337
sudo ufw deny in 2710
sudo ufw deny in 8999
sudo ufw deny in 42069
sudo ufw deny in 16881
sudo ufw deny in 6880:6999

echo "=== Allowing important media/game/messaging traffic ==="
sudo ufw allow out 443/udp
sudo ufw allow out 3478/udp
sudo ufw allow out 19302/udp
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 45395:45400/udp
sudo ufw allow out 49152:65535/udp

# Add your allowed game ports here (already in your existing script)
# ...

echo "=== Enabling UFW ==="
sudo ufw logging on
sudo ufw --force enable

echo "=== Installing xtables addons for DPI BitTorrent blocking ==="
sudo apt update
sudo apt install -y xtables-addons-common xtables-addons-source dkms ipset

echo "=== Building xtables modules (may take a moment) ==="
sudo dpkg-reconfigure xtables-addons-dkms

echo "=== Loading BitTorrent DPI kernel module ==="
sudo modprobe xt_bittorrent

echo "=== Adding iptables rules to drop BitTorrent traffic ==="
sudo iptables -A OUTPUT -m bittorrent -j DROP
sudo iptables -A INPUT -m bittorrent -j DROP

echo "=== Saving iptables rules for persistence ==="
sudo apt install -y iptables-persistent
sudo netfilter-persistent save

echo "✅ Firewall and torrent-blocking configured successfully."
