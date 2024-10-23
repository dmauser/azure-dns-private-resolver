### Deploy the lab environment using Azure Cloud Shell bash
curl -s https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/adr-lab/demo/s1-contoso.azcli | bash


#check ssh extention and add if not present
az extension show --name ssh -o none
if [ $? -ne 0 ]; then
    az extension add --name ssh
fi

# **** Validation *****
#Parameters
rg=lab-dns-contoso 
location=$(az group show -n $rg --query location -o tsv)


###### BASTION SSH ######
# contoso-lxvm
az network bastion ssh --name contoso-bastion --resource-group $rg --target-resource-id $(az vm show -g $rg -n contoso-lxvm --query id -o tsv) --auth-type password --username azureuser
# contoso-binddns
az network bastion ssh --name contoso-bastion --resource-group $rg --target-resource-id $(az vm show -g $rg -n contoso-binddns --query id -o tsv) --auth-type password --username azureuser

# 1) List Blob Storage Account names to test Private Endpoint name resolution.
az storage account list -g $rg --query [].primaryEndpoints.blob -o tsv
# Example of the ouput for the hub storage account: https://hubstg32476.blob.core.windows.net/

###=> List all private endpoints fqdns in the resource group with their private IPs and fqdn names
az network nic list --resource-group $rg \
 --query "[?contains(name, 'pe')].{fqdn:ipConfigurations[0].privateLinkConnectionProperties.fqdns[0], privateIp:ipConfigurations[0].privateIPAddress,Nic:name, privateIp:ipConfigurations[0].privateIPAddress}" \
 -o table

# 2) Access VM contoso-vmlx via serial console/SSH or Bastion
## 2.1) Review DNS client config. It will show the DNS server configured.
resolvectl status | grep "DNS Servers:"
## 2.2) Test storage account name resolution (Note your storage may have changed, update below based on the output on step 1):
nslookup hubstg14419.blob.core.windows.net
dig hubstg14419.blob.core.windows.net
sudo resolvectl flush-caches # Clear the local DNS cache

# Review Bind DNS configuration
hostname -I
cat /etc/bind/named.conf.options
cat /etc/bind/named.conf.local

# Use Bind DNS to resolve the private endpoint name
nslookup hubstg14419.blob.core.windows.net 192.168.100.6






