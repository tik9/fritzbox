
$fb = "$($env:USERPROFILE)/fritzbox"
# Write-Output $fb
$action = 'getinfo'
$action = 'setenable'

$result = Invoke-WebRequest -Headers @{'soapaction' = 'urn:dslforum-org:service:DeviceInfo:1#getinfo' } -Method post `
    -InFile $fb/$action.xml -Uri http://192.168.178.1:49000/upnp/control/deviceinfo -ContentType text/xml


$result = Invoke-WebRequest -Headers @{'soapaction' = "urn:dslforum-org:service:WLANConfiguration:1#$action" } -infile $fb/$action.xml -Uri http://192.168.178.1:49000/upnp/control/wlanconfig1 -ContentType text/xml -Method Post


Write-Output $result | Select-Object content | Format-List