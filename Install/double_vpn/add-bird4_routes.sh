#!/bin/sh

 #USER VARIABLE
ISP=ISPINPUT
#ISP_GW=$(ip route | grep -m 1 -E "via.*$ISP" | awk '{print $3}')
VPN1=VPN1INPUT
VPN2=VPN2INPUT
URLS="URLINPUT"

 #SCRIPT VARIABE
HOMEPATH=HOMEFOLDERINPUT

source $HOMEPATH/scripts/func.sh

 #GET INFO ABOUT SCRIPT
get_info_func $1

 #INIT FILES
WORK_FILES="$BLACKLIST \
            $ROUTE_FORCE_ISP $ROUTE_FORCE_VPN1 $ROUTE_FORCE_VPN2 \
            $ROUTE_BASE_VPN $ROUTE_USER_VPN \
            $MD5_SUM"
INIT=$1
init_files_func $WORK_FILES

 #WAIT DNS
wait_dns_func

 #CHECK AND REPLACE VPN IN BIRD CONF
vpn_bird_func $BIRD_CONF $VPN1 $VPN2

 #BASE_LIST
curl_funk $URLS $BLACKLIST | diff_funk $BLACKLIST -
ipr_func lo $BLACKLIST | diff_funk $ROUTE_BASE_VPN -

 #BASE_USER_LIST
ipr_func lo $VPNTXT | diff_funk $ROUTE_USER_VPN -

 #FORCE_LIST
if [ ! -z "$ISP_GW" ]; then ISP=$ISP_GW; fi
ipr_func $ISP $ISPTXT | diff_funk $ROUTE_FORCE_ISP -
ipr_func $VPN1 $VPN1TXT | diff_funk $ROUTE_FORCE_VPN1 -
ipr_func $VPN2 $VPN2TXT | diff_funk $ROUTE_FORCE_VPN2 -

 #RESTART BIRD
restart_bird_func

 #CHECK DUPLICATE
check_dupl_func
