
declare -A settings

change_enable(){
    setenable=$fb_folder/setenable.xml
    
    value_pre=$(cat $setenable| sed -n -r 's/.+([01]).+/\1/p')
    echo val pre $value_pre
    value=$(echo 1-$value_pre|bc)

    sed -i "s/[01]/$value/" $setenable

    fb setenable
}

ho=$HOME
do=Dokumente
if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; do=documents fi
fb_folder=$ho/fritzbox

boxuser=fritz3220
boxpw=$(cat $ho/$do/irule)

settings=(
[wlanconfig1]=NewEnable
[deviceinfo]=NewSoftwareVersion
)

# change_enable

fb () {
    action=$1
    ip=http://192.168.178.1
    echo service $service
    servicenew=wlanconfiguration
    # servicenew=WANIPConnection
    
    if [[ $service == 'deviceinfo' ]];then
        servicenew=$service
    fi

    result=$(curl --anyauth -u $boxuser:$boxpw $ip:49000/upnp/control/$service -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$servicenew:1#$action -d @$fb_folder/$action.xml -s)

    result=$(echo "$result"| grep $settings[$service] )

    echo result $result 
    # | awk -F'>' '{print $2}' | awk -F'<' '{print $1}'
}


service=deviceinfo
service=wlanconfig1
# service=WANCommonIFC1

change_enable
# fb setenable
fb getinfo