# Introduction
I am a fan of the light mode in Windows 11. However, it can be a bit too much when I'm working in our home office and when it's dark outside. I'm really missing a feature that switches from light to darkmode based on the time of the day, and vice versa. That is why I developed this script which is running as a service, and checks every 15 minutes if it's either sunrise or sunsite time and changes the color mode accordingly.

> [!IMPORTANT]  
> Currently the script only works with an API from [Weerlive](https://weerlive.nl). I'm planning to add support for Home Assistant sensors.

# Requirements
* Download the files from this repository and save them to `C:\Scripts\Set-WindowsColorMode`
* (Optional) Create an account and request an API key at [Weerlive](https://weerlive.nl/delen.php)
  * Edit the Settings.ps1 file and:
    * Replace `<API KEY>` with the API you received
    * Replace `<CITY>` with the name of the city where you are based
    * Optionally change different wallpapers for light and dark modes
  * Save the Settings.ps1 file
* Start a elevated PowerShell prompt, browse to the folder you have stored the scripts, and run the following command:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -ErrorAction SilentlyContinue
Unblock-File .\Settings.ps1
Unblock-File .\Set-WindowsColorMode.ps1
Start-Process -FilePath .\nssm.exe -ArgumentList 'install "Windows Color Mode monitoring" "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-command "& { . C:\Scripts\Set-WindowsColorMode\Set-WindowsColorMode.ps1 }"" ' -NoNewWindow -Wait
Start-Service -Name "Windows Color Mode monitoring"
```

After completing the steps below, confirm if the color mode is updated as expected when it's either getting light or dark outside.