$AutoUpdateNotificationLevels= @{0=”Not configured”; 1=”Disabled” ; 2=”Notify before download”; 3=”Notify before installation”; 4=”Scheduled installation”}

Function Set-WindowsUpdateConfig($NotificationLevel) {
 $AUSettings = (New-Object -com “Microsoft.Update.AutoUpdate”).Settings
 if ($NotificationLevel)  {$AUSettings.NotificationLevel = $NotificationLevel}
 $AUSettings.Save
} 
