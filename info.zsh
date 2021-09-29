# curl "http://fritz.box:49000/upnp/control/WANIPConn1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#GetExternalIPAddress" -d "<?xml version='1.0' encoding='utf-8'?> <s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'> <s:Body> <u:GetExternalIPAddress xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1" /> </s:Body> </s:Envelope>" -s | grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>'

declare -A settings

user=fritz3220

ho=$HOME
do=Dokumente
if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; do=documents fi
fb_folder=$ho/fritzbox
setenable=$fb_folder/setenable.xml

p=$(cat $ho/$do/irule)

# echo passw $p

settings=(
[wlanconfig1]=NewEnable
[deviceinfo]=NewSoftwareVersion
)
# echo $settings[$service]

change_enable(){
    value=$(cat $setenable| sed -n 's/.\+\([01]\).\+/\1/p')
    value=$(echo 1-$value|bc)

    sed -i "s/[01]/$value/" $setenable
    service=wlanconfig1

    fb setenable
    # echo $value
    # echo 1 >>setenable.xml
}

fb () {
    local action=$1
    # echo $service $action
    ip=http://192.168.178.1
      
    servicenew=wlanconfiguration
    # servicenew=WANIPConnection
    
    if [[ $service == 'deviceinfo' ]];then
        servicenew=$service
    fi
    # echo $servicenew $service $action

    xml=$fb_folder/$action.xml

    result=$(curl --anyauth $ip:49000/upnp/control/$service -u $user:$p -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$servicenew:1#$action -d @$xml -s)
    # echo $result
    result=$(echo "$result"| grep $settings[$service] )
    echo result $result 
    # | awk -F'>' '{print $2}' | awk -F'<' '{print $1}'
}


service=wlanconfig1
# service=deviceinfo
# service=WANCommonIFC1

# fb getinfo
# change_enable
fb getinfo