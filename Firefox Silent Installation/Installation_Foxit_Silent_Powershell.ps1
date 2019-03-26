$servers = "Hyperv10", "Hyperv11", "Hyperv12", "Hyperv13", "Hyperv14", "Hyperv15", "Hyperv16", "Hyperv17", "Hyperv18", "Hyperv19", "Hyperv20", "Hyperv21"
foreach ($server in $servers)
{
    New-item -ItemType Directory -Path "\\$server\c$\system"
    Copy-Item -Path "C:\system\FoxitReader83_L10N_Setup_Prom.exe" -Destination "\\$server\c$\system\"
    Invoke-Command -ComputerName $server -ScriptBlock { Start-Process -FilePath "C:\system\FoxitReader83_L10N_Setup_Prom.exe" -ArgumentList '/ForceInstall /VERYSILENT DESKTOP_SHORTCUT="1" MAKEDEFAULT="1" VIEWINBROWSER="0" LAUNCHCHECKDEFAULT="1" AUTO_UPDATE="2" /passive /norestart' -Wait }
}