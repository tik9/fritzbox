# zeile 370 fritzboxshell.sh
location="/upnp/control/wlanconfig1"
uri=urn:dslforum-org:service:WLANConfiguration:1
action=SetEnable
option=1
source config.sh
# echo $boxip

curl -k -m 5 "http://$boxip:49000/upnp/control/wlanconfig1" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'><NewEnable>$option</NewEnable></u:$action></s:Body></s:Envelope>" -s >/dev/null

# timokoe ist 1
action=GetInfo
curlOutput1=$(curl -s -k -m 5 "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" | grep NewEnable | awk -F">" '{print $2}' | awk -F"<" '{print $1}')

curlOutput2=$(curl -s -k -m 5 "http://$boxip:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" | grep NewSSID | awk -F">" '{print $2}' | awk -F"<" '{print $1}')

echo "2,4 Ghz $curlOutput2 ist $curlOutput1"