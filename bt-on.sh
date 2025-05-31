#!/bin/bash

echo "[+] Enabling advanced torrent blocking..."

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Allow established and related connections (important for gaming & browsing)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Block common torrent ports TCP/UDP
iptables -A INPUT -p tcp --dport 6881:6999 -j DROP
iptables -A OUTPUT -p tcp --dport 6881:6999 -j DROP
iptables -A INPUT -p udp --dport 6881:6999 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP

iptables -A INPUT -p tcp --dport 51413 -j DROP
iptables -A OUTPUT -p tcp --dport 51413 -j DROP
iptables -A INPUT -p udp --dport 51413 -j DROP
iptables -A OUTPUT -p udp --dport 51413 -j DROP

# Block torrent-related strings in packets with limited payload scope for performance
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent" "magnet:"; do
  iptables -A FORWARD -m string --string "$keyword" --algo bm --from 40 --to 200 -j DROP
  iptables -A OUTPUT  -m string --string "$keyword" --algo bm --from 40 --to 200 -j DROP
  iptables -A INPUT   -m string --string "$keyword" --algo bm --from 40 --to 200 -j DROP
done

# Block new UDP connections on common DHT ports (restrict to NEW only to avoid blocking game UDP)
iptables -A OUTPUT -p udp --dport 6881:6999 -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p udp --dport 6881:6999 -m conntrack --ctstate NEW -j DROP

# Optional: limit blocking UDP 33434-33534 (used by traceroute, games)
# You might whitelist specific game ports here or remove this if it causes issues
iptables -A OUTPUT -p udp --dport 33434:33534 -m conntrack --ctstate NEW -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
systemctl restart netfilter-persistent

echo "[✓] Advanced torrent blocking enabled."
