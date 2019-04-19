#region Microsoft Credentials

$MSUserName = ''
#$MSPassword = ''

$credentials = Get-Credential -UserName $MSUserName -Message 'Enter password'

#endregion

#region variables to create ResourceGroup 

$Location = 'West US'
$ResourceGroup = 'CheckResourceGroup1'
$NoOfInstances = 2
$VMName = 'WebMachine'
$VmUserName = 'User123'
$VmPassword = 'Welcome@1234'
$DnsName = 'webdev1'
$storageAccountName = 'webabcd'

$winrmScript = 'new_script.ps1'

#endregion 

#region Connecting to azure account

Add-AzureAccount -Credential $credentials

$Subscription = Get-AzureSubscription | select SubscriptionName

Select-AzureSubscription -SubscriptionName $Subscription.SubscriptionName

Login-AzureRmAccount -Credential $credentials

#endregion

#region Deploying Resource Group

New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location

$parameters = @{ 
        "adminUsername"=$VmUserName;
        "adminPassword"=$VmPassword;
        "DnsName"=$DnsName;
        "NoOfInstances" = $NoOfInstances;
        "VmName" = $VMName;
        "storageAccountName" = $storageAccountName
    }

New-AzureRmResourceGroupDeployment -Name WebApplcationDeployment -ResourceGroupName $ResourceGroup -TemplateParameterObject $parameters -TemplateFile 'C:\Users\Administrator\WebTemplate.json'

#endregion

#region to Create the file containing the WinRm enabling script

# Path to the file created in local
$file = $env:TEMP+'\' + $winrmScript
 
{
 
# Ensure PS remoting is enabled, although this is enabled by default for Azure VMs
Enable-PSRemoting -Force

Set-ExecutionPolicy RemoteSigned -Force
Set-item wsman:\localhost\Client\TrustedHosts -value '*' -Force 
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -RemoteAddress 'Any'

 
} | out-file $file

#endregion

#region Configuring VM with WinRm

for($i=0; $i -lt $NoOfInstances; $i++)
{
    $ListOfVMs = $VMName+$i
 
    #region Storage Account Details
    $StorageAcnt = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup
    $storageaccountname =$StorageAcnt.StorageAccountName
    $storageContext = $StorageAcnt.Context
    $StorageContainer = 'scripts'
    $key = (Get-AzureRmStorageAccountKey -Name $storageaccountname -ResourceGroupName $ResourceGroup).Value[0]
 
    #endregion

    # Checking for container
    try
    {
        Get-AzureStorageContainer -Name $StorageContainer -Context $storageContext -ErrorAction Stop
    }
    catch
    {
        New-AzureStorageContainer -Name $StorageContainer -Context $storageContext
    }

 
    #Checking for blob
    try
    {
        Get-AzureStorageBlobContent -Container $StorageContainer -Blob $winrmScript -Context $storageContext -ErrorAction Stop
    }
    catch
    {
        Set-AzureStorageBlobContent -Container $StorageContainer -File $file -Blob $winrmScript -Context $storageContext
    }

    #Exectuing the custom script
    Set-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroup -VMName  $ListOfVMs -Name "EnableWinRM_HTTPS" -Location $Location -StorageAccountName $storageaccountname -StorageAccountKey $key -FileName $winrmScript -ContainerName $StorageContainer
    #Deleting the file from the local machine
     $value = pwd
    $path = $value.Path + '\' + "$winrmScript"
    if(Test-Path $path)
    {
        $path | Remove-Item -Confirm:$false -Force
    } 

}

#endregion

#region To Install IIS

#$ToGetIp = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup 


#Invoke-Command  -ComputerName $ToGetIp.IpAddress  -Credential $cred  -ScriptBlock { 
                        #Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools -Verbose} -Verbose  

#endregion


