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
#create service node
    echo "[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0
[Service] 
User=root 
ExecStart=avail-light --network goldberg
Restart=always 
RestartSec=120
[Install] 
WantedBy=multi-user.target
    " > $HOME/avail.service.service

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