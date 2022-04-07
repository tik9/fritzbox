# https://www.msxfaq.de/tools/prtg/getfritzmactable.htm#prtg
# (c) 2020  frank@carius.de
# powershell to query the mac-table from a fritzbox via UPNP. FB does not support SNMP authentication required.
# 20201122  Initial Version

$ipf = '192.168.178.1'

$secure_pwd = Get-Content './env' | ConvertTo-SecureString -AsPlainText -Force
Write-Host "pa $secure_pwd"

$hosturl = "$ipf:49000" 
$soapaction = "urn:dslforum-org:service:Hosts:1#X_AVM-DE_GetHostListPath"

$creds = New-Object System.Management.Automation.PSCredential -ArgumentList 'fritz3220', $secure_pwd

$ReturnXml = Invoke-RestMethod -Method POST -Headers @{'soapaction' = ($soapaction) } -Uri ($hosturl + '/upnp/control/hosts') -Credential $creds `
  -AllowUnencryptedAuthentication `
  -ContentType 'text/xml' `
  -infile ('gethostlistpath.xml')

Write-Host ('RX' + $ReturnXml)
# Write-host " Download MAC-List from ($hosturl($($ReturnXml.Envelope.Body.'X_AVM-DE_GetHostListPathResponse'.'NewX_AVM-DE_HostListPath')))"
$devicehostlist = invoke-restmethod -Uri ($hosturl + ($ReturnXml.Envelope.Body.'X_AVM-DE_GetHostListPathResponse'.'NewX_AVM-DE_HostListPath')) `
  # convert System.Xml.XmlLinkedNode to standard Object
  $mactable = $devicehostlist.List.Item.GetEnumerator() |  ConvertTo-Csv | ConvertFrom-Csv
# Write-host "Total Entries: $($mactable.count)"

# if ($prtgdetail) {
$res =
$(
  "<?xml version=""1.0"" encoding=""UTF-8"" ?>
  <prtg>
    <result>
      <channel>Active Hosts</channel>
      <value>$(($mactable | where-object {$_.active -eq 1}).count)</value>
      <float>0</float>
    </result>
    <result>
      <channel>Passive Hosts</channel>
      <value>$(($mactable | where-object {$_.active -eq 0}).count)</value>
      <float>0</float>
    </result>
    <result>
      <channel>Guest Hosts</channel>
      <value>$(($mactable | where-object {$_."X_AVM-DE_Guest" -eq 1}).count)</value>
      <float>0</float>
    </result>"
  foreach ($mac in $mactable) {
    "<result>
      <channel>$($mac.MACAddress)</channel>
      <value>$($mac.active)</value>
      <float>0</float>
    </result>"
  }

  "<text>Anzahl der Eintraege in der FB MacTabelle</text>
  </prtg>"
)
$res
# }
# elseif ($prtg) {

# }
# Write-Host "Export all entries"
# $mactable

