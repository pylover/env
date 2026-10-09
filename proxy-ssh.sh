#! /usr/bin/env bash
HOST=$1

usage() {
  echo "Usage: $0 HOST " >&2
  exit 1
}


if [ -z "${HOST}" ]; then
  usage
fi

LCMD="gsettings set org.gnome.system.proxy mode 'manual'"

ssh -vND 127.0.0.1:1080  \
  -o PermitLocalCommand=yes \
  -o LocalCommand="$LCMD" \
  $HOST


gsettings set org.gnome.system.proxy mode 'none'
