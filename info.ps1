
# $Global:fb_folder = "$env:USERPROFILE/fritzbox"
$fb_folder = "$env:USERPROFILE/fritzbox"
$newen = '<NewEnable>'
$close_newen = '</NewEnable>'

function changeenable() {
    $xml = "$fb_folder/setenable.xml"
    $xmlcontent = Get-Content $xml
    # Write-Output $xmlcontent
    $newen = 'Newenable>'
    $matches = $xmlcontent | Select-String('(' + $newen + ')([01])') -AllMatches | Foreach-Object { $_.Matches } 

    $groups = $matches | Foreach-Object { $_.Groups }
    $value = $groups[2].value
    $value = 1 - $value
    Write-Host $value
    $xmlcontent -replace '(' + $newen + ')([01]', '$1$value' | Out-File $xml
    
}

changeenable

function regex($action) {
    $xml = "$fb_folder/$action.xml"
    # Get-Item $xml

    $xmlcontent = Get-Content $xml
    Write-Output $xmlcontent
    
    $xmlcontent -replace '(<NewEnable>)1(</NewEnable>)', '${1}0$2' | Out-File $xml
    # $xmlcontent -replace '"(<NewEnable>)1(</NewEnable>)"', '$1.$2' | Out-File $xml
}
function fb ($url, $action) {

    $control = 'http://192.168.178.1:49000/upnp/control'
    $service = 'urn:dslforum-org:service'
      
    $location = "$control/$url"
    if ($url -eq 'deviceinfo') {
        $url_ = $url
    }
    else {
        $url_ = 'wlanconfiguration'
    }

    $uri = $service + ':' + $url_ + ':1#'

    $xml = "$fb_folder/$action.xml"

    $result = Invoke-WebRequest $location -Headers @{'soapaction' = $uri + $action } -Method post -InFile $xml -ContentType text/xml

    Write-Output $result | Select-Object content | Format-List
    # $global:test=2
    # $test2=2

}
$action = 'getinfo'
$url = 'deviceinfo'
# fb $url $action
$action = 'setenable'
# regex $action
$url = 'wlanconfig1'
# fb $url $action
$action = 'getinfo'
# fb $url $action
# Write-Host $Global:test
# Write-Host $test2

# ho=$HOME
# if [[ $HOSTNAME == tik ]]; then ho=/mnt/c/Users/User; fi
# grep_=NewSSID
# grep_=NewEnable

#  | grep $grep_  | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
# -s >/dev/null
