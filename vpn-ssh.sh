#! /usr/bin/env bash
HOST=$1
TUN=$2

usage() {
  echo "Usage: $0 HOST ID [PORT]" >&2
  exit 1
}


if [ -z "${HOST}" ] || [ -z "${TUN}" ]; then
  usage
fi


if [ -n "$3" ]; then
  PORT=$3
else
  PORT=22
fi


GWIFACE=$(ip ro sh | grep '^default' | head -n 1 | grep -Po 'dev (.*)' | \
  cut -d' ' -f2)
GWADDR=$(ip ro sh | grep '^default' | head -n 1 | cut -d' ' -f3)

LADDR=192.168.21.$(expr $TUN \* 2)
RADDR=192.168.21.$(expr $TUN \* 2 + 1)
EXCEPTIONFILE=${HOME}/.ssh/vpn-exceptions


echo "Hostname: ${HOST}"
echo "Port: ${PORT}"
echo "GW: ${GWADDR} ${GWIFACE}"
echo "TUN addresses: ${LADDR} ${RADDR}"


if [ -f "${HOME}/.ssh/vpn-exceptions" ]; then
  while read p; do
    echo "Excpet: $p"
  done <${EXCEPTIONFILE}
fi


FLAGS="-p${PORT} -v -w $TUN:$TUN"
USER=root

LCMD="ip ad add $LADDR/31 peer $RADDR dev tun$TUN"
LCMD="$LCMD;ip ro replace $HOST via $GWADDR"
LCMD="$LCMD;ip li set mtu 1400 dev tun$TUN"
LCMD="$LCMD;ip li set up dev tun$TUN"
LCMD="$LCMD;ip ro replace default via $RADDR"
LCMD="$LCMD;resolvectl dns tun$TUN 1.1.1.1 8.8.8.8"
LCMD="$LCMD;resolvectl default-route tun$TUN true"
LCMD="$LCMD;resolvectl default-route $GWIFACE false"


if [ -f "${HOME}/.ssh/vpn-exceptions" ]; then
  while read p; do
    LCMD="$LCMD;ip ro replace ${p} via $GWADDR"
  done <${EXCEPTIONFILE}
fi


RCMD="ip ad add $RADDR/31 peer $LADDR dev tun$TUN"
RCMD="$RCMD;ip li set mtu 1400 dev tun$TUN"
RCMD="$RCMD;ip li set up dev tun$TUN"
RCMD="$RCMD;iptables -tnat -DPOSTROUTING -s $LADDR -j MASQUERADE"
RCMD="$RCMD;iptables -tnat -APOSTROUTING -s $LADDR -j MASQUERADE"


sudo ssh $FLAGS \
  -o PermitLocalCommand=yes \
  -o LocalCommand="$LCMD" \
  -o RemoteCommand="$RCMD" \
  $USER@$HOST


sudo ip ro del $HOST via $GWADDR
sudo ip ro replace default via $GWADDR dev $GWIFACE
sudo resolvectl default-route $GWIFACE true


if [ -f "${HOME}/.ssh/vpn-exceptions" ]; then
  while read p; do
    sudo ip ro del ${p} via $GWADDR
  done <${EXCEPTIONFILE}
fi
