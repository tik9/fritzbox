
# $Global:fb_folder = "$env:USERPROFILE/fritzbox"
$fb_folder = "$env:USERPROFILE/fritzbox"
$newen = 'Enable>'

function change_enable() {
    $xml = "$fb_folder/setenable.xml"
    $xmlcontent = Get-Content $xml
    $matches = $xmlcontent | Select-String('(' + $newen + ')([01])') -AllMatches | Foreach-Object { $_.Matches } 

    $groups = $matches | Foreach-Object { $_.Groups }
    $value = $groups[2].value
    $value = 1 - $value
    $xmlcontent -replace "$newen[01]", "$newen$value" | Out-File $xml
    
}

function fb ($url, $action) {
    
    $url_ = 'wlanconfiguration'
    if ($url -eq 'deviceinfo') {
        $url_ = $url
    }

        $result = Invoke-WebRequest "http://192.168.178.1:49000/upnp/control/$url" -Headers @{'soapaction' = 'urn:dslforum-org:service:' + $url_ + ':1#' + $action } -Method post -InFile "$fb_folder/$action.xml" -ContentType text/xml

        return ($result | Select-Object content)
}
function parse_info($response, $key) {
    $xml = $response
    # Write-Host $xml
    # $xml = $xml.Content
    [xml]$xml = $xml.Content

    return $xml.envelope.body.getinforesponse.$key
}

$seten = 'setenable'
# change_enable($seten)
# $xml = fb 'wlanconfig1' $seten

$sett = 'wlanconfig1'
# $sett = 'deviceinfo'
$xml = fb $sett 'getinfo'

$settings = @{deviceinfo = 'newsoftwareversion'; wlanconfig1 = 'newenable' }
$xml = parse_info $xml $settings.$sett
Write-Host($xml)