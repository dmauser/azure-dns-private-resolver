## Deploy the solution

The lab is also available in the above .azcli that you can rename as .sh (shell script) and execute. You can open [Azure Cloud Shell (Bash)](https://shell.azure.com) and run the following commands to build the entire lab:

```bash
wget -O adr-vwan-deploy.sh https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/vwan-lab/adr-vwan-deploy.azcli
chmod +xr adr-vwan-deploy.sh
./adr-vwan-deploy.sh
```

## Setup the DNS solution

Option 1: If you want a ready demo to get all DNS configured use the following script:

```bash
wget -O adr-wvan-dns.sh https://raw.githubusercontent.com/dmauser/azure-dns-private-resolver/main/vwan-lab/adr-wvan-dns.azcli
chmod +xr adr-wvan-dns.sh
./adr-wvan-dns.sh
```

Option 2: Step by Step building the DNS solution.

