#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "[+] Enabling advanced torrent blocking..."

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Install iptables-persistent if missing
if ! dpkg -s iptables-persistent &> /dev/null; then
  echo "[+] Installing iptables-persistent..."
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
fi

# Block common torrent ports (TCP/UDP)
iptables -A OUTPUT -p tcp --dport 6881:6999 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP
iptables -A INPUT  -p tcp --dport 6881:6999 -j DROP
iptables -A INPUT  -p udp --dport 6881:6999 -j DROP

iptables -A OUTPUT -p tcp --dport 51413 -j DROP
iptables -A OUTPUT -p udp --dport 51413 -j DROP
iptables -A INPUT  -p tcp --dport 51413 -j DROP
iptables -A INPUT  -p udp --dport 51413 -j DROP

# Block by string match (may impact performance)
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent" "magnet:"; do
  iptables -A OUTPUT  -m string --string "$keyword" --algo bm -j DROP
  iptables -A INPUT   -m string --string "$keyword" --algo bm -j DROP
  iptables -A FORWARD -m string --string "$keyword" --algo bm -j DROP
done

# Block UDP DHT ports with rate limiting to avoid blocking all UDP
iptables -N UDP_DHT
iptables -A UDP_DHT -m limit --limit 5/sec --limit-burst 10 -j RETURN
iptables -A UDP_DHT -j DROP
iptables -A OUTPUT -p udp --dport 1024:65535 -j UDP_DHT
iptables -A INPUT -p udp --sport 1024:65535 -j UDP_DHT

# Block some known public tracker IPs (example list)
TRACKER_IPS=(
  "104.16.123.96"   # example tracker IP 1
  "107.151.132.69"  # example tracker IP 2
  # Add more known trackers here...
)

for ip in "${TRACKER_IPS[@]}"; do
  iptables -A OUTPUT -d "$ip" -j DROP
  iptables -A INPUT -s "$ip" -j DROP
done

# Save rules persistently
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
systemctl restart netfilter-persistent

echo "[✓] Advanced torrent blocking enabled."
