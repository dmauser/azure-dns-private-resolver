# **** Validation *****
#Parameters
rg=lab-dns-fabrikam 
location=$(az group show -n $rg --query location -o tsv)
#check ssh extention and add if not present
az extension show --name ssh -o none
if [ $? -ne 0 ]; then
    az extension add --name ssh
fi

###### BASTION SSH ######
# fabrikam-lxvm
az network bastion ssh --name fabrikam-bastion --resource-group $rg --target-resource-id $(az vm show -g $rg -n fabrikam-lxvm --query id -o tsv) --auth-type password --username azureuser


# 1) List Blob Storage Account names to test Private Endpoint name resolution.
az storage account list -g $rg --query [].primaryEndpoints.blob -o tsv
# Example of the ouput for the hub storage account: https://hubstg32476.blob.core.windows.net/

###=> List all private endpoints fqdns in the resource group with their private IPs and fqdn names
az network nic list --resource-group $rg \
 --query "[?contains(name, 'pe')].{fqdn:ipConfigurations[0].privateLinkConnectionProperties.fqdns[0], privateIp:ipConfigurations[0].privateIPAddress,Nic:name, privateIp:ipConfigurations[0].privateIPAddress}" \
 -o table

# 2) Access VM fabrikam-vmlx via serial console/SSH or Bastion
## 2.1) Review DNS client config. It will show the DNS server configured.
resolvectl status | grep "DNS Servers:"
## 2.2) Test storage account name resolution (change the name below based on the output on step 1):
nslookup hubstg20641.blob.core.windows.net 
dig hubstg20641.blob.core.windows.net 

nslookup contosofabrikam.blob.core.windows.net
dig contosofabrikam.blob.core.windows.net

nslookup contosofabrikam.blob.core.windows.net 8.8.8.8








