New-Item -type directory -path C:\Users\TestUser
$Acl = Get-Acl "C:\Users\TestUser"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("TestUser","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "C:\Users\TestUser" $Acl
