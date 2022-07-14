#Making Privatelink.blob.core.windows.net zone to work | SOLUTION: RootHints = No Forwarders set.
Get-DnsServerForwarder
Set-DnsServerForwarder -IPAddress 192.168.0.45 # Set DMZ DNS as Forwarder
Remove-DnsServerForwarder -IPAddress 192.168.0.45 -Force | Clear-DnsServerCache -Force

Add-DnsServerConditionalForwarderZone -Name "blob.core.windows.net" -MasterServers 10.0.0.4 -PassThru 
Clear-DnsServerCache -Force

Remove-DnsServerZone -Name  "blob.core.windows.net" -Force 
Clear-DnsServerCache -Force