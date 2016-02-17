#!/bin/ash
#
# Copyright 2013 Servicio Andaluz de Salud / Junta de Andalucia
# Author Gerardo Puerta Cardelles <gerardo.puerta@juntadeandalucia.es>
# v0.1
# Licensed under the EUPL, Version 1.1 or - as soon they
# will be approved by the European Commission - subsequent
# versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the
# Licence.
# You may obtain a copy of the Licence at:
#
# http://ec.europa.eu/idabc/eupl
#
# Unless required by applicable law or agreed to in
# writing, software distributed under the Licence is
# distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.
# See the Licence for the specific language governing
# permissions and limitations under the Licence.
#

debug="False"
dmidecode="/usr/sbin/dmidecode"
invfile="/etc/sysconfig/logistica.info"
if [ ! -e $invfile ]; then
    touch $invfile
fi
debug() {
    if [ "${debug}" == "True" ]; then
        echo "$2: "
        eval echo "$1 = \$$1"
	echo ""
    fi
}

exec_to_var() {
    tmp=$(eval $1)
    return=$?
    eval ${2}=\$tmp 
    if [ "$return" -eq 0 ]; then
        return $return
    fi
    debug $2 $0
    return 1
}

get_parm(){
    num_p=$(($i / 2))
    num_p=$(($num_p - 1))
    for j in $(seq 0 ${num_p}); do
        n_parm=$(( $j * 2))
        n_cont=$(( ${n_parm} + 1))
        eval parm=\$parm_${n_parm}
        if [ "$(echo $parm | grep $1)" != "" ]; then
            eval $parm=\$parm_${n_cont}
            return 0
        fi
    done
    return 1
}

dmidecode_type() {
    eval ${1}='"$($dmidecode -t $1)"'
    ret=$?
    debug $1 $FUNCNAME
    return $ret
}

dmidecode_string() {
    eval ${1//-/_}='"$($dmidecode -s $1)"'
    ret=$?
    debug $1 $FUNCNAME
    return $ret
}

get_resolution() {
#    cmd="grep Modeline /var/log/Xorg.0.log 2>&1 | grep current | cut -d ' ' -f 15,20 | awk '{printf $1 \"x\" $2}'"
    exec_to_var "grep Modeline /var/log/Xorg.0.log 2>&1 | grep current | cut -d ' ' -f 15,20 | awk '{printf \$1 \"x\" \$2}'" resolucion
    return $?
}

disk_info() {
    tmp=""
    for file in $(find /sys/block/[sh][dr]*/device/ /sys/block/[sh][dr]*/ -maxdepth 1 2>/dev/null|egrep '(vendor|model|/size|/sys/block/[sh][dr]./$)'|sort); do 
    [ -d $file ] && tmp="$tmp\n -- DEVICE $(basename $file) --" && continue; tmp="tmp $(grep -H . $file|sed -e 's|^/sys/block/||;s|/d*e*v*i*c*e*/*\(.*\):| \1 |'|awk '{if($2 == "size") {printf "%-3s %-6s: %d MB\n", $1,$2,(($3 * 512)/1048576)} else {printf "%-3s %-6s: ", $1,$2;for(i=3;i<NF;++i) printf "%s ",$i;print $(NF) };}')"
    done
    eval ${1}=\$tmp
    ret=$?
    debug $1 $FUNCNAME
    return $ret
}

process_running() {
    tmp=$(ps -ef | grep $1 | grep -v grep)
    [ $? -eq "0" ] && eval ${1}="Online" || eval ${1}="Offline"
    debug $1 $FUNCNAME
    return 0
}

uname() {
    eval ${1}=$(/bin/uname -$2) 
    ret=$?
    debug $1 $FUNCNAME
    return $?
}

set_hostname() {
    stat=0
    host=$1
    hostsfile="/etc/hosts"
    hostnamefile="/etc/sysconfig/hostname"
    echo $host > $hostnamefile
    hostname -F $hostnamefile
    stat=$(($? + $stat))
    return $stat
}

set_code() {
    stat=0
    sascode=$1
    invfile="/etc/sysconfig/logistica.info"
    [ -e $invfile ] && line=`grep :log_term_inven: $invfile`
    if [ $? -ne 0 ]; then
        echo "Numero de inventario del terminal:log_term_inven:$sascode" >> $invfile
        stat=$?
    else
        sed -i "s/$line/Numero de inventario del terminal:log_term_inven:$sascode/g" $invfile
        stat=$?
    fi
    return $stat
}

set_location() {
    stat=0
    get_urldecoded $1 loc
    invfile="/etc/sysconfig/logistica.info"                                                                                                           
    [ -e $invfile ] && line=`grep :log_term_location: $invfile`                                                                                          
    if [ $? -ne 0 ]; then                                                                                                                             
        echo "Localizacion del terminal:log_term_location:$loc" >> $invfile                                                                  
        stat=$?                                                                                                                                       
    else                                                                                                                                              
        sed -i "s/$line/log_term_location:log_term_location:$loc/g" $invfile                                                         
        stat=$?                                                                                                                                       
    fi                                                                                                                                                
    return $stat
}

set_contactphone() {
    stat=0                                                                                                                                            
    get_urldecoded $1 phone                                                                                                                                           
    invfile="/etc/sysconfig/logistica.info"                                                                                                           
    [ -e $invfile ] && line=`grep :log_term_contactphone: $invfile`                                                                                       
    if [ $? -ne 0 ]; then                                                                                                                             
        echo "Telefono de contacto en ubicaion:log_term_contactphone:$phone" >> $invfile                                                                           
        stat=$?                                                                                                                                       
    else                                                                                                                                              
        sed -i "s/$line/Telefono de contacto en ubicaion:log_term_contactphone:$phone/g" $invfile                                                                          
        stat=$?                                                                                                                                       
    fi                                                                                                                                                
    return $stat                                                                                                                                      
}

set_res() {
    stat=0
    echo "RESOLUTION=\"$1\"" > /etc/sysconfig/resolution.info
    #if [ "$2" == "" ]; then
    #    xinitrcfile="/etc/skel/.xinitrc"                
    #else                                                  
    #    xinitrcfile="/home/$2/.xinitrc"
    #fi                                                   
    #line1=`grep xrandr $xinitrcfile | grep default`
    #line2=`grep xrandr $xinitrcfile | grep VGA`
    #sed -i "s/$line1/xrandr --output default --mode $1/g" $xinitrcfile
    #sed -i "s/$line2/xrandr --output VGA-0 --mode $1/g" $xinitrcfile                                               
    stat=$?
    return $stat
}

set_net() {
    netfile="/etc/sysconfig/networkinterfaces"
    if [ "$1" == "dhcp" ]; then
        echo "auto eth0" > $netfile
        echo "iface eth0 inet dhcp" >> $netfile
	if [ "$2" == "true" ]; then
		echo "  force-link $2" >> $netfile
	else
		echo "  force-link false" >> $netfile
	fi
	if [ "$3" == "true" ]; then                                                                                                                   
                echo "  change-mac $3" >> $netfile                                                                                                    
        else                                                                                                                                          
                echo "  change-mac false" >> $netfile                                                                                                 
        fi
    else
        echo "auto eth0" > $netfile
        echo "iface eth0 inet static" >> $netfile
	echo "  force-link $2" >> $netfile
	echo "  change-mac $3" >> $netfile
        echo "  address $4" >> $netfile
        echo "  netmask $5" >> $netfile
        echo "  gateway $6" >> $netfile
	[ "$7" != "" ] && get_urldecoded $7 nameserv
        echo "  dns-nameservers $nameserv" >> $netfile
        [ "$8" != "" ] && get_urldecoded $8 dsearch && echo "  dns-search $dsearch" >> $netfile
    fi
    return 0
}

assignProxy(){
        PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
        for envar in $PROXY_ENV
        do
            export $envar=$1
        done
        for envar in "no_proxy NO_PROXY"
        do
            export $envar=$2
        done
        return 0
}

clrProxy(){
        assignProxy "" ""# This is what 'unset' does.
        return $?
}

SASProxy(){
        #user=YourUserName
        #read -p "Password: " -s pass &&  echo -e " "
        . /etc/proxy.conf
        if [ "$proxy_value" == "" ]; then
            clrProxy
        else
            assignProxy $proxy_value $no_proxy_value
        fi
        return $?
}

set_proxy() {
    pfile="/etc/proxy.conf"
    if [ "$1" == "" ]; then
        newproxy=""
    else
        newproxy=`echo -e $( echo $1 | sed -e 's/+/ /g;s/%\(..\)/\\\x\1/g;' )`
    fi
    line=`grep proxy_value /etc/proxy.conf | grep -v assignProxy | grep -v no_proxy`
    sed -i "s#${line}#proxy_value=\"${newproxy}\"#g" $pfile
    ret=$?
    sync
    return $ret
}

set_pexc() {
    pfile="/etc/proxy.conf"
    if [ "$1" == "" ]; then
        newpexc=""
    else
        newpexc=`echo -e $( echo $1 | sed -e 's/+/ /g;s/%\(..\)/\\\x\1/g;' )`
    fi
    line=`grep no_proxy_value /etc/proxy.conf | grep -v assignProxy | sed -e 's/\*/\\\*/g'`
    sed -i "s#${line}#no_proxy_value=\"${newpexc}\"#g" $pfile
    ret=$?
    sync
    return $ret
}

set_printertype() {
    prtfile="/etc/printers.conf"
    line=`grep UBICACION $prtfile`
    if [ "$line" != "" ]; then
	sed -i "s/$line/UBICACION\=\"${1}\"/g" $prtfile
	ret=$?
    fi
    return $ret
}

getpid(){
    apid=`pidof $1`
    if [ $? -ne 0 ]; then
        eval ${1}pid=0
    else
        eval ${1}pid=$( pidof $1 )
    fi
    return $?
}

restartservice(){
    case $1 in
        "slim" )
            [ $2 -ne 0 ] && kill -9 $2
            getpid "Xorg"
            restartservice "Xorg" $Xorgpid
            slim
            ret=$?
        ;;
        "Xorg" )
            [ $2 -ne 0 ] && kill -9 $2
            sleep 1
            ret=0
        ;;
        "dropbear" )
            [ $2 -ne 0 ] && kill -9 $2
            sleep 1
            /usr/sbin/dropbear > /dev/null 2>&1
            ret=$?
        ;;
        "xinetd" )
            [ $2 -ne 0 ] && kill -9 $2
            sleep 1
            /usr/sbin/xinetd
        ;;
        * )
            /etc/init.d/$1 restart > /dev/null 2>&1
        ;;
    esac
    return $ret
}

xinetd_process_active(){
    par=$1
    procc=`echo $par | tr '[:upper:]' '[:lower:]'`
    status=`grep disable /etc/xinetd.d/* | grep $procc | awk -F'=' '{print $2}' | awk '{print $1}'`
    port=`grep port /etc/xinetd.d/* | grep $procc | awk -F'=' '{print $2}' | awk '{print $1}'`
    if [ "$status" == "no" ]; then
	if [ "`netstat -atn 2> /dev/null | grep 0\.0\.0\.0:$port | grep LISTEN`" != "" ]; then 
	            eval ${par}status=\"Activado y escuchando en el puerto ${port}\"
        else
            eval ${par}status=\"Activado pero NO escuchando en el puerto ${port}\"
        fi
    else
        eval ${par}status="Desactivado"
    fi
    return $?
}

#altiris
#altirisp

#resolution
#dmidecode_string system-manufacturer
#dmidecode_string system-product-name
#dmidecode_string system-serial-number
#dmidecode_string bios-version
#dmidecode_string bios-release-date
#process_running slim
#process_running sshd
#process_running x11vnc
#process_running xinetd
#process_running httpd
#process_running altiris
#process_running lpd
#process_running ntpd

#OS version
get_os(){
    exec_to_var "/bin/uname -o" os
    return $?
}
get_hostname(){
    exec_to_var "hostname" hostname
    return $?
}

get_net_dns(){
    exec_to_var "cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2 | awk '{printf \$1 \" \"}'" dns
    return $?
}
get_net_domain(){
    exec_to_var "cat /etc/resolv.conf | grep search | cut -d' ' -f2-" domain
    return $?
}

#Network mode
get_net_mode() {
    exec_to_var "grep iface /etc/sysconfig/networkinterfaces | grep eth0 | awk '{print \$4}'" netmode
    if [ "$netmode" != "dhcp" ]; then
        netmode="manual"
    fi
    return $?
}

#IP
get_net_ip() {
    exec_to_var "ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'" ip
    return $?
}

#Netmask
get_net_mask() {
    exec_to_var "ifconfig | grep -Eo 'Mask:?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '255.0.0.0'" netmask
    return $?
}

#MAC (Ether)
get_net_mac() {
    exec_to_var "ifconfig | grep -Eo 'HWaddr ?([[:xdigit:]]*\:){5}[[:xdigit:]]*' | grep -Eo '([[:xdigit:]]*\:){5}[[:xdigit:]]*'" mac
    return $?
}

#GW
get_net_gw(){
    exec_to_var "route -n | grep UG | grep -v '127.0.0.1' | awk '{ print \$2 }'" gateway
    return $?
}

#Force-link
get_net_forcelink(){
    exec_to_var "grep force-link /etc/sysconfig/networkinterfaces | grep true | awk '{print \$2}'" forcelink
    return $?
}

#Change-mac
get_net_changemac(){
    exec_to_var "grep change-mac /etc/sysconfig/networkinterfaces | grep true | awk '{print \$2}'" changemac                                          
    return $?
}

#NTP
get_ntp_server() {
    exec_to_var "cat /etc/init.d/rcS | grep ntpd | awk '{ print \$4}'" ntp_server
    return $?
}

#Proxy
get_proxy(){
    exec_to_var "grep proxy_value /etc/proxy.conf | grep -v assignProxy | grep -v no_proxy | awk -F'=\"' '{print \$2}' | awk -F'\"' '{print \$1}'" proxy
    return $?
}

#Proxy exceptions
get_proxy_exceptions(){
    exec_to_var "grep no_proxy_value /etc/proxy.conf | grep -v assignProxy | awk -F'=\"' '{print \$2}' | awk -F'\"' '{print \$1}'" pexceptions
    return $?
}

#Printer type
get_printertype(){
    exec_to_var "grep UBICACION /etc/printers.conf | awk -F'=\"' '{print \$2}' | awk -F'\"' '{print \$1}'" printertype
    return $?
}

# Memory stat
get_memory_stat() {
    exec_to_var "free -m --si | grep Mem | awk '{t=\$2; u=(\$3*100); b=(\$6*100); c=(\$7*100); printf \"%2.0f\n\", (u/t)}'" mem_u
    ret=$?
    exec_to_var "free -m --si | grep Mem | awk '{t=\$2; u=(\$3*100); b=(\$6*100); c=(\$7*100); printf \"%2.0f\n\", ((c+f)/t)}'" mem_c
    ret=$(($ret + $?))
    mem_f=$((100 - $(($mem_u - $mem_c))))
    exec_to_var "free -m --si" mem_r
    ret=$(($ret + $?))
    return $ret
}

# CPU Stat
get_cpu_stat() {
    exec_to_var "busybox mpstat | grep all | awk '{printf \"%2.0f\n\", \$3}'" cpu_u
    ret=$?
    exec_to_var "busybox mpstat | grep all | awk '{printf \"%2.0f\n\", \$5}'" cpu_c
    ret=$(($ret + $?))
    cpu_f=$((100 - $(($cpu_u - $cpu_c))))
    exec_to_var "top -b -n 1" cpu_r
    ret=$(($ret + $?))
    return $ret
}

# HDD Stat
get_hdd_stat() {
    exec_to_var "df -h | grep -E ' /\$' | awk -F'%' '{printf \$1}' | awk '{printf \$NF}'" dis_u
    ret=$?
    exec_to_var "df -h | grep -E '^tmpfs' | awk -F'%' '{print \$1}' | awk '{a=a+\$NF}END{printf a}'" dis_c
    ret=$(($ret + $?))
    dis_f=$((100 - (($dis_u - $dis_c))))
    exec_to_var "df -h" dis_r
    ret=$(($ret + $?))
    return $ret
}

# Terminal Code
get_code() {
    exec_to_var "grep :log_term_inven: $invfile | awk -F':' '{printf \$3}'" code
    return $?
}

# Terminal location
get_location() {
    exec_to_var "grep :log_term_location: $invfile | awk -F':' '{printf \$3}'" location                                                                      
    return $?
}

# Terminal location                                                                                                                                   
get_contactphone() {                                                                                                                                      
    exec_to_var "grep :log_term_contactphone: $invfile | awk -F':' '{printf \$3}'" contactphone
    return $?                                                                                                                                         
}

# CPU
get_cpu_info() {
    exec_to_var "cat /proc/cpuinfo | grep model | grep name | awk -F':' '{print \$2}' | sed -e 's/^ //g'" cpumodel
    ret=$?
    exec_to_var "cat /proc/cpuinfo | grep vendor | grep id | awk -F':' '{print \$2}' | sed -e 's/^ //g'" cpuvendor
    ret=$(($ret + $?))
    exec_to_var "cat /proc/cpuinfo | grep MHz | grep cpu | awk -F':' '{print \$2}' | sed -e 's/^ //g'" cpufreq
    ret=$(($ret + $?))
    cpuinfo="$cpumodel $cpuvendor $cpufreq"
    return $ret
}

# RAM
get_ram_info(){
    exec_to_var "free -m | grep Mem | awk '{print \$2}'" raminfo
    return $?
}

# Swap
get_swap_info(){
    exec_to_var "free -m | grep Swap | awk '{print \$2}'" swapinfo
    return $?
}

# HDD
get_hdd_info(){
    exec_to_var "/usr/sbin/hwinfo --disk | grep Model | grep -v '\"Disk\"' | awk -F'\"' '{print \$2}'" hddinfo
    return $?
}

# NET
get_net_info(){
    exec_to_var "/usr/sbin/hwinfo --netcard | grep Model | awk -F'\"' '{print \$2}'" netinfo
    return $?
}

# Decode URL
get_urldecoded() {
    local url_encoded="${1//+/ }"                                                                                                                     
    url_decoded=`printf '%b' "${url_encoded//%/\\x}"`
    exec_to_var "echo $url_decoded" $2
}

valid_ip()
{
    local  ip=$1
    local  stat=1

    ip1=`echo $ip | awk -F'.' '{printf $1}'`
    ip2=`echo $ip | awk -F'.' '{printf $2}'`
    ip3=`echo $ip | awk -F'.' '{printf $3}'`
    ip4=`echo $ip | awk -F'.' '{printf $4}'`

    if [ "`echo $ip | awk '/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/'`" != "" ]; then
	ip0=`echo $ip | awk -F'.' '{printf $1}'`                                                                                                          
	ip1=`echo $ip | awk -F'.' '{printf $2}'`                                                                                                          
    	ip2=`echo $ip | awk -F'.' '{printf $3}'`                                                                                                          
    	ip3=`echo $ip | awk -F'.' '{printf $4}'`
        [ ${ip0} -le 255 ] && [ ${ip1} -le 255 ] && [ ${ip2} -le 255 ] && [ ${ip3} -le 255 ]
        stat=$?
    fi
    return $stat
}

