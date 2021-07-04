
# Write-Output $fb_folder
action=getinfo
action=setenable
url=deviceinfo
url=wlanconfig1

fb () {

    ho=$HOME
    if [[ $HOSTNAME == tik ]]; then ho=/mnt/c/Users/User; fi
    fb_folder=$ho/fritzbox
      
    # location="$control/$1"
    urlnew=wlanconfiguration
    if [[ $url == 'deviceinfo' ]];then
        urlnew=$url
    fi
    # uri=urn:dslforum-org:service:$urlnew:1#
    xml=$fb_folder/$action.xml

    result=$(curl http://192.168.178.1:49000/upnp/control/$url -H Content-Type:text/xml -H soapaction:urn:dslforum-org:service:$urlnew:1#$action -d @$fb_folder/$action.xml -s)
    
    echo $result
}
fb

# grep_=NewSSID
# grep_=NewEnable
#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
    # -s >/dev/null
