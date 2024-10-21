#### BASTION RDP ####
# onprem-windns
$rg="lab-dns-resolver"
az network bastion rdp --name onprem-bastion --resource-group $rg --target-resource-id $(az vm show -g $rg -n onprem-windns --query id -o tsv) --configure

# Making privatelink.blob.core.windows.net to work on Windows
Remove-DnsServerForwarder -IPAddress 8.8.8.8 -Force
Add-DnsServerConditionalForwarderZone -Name "privatelink.blob.core.windows.net" -MasterServers 10.0.20.164 -PassThru 
Remove-DnsServerZone -Name  "blob.core.windows.net" -Force

# Adding Forwarder 
Set-DnsServerForwarder -IPAddress 8.8.8.8 | Clear-DnsServerCache -Force

# Original config
Set-DnsServerForwarder -IPAddress 8.8.8.8
Remove-DnsServerZone -Name  "privatelink.blob.core.windows.net" -Force
Add-DnsServerConditionalForwarderZone -Name "blob.core.windows.net" -MasterServers 10.0.20.164 -PassThru 
Clear-DnsServerCache -Force


