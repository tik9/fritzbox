declare -A settings

ho=$HOME
if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; fi
fb_folder=$ho/fritzbox

settings=(
[wlanconfig1]=NewEnable
[deviceinfo]=NewSoftwareVersion
)
# echo $settings[$service]

change_enable(){
    value=$(cat $fb_folder/setenable.xml| sed -n 's/.\+\([01]\).\+/\1/p')
    value=$(echo 1-$value|bc)

    sed -i "s/[01]/$value/" $fb_folder/setenable.xml
    service=wlanconfig1

    # fb setenable
    # echo $value
    # echo 1 >>setenable.xml
}

fb () {
    local action=$1
    # echo $service $action
    ip=http://192.168.178.1

    ho=$HOME
    if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; fi
    fb_folder=$ho/fritzbox
      
    servicenew=wlanconfiguration
    # servicenew=WANIPConnection
    
    if [[ $service == 'deviceinfo' ]];then
        servicenew=$service
    fi
    # echo $servicenew $service $action

    xml=$fb_folder/$action.xml

    result=$(curl $ip:49000/upnp/control/$service -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$servicenew:1#$action -d @$fb_folder/$action.xml -s)
    # echo $result
    result=$(echo "$result" | grep $settings[$service] )
    echo $result | awk -F'>' '{print $2}' | awk -F'<' '{print $1}'
}

test(){
    foo=str
    for (( i=0; i<${#foo}; i++ )); do echo "${foo:$i}"; done
}
test2(){
    num=123
    for((i=0;i<${#num};i++)); do ((sum+=${num:i})); done
    echo $sum
}
# change_enable
test2

service=wlanconfig1
service=deviceinfo
# service=WANCommonIFC1

# fb getinfo