
# Write-Output $fb_folder
action='getinfo'
# $action='setenable'
# $url='wlanconfig1'
url='deviceinfo'

fb () {
    control='http://192.168.178.1:49000/upnp/control'
    service='urn:dslforum-org:service'

    ho=$HOME
    if [[ $HOSTNAME == tik ]]; then ho=/mnt/c/Users/User; fi
    fb_folder=$ho/fritzbox
      
    location="$control/$1"
    urlnew='wlanconfiguration'
    if [[$url == 'deviceinfo' ]];then
        $urlnew=$url
    fi
    uri=$service:$urlnew:1#
    xml="$fb_folder/$2.xml"

    result=$(curl $location -H 'Content-Type:text/xml' -H "soapaction:$uri" -d @$xml -s)
    
    echo $result
}
fb $url $action

# grep_=NewSSID
# grep_=NewEnable
#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
    # -s >/dev/null
