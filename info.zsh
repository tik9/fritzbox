
declare -A settings

fb () {
    action=$1
    boxip=192.168.178.1

    servicenew=wanipconnection
    servicenew=wlanconfiguration
    
    if [[ $service == 'deviceinfo' ]];then
        servicenew=$service
    fi

    # result=$(curl -s --anyauth -u $boxuser:$boxpw $boxip:49000/upnp/control/$service -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$servicenew:1#$action -d @$fb_folder/$action.xml )

    result=$(curl -s --anyauth -u fritz3220:$boxpw 192.168.178.1:49000/upnp/control/wlanconfig1 -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:wlanconfiguration:1#getinfo -d '<?xml?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope"><s:Body><u:getinfo></u:getinfo></s:Body></s:Envelope>' )


    result=$(echo "$result"| grep $settings[$service] )

    echo result $result 
    # | awk -F'>' '{print $2}' | awk -F'<' '{print $1}'
}

change_enable(){
    setenable=$fb_folder/setenable.xml
    echo seten $setenable

    value_pre=$(cat $setenable| sed -n -r 's/.+([01]).+/\1/p')
    echo val pre $value_pre
    value=$(echo 1-$value_pre|bc)
    echo val post $value

    sed -i '' "s/[01]/$value/" $setenable

}

fb_folder=$HOME/fritzbox

boxuser=fritz3220
boxpw=$(cat $fb_folder/env)

settings=(
[wlanconfig1]=NewEnable
[deviceinfo]=NewSoftwareVersion
)

service=deviceinfo
service=wlanconfig1
# service=WANCommonIFC1

# change_enable
# fb setenable
fb getinfo