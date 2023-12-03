#! /usr/bin/env bash

TUN=$1
CMD=$2


usage() {
  echo "Usage: wgctl <TUN> <up|down>" >&2
}


if [ -z "$TUN" ] || [ -z "$CMD" ]; then
  usage
  exit 1
fi


WGFILE=/etc/wireguard/${TUN}.conf
if sudo test -f "$WGFILE"; then
  echo "$WGFILE OK" >&2
else
  echo "Please create $WGFILE and try again" >&2
  exit 1
fi

if [ "$CMD" == "up" ]; then
  echo "Bringing up WireGuard connection"
  sudo wg-quick up ${TUN}
elif [ "$CMD" == "down" ]; then
  echo "Turning off WireGuard connection"
  sudo wg-quick down ${TUN}
else
  usage
  exit 1
fi
