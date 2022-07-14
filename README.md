# Lab: Azure DNS Private Resolver

## Intro

## Lab diagram

## Deploy

The lab is also available in the above .azcli that you can rename as .sh (shell script) and execute. You can open [Azure Cloud Shell (Bash)](https://shell.azure.com) and run the following commands build the entire lab:

```bash
wget -O adr-deploy.sh https://raw.githubusercontent.com/dmauser/azure-virtualwan/main/inter-region-nva/adr-deploy.azcli
chmod +xr adr-deploy.sh
./adr-deploy.sh 
```

**Note:** the provisioning process will take around 60 minutes to complete.