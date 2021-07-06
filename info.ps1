
$fb_folder = "$env:USERPROFILE/fritzbox"
$newen = 'Enable>'

function change_enable() {
    $xml = "$fb_folder/setenable.xml"
    $xmlcontent = Get-Content $xml

    $match = $xmlcontent | Select-String('([01])') -AllMatches | Foreach-Object { $_.Matches } 
    
    $groups = $match | Foreach-Object { $_.Groups }
    # Write-Host $match
    $value = $groups[0].value
    $value = 1 - $value
    $xmlcontent -replace "$newen[01]", "$newen$value" | Out-File $xml
    
}

function fb ($url, $action) {
    
    $settings = @{deviceinfo = 'newsoftwareversion'; wlanconfig1 = 'newenable' }
    
    $url_ = 'wlanconfiguration'
    if ($url -eq 'deviceinfo') {
        $url_ = $url
    }

    $response = Invoke-WebRequest "http://192.168.178.1:49000/upnp/control/$url" -Headers @{'soapaction' = 'urn:dslforum-org:service:' + $url_ + ':1#' + $action } -Method post -InFile "$fb_folder/$action.xml" -ContentType text/xml

    [xml]$xml = $response
    # Write-Host $xml
    return $xml.envelope.body.getinforesponse.$($settings.$url)
}

change_enable

$url = 'deviceinfo'
$url = 'wlanconfig1'

# $xml = fb $url 'setenable'
$xml = fb $url 'getinfo'
Write-Host($xml)

