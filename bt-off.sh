#!/bin/bash

echo "[+] Disabling torrent blocking rules..."

iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
systemctl restart netfilter-persistent

echo "[✓] Torrent blocking disabled."
