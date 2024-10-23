#### BASTION RDP ####
# onprem-windns
$rg="lab-dns-resolver"
az network bastion rdp --name onprem-bastion --resource-group $rg --target-resource-id $(az vm show -g $rg -n onprem-windns --query id -o tsv) --configure

#Current config:
Get-DnsServerZone | Where-Object { $_.ZoneName -like "*blob*" }
Get-DnsServerForwarder

#### Run the commands inside Contoso-WinDNS VM using Powershell ISE ####
# Making privatelink.blob.core.windows.net to work on Windows DNS
Remove-DnsServerForwarder -IPAddress 8.8.8.8 -Force # Removes Global Forwarder
Add-DnsServerConditionalForwarderZone -Name "privatelink.blob.core.windows.net" -MasterServers 10.0.20.164 -PassThru 
Remove-DnsServerZone -Name  "blob.core.windows.net" -Force
Clear-DnsServerCache -Force

# Adding Forwarder 
Set-DnsServerForwarder -IPAddress 8.8.8.8
Clear-DnsServerCache -Force

# Original config
Set-DnsServerForwarder -IPAddress 8.8.8.8
Remove-DnsServerZone -Name  "privatelink.blob.core.windows.net" -Force
Add-DnsServerConditionalForwarderZone -Name "blob.core.windows.net" -MasterServers 10.0.20.164 -PassThru 
Clear-DnsServerCache -Force


