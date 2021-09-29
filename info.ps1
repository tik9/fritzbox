
$ho = "$env:USERPROFILE"
$docs = "$ho/documents"

if ($hostname -eq 't--pc') {
    $ho = '/home/tk'
    $docs = "$ho/Dokumente"
}
$password = Get-Content "$docs/irule"
$secure_pwd = $password | ConvertTo-SecureString -AsPlainText -Force

$fb_folder = "$ho/fritzbox"
$hostURL = 'http://192.168.178.1:49000'

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
    $user = 'fritz3220'
    # $pair = "$($user):$secure_pwd"
    # Write-Output "us pa pair $pair"
    
    # $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $credential = New-Object System.Management.Automation.PSCredential($user, $secure_pwd)

    $headers = @{'soapaction' = 'urn:dslforum-org:service:' + $servicenew + ':1#' + $action } 
    # ;Authorization = "Basic $auth"
    # Write-Output "action $action"

    $response = Invoke-WebRequest `
        -Method post `
        -uri ($hosturl + "/upnp/control/$service") `
        -Headers $headers `
        -Credential $credential `
        -AllowUnencryptedAuthentication `
        -InFile "$fb_folder/$action.xml" `
        -ContentType text/xml `

    [xml]$xml = $response
    # Write-Host $xml
    return $xml.envelope.body.getinforesponse.$($settings.$service)
}

change_enable

$service = 'deviceinfo'
$service = 'wlanconfig1'

$xml = fb $service 'getinfo'
Write-Host('xml' + $xml)

