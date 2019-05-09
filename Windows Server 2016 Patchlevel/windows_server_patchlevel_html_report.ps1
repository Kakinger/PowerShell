<#    
    .SYNOPSIS
    Auflistung aller Windows Server Patchlevel im WSUS als HTML Report
    .DESCRIPTION
    PowerShell Script zur Auflistung aller Windows Server
    und Sortierung nach Release/Build inkl. HTML Report
    .EXAMPLE
    C:\Scripts\windows_server_patchlevel_html_report.ps1
    .NOTES
    Date:    10.04.2019
    Author:  Jan Kappen
    Website: https://www.zueschen.eu
    Twitter: @JanKappen
#>

# Variablen und Einstellungen
$WSUSServer = "WSUS_Servername"
$Port = "8531"
$Groupname = "Server"
$date = Get-Date -UFormat "%Y%m%d"
$Logfile = "C:\temp\$date-wsus_server_log.log"
$HTMLFile = "C:\temp\$date-wsus_server_log.htm"
$SSL = $true

# Abfrage der möglichen Releases - Neuere Builds müssen hier hinzugefügt werden
$releases = "14393.2941","14393.2906","14393.2879","14393.2848","14393.2828","14393.2791","14393.2759","14393.2724","14393.2670","14393.2665","14393.2641","14393.2639","14393.2608","14393.2580","14393.2551","14393.2515","14393.2485","14393.2457","14393.2430","14393.2396","14393.2395","14393.2368","14393.2363","14393.2339","14393.2312","14393.2273","14393.2248","14393.2214","14393.2189","14393.2156","14393.2155","14393.2126","14393.2125","14393.2097","14393.2068","14393.2034","14393.2007","14393.1944","14393.1914","14393.1884","14393.1797","14393.1794","14393.1770","14393.1737","14393.1715","14393.1670","14393.1613","14393.1593","14393.1537","14393.1532","14393.1480","14393.1378","14393.1358","14393.1230","14393.1198","14393.1066","14393.1083","14393.970","14393.969","14393.953","14393.729","14393.726","14393.693","14393.576","14393.479","14393.448","14393.447","14393.351","14393.321"

# Prüfung auf benötigtes Modul
if (-not (Get-Module -ListAvailable -Name ReportHTML)) {
    Write-Host -ForegroundColor Red 'Benötigtes Modul "ReportHTML" nicht vorhanden, Abbruch!'`n
    Write-Host -ForegroundColor Green 'Installation muss mir "Install-Module -Name ReportHTML" durchgeführt werden'
    Write-Host -ForegroundColor Green 'Weitere Infos unter "https://www.powershellgallery.com/packages/ReportHTML/"'
    # Hilfe und Anleitung: https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/06/Help-ReportHTML2.html
    exit 
}

# Abfrage der WSUS-Clients
if ($SSL -eq $true) {
    $Clients = Get-WsusServer -Name $WSUSServer -Port $Port -UseSsl | get-wsuscomputer -ComputerTargetGroups $Groupname | select FullDomainName, IPAddress, ClientVersion, OSDescription, RequestedTargetGroupName
} else {
    $Clients = Get-WsusServer -Name $WSUSServer -Port $Port | get-wsuscomputer -ComputerTargetGroups $Groupname | select FullDomainName, IPAddress, ClientVersion, OSDescription, RequestedTargetGroupName
}

# Bau den Report
$rpt = @()
$rpt += Get-HTMLOpenPage -TitleText "WSUS Status Übersicht - Windows Server 2016 Patchlevel" -HideLogos

$rpt += Get-HtmlContentOpen -HeaderText "Weitere Informationen - https://support.microsoft.com/en-us/help/4000825/windows-10-windows-server-2016-update-history"
$rpt += Get-HTMLContentClose

#region
foreach ($release in $releases) {

    # Auflistung der Systeme und Zuordnung zu Build-Version
    $x = @()
    foreach ($Client in $Clients) {
        if ($Client.ClientVersion -match $release) {
            $x += $Client
        }}

    ### Hinzufügen zu Liste (nur wenn Variable nicht leer)
    if ($x) {
        $rpt += Get-HtmlContentOpen -HeaderText "OS-Build $release"
            $rpt+= Get-HtmlContentTable $x
        $rpt += Get-HTMLContentClose 
    }
}

#
$rpt += Get-HTMLClosePage  
$rpt | set-content -path "c:\temp\server_status.html"

# Ablegen der Output-Datei im IIS-Verzeichnis
Set-Content -Value $rpt -path "C:\inetpub\wwwroot\server_status.html"  
