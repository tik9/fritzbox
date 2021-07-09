$ho="$env:USERPROFILE"

if ($hostname -eq 't--pc'){
    $ho='/home/tk'
}
$fb_folder = "$ho/fritzbox"

function change_enable() {
    $xml = "$fb_folder/setenable.xml"
    $xmlcontent = Get-Content $xml
    $newen = 'Enable>'

    $match = $xmlcontent | Select-String('([01])') -AllMatches | Foreach-Object { $_.Matches } 
    
    $groups = $match | Foreach-Object { $_.Groups }
    # Write-Host $match
    $value = $groups[0].value
    $value = 1 - $value
    $xmlcontent -replace "$newen[01]", "$newen$value" | Out-File $xml    
    $xml = fb 'wlanconfig1' 'setenable'
    # Write-Host('return seten')
}

function fb ($service, $action) {
    
    $settings = @{deviceinfo = 'newsoftwareversion'; wlanconfig1 = 'newenable' }
    
    $servicenew = 'wlanconfiguration'
    if ($service -eq 'deviceinfo') {
        $servicenew = $service
    }

    $response = Invoke-WebRequest "http://192.168.178.1:49000/upnp/control/$service" -Headers @{'soapaction' = 'urn:dslforum-org:service:' + $servicenew + ':1#' + $action } -Method post -InFile "$fb_folder/$action.xml" -ContentType text/xml

    [xml]$xml = $response
    # Write-Host $xml
    return $xml.envelope.body.getinforesponse.$($settings.$service)
}

# change_enable

$service = 'deviceinfo'
$service = 'wlanconfig1'

$xml = fb $service 'getinfo'
Write-Host($xml)

