$Global:test = 1
$test2 = 1

function fb ($url, $action) {

    $control = 'http://192.168.178.1:49000/upnp/control'
    $service = 'urn:dslforum-org:service'
    $fb_folder = "$env:USERPROFILE/fritzbox"
      
    $location = "$control/$url"
    if ($url -eq 'deviceinfo') {
        $urlnew = $url
    }
    else {
        $urlnew = 'wlanconfiguration'
    }

    $uri = $service + ':' + $urlnew + ':1#'

    $xml = "$fb_folder/$action.xml"

    $result = Invoke-WebRequest $location -Headers @{'soapaction' = $uri + $action } -Method post -InFile $xml -ContentType text/xml

    Write-Output $result | Select-Object content | Format-List
    $global:test=2
    $test2=2

}
$action = 'setenable'
$url = 'wlanconfig1'
# fb $url $action
$action = 'getinfo'
fb $url $action
# $url = 'deviceinfo'
# Write-Host $Global:test
# Write-Host $test2

# ho=$HOME
# if [[ $HOSTNAME == tik ]]; then ho=/mnt/c/Users/User; fi
# grep_=NewSSID
# grep_=NewEnable

#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
# -s >/dev/null
