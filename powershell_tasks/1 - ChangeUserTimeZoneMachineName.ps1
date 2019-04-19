#Changing the Username of a user

function RenameUser($oldName,$newName){
#Check if the user exists
$user = Get-WMIObject Win32_UserAccount -Filter "Name='$oldName'"
if($user -ne $null)
{
    write-host "The old username exists!!"

    #Check if the old and new usernames are same!!!
    If($oldName -eq $newName)
    {
    Write-Host "The specified username is same as the old username"
    }
    Else
    {
    $userCheck = Get-WmiObject Win32_UserAccount -Filter "Name='$newName'"

    If($userCheck -ne $null)
    {
        $userCheck
        Write-Host "The desired username already exists"
    }
    else
    {
        $result = $user.Rename($newName)
        Write-Host "The username has been successfully changed."
        Get-WmiObject Win32_UserAccount
    }
    }
}

}



# Changing the password of an User

function ChangePassword($user,$password){
([adsi]"WinNT://Remote-PC/$user").SetPassword("$password")
}
ChangePassword "Administrator" "Welcome@1234"


# Changing the Time Zone

function TimeZone ($param){

    $CurTimeZone = tzutil.exe /g
    If($CurTimeZone -eq $param)
    {
        Write-Host "The Time Zone is already set to the desired time zone"
    }
    Else
    {
        $IsTimeZoneValid = tzutil.exe /l | Where-Object { $_ -eq $param}
        If( $IsTimeZoneValid -ne $null)
        {
            tzutil.exe /s $param
            $CurTimeZone = tzutil.exe /g
            Write-Host "The Time zone is set to" $CurTimeZone
        }
        Else
        {
            Write-Host "Please specify a valid time Zone"
        }
    }

}

TimeZone("Central Pacific Standard Time")


# Changing the Machine Name 

function RenameComp($name){
$computer = Get-WmiObject win32_computersystem
If( $computer.Name -eq $name){
                Write-Host "The computer's name is same as the desired name.Please give a different name in-order to rename the PC."
        }
Else
{
    $computer.Rename($name)
    Write-Host "The computer's name will be reset to $name after restart"
}
}

RenameComp("Test-Comp")




