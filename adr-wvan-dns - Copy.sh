# Pre-Requisites
az extension add -n dns-resolver

# Parameters (make changes based on your requirements)
region1=southcentralus
region2=northcentralus
rg=lab-vwan-adr
vwanname=vwan-adr
hub1name=hub1
hub2name=hub2
username=azureuser
password="Msft123Msft123"
vmsize=Standard_DS1_v2
#DNS Private Resolver
hub1servicesDnsInSubnetPrefix=172.16.10.32/28
hub1servicesDnsOutSubnetPrefix=172.16.10.48/28
hub2servicesDnsInSubnetPrefix=172.16.20.32/28
hub2servicesDnsOutSubnetPrefix=172.16.20.48/28

# Deploying Branch1 Windows DNS Server
echo Deploying Branch1 Windows DNS Server
az network nic create --name branch1-windns-nic --resource-group $rg --subnet main --vnet branch1 --location $region1 -o none
az vm create --resource-group $rg --location $region1 --name branch1-windns --size $vmsize --nics branch1-windns-nic  --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter-smalldisk:latest --admin-username $username --admin-password $password -o none
az vm extension set --resource-group $rg --vm-name branch1-windns  --name CustomScriptExtension \
 --publisher Microsoft.Compute \
 --setting "{\"commandToExecute\": \"powershell Install-WindowsFeature -Name DNS -IncludeManagementTools\"}" \
 --no-wait

# Deploying Branch2 Windows DNS Server
echo Deploying Branch2 Windows DNS Server
az network nic create --name branch2-windns-nic --resource-group $rg --subnet main --vnet branch2 --location $region2 -o none
az vm create --resource-group $rg --location $region2 --name branch2-windns --size $vmsize --nics branch2-windns-nic  --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter-smalldisk:latest --admin-username $username --admin-password $password -o none
az vm extension set --resource-group $rg --vm-name branch2-windns  --name CustomScriptExtension \
 --publisher Microsoft.Compute \
 --setting "{\"commandToExecute\": \"powershell Install-WindowsFeature -Name DNS -IncludeManagementTools\"}" \
 --no-wait

# Deploying Azure DNS Private Resolver
echo Deploying Azure DNS Private Resolvers
#Hub1
hub1svcvnetid=$(az network vnet show -g $rg -n $hub1name-svc --query id -o tsv)
az dns-resolver create --name $hub1name-svc-dnsresolver -g $rg --location $region1 --id $hub1svcvnetid -o none 

#Hub2
hub2svcvnetid=$(az network vnet show -g $rg -n $hub2name-svc --query id -o tsv)
az dns-resolver create --name $hub2name-svc-dnsresolver -g $rg --location $region2 --id $hub2svcvnetid -o none

# Creating DNS inbound-endpoint 
#Hub1
echo Creating DNS inbound-endpoint on $hub1name-svc-dnsresolver
az network vnet subnet create -g $rg --vnet-name $hub1name-svc -n dnsin --address-prefixes $hub1servicesDnsInSubnetPrefix --output none
indnsid=$(az network vnet subnet show -g $rg -n dnsin --vnet-name $hub1name-svc --query id -o tsv)
az dns-resolver inbound-endpoint create -g $rg --name InboundEndpoint \
 --dns-resolver-name $hub1name-svc-dnsresolver \
 --location $region1 \
 --ip-configurations '[{"private-ip-address":"","private-ip-allocation-method":"Dynamic","id":"'$indnsid'"}]' \
 --output none \
 --no-wait
#Hub2
# Creating DNS inbound-endpoint 
echo Creating DNS inbound-endpoint on $hub2name-svc-dnsresolver
az network vnet subnet create -g $rg --vnet-name $hub2name-svc -n dnsin --address-prefixes $hub2servicesDnsInSubnetPrefix --output none
indnsid=$(az network vnet subnet show -g $rg -n dnsin --vnet-name $hub2name-svc --query id -o tsv)
az dns-resolver inbound-endpoint create -g $rg --name InboundEndpoint \
 --dns-resolver-name $hub2name-svc-dnsresolver \
 --location $region2 \
 --ip-configurations '[{"private-ip-address":"","private-ip-allocation-method":"Dynamic","id":"'$indnsid'"}]' \
 --output none \
 --no-wait

# Creating DNS outbound-endpoint 
echo Creating DNS outbound-endpoint on $hub1name-svc-dnsresolver
#Hub1
az network vnet subnet create -g $rg --vnet-name $hub1name-svc -n dnsout --address-prefixes $hub1servicesDnsOutSubnetPrefix --output none
outdnsid=$(az network vnet subnet show -g $rg -n dnsout --vnet-name $hub1name-svc --query id -o tsv)
az dns-resolver outbound-endpoint create -g $rg --name OutboundEndpoint \
 --dns-resolver-name $hub1name-svc-dnsresolver \
 --location $region1 \
 --id="$outdnsid" \
 --output none

#Hub2
echo Creating DNS outbound-endpoint on $hub2name-svc-dnsresolver
az network vnet subnet create -g $rg --vnet-name $hub2name-svc -n dnsout --address-prefixes $hub2servicesDnsOutSubnetPrefix --output none
outdnsid=$(az network vnet subnet show -g $rg -n dnsout --vnet-name $hub2name-svc --query id -o tsv)
az dns-resolver outbound-endpoint create -g $rg --name OutboundEndpoint \
 --dns-resolver-name $hub2name-svc-dnsresolver \
 --location $region2 \
 --id="$outdnsid" \
 --output none

#***** Configuring Branch DNS *****
echo Configuring Branch1 DNS Server
# Run command for Onprem DNS configuration:
dnsresolverip1=$(az dns-resolver inbound-endpoint show -g $rg --dns-resolver-name $hub1name-svc-dnsresolver --name InboundEndpoint --query ipConfigurations[].privateIpAddress -o tsv)
dnsresolverip2=$(az dns-resolver inbound-endpoint show -g $rg --dns-resolver-name $hub2name-svc-dnsresolver --name InboundEndpoint --query ipConfigurations[].privateIpAddress -o tsv)
# fwdnsresolverip=$(az network firewall show --name $hubname-azfw --resource-group $rg --query "hubIpAddresses.privateIpAddress" -o tsv)
globaldnsfwd=8.8.8.8 # Global/Server level DNS Forwarder
branch1vmip=$(az network nic show --name branch1VMVMNic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv)
branch2vmip=$(az network nic show --name branch2VMVMNic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv)
az vm run-command invoke --command-id RunPowerShellScript \
 --name branch1-windns \
 --resource-group $rg \
 --scripts 'param([string]$arg3)' \
 'Set-DnsServerForwarder -IPAddress $arg3' \
 --parameters $(echo "arg3=$globaldnsfwd") \
 --output none \
 --no-wait

echo Configuring Branch2 DNS Server
# Run command for Onprem DNS configuration:
dnsresolverip1=$(az dns-resolver inbound-endpoint show -g $rg --dns-resolver-name $hub2name-svc-dnsresolver --name InboundEndpoint --query ipConfigurations[].privateIpAddress -o tsv)
dnsresolverip2=$(az dns-resolver inbound-endpoint show -g $rg --dns-resolver-name $hub1name-svc-dnsresolver --name InboundEndpoint --query ipConfigurations[].privateIpAddress -o tsv)
# fwdnsresolverip=$(az network firewall show --name $hubname-azfw --resource-group $rg --query "hubIpAddresses.privateIpAddress" -o tsv)
globaldnsfwd=8.8.8.8 # Global/Server level DNS Forwarder
branch1vmip=$(az network nic show --name branch1VMVMNic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv)
branch2vmip=$(az network nic show --name branch2VMVMNic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv)
az vm run-command invoke --command-id RunPowerShellScript \
 --name branch2-windns \
 --resource-group $rg \
 --scripts 'param([string]$arg3)' \
 'Set-DnsServerForwarder -IPAddress $arg3' \
 --parameters $(echo "arg3=$globaldnsfwd") \
 --output none \
 --no-wait

# Creating forwarding-ruleset
echo Creating forwarding-ruleset on $hub1name-svc-dnsresolver
#Hub1
outepid=$(az dns-resolver outbound-endpoint show -g $rg --name OutboundEndpoint --dns-resolver-name $hub1name-svc-dnsresolver --query id -o tsv)
az dns-resolver forwarding-ruleset create -g $rg --name $hub1name-svc-fwd-ruleset \
 --location $region1 \
 --outbound-endpoints '[{"id":"'$outepid'"}]' \
 --output none

#Hub2
echo Creating forwarding-ruleset on $hub2name-svc-dnsresolver
outepid=$(az dns-resolver outbound-endpoint show -g $rg --name OutboundEndpoint --dns-resolver-name $hub2name-svc-dnsresolver --query id -o tsv)
az dns-resolver forwarding-ruleset create -g $rg --name $hub2name-svc-fwd-ruleset \
 --location $region2 \
 --outbound-endpoints '[{"id":"'$outepid'"}]' \
 --output none

# ***** Preparing Branch VMs for Name Resolution *****
echo ***** Preparing Branch VMs for Name Resolution *****
# Setting Branch1 vnet to use Branch1 DNS Server
echo Setting Branch1 vnet to use Branch1 DNS Server
az network vnet update -g $rg -n branch1 \
 --dns-servers $(az network nic show --name branch1-windns-nic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv) \
 --output none
echo Setting Branch2 vnet to use Branch2 DNS Server
az network vnet update -g $rg -n branch2 \
 --dns-servers $(az network nic show --name branch2-windns-nic -g $rg  --query "ipConfigurations[0].privateIpAddress" -o tsv) \
 --output none
# Restarting onprem VMs to commit the new VNET DNS settings.
echo Restarting branches VMs to commit the new VNET DNS settings.
az vm restart --ids $(az vm list -g $rg --query '[?contains(name,`'branch'`)].{id:id}' -o tsv) --no- --output none
echo Follow the validation script to test the name resolution.
echo echo Lab deployment has finished.