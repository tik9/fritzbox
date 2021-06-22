uri=urn:dslforum-org:service:DeviceInfo:1
action=getinfo
source config.sh
### -- General function for sending the SOAP request via TR-064 Protocol - called from other functions -- ###

curlOutput1=$(curl -s -k -m 5 "http://192.168.178.1:49000/upnp/control/deviceinfo" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:urn:dslforum-org:service:DeviceInfo:1#getinfo" -d "<?xml version='1.0' encoding='utf-8'?>
<s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'>
<s:Body>
<u:getinfo>
</u:getinfo>
</s:Body>
</s:Envelope>" | grep "<New"| 
awk -F"</" '{print $1}' |
sed -En "s/<(.*)>(.*)/\1 \2/p")

echo "$curlOutput1"
