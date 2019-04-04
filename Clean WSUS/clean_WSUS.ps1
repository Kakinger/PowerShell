<#
windows server updates (WSUS) cleanup script
server: wsus
date: 15.11.2018 @JanKappen
web: www.zueschen.eu
#>

$server = "wsus_server"
$port = "8531"
$useSSL = $true
$DeclineSupersededUpdates = $true
$DeclineExpiredUpdates = $true
$CleanupObsoleteUpdates = $true
$CompressUpdates = $true
$CleanupObsoleteComputers = $false
$CleanupUnneededContentFiles = $true
$date = get-date

# Grundbefehl
$command = "Get-WsusServer $server -port $port"

# Erstellen von custom Befehl mit benötigten Parametern
if ($useSSL -eq $true) { $command = $command + " -useSSL" }
$command = $command + " | Invoke-WsusServerCleanup"
if ($DeclineSupersededUpdates -eq $true) { $command = $command + " -DeclineSupersededUpdates" }
if ($DeclineExpiredUpdates -eq $true) { $command = $command + " -DeclineExpiredUpdates" }
if ($CleanupObsoleteUpdates -eq $true) { $command = $command + " -CleanupObsoleteUpdates" }
if ($CompressUpdates -eq $true) { $command = $command + " -CompressUpdates" }
if ($CleanupObsoleteComputers -eq $true) { $command = $command + " -CleanupObsoleteComputers" }
if ($CleanupUnneededContentFiles -eq $true) { $command = $command + " -CleanupUnneededContentFiles" }

# Aufräumen mit den gewünschten Parametern
Write-Host -ForegroundColor Green "Ausführung von:"
Write-Host -ForegroundColor Green "$command"
$output = Invoke-Expression $command

# Logging der Ausgabe
Add-Content -Path C:\Windows\Logs\wsus_cleanup.log -Value "##############"
Add-Content -Path C:\Windows\Logs\wsus_cleanup.log -Value "$date `n"
Add-Content -Path C:\Windows\Logs\wsus_cleanup.log -Value "$output `n`n"
