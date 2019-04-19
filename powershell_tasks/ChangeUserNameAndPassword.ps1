function RenameUser($oldName,$newName){
$user = Get-WMIObject Win32_UserAccount -Filter "Name='$oldName'"
$result = $user.Rename($newName)
Get-WMIObject Win32_UserAccount
}

RenameUser("Administrator","Administrator 1")

function ChangePassword($user,$password){
([adsi]"WinNT://Remote-PC/$user").SetPassword("$password")
}
ChangePassword("Administrator","Welcome@1234")
