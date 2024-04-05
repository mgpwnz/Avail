#!/bin/bash
# Default variables
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
	    -up|--update)
            function="update"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
echo -e "\e[1m\e[32m2. Enter Avail FullNode name \e[0m"
read -p "FullNode Name : " NAME
sudo apt update &> /dev/null
apt-get install protobuf-compiler -y
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)
sleep 3
sudo apt install wget -y &> /dev/null
sudo apt-get install libgomp1 -y &> /dev/null
cd $HOME
#create dir
sudo mkdir $HOME/avail
#download 
cd $HOME/avail
sudo docker run -v $(pwd)/state:/da/state:rw -v $(pwd)/keystore:/da/keystore:rw -e DA_CHAIN=goldberg -e DA_NAME=$NAME -p 37333:30333 -p 10615:9615 -p 10944:9944 -d --name=avail --restart unless-stopped availj/avail:v1.8.0.0 --rpc-cors=all --rpc-external --rpc-methods=unsafe --rpc-port 9944
cd $HOME
}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    docker stop avail docker rm avail
    echo "Done"
    cd $HOME
    ;;
    *)
        echo Сanceled
        return 0
        ;;
esac
}

update() {
cd $HOME
sudo apt update &> /dev/null
#download cli
echo -e "Your Avail node \e[32mUpdate\e[39m!"
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function