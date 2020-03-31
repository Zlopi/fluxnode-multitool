#!/bin/bash

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
GREEN='\033[1;32m'
NC='\033[0m'
CYAN='\033[1;36m'
REPLACE="0"
FLUXCONF="0"
BTEST="0"
LC_CHECK="0"
SCVESION=v3.0

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9D\x8C${NC}"

#function
round() {
  printf "%.${2}f" "${1}"
}

function check_benchmarks() {
 var_benchmark=$(zelbench-cli getbenchmarks | jq ".$1")
 limit=$2
 if [[ $(echo "$limit>$var_benchmark" | bc) == "1" ]]
 then
  var_round=$(round "$var_benchmark" 2)
  echo -e "${X_MARK} ${CYAN}$3 $var_round $4${NC}"
 fi

}

echo -e "${YELLOW}================================================================${NC}"
echo -e "${BLUE}            ZelNode ANALIZER/FiXER $SCVESION for Ubuntu by XK4MiLX${NC}"
echo -e "${BLUE}            Special thanks to dk808 and jriggs28"
echo -e "${YELLOW}================================================================${NC}"
if [[ "$USER" == "root" ]]
then
    echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
    echo -e "${CYAN}Please switch to the user accont.${NC}"
    echo -e "${YELLOW}================================================================${NC}"
    echo -e "${NC}"
    exit
fi
### cat  ~/.zelcash/debug.log | egrep -i "benchmarking" | grep -v Ping | grep -v "benchmarking" | grep -v "znw - invalid" | tee parse-zelcash_debug-log.txt
echo -e "${NC}"
echo -e "${YELLOW}Installing bc...${NC}"
sudo apt install bc
echo -e "${NC}"
echo -e "${YELLOW}Checking zelbenchmark debug.log${NC}"
cat  ~/.zelbenchmark/debug.log | egrep -i "failed" | grep -v Ping | grep -v "Got bad" | grep -v "error" | tee parse-zelbenchmark-debug-log.txt
echo -e "${NC}"
echo -e "${YELLOW}Checking benchmark status...${NC}"
zelbench-cli getstatus
echo -e "${NC}"
echo -e "${YELLOW}Checking benchmarks details...${NC}"
zelbench-cli getbenchmarks
echo -e "${NC}"
echo -e "${YELLOW}Checking zelcash information...${NC}"
zelcash-cli getinfo
echo -e "${NC}"
echo -e "${YELLOW}Checking node status...${NC}"
zelcash-cli getzelnodestatus
echo -e "${NC}"
echo -e "${YELLOW}Checking ports...${NC}"
echo -e "$(sudo netstat -tulpn | grep zel)"
echo -e "${NC}"
WANIP=$(wget http://ipecho.net/plain -O - -q)
if ! whiptail --yesno "Detected IP address is $WANIP is this correct?" 8 60; then
   WANIP=$(whiptail  --title "ZelNode ANALIZER/FiXER $SCVESION" --inputbox "        Enter IP address" 8 36 3>&1 1>&2 2>&3)
fi
zelnodeprivkey="$(whiptail --title "ZelNode ANALIZER/FiXER $SCVESION" --inputbox "Enter your zelnode Private Key generated by your Zelcore/Zelmate wallet" 8 72 3>&1 1>&2 2>&3)"
zelnodeoutpoint="$(whiptail --title "ZelNode ANALIZER/FiXER $SCVESION" --inputbox "Enter your zelnode Output TX ID" 8 72 3>&1 1>&2 2>&3)"
zelnodeindex="$(whiptail --title "ZelNode ANALIZER/FiXER $SCVESION" --inputbox "Enter your zelnode Output Index" 8 60 3>&1 1>&2 2>&3)"
echo -e "${YELLOW}=====================================================${NC}"

if [[ $zelnodeprivkey == $(grep -w zelnodeprivkey ~/.zelcash/zelcash.conf | sed -e 's/zelnodeprivkey=//') ]]
then
echo -e "${CHECK_MARK} ${CYAN}Zelnodeprivkey matches${NC}"
else
REPLACE="1"
echo -e "${X_MARK} ${CYAN}Zelnodeprivkey does not match${NC}"
fi

if [[ $zelnodeoutpoint == $(grep -w zelnodeoutpoint ~/.zelcash/zelcash.conf | sed -e 's/zelnodeoutpoint=//') ]]
then
echo -e "${CHECK_MARK} ${CYAN}Zelnodeoutpoint matches${NC}"
else
REPLACE="1"
echo -e "${X_MARK} ${CYAN}Zelnodeoutpoint does not match${NC}"
fi

if [[ $zelnodeindex == $(grep -w zelnodeindex ~/.zelcash/zelcash.conf | sed -e 's/zelnodeindex=//') ]]
then
echo -e "${CHECK_MARK} ${CYAN}Zelnodeindex matches${NC}"
else
REPLACE="1"
echo -e "${X_MARK} ${CYAN}Zelnodeindex does not match${NC}"
fi

if pgrep zelcashd > /dev/null; then
    	echo -e "${CHECK_MARK} ${CYAN}Zelcash daemon is installed and running${NC}"
else
    	echo -e "${X_MARK} ${CYAN}Zelcash daemon is not running${NC}"
fi

if pgrep mongod > /dev/null; then
    	echo -e "${CHECK_MARK} ${CYAN}Mongodb is installed and running${NC}"
else
    	echo -e "${X_MARK} ${CYAN}Mongodb is not running or failed to install${NC}"
fi
if node -v > /dev/null 2>&1; then
    	echo -e "${CHECK_MARK} ${CYAN}Nodejs is installed${NC}"
else
    	echo -e "${X_MARK} ${CYAN}Nodejs did not install${NC}"
fi

if [[ $(docker -v) == *"Docker"* ]]
then
echo -e "${CHECK_MARK} ${CYAN}Docker is installed${NC}"
else
echo -e "${X_MARK} ${CYAN}Docker did not installed${NC}"
fi

if [[ $(groups | grep docker) && $(groups | grep "$USER")  ]] 
then
echo -e "${CHECK_MARK} ${CYAN}User $USER is member of 'docker'${NC}"
else
echo -e "${X_MARK} ${CYAN}User $USER is not member of 'docker'${NC}"
fi

b_status=$(zelbench-cli getstatus | jq '.benchmarking')
zelback=$(zelbench-cli getstatus | jq '.zelback')

good_zelback='"connected"'
good_benchamrk1='"BASIC"'
good_benchamrk2='"SUPER"'
good_benchamrk3='"BAMF"'
failed_benchamrk='"failed"'

if [[ "$b_status"  == "$good_benchamrk1" || "$b_status"  == "$good_benchamrk2" || "$b_status"  == "$good_benchamrk3" ]]
then
echo -e "${CHECK_MARK} ${CYAN}Benchmark [OK]($b_status)${NC}"
else
BTEST="1"
echo -e "${X_MARK} ${CYAN}Benchmark [Failed]${NC}"

bench_status=$(zelbench-cli getbenchmarks | jq '.status')
if [[ "$bench_status" == "$failed_benchamrk" ]] 
then
lc_numeric_var=$(locale | grep LC_NUMERIC | sed -e 's/.*LC_NUMERIC=//')
lc_numeric_need='"en_US.UTF-8"'

if [ "$lc_numeric_var" == "$lc_numeric_need" ]
then
echo -e "${CHECK_MARK} ${CYAN}LC_NUMERIC is correct${NC}"
else
echo -e "${X_MARK} ${CYAN}You need set LC_NUMERIC to en_US.UTF-8${NC}"
LC_CHECK="1"
fi
fi

check_benchmarks "eps" "89.99" "CPU speed" "< 90.00 events per second"
check_benchmarks "ddwrite" "159.99" "Disk write speed" "< 160.00 events per second"

fi

if [ "$good_zelback" == "$zelback" ]
then
echo -e "${CHECK_MARK} ${CYAN}ZelBack is working${NC}"
else
echo -e "${X_MARK} ${CYAN}ZelBack is not working${NC}"
fi

if [[ $(curl -s --head "$WANIP:16126" | head -n 1 | grep "200 OK") ]]
then
echo -e "${CHECK_MARK} ${CYAN}ZelFront is working${NC}"
else
echo -e "${X_MARK} ${CYAN}ZelFront is not working${NC}"
fi

if [ -d ~/zelflux ]
then
FILE=~/zelflux/config/userconfig.js
if [ -f "$FILE" ]
then
echo -e "${CHECK_MARK} ${CYAN}Zelflux config  ~/zelflux/config/userconfig.js exists${NC}"

ZELIDLG=`echo -n $(grep -w zelid ~/zelflux/config/userconfig.js | sed -e 's/        zelid: .//') | wc -m`
if [ "$ZELIDLG" -eq "36" ]
then
echo -e "${CHECK_MARK} ${CYAN}Zel ID is valid${NC}"
else
echo -e "${X_MARK} ${CYAN}Zel ID is not valid${NC}"
fi

else
FLUXCONF="1"
    echo -e "${X_MARK} ${CYAN}Zelflux config ~/zelflux/config/userconfig.js does not exists${NC}"
fi

else
    echo -e "${X_MARK} ${CYAN}Directory ~/zelflux does not exists${CYAN}"
fi

url_to_check="https://explorer.zel.cash/api/tx/$zelnodeoutpoint"
conf=$(wget -nv -qO - $url_to_check | jq '.confirmations')

if [[ $conf == ?(-)+([0-9]) ]]
then
if [ "$conf" -ge "100" ]
then
echo -e "${CHECK_MARK} ${CYAN}Confirmations numbers >= 100($conf)${NC}"
else
echo -e "${X_MARK} ${CYAN}Confirmations numbers < 100($conf)${NC}"
fi
else
echo -e "${X_MARK} ${CYAN}Zelnodeoutpoint is not valid or explorer.zel.cash is unavailable${NC}"
fi

if [[ $(ping -c1 $(hostname | grep .) | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p') =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
        echo -e "${CHECK_MARK} ${CYAN}IP detected successful ${NC}"
else
        echo -e "${X_MARK} ${CYAN}IP was not detected try edit /etc/hosts and add there 'your_external_ip hostname' your hostname is $(hostname) ${RED}(only if zelback status is disconnected)${CYAN}"
fi

if [[ $(tmux ls) == *"created"* ]]
then
echo -e "${CHECK_MARK} ${CYAN}Tmux session exists${NC}"
else
echo -e "${X_MARK} ${CYAN}Tmux session does not exists (prabobly zelflux is not correctly installed)${NC}"
fi

echo -e "${YELLOW}=====================================================${NC}"

if [[ "$REPLACE" == "1" ]]
then
read -p "Would you like to correct zelcash.conf errors Y/N?" -n 1 -r
echo -e ""
if [[ $REPLY =~ ^[Yy]$ ]]
then

if [[ "zelnodeprivkey=$zelnodeprivkey" == $(grep -w zelnodeprivkey ~/.zelcash/zelcash.conf) ]]
then
echo -e "\c"
        else
        sed -i "s/$(grep -e zelnodeprivkey ~/.zelcash/zelcash.conf)/zelnodeprivkey=$zelnodeprivkey/" ~/.zelcash/zelcash.conf
                if [[ "zelnodeprivkey=$zelnodeprivkey" == $(grep -w zelnodeprivkey ~/.zelcash/zelcash.conf) ]]
                then
                        echo -e "${GREEN}Zelnodeprivkey replaced successful!!!${NC}"
                fi
fi
if [[ "zelnodeoutpoint=$zelnodeoutpoint" == $(grep -w zelnodeoutpoint ~/.zelcash/zelcash.conf) ]]
then
echo -e "\c"
        else
        sed -i "s/$(grep -e zelnodeoutpoint ~/.zelcash/zelcash.conf)/zelnodeoutpoint=$zelnodeoutpoint/" ~/.zelcash/zelcash.conf
                if [[ "zelnodeoutpoint=$zelnodeoutpoint" == $(grep -w zelnodeoutpoint ~/.zelcash/zelcash.conf) ]]
                then
                        echo -e "${GREEN}Zelnodeoutpoint replaced successful!!!${NC}"
                fi
fi
if [[ "zelnodeindex=$zelnodeindex" == $(grep -w zelnodeindex ~/.zelcash/zelcash.conf) ]]
then
echo -e "\c"
        else
        sed -i "s/$(grep -w zelnodeindex ~/.zelcash/zelcash.conf)/zelnodeindex=$zelnodeindex/" ~/.zelcash/zelcash.conf
                if [[ "zelnodeindex=$zelnodeindex" == $(grep -w zelnodeindex ~/.zelcash/zelcash.conf) ]]
                then
                        echo -e "${GREEN}Zelnodeindex replaced successful!!!${NC}"
                fi
echo -e "${YELLOW}=====================================================${NC}"
fi
fi
fi
if [[ "$FLUXCONF" == "1" ]]
then
read -p "Would you like to create zelflux userconfig.js Y/N?" -n 1 -r
echo -e ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
while true
do
zel_id="$(whiptail --title "ZelNode ANALIZER/FiXER $SCVESION" --inputbox "Enter your ZEL ID from ZelCore (Apps -> Zel ID (CLICK QR CODE)) " 8 72 3>&1 1>&2 2>&3)"
if [ $(printf "%s" "$zel_id" | wc -c) -eq "34" ]
then
echo -e "${CHECK_MARK} ${CYAN}Zel ID is valid${NC}"
break
else
echo -e "${X_MARK} ${CYAN}Zel ID is not valid try again...${NC}"
sleep 4
fi
done

touch ~/zelflux/config/userconfig.js
    cat << EOF > ~/zelflux/config/userconfig.js
module.exports = {
      initial: {
        ipaddress: '$WANIP',
        zelid: '$zel_id',
        testnet: false
      }
    }
EOF
FILE1=~/zelflux/config/userconfig.js
if [ -f "$FILE1" ]
then
    echo -e "${CHECK_MARK} ${CYAN}File ~/zelflux/config/userconfig.js created successful${NC}${NC}"
else
    echo -e "${X_MARK} ${CYAN}File ~/zelflux/config/userconfig.js file create failed${NC}"
fi
fi
fi

FILE2="/home/$USER/update-zelflux.sh"
if [ -f "$FILE2" ]
then
echo -e "\c"
else
echo -e "${YELLOW}=====================================================${NC}"
read -p "Would you like to add auto-update zelflux via crontab Y/N" -n 1 -r
echo -e ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "cd /home/$USER/zelflux" >> "/home/$USER/update-zelflux.sh"
echo "git pull" >> "/home/$USER/update-zelflux.sh"
chmod +x "/home/$USER/update-zelflux.sh"
(crontab -l -u "$USER" 2>/dev/null; echo "0 0 * * 0 /home/$USER/update-zelflux.sh") | crontab -

if [[ $(crontab -l | grep -i update-zelflux) ]]
then
echo -e "${CHECK_MARK} ${CYAN}Zelflux auto-update was installed successfully${NC}"
else
echo -e "${X_MARK} ${CYAN}Zelflux auto-update installation has failed${NC}"
fi

fi
fi

if [[ "$LC_CHECK" == "1" ]]
then
echo -e "${YELLOW}=====================================================${NC}"
read -p "Would you like to change LC_NUMERIC to en_US.UTF-8 Y/N?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
sudo bash -c 'echo "LC_NUMERIC="en_US.UTF-8"" >>/etc/default/locale'
echo -e ""
echo -e "${CHECK_MARK} ${CYAN}LC_NUMERIC changed to en_US.UTF-8 now you need restart pc${NC}"
echo -e "${YELLOW}=====================================================${NC}"
read -p "Would you like to reboot pc Y/N?" -n 1 -r
echo -e "${NC}"

if [[ $REPLY =~ ^[Yy]$ ]]
then
sudo reboot -n
fi

fi
fi

if [[ "$BTEST" == "1" ]]
then
echo -e "${YELLOW}=====================================================${NC}"
read -p "Would you like to restart node benchmarks Y/N?" -n 1 -r
echo -e ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
zelbench-cli restartnodebenchmarks
sleep 50
echo -e "${NC}"
echo -e "${YELLOW}Checking benchmarks details...${NC}"
zelbench-cli getbenchmarks
fi
fi
