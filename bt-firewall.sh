#!/bin/bash

# Torrent blocker using nDPI xt_ndpi kernel module + iptables

XT_NDPI_DIR="/usr/src/xt_ndpi"
MODULE="xt_ndpi"
RULES_FILE="/etc/iptables/rules.v4"

function install_dependencies() {
  apt-get update
  apt-get install -y git build-essential linux-headers-$(uname -r) iptables iptables-dev dkms
}

function clone_and_build_module() {
  if [ ! -d "$XT_NDPI_DIR" ]; then
    git clone https://github.com/ntop/xt_ndpi.git "$XT_NDPI_DIR"
  fi
  cd "$XT_NDPI_DIR"
  make clean
  make
}

function load_module() {
  if ! lsmod | grep -q "$MODULE"; then
    insmod "$XT_NDPI_DIR/$MODULE.ko" 2>/dev/null || modprobe "$MODULE"
  fi
}

function unblock_firewall() {
  echo "[+] Removing torrent blocking rules..."
  iptables -D FORWARD -m ndpi --bittorrent -j DROP 2>/dev/null || true
  iptables -D OUTPUT  -m ndpi --bittorrent -j DROP 2>/dev/null || true
  iptables -D INPUT   -m ndpi --bittorrent -j DROP 2>/dev/null || true
  iptables-save > "$RULES_FILE"
  echo "[✓] Torrent blocking disabled."
}

function block_firewall() {
  echo "[+] Enabling torrent blocking rules..."
  unblock_firewall  # Remove any duplicates first

  iptables -I FORWARD -m ndpi --bittorrent -j DROP
  iptables -I OUTPUT  -m ndpi --bittorrent -j DROP
  iptables -I INPUT   -m ndpi --bittorrent -j DROP
  iptables-save > "$RULES_FILE"
  echo "[✓] Torrent blocking enabled."
}

function install_script() {
  echo "[+] Installing dependencies..."
  install_dependencies

  echo "[+] Cloning and building xt_ndpi kernel module..."
  clone_and_build_module

  echo "[+] Loading xt_ndpi kernel module..."
  load_module

  # Install this script as 'bt' command
  cp "$0" /usr/local/bin/bt
  chmod +x /usr/local/bin/bt

  echo "[✓] Installed! Use 'bt on' to enable and 'bt off' to disable torrent blocking."
}

function show_status() {
  if iptables -C FORWARD -m ndpi --bittorrent -j DROP 2>/dev/null; then
    echo "Torrent blocking: ON"
  else
    echo "Torrent blocking: OFF"
  fi
}

case "$1" in
  install)
    install_script
    ;;
  on)
    block_firewall
    ;;
  off)
    unblock_firewall
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: bt {install|on|off|status}"
    ;;
esac
