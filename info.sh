control=upnp/control
service=urn:dslforum-org:service

location=$control/wlanconfig1
uri=$service:wlanconfiguration:1
action=setenable

location=$control/deviceinfo
uri=$service:deviceinfo:1
action=getinfo

grep_=NewSSID
grep_=NewEnable

ho=$HOME
if [[ $HOSTNAME == tik ]]; then ho=/mnt/c/Users/User; fi

fb=$ho/fritzbox

curlOutput=$(curl "http://192.168.178.1:49000/$location" -H 'Content-Type: text/xml' -H "soapaction:$uri#$action" -d @$fb/$action.xml -s)
#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
# -s >/dev/null

echo $curlOutput
# echo $fb
