#!/bin/bash

echo "[+] Enabling torrent blocking rules..."

# Reset rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Install iptables-persistent if not installed
if ! dpkg -s iptables-persistent &> /dev/null; then
  echo "[+] Installing iptables-persistent..."
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
fi

# Block torrent ports
iptables -A OUTPUT -p tcp --dport 6881:6999 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP
iptables -A INPUT  -p tcp --dport 6881:6999 -j DROP
iptables -A INPUT  -p udp --dport 6881:6999 -j DROP

iptables -A OUTPUT -p tcp --dport 51413 -j DROP
iptables -A OUTPUT -p udp --dport 51413 -j DROP
iptables -A INPUT  -p tcp --dport 51413 -j DROP
iptables -A INPUT  -p udp --dport 51413 -j DROP

# Block by string match
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent" "magnet:"; do
  iptables -A FORWARD -m string --string "$keyword" --algo bm -j DROP
  iptables -A OUTPUT  -m string --string "$keyword" --algo bm -j DROP
  iptables -A INPUT   -m string --string "$keyword" --algo bm -j DROP
done

# Block DHT/WebRTC
iptables -A FORWARD -p udp --dport 6881:6999 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP
iptables -A INPUT  -p udp --dport 6881:6999 -j DROP

iptables -A OUTPUT -p udp --dport 33434:65535 -m conntrack --ctstate NEW -j DROP

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
systemctl restart netfilter-persistent

echo "[✓] Torrent blocking enabled."
