$username = "Administrator"
$passwd = ConvertTo-SecureString "uqj5@y.ZQbm" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $passwd
New-PSSession -ComputerName 54.169.183.255  -Authentication Default -Credential $cred
Invoke-Command -ComputerName 54.169.183.255 -Authentication Default -Credential $cred -ScriptBlock {hostname}
Invoke-Command -ComputerName 54.169.183.255 -Authentication Default -Credential $cred -ScriptBlock {Dir}
