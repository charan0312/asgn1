
#Creating a folder
New-Item -type directory -path C:\Users\TestUser

#Creating a User
$comp = $env:computername
$ADSIcomp = [adsi]"WinNT://$comp"

$username= "TestUser"
$NewUser=$ADSIcomp.Create("User",$username)

$NewUser.SetPassword("Welcome@1234")
$NewUser.SetInfo()

Get-WmiObject win32_useraccount


#Giving permissions to a folder for the local user
$Acl = Get-Acl "C:\Users\TestUser"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("TestUser","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "C:\Users\TestUser" $Acl 
