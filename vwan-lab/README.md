# Lab: Multi-Region DNS Private Resolver (Virtual WAN)

**Content**

[Intro](#intro)

[Lab diagram](#lab-diagram)
- [Scenario 1: Private endpoint DNS name resolution](#scenario-1-private-endpoint-dns-name-resolution)
- [Scenario 2: On-premises and Azure DNS integration](#scenario-2-on-premises-and-azure-dns-integration)

[Lab components](#lab-components)

[Considerations](#considerations)

[Deploy this solution](#deploy-this-solution)

[Clean up](#clean-up)

## Intro

Azure DNS Private Resolver is a first-party Azure network component that facilitates DNS name resolution integration between On-premises to Azure and vice-versa. Please, review the official documentation for more information: [What is Azure DNS Private Resolver?](https://docs.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)

This repo goes over DNS Private Resolver on a multi-region scenario, where we going to explore the following scenarios:

1 - Azure Private Link name resolution
2 - Multiple Private DNS Zones resolution (the Business Unit use case)
3 - Name resolution multi-region failover validation

Although this article goes over multi-region with Virtual WAN the same scenarios can be easily applied to Hub/Spoke architecture. The difference is on vWAN is mandatory that you host a shared service such as DNS Private Resolver in a dedicated Virtual Network (VNet). On a Hub/Spoke architecture, you can use either a dedicated VNET or host DNS Private Resolver inside the HUB.

## Deploy the solution

The lab is also available in the above .azcli that you can rename as .sh (shell script) and execute. You can open [Azure Cloud Shell (Bash)](https://shell.azure.com) and run the following commands to build the entire lab:

```bash
wget -O adr-vwan-deploy.sh https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/vwan-lab/adr-vwan-deploy.azcli
chmod +xr adr-vwan-deploy.sh
./adr-vwan-deploy.sh
```

## Scenario 1: DNS componentsIn this part of the lab, you will add all DNS components:

1 - On-premises Windows DNS Servers (Branch 1 and Branch2).
2 - DNS Private Resolver with Inbound and Outbound endpoints.

```bash
wget -O adr-wvan-dns.sh https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/vwan-lab/adr-wvan-dns.azcli
chmod +xr adr-wvan-dns.sh
./adr-wvan-dns.sh
```

The following diagram reflects what is expected after deploying the shell adr-wvan-dns.sh script.

## Scenario 2: Private Link name resolution


```bash
wget -O adr-vwan-pl.sh https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/vwan-lab/adr-vwan-pl.azcli
chmod +xr adr-vwan-pl.sh
./adr-vwan-pl.sh
```
