#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

#--------------------------------------------- COIN INFORMATION --------------------------------------------
# CONFIG ABOUT COIN
COIN_NAME=DextroCoin
COLATERAL=1000 DXO
CONFIG_FILE=dextro.conf

# ALWAYS START WITH ~/ AND DEFAULT COIN FOLDER
CONFIG_FOLDER=~/.dextro
COIN_DAEMON=dextrod
COIN_CLI=dextro-cli
COIN_TX=dextro-tx
COIN_QT=dextro-qt
MAX_CONNECTIONS=30
LOGINTIMESTAMPS=1
COIN_PORT=39320
RPC_PORT=39321

# TO CONFIG
COIN_PATH=/usr/local/bin/
TMP_FOLDER=~/temp_masternodes

# DONT TOUCH
COIN_ZIP=$(echo $COIN_TGZ_ZIP | awk -F'/' '{print $NF}')
NODEIP=$(curl -s4 icanhazip.com)

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#-------------------------------------------- LETS START ----------------------------------------

noflags() {
    echo "??????????????????????????????????????"
    echo "Usage: ./rebase.sh"
    echo "Example: ./rebase.sh"
    echo "??????????????????????????????????????"
    exit 1
}

message() {
	echo "+-------------------------------------------------------------------------------->>"
	echo "| $1"
	echo "+--------------------------------------------<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}

# ---------------------------------------- INSTALL ------------------------------------
function prepare_dependencies() { #TODO: add error detection
   PS3='Need to Install Depedencies and Libraries'
   echo -e "Prepare the system to install ${GREEN}$COIN_NAME master node.${NC}"
   echo -e "If prompted enter password of current user!"
   sudo apt-get -y update >/dev/null 2>&1  
   sudo apt-get -y install python-virtualenv
   if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
      echo "sudo apt-get -y update"
      echo " sudo apt-get -y install python-virtualenv"
      exit 1
   fi
   clear
}
   
function check_version() {   
   echo -e "Check if OmegaCoin is at least version 12.1 (120100)"
   omegacoin-cli getinfo | grep version

}


funtion install_sentinel() {
    cd ~
    git clone https://github.com/omegacoinnetwork/sentinel.git && cd sentinel
    virtualenv ./venv
    ./venv/bin/pip install -r requirements.txt
}

function configure_sentinel() {
   cronjob_creator () {
          # usage: cronjob_creator '<interval>' '<command>'

            if [[ -z $1 ]] ;then
                printf " no interval specified\n"
            elif [[ -z $2 ]] ;then
                printf " no command specified\n"
            else
                CRONIN="/tmp/cti_tmp"
                crontab -l | grep -vw "$1 $2" > "$CRONIN"
                echo "$1 $2" >> $CRONIN
                crontab "$CRONIN"
            rm $CRONIN
            fi
     }
     cronjob_creator '* * * * * ' 'cd /home/'$USERNAME'/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1'
}    


function testing_sentinel() {
      echo -e "Testing Sentinel"
      ./venv/bin/py.test ./test
}

###### MAIN ######
clear
prepare_dependencies
check_version
install_sentinel
configure_sentinel
testing_sentinel
