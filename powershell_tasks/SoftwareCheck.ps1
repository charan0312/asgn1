function SoftCheck($param) {

$ReqSoft = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -match $param}
If ( $ReqSoft -ne $null)
{
    Write-Host "Name: " $ReqSoft.DisplayName
    Write-Host "Version: " $ReqSoft.DisplayVersion
}

Else
{
    Write-Host "No software found"
}

}

SoftCheck("aws-cfn-bootstrap")
