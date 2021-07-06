declare -A settings

ho=$HOME
if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; fi
fb_folder=$ho/fritzbox

settings=(
[wlanconfig1]=NewEnable
[deviceinfo]=NewSoftwareVersion
)
# echo $settings[$url]

change_enable(){
    value=$(cat $fb_folder/setenable.xml| sed -n 's/.\+\([01]\).\+/\1/p')
    value=$(echo 1-$value|bc)

    sed -i "s/[01]/$value/" $fb_folder/setenable.xml
    # echo $value
    # echo 1 >>setenable.xml
}

fb () {
    # local url=$1
    local action=$1
    # echo $url $action

    ho=$HOME
    if [[ $HOST == tik ]]; then ho=/mnt/c/Users/User; fi
    fb_folder=$ho/fritzbox
      
    urlnew=wlanconfiguration
    if [[ $url == 'deviceinfo' ]];then
        urlnew=$url
    fi
    xml=$fb_folder/$action.xml

    # grep_=NewEnable
    result=$(curl http://192.168.178.1:49000/upnp/control/$url -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$urlnew:1#$action -d @$fb_folder/$action.xml -s)
    # $a=5
    result=$(echo "$result" | grep $settings[$url] )
    echo $result | awk -F'>' '{print $2}' | awk -F'<' '{print $1}'
}
# change_enable

url=wlanconfig1
url=deviceinfo

# fb setenable

fb getinfo