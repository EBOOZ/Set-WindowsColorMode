<#
.NOTES
    Name: Set-WindowsColorMode.ps1
    Author: Danny de Vries
    Requires: PowerShell v2 or higher
    Version History: https://github.com/EBOOZ/Set-WindowsColorMode/commits/main
.SYNOPSIS
    Sets Windows 11 Light or Dark theme based on sunrise or sunsite time
.DESCRIPTION
    Weerlive API reference: https://weerlive.nl/delen.php
.PARAMETER Mode
    -Mode
.EXAMPLE
    .\Set-DarkMode.ps1 -Mode Dark
#>
# Configuring parameter for interactive run
Param($Mode)

################################################################################################################################
#                                Don't edit the code below, unless you know what you're doing                                  #
################################################################################################################################
# Import Settings PowerShell script
. ($PSScriptRoot + "\Settings.ps1")

# Get script working directory
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host ("LOG: Script location is: $ScriptDir")

# Set light or dark mode based on parameter
If($Mode -eq "Light"){
   Write-Host ("LOG: Parameter used. Setting theme to Light.")
   $Wallpaper = $LightWallpaper
   $RegFile = "$ScriptDir\Light.reg"
}
ElseIf($Mode -eq "Dark"){
   Write-Host ("LOG: Parameter used. Setting theme to Dark.")
   $Wallpaper = $DarkWallpaper
   $RegFile = "$ScriptDir\Dark.reg"
}
# Set light or darkmode based on time if no parameter is used
Else {
   # Get sunrise and sunset values
   If ($ApiKey -eq ""){ 
      # Use demo API if no key is configured
      Write-Host ("LOG: No API configured. Using Amsterdam as location.")
      $WebResponse = Invoke-WebRequest -Uri "https://weerlive.nl/api/json-data-10min.php?key=demo&locatie=Amsterdam" -ContentType 'application/json'
   }
   Else{
      # Use key and city when configured
      Write-Host ("LOG: API key is configured. Using $City as location.")
      $WebResponse = Invoke-WebRequest -Uri "https://weerlive.nl/api/json-data-10min.php?key=$ApiKey&locatie=$City" -ContentType 'application/json'
   }

   $WebResponse = $WebResponse.Content | ConvertFrom-Json
   Write-Host ("LOG: Sunset time is: "+$WebResponse.liveweer.sunder)
   $Sunset = $WebResponse.liveweer.sunder -replace ":",""
   $Sunset = $Sunset | Where-Object {$_.trim() -ne "" }
   Write-Host ("LOG: Sunrise time is: "+$WebResponse.liveweer.sup)
   $Sunrise = $WebResponse.liveweer.sup -replace ":",""
   $Sunrise = $Sunrise | Where-Object {$_.trim() -ne "" }
   $CurrentTime = Get-Date -Format HHmm
   $CurrentTime = $CurrentTime | Where-Object {$_.trim() -ne "" }

   # Set to light mode between sunrise and sunset
   If($CurrentTime -gt $Sunrise -and $CurrentTime -lt $Sunset){
      Write-Host ("LOG: It's between sunrise and sunset. Setting theme to Light.")
      $Wallpaper = $LightWallpaper
      $RegFile = "$ScriptDir\Light.reg"
   }
   # Set to dark mode from sunset to sunrise
   Else {
      Write-Host ("LOG: It's between sunset and sunrise. Setting theme to Dark.")
      $Wallpaper = $DarkWallpaper
      $RegFile = "$ScriptDir\Dark.reg"
   }   
}

# Apply settings based on set variables
Write-Host ("LOG: Import registry settings from: $RegFile")
reg import $RegFile
Stop-Process -Name explorer -Force

If($LightWallpaper -ne "" -and $DarkWallpaper -ne ""){
$code = @' 
   using System.Runtime.InteropServices; 
   namespace Win32{ 
      
      public class Wallpaper{ 
         [DllImport("user32.dll", CharSet=CharSet.Auto)] 
            static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
            
            public static void SetWallpaper(string thePath){ 
               SystemParametersInfo(20,0,thePath,3); 
            }
      }
   } 
'@

Add-Type $code
Write-Host ("LOG: Setting background image: $Wallpaper")
[Win32.Wallpaper]::SetWallpaper($Wallpaper)
}
Write-Host ("")