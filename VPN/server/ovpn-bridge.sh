#!/usr/bin/env bash

DF_SERVER=""
DF_NETWK="public"
DF_BR="br0"
DF_PORT="1194"
DF_MTU="1500"
DF_IP="10.10.1.0/24"
DF_GW="10.10.1.248"
DF_URL="udp://77.234.203.58:11194"

enter_env() {
 local srv
 if [ -f "$(pwd)/answer" ]; then source "$(pwd)/answer";fi
 read -p "Enter the server name [$DF_SERVER] " SERVER
 [ -z "$SERVER" ] && SERVER="$DF_SERVER"
 if [ -z $SERVER ]; then
  echo "Think of the name of the server and start again."
  exit
 fi
 OVPN_DATA="$(pwd)/${SERVER}"
 read -p "Enter the local network name [$DF_NETWK] " NETWK
 [ -z "$NETWK" ] && NETWK="$DF_NETWK"
 read -p "Enter the bridge name [$DF_BR] " BR
 [ -z "$BR" ] && BR="$DF_BR"
 read -p "Enter the port connections [$DF_PORT] " PORT
 [ -z "$PORT" ] && PORT="$DF_PORT"
 read -p "Enter the MTU connections [$DF_MTU] " MTU
 [ -z "$MTU" ] && MTU="$DF_MTU"
 read -p "Enter the local network cidr [$DF_IP] " IP
 [ -z "$IP" ] && IP="$DF_IP"
 read -p "Enter the ip addres of the bridge of local network of server [$DF_GW] " GW
 [ -z "$GW" ] && GW="$DF_GW"
 NA=$(echo $GW|awk -F\. '{print $1"."$2"."$3}')
 NH=$(echo $GW|awk -F\. '{print $4}')
 read -p "Enter the URL of the OpenVPN server [$DF_URL] " URL
 [ -z "$URL" ] && URL="$DF_URL"
 if [[ "${URL:-}" =~ ^((udp|tcp|udp6|tcp6)://)?([0-9a-zA-Z\.\-]+)(:([0-9]+))?$ ]] ; then
  PROTO=${BASH_REMATCH[2]};
  CN=${BASH_REMATCH[3]};
  GPORT=${BASH_REMATCH[5]};
 fi

 tee > "$(pwd)/answer" <<-EOF
DF_SERVER="$SERVER"
DF_NETWK="$NETWK"
DF_BR="$BR"
DF_PORT="$PORT"
DF_MTU="$MTU"
DF_IP="$IP"
DF_GW="$GW"
DF_URL="$URL"
EOF
 
}

docker_create_network() {
  local ip="$1"
  local gw="$2"
  local br="$3"
  local netwk="$4"
  local mtu="$5"

  docker network create --driver=bridge --subnet="$ip" \
    --gateway="$gw" \
    --opt="com.docker.network.bridge.default_bridge"="true" \
    --opt="com.docker.network.bridge.enable_icc"="true" \
    --opt="com.docker.network.bridge.enable_ip_masquerade"="false" \
    --opt="com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" \
    --opt="com.docker.network.bridge.name"="$br" \
    --opt="com.docker.network.driver.mtu"="$mtu" $netwk
}

mk_tap_up() {
  local o_data="$1"
  mkdir -p $o_data
  tee >$o_data/tap-up.sh<<-EOF
#!/bin/sh

tap=\$1
br="br0"
eth="eth1"
/usr/sbin/brctl addbr \$br
/usr/sbin/brctl stp \$br on
/sbin/ifconfig \$br up
/sbin/ifconfig \$eth 0.0.0.0
/usr/sbin/brctl addif \$br \$eth
/usr/sbin/brctl addif \$br \$tap
EOF
  chmod +x $o_data/tap-up.sh
  return 0
}

if [ -z "$(id|grep docker)" -a $(id -u) != 0 ];then
 echo "Installation OpenVPN must be root or with docker group member permission."
 echo "Perform \"sudo usermod -aG docker $(whoami)\" and relogin."
 exit
fi
enter_env
echo "1. Create and run the OpenVPN server docker"
echo "2. Create the OpenVPN client config"
echo "3. Create and run the OpenVPN client docker"
echo "4. Quit"
read -p "Our choice? " ans
case $ans in
  1) ### Initialize the `$OVPN_DATA` container that will hold the configuration
     ### files and certificates.  The container will prompt for a passphrase
     ### to protect the private key used by the newly generated certificate
     ### authority, then start OpenVPN server process
    if [ ! $(docker network inspect $NETWK >/dev/null 2>&1) ]; then
     docker_create_network "$IP" "$GW" "$BR" "$NETWK" "$MTU"
     mk_tap_up "$OVPN_DATA"
      docker run \
      -v $OVPN_DATA:/etc/openvpn \
      -e OVPN_CN="$SERVER CA" \
      --rm kylemanna/openvpn ovpn_genconfig \
      -bcdDt \
      -m "$MTU" \
      -e "up tap-up.sh" \
      -e "script-security 2" \
      -E "up tap-up.sh" \
      -E "script-security 2" \
      -s "192.168.55.0/24" \
      -u "$URL"

     docker run -v $OVPN_DATA:/etc/openvpn --rm -it -e OVPN_CN="$SERVER CA" kylemanna/openvpn ovpn_initpki
     docker create \
      -v $OVPN_DATA:/etc/openvpn -p $PORT:1194/$PROTO \
      --cap-add=NET_ADMIN \
      --name="$SERVER" kylemanna/openvpn
    
     docker network connect $NETWK $SERVER
    fi
    docker start $SERVER
    ;;
  2) ### Generate a client certificate without a passphrase and
     ### Retrieve the client configuration with embedded certificates
    if [ $(docker network inspect $NETWK >/dev/null 2>&1) ]; then
     echo "Create and run the OpenVPN server docker first."
     exit
    fi
    read -p "Input this client name " CLIENT
    docker run -v $OVPN_DATA:/etc/openvpn --rm \
     -it kylemanna/openvpn easyrsa build-client-full $CLIENT nopass
    docker run -v $OVPN_DATA:/etc/openvpn --rm \
     kylemanna/openvpn ovpn_getclient $CLIENT > $CLIENT.ovpn
    cp $OVPN_DATA/ovpn_env.sh $CLIENT.env
    echo "don't remeber to copy \"$0\", \"$CLIENT.ovpn\", \"$CLIENT.env\" and"
    echo "\"answer\" files to the client working directory on the client's host"
    ;;
  3) #### Start OpenVPN client process
    CFG="$(/bin/ls *.ovpn)"
    CLIENT="$(echo $CFG|sed -e 's/\(.*\).ovpn/\1/')"
    OVPN_DATA="$(pwd)/${CLIENT}"
    read -p "Input this client number " CN
    echo ""
    GW="$NA.$((NH+$CN))"
    if [ ! -f "$(pwd)/${CFG}" ]; then
      echo "Put the client config file $CFG in the working directory and try again."
      exit
    fi
    if [ ! $(docker network inspect $NETWK >/dev/null 2>&1) ]; then
     docker_create_network "$IP" "$GW" "$BR" "$NETWK" "$MTU"
     mk_tap_up "$OVPN_DATA"
     cp $CFG $OVPN_DATA/openvpn.conf
     cp "$CLIENT.env" $OVPN_DATA/ovpn_env.sh
     docker create \
      -v $OVPN_DATA:/etc/openvpn -p $PORT:1194/$PROTO \
      --cap-add=NET_ADMIN \
      --name="$CLIENT" kylemanna/openvpn
     docker network connect $NETWK $CLIENT
    fi
    docker start $CLIENT 
    ;;
  4|*) ;;
esac
echo "Good bye"
