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
