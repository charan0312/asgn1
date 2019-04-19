# Creating a folder in wwwroot folder
mkdir C:\inetpub\wwwroot\DemoApp

# Creating a default.html page

"<html>
    <head> <title> Sample Page </title> </head>

    <body>
        <p> This is a sample paragraph </p>
    </body>
</html>
" > .\default.html

#Creating the Web Application

Import-Module WebAdministration
$iisAppPoolName = "MyAppPool"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "DemoApp"
$directoryPath = "C:\inetpub\wwwroot\DemoApp"

#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-Item $iisAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $iisAppName -pathType container)
{
    return
}

#create the site
$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":81:" + $iisAppName} -physicalPath $directoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
