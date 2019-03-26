# Version 0.1, j.kappen@rachfahl.de, http://www.hyper-v-server.de
#
Write-Host -ForegroundColor Green "Info: Dieser Installer funktioniert nicht bei einem Aufruf per ISE"
# create C:\tools, if needed - asking for "false" doesn't work -.-
Write-Host -ForegroundColor Green "Test auf Verfügbarkeit von C:\tools, falls nicht vorhanden wird der Ordner angelegt"
$path = Test-Path C:\Tools
if ($path -eq 'True') 
{} 
else 
{New-Item -ItemType Directory C:\Tools}
# copy the script to C:\tools
Write-Host -ForegroundColor Green "Kopie des AutoTiering-Skripts nach C:\tools\"
Copy-Item .\AutoTiering.ps1 C:\tools\
# change autotiering task
Write-Host -ForegroundColor Green "Anpassung von geplanten Task"
$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe" -Argument 'C:\tools\AutoTiering.ps1'
$path = (Get-ScheduledTask "Storage Tiers Optimization").TaskPath
Set-ScheduledTask -TaskName "Storage Tiers Optimization" -Action $action -TaskPath $path