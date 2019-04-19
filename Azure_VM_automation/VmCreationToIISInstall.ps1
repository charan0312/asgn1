

$resourceGrp = "newSample"
$CompName = "MyComp"
$location = "Central US"

New-AzureRmResourceGroup -Name $resourceGrp -Location "Central US"

#Storage account
#Test-AzureName -Storage "rakstore"

$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $resourceGrp -Name "rakstore" -Type "Standard_LRS" -Location "Central US"

#Create Virtual network
$singlesubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "Mysubnet" -AddressPrefix 10.0.0.0/24
$vnet = New-AzureRmVirtualNetwork -Name "vnet" -ResourceGroupName $resourceGrp -Location "Central US" -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet


#Create a public IP address and network interface
$pip = New-AzureRmPublicIpAddress -Name "ipname" -ResourceGroupName $resourceGrp -Location "Central US"  -AllocationMethod Dynamic

$nic = New-AzureRmNetworkInterface -Name "nicName" -ResourceGroupName $resourceGrp -Location "Central US" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

#Create Virtual machine

$cred = Get-Credential 

$vm = New-AzureRmVMConfig -VMName "myVM" -VMSize "Standard_A1" 



#Operating system information to the configuration
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $CompName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

#Image to choose VM
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"

#Add network interface to configuration
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

#Path of virtual hard disk stored in the container
$blobPath = "vhds/WindowsVMosDisk.vhd"
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + $blobPath



$vm = Set-AzureRmVMOSDisk -VM $vm -Name "windowsdisk" -VhdUri $osDiskUri -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $resourceGrp -Location "Central US" -VM $vm 



# define a temporary file in the users TEMP directory
$file = $env:TEMP + "\new_script.ps1"
 
#Create the file containing the PowerShell
 
{
 
# POWERSHELL TO EXECUTE ON REMOTE SERVER BEGINS HERE
 
# Ensure PS remoting is enabled, although this is enabled by default for Azure VMs
Enable-PSRemoting -Force

Set-ExecutionPolicy RemoteSigned -Force
Set-item wsman:\localhost\Client\TrustedHosts -value '*' -Force 
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -RemoteAddress 'Any'

 
 md C:\Users\Administrator\

 
} | out-file $file

$VmName = "myVM"

# Get the VM we need to configure
$vm = Get-AzureRmVM -ResourceGroupName $resourceGrp -Name $VmName
 
# Get storage account name
 $StorageAcnt = Get-AzureRmStorageAccount -ResourceGroupName $resourceGrp
 $storageaccountname =$StorageAcnt.StorageAccountName
 $storageContext = $StorageAcnt.Context

# get storage account key
$key = (Get-AzureRmStorageAccountKey -Name $storageaccountname -ResourceGroupName $resourceGrp).Value[0]
 
# create storage context

 
# create a container called scripts
New-AzureStorageContainer -Name "scripts" -Context $storageContext
 
#upload the file
Set-AzureStorageBlobContent -Container "scripts" -File $file -Blob "new_script.ps1" -Context $storageContext




# Create custom script extension from uploaded file
Set-AzureRmVMCustomScriptExtension -ResourceGroupName $resourceGrp -VMName $VmName -Name "EnableWinRM_HTTPS" -Location $location -StorageAccountName $storageaccountname -StorageAccountKey $key -FileName "new_script.ps1" -ContainerName "scripts"



$ToGetIp = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGrp 


Invoke-Command  -ComputerName $ToGetIp.IpAddress  -Credential $cred  -ScriptBlock { 
                        Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools -Verbose} -Verbose  






