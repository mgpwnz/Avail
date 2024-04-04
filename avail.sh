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
sleep 3
sudo apt install wget -y &> /dev/null
sudo apt-get install libgomp1 -y &> /dev/null
cd $HOME
#download binary
wget https://github.com/availproject/avail-light/releases/download/$version/avail-light-linux-amd64.tar.gz  && \
tar zxvf avail-light-linux-amd64.tar.gz && \
rm avail-light-linux-amd64.tar.gz
sleep 1
sudo mv avail-light-linux-amd64 /usr/local/bin/avail-light
sudo chmod +x /usr/local/bin/avail-light
#cretae sonfig
if [ ! -d "$HOME/.avail" ]; then
    mkdir $HOME/.avail
fi
if [ ! -d "$HOME/.avail/config" ]; then
    mkdir $HOME/.avail/config
fi
if [ ! -d "$HOME/.avail/identity" ]; then
    mkdir $HOME/.avail/identity
fi
if [ ! -d "$HOME/.avail/data" ]; then
    mkdir $HOME/.avail/data
fi
if [ -z "$identity" ]; then
    IDENTITY=$HOME/.avail/identity/identity.toml
    if [ -f "$IDENTITY" ]; then
        echo "🔑 Identity found at $IDENTITY."
    else
        echo "🤷 No identity set. This will be automatically generated at startup."
    fi
else
    IDENTITY="$identity"
fi
CONFIG_PARAMS="bootstraps=['/dns/bootnode.1.lightclient.goldberg.avail.tools/tcp/37000/p2p/12D3KooWBkLsNGaD3SpMaRWtAmWVuiZg1afdNSPbtJ8M8r9ArGRT','/dns/bootnode.2.lightclient.goldberg.avail.tools/tcp/37000/p2p/12D3KooWRCgfvaLSnQfkwGehrhSNpY7i5RenWKL2ARst6ZqgdZZd']\nfull_node_ws=['wss://rpc-goldberg.sandbox.avail.tools:443','wss://goldberg-rpc.fra.avail.tools:443']\nconfidence=99.0\navail_path='$HOME/.avail/data'\nkad_record_ttl=43200\not_collector_endpoint='http://otelcol.lightclient.goldberg.avail.tools:4317'\ngenesis_hash='6f09966420b2608d1947ccfb0f2a362450d1fc7fd902c29b67c906eaa965a7ae'\n"
if [ -z "$config" ]; then
        CONFIG="$HOME/.avail/config/config.yml"
        if [ -f "$CONFIG" ]; then
            echo "🗑️  Wiping old config file at $CONFIG."
            rm $CONFIG
        else
            echo "🤷 No configuration file set. This will be automatically generated at startup."
        fi
        touch $CONFIG
        echo -e $CONFIG_PARAMS >>$CONFIG
    else
        CONFIG="$config"
    fi
#create service node
    echo "[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0
[Service] 
User=$USER 
ExecStart=avail-light --network goldberg --config $CONFIG --identity $IDENTITY
Restart=always 
RestartSec=120
LimitNOFILE=65535
[Install] 
WantedBy=multi-user.target
    " > $HOME/avail.service

    sudo mv $HOME/avail.service /etc/systemd/system

# Enabling services
    sudo systemctl daemon-reload
    sudo systemctl enable avail.service
# Starting services
    sudo systemctl restart avail.service
#logs
    echo -e "\e[1m\e[32mTo check the Avail Node Logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u avail.service -f \n \e[0m" 
}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    sudo systemctl disable avail.service
    sudo rm /etc/systemd/system/avail.service
    sudo rm /usr/local/bin/avail-light 
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
wget https://github.com/availproject/avail-light/releases/download/$version/avail-light-linux-amd64.tar.gz  && \
tar zxvf avail-light-linux-amd64.tar.gz && \
rm avail-light-linux-amd64.tar.gz
sleep 1
sudo mv avail-light-linux-amd64 /usr/local/bin/avail-light
sudo chmod +x /usr/local/bin/avail-light
sleep 1
# Enabling services
    sudo systemctl daemon-reload
# Starting services
    sudo systemctl restart avail.service
echo -e "Your Avail node \e[32mUpdate\e[39m!"
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function