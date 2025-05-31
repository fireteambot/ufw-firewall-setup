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

# Define ports to NEVER block (whitelist)
WHITELIST_PORTS=(
  80    # HTTP
  443   # HTTPS
  53    # DNS
  22    # SSH
  25    # SMTP
  587   # SMTP SSL
  465   # SMTP SSL
  110   # POP3
  995   # POP3 SSL
  143   # IMAP
  993   # IMAP SSL
  1194  # OpenVPN
  5060  # SIP
  5061  # SIP TLS
  3478  # STUN/TURN
  5349  # TURN over TLS
  1935  # RTMP
  5222  # XMPP
  5223  # XMPP SSL
  5228  # XMPP (Google)
  5269  # XMPP Server
  5280  # XMPP BOSH
  5281  # XMPP BOSH SSL
  3478  # STUN
  5349  # STUN over TLS
  10000 # Webmin
  3389  # RDP
  5900  # VNC
  119   # NNTP
  563   # NNTP SSL
)

# Block common torrent ports (TCP/UDP) except whitelisted ports
for port in {6881..6999} 51413; do
  if [[ ! " ${WHITELIST_PORTS[@]} " =~ " ${port} " ]]; then
    iptables -A OUTPUT -p tcp --dport $port -j DROP
    iptables -A OUTPUT -p udp --dport $port -j DROP
    iptables -A INPUT -p tcp --dport $port -j DROP
    iptables -A INPUT -p udp --dport $port -j DROP
  fi
done

# Block by string match (may impact performance)
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent"; do
  # Skip checking whitelisted ports for string matches
  for port in "${WHITELIST_PORTS[@]}"; do
    iptables -A OUTPUT -p tcp --dport $port -m string --string "$keyword" --algo bm -j ACCEPT
    iptables -A INPUT -p tcp --sport $port -m string --string "$keyword" --algo bm -j ACCEPT
  done
  
  # Apply string matching to non-whitelisted traffic
  iptables -A OUTPUT -m string --string "$keyword" --algo bm -j DROP
  iptables -A INPUT -m string --string "$keyword" --algo bm -j DROP
  iptables -A FORWARD -m string --string "$keyword" --algo bm -j DROP
done

# Block UDP DHT ports with rate limiting (excluding whitelisted ports)
iptables -N UDP_DHT
iptables -A UDP_DHT -m limit --limit 5/sec --limit-burst 10 -j RETURN
iptables -A UDP_DHT -j DROP

# Apply DHT blocking only to non-whitelisted ports
iptables -A OUTPUT -p udp -m multiport ! --dports $(IFS=,; echo "${WHITELIST_PORTS[*]}") -j UDP_DHT
iptables -A INPUT -p udp -m multiport ! --sports $(IFS=,; echo "${WHITELIST_PORTS[*]}") -j UDP_DHT

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

echo "[✓] Advanced torrent blocking enabled while preserving essential services."
echo "    Whitelisted ports: ${WHITELIST_PORTS[@]}"
