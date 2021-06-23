# zeile 370 fritzboxshell.sh
location=/upnp/control/wlanconfig1
uri=urn:dslforum-org:service:WLANConfiguration:1
action=setenable
# action=getinfo
grep_=NewSSID
grep_=NewEnable

ho=$HOME
if [[ $HOSTNAME == tik ]];then ho=/mnt/c/Users/User ; fi

fb=$ho/fritzbox

curlOutput=$(curl "http://192.168.178.1:49000/upnp/control/deviceinfo" -H 'Content-Type: text/xml' -H "soapaction:urn:dslforum-org:service:DeviceInfo:1#$action" -d @$fb/$action.xml )

curlOutput=$(curl "http://192.168.178.1:49000/upnp/control/wlanconfig1" -H 'Content-Type: text/xml' -H "SoapAction:urn:dslforum-org:service:WLANConfiguration:1#$action" -d @$fb/$action.xml -s) 
#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
# -s >/dev/null

echo $curlOutput