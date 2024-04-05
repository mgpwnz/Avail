#!/bin/bash
# Default variables
function="install"
#new version 04.04.2024
version=v1.7.10
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
sudo apt update &> /dev/null
apt-get install protobuf-compiler -y
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 3
sudo apt install wget -y &> /dev/null
sudo apt-get install libgomp1 -y &> /dev/null
cd $HOME
#create dir
sudo mkdir $HOME/avail
sudo mkdir $HOME/avail/config
sudo mkdir $HOME/avail/state
sudo mkdir $HOME/avail/keystore
#download 
cd $HOME/avail
sudo docker run -v $(pwd)/state:/da/state:rw -p 37333:30333 -p 9615:9615 -p 9944:9944 -d --restart unless-stopped availj/avail:v1.10.0.0 --chain goldberg --name "MyAweasomeInContainerAvailAnode" -d /da/state

}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    
    echo "Done"
    cd $HOME
    ;;
    *)
        echo Сanceled
        return 0
        ;;
esac
}
new(){
echo "3h update is not possible. If you have a node from the 3g network, you need to delete the old version!"
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