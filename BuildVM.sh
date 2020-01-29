#!/bin/bash
#
#
# setup variables to make the commands less spammy.

# Specify which subscription (if you have multiple Azure subscriptions) to use for this server.
# this is potentially very important if you have multiple Azure subscriptions!
# ***If you have only one subscription, you should leave the NULL value as shown below.***
SUBNAME="NULL"

# yor resource group name.
RESGROUP="rglab"
# pick an Azure Region
REGION="eastus2"
# pick a Network Security Group name
NSG="MyNSG"
# pick and AvailabilitySet name
AVSET="MyAvailabilitySet"
# pick a server hostname 
SERVERNAME="mytestlab001"
# pick the size of the server, more info can be found at https://azure.mirosoft.com/pricing/details/irtual-machines
# default Standard_B2s is 2 cores, 4GB RAM (For a iUbuntu or CentOS box with these specs, the monthly cost would be $37.13)
SERVERSIZE="Standard_B2s"
# pick a username to login to the new server with
VMUSER="azureuser"

# pick an OS image for the Virtual Machine
# In this case, I pick a Linux VM, but you can absolutely select a Windows Image, keep in mind your NSG rules will need
# to include remote connectivity for your OS, for Linux, ssh (port 22) for Windows, RDP (port 3389)
IMG="UbuntuLTS"

### IMPORTANT: If you have NOT already logged into your Azure account, you need this.
# otherwise, if you ARe logged in, you can comment this out.
az login

# If the default SUBNAME variable hasn't been changed, assume no subscription has been declared and skip this part.
if [ "$SUBNAME" = "NULL" ]
	then
		echo "Using your default subscription."	
	else
		az account set -s $SUBNAME
	fi

# Create a Resource Group, and specify a Region
az group create --name $RESGROUP  --location $REGION

# Create a vNet and subnet
az network vnet create --resource-group $RESGROUP --name myVnet --address-prefix 192.168.0.0/16 --subnet-name mySubnet --subnet-prefix 192.168.1.0/24

# Create a Public IP
az network public-ip create --resource-group $RESGROUP  --name myPublicIP --dns-name $SERVERNAME

# Create a NSG
az network nsg create --resource-group $RESGROUP --name $NSG 

# Create any firewall rules in the Network Security Group we just created.

# This is a Linux VM, so we need to create an inbound SSH rule. If this were a Windows VM, we'd ned to open port 3389`
az network nsg rule create --resource-group $RESGROUP --nsg-name $NSG --name mySSHrule --protocol tcp --priority 1000 --destination-port-range 22 --access allow

# This server will function as a web server, so we create an inbound HTTP rule 
az network nsg rule create --resource-group $RESGROUP --nsg-name $NSG --name myWWWrule --protocol tcp --priority 1001 --destination-port-range 80 --access allow

# Display the NSG and new rules.
az network nsg show --resource-group $RESGROUP --name $NSG

# Create a vNIC
az network nic create --resource-group $RESGROUP --name myNic --vnet-name myVnet --subnet mySubnet --public-ip-address myPublicIP --network-security-group $NSG 

# Create an Availabilty Set
az vm availability-set create --resource-group $RESGROUP --name $AVSET

# Create the VM
az vm create --resource-group $RESGROUP --name myLabVM --location $REGION --size $SERVERSIZE --availability-set $AVSET --nics myNic --image $IMG --admin-username $VMUSER --generate-ssh-keys >temp.txt
SERVER=`cat temp.txt |grep -e fqdns |awk '{print $2}' |cut -d\" -f2`

echo "Server: $SERVER"
echo "Username: $VMUSER"

# BROKEN

#echo "Now we connect to: $VMUSER@$SERVER"
#
#echo "Now we spawn a new shell and login to the server." 
#bash --rcfile <(echo '. ~/.bashrc; ssh $VMUSER@$SERVER ; exit')                                         

echo "Continuing with the script.."   
echo "Creating template of this VM.."         
# export template
az group export --name $RESGROUP > $RESGROUP.json

echo "Creating an environment from the template."

# create environment from template
az group deployment create --resource-group $RESGROUP --template-file $RESGROUP.json
