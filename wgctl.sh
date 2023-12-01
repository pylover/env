#! /usr/bin/env bash

cmd=$1

usage() {
  echo "Usage: wg [up|down]" >&2
}

if [ -z "$cmd" ]; then
  usage
  exit 1
fi

WGFILE=/etc/wireguard/wg0.conf
if sudo test -f "$WGFILE"; then
  echo "$WGFILE OK" >&2
else
  echo "Please create $WGFILE and try again" >&2
  exit 1
fi

if [ "$cmd" == "up" ]; then
  echo "Bringing up WireGuard connection"
  sudo wg-quick up wg0
elif [ "$cmd" == "down" ]; then
  echo "Turning off WireGuard connection"
  sudo wg-quick down wg0
else
  usage
  exit 1
fi
