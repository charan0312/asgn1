# Installing Telnet Client
$soft = Get-WindowsFeature | Where-Object {$_.Name -eq 'telnet-client'}

if($soft.InstallState -eq "Installed")
{
 Write-Host "Telnet-Client is already installed on the system"
}
else
{
  Install-WindowsFeature telnet-client
  Write-Host "Telnet-Client is successfully installed on the system"
}

# Installing .NET 3.5

$soft = Get-WindowsFeature | Where-Object {$_.Name -eq 'NET-Framework-Features'}

if($soft.InstallState -eq "Installed")
{
 Write-Host "The NET-Framework-Features is already installed on the system"
}
else
{
  Install-WindowsFeature NET-Framework-Features -IncludeAllSubFeature -IncludeManagementTools
  Write-Host "NET-Framework-Features is successfully installed on the system"
}


# Installing .NET 4.5

$soft = Get-WindowsFeature | Where-Object {$_.Name -eq 'NET-Framework-45-Features'}

if($soft.InstallState -eq "Installed")
{
 Write-Host "The NET-Framework-Features is already installed on the system"
}
else
{
  Install-WindowsFeature NET-Framework-45-Features -IncludeAllSubFeature -IncludeManagementTools
  Write-Host "NET-Framework-45-Features is successfully installed on the system"
}
