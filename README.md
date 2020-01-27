# AzureVMScripts
Collection of scripts to automate the creation and customization of MS Azure Virtual Machines

# BuildVM.sh
This Linux shell script (bash) will automate the process of deploying a VM in Azure. It's decently commented, and should
be easy enough for Beginners to read. Simple changes to declared variables will allow you to customize thigs such as:
+ Resource Group
+ Azure Region
+ Servername
+ Server Size (remember, not all sizes are available in all regions, check with az vm list-sizes --location <region you are deploying to>
+ OS Type
+ Admin Userame
+ Defining Network Security Group Name (NSG)
+ Creating inbound port rules within the NSG
+ Defining Availability Set Name

If you have multiple subscriptions, the script supports declaring which subscription to use. Otherwise it will default to using the default subscription if only one exists.

This script defaults to creating a Standard_B2s server size (2 cores, 4GB of RAM)

This script configures the Azure VM to authenticate via SSH keys, you can modify this for username/password if you'd like.

This is a basic script, and should be useful as a starting point for your further customization.

If you have any questions or would like to request additional features for this script, feel free to ping me!
