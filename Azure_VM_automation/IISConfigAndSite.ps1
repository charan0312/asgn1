#region Microsoft Credentials

$MSUserName = ''
$MSPassword = ""
$SecureMSPswd = $MSPassword| ConvertTo-SecureString -AsPlainText -Force
$credentials = New-Object Management.Automation.PSCredential -ArgumentList $MSUserName, $SecureMSPswd


#endregion

#region Connecting to azure account
$ResourceGroup = 'CheckResourceGroup1'

Add-AzureAccount -Credential $credentials

$Subscription = Get-AzureSubscription | select SubscriptionName

Select-AzureSubscription -SubscriptionName $Subscription.SubscriptionName

Login-AzureRmAccount -Credential $credentials

#endregion

#region Virtual Machine Details

$VMIpAddress= Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup | Select IpAddress

$VmUserName = 'User1'
$VmPassword = 'Welcome@1234'
$SecureVMPswd = $VmPassword| ConvertTo-SecureString -AsPlainText -Force
$VmCredentials = New-Object Management.Automation.PSCredential -ArgumentList $VmUserName, $SecureVMPswd

#endregion

#region IIS Configuring variables

$AppPoolName = "smallSample"
$AppPoolPath = "IIS:\apppools"
$PhysicalPath = "D:\Websites\smallSample"
$sitePath = "IIS:\sites"
$siteName = "smallSample"
$portNum = '81'
$ManagedPipelineMode="Integrated"

#endregion

#region Configuring IIS in VMs

$IISConfigScriptBLock = {

param(
    [string]$AppPoolName,
    [string]$AppPoolPath,
    [string]$PhysicalPath,
    [string]$sitePath,
    [string]$siteName,
    [string]$portNum,
    [string]$ManagedPipelineMode

)

if($ManagedPipelineMode -eq "Classic")
{
    $Pmode = 1
}
else
{
    $Pmode=0
}

Import-Module WebAdministration

cd $AppPoolPath

$PoolData = get-childitem | where-object {$_.Name -eq $AppPoolName}

cd C:\

IF ($PoolData.Name -eq $AppPoolName)
{
    Write-Host "AppPool already exists"
}
else
{
    cd $AppPoolPath
    New-Item $AppPoolName
    set-ItemProperty IIS:\AppPools\$AppPoolName -name managedRuntimeVersion -value "v4.0"
    set-ItemProperty IIS:\AppPools\$AppPoolName -name ManagedPipelineMode -value $Pmode
}

$folderStatus = Test-path $PhysicalPath

IF ($folderStatus)
{
    Write-Host "Directory exist"
}
else
{
    md $PhysicalPath
    Write-Host "Directory created"
}

cd $sitePath
$SiteData = get-childitem | where-object {$_.Name -eq $siteName}
cd C:\

IF ($SiteData.Name -eq $siteName)
{
    Write-Host "site already exists"
    $Site = get-item IIS:\sites\$siteName
    $sitePool = get-itemproperty IIS:\sites\$siteName -name applicationpool

    IF ($sitePool.applicationpool -eq $AppPoolName)
    {
        Write-Host "Application pool name Ok"
    }
    else
    {
        set-ItemProperty IIS:\sites\$siteName -name applicationpool -value $AppPoolName
    }

    IF ($site.physicalpath -eq $PhysicalPath)
    {
        Write-Host "Physical path is OK"
    }
    else
    {
        set-ItemProperty IIS:\sites\$siteName -name physicalpath -value $PhysicalPath
    }
}
else
{
    cd $sitePath
    new-item IIS:\sites\$siteName -bindings @{protocol = "http"; bindinginformation="*:$($portNum):" } -physicalpath $PhysicalPath
    set-ItemProperty IIS:\sites\$siteName -name applicationpool -value $AppPoolName
}

}
Invoke-Command -ScriptBlock $IISConfigScriptBLock -ComputerName $VMIpAddress.IpAddress -Credential $VmCredentials -ArgumentList $AppPoolName,$AppPoolPath,$PhysicalPath,$sitePath,$siteName,$portNum,$ManagedPipelineMode

#endregion

#region Moving zipped folder to Destination Server

cd C:\Users\Administrator

Invoke-Command -ScriptBlock {Set-NetFirewallRule -Name AllTraffic -Enabled True} -ComputerName $VMIpAddress.IpAddress -Credential $VmCredentials


New-PsDrive -Name X -PSProvider FileSystem -Root \\$($VMIpAddress.IpAddress)\c$ -Credential $VmCredentials
cd X:\
if(!(Test-Path X:\TestDest))
{
    md X:\TestDest
}
cd X:\TestDest
$ZipDest = 'C:\TestDest'
cp C:\Users\Administrator\index.zip .\
cd c:\
Remove-PSDrive X
#Invoke-Command -ScriptBlock {Set-NetFirewallRule -Name AllTraffic -Enabled False} -ComputerName $VMIpAddress -Credential $VmCredentials

#endregion

#region unzipping the zipped content

$UnzipScript = {

    param(
        [string]$destination,
        [string]$zipFile
    )

     Add-Type -AssemblyName System.IO.Compression.FileSystem;
     if((Test-Path "$($destination)\*.*"))
     {
        Get-ChildItem $destination | Remove-Item -Force
     }
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$($zipFile)\index.zip", "$($destination)\");
}

Invoke-Command -ScriptBlock $UnzipScript -ComputerName $VMIpAddress.IpAddress -Credential $VmCredentials -ArgumentList $PhysicalPath,$ZipDest

#endregion