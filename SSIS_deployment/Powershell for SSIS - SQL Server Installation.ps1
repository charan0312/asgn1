New-Item -ItemType directory -Path C:\SQL_Data
New-Item -ItemType directory -Path C:\SQL_Logs
New-Item -ItemType directory -Path C:\Temp_DB
New-Item -ItemType directory -Path C:\SQLAgentLogs
$WindowsVersion = [environment]::OSVersion.Version
$WindowsVersion
Add-WindowsFeature Net-Framework-Core


$passwd = '&EmGYEYx2A'
$sa_passwd = "Welcome@1234"
$output1 = C:\Users\Administrator\Downloads\SQLFULL_ENU.iso
cd D:\

.\\setup.exe /q /ACTION=Install /FEATURES=SQL,Tools /INSTANCENAME=MSSQLSERVER /SECURITYMODE=SQL /SAPWD=$sa_passwd /SQLSVCACCOUNT="Administrator" /SQLSVCPASSWORD=$passwd /SQLSYSADMINACCOUNTS="Administrator" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled /IndicateProgress