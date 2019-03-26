# Skript zur Erst-Konfiguration einer neuen VM
# Jan Kappen, j.kappen@rachfahl.de, 28.10.2015
#
#region Vorab definierte Variablen
$PrefixLength = "22"
$DefaultGateway = "10.10.10.1"
$DNSServers = ("10.10.10.2","10.10.10.3")
$Domainname = "domain.de"
#endregion

#region Ausgabe der vordefinierten Einstellungen
Write-Host "Prefix-Länge:      " $PrefixLength
Write-Host "Default Gateway:   " $DefaultGateway
Write-Host "DNS-Server:        " $DNSServers
Write-Host "Name der Domain:   " $Domainname
Write-Host ""

Write-Host -ForegroundColor Green "Wenn diese Einstellungen korrekt sind, bestätigen Sie dies mit 'Y'"
Write-Host -ForegroundColor Green "Möchten Sie eigene Werte eingeben, bestätigen Sie dies mit 'N'"
$Abfrage = Read-Host "Ihre Auswahl (Y/N)"
#endregion

#region Abfrage auf korrekte Einstellungen
if ($Abfrage -eq "Y")
{
    # Einrichtung mit Standard-Werten
    Write-Host -ForegroundColor Green "Einrichtung wird fortgesetzt..."
    Write-Host ""
    # Konfiguration der RDS VMs
    #Abfrage der Hostnummer
    Write-Host -ForegroundColor Green "Abfrage des Hostnamen und des Kennworts zur Aufnahme in AD"
    Sleep -Seconds 3
    $HostName = Read-Host "Geben Sie den Hostnamen ein"
    $Credentials = Get-Credential -Message "Domain Join Benutzer" -UserName "domain\Administrator"

    # Löschen von unattend-Datei im Sysprep-Verzeichnis
    Remove-Item "C:\unattend.xml" -Force

    #region Anzeige der Adapter und MAC-Adressen
    Write-Host -ForegroundColor Green "Es folgt eine Auflistung der Netzwerkadapter in dieser VM"
    Write-Host""
        Get-NetAdapter | ft Name, InterfaceDescription, MacAddress
    Write-Host ""
    Write-Host -ForegroundColor Green "Im nächsten Schritt wird der Management-Adapter umbenannt"
        $Adapter1 = Read-Host "Geben Sie den Namen der Karte ein, die in 'Management' umbenannt werden soll"
        Rename-NetAdapter –Name $Adapter1 –NewName Management
    Write-Host ""
        Get-NetAdapter | ft Name, InterfaceDescription, MacAddress
    #endregion

    # Konfiguration der IP-Adressen
    #region Management
    Write-Host -ForegroundColor Green "Konfiguration der IP-Einstellungen"
    Sleep -Seconds 1
        $IPAddress = Read-Host "Bitte geben Sie die IP-Adresse für diesen Server ein"
        Set-NetIPInterface -InterfaceAlias "Management" -dhcp Disabled
        New-NetIPAddress -AddressFamily IPv4 -PrefixLength $PrefixLength -InterfaceAlias "Management" -IPAddress $IPAddress -DefaultGateway $DefaultGateway
        # Set-NetAdapterBinding -Name "Management" -ComponentID ms_tcpip6 -Enabled $False
        Set-DnsClientServerAddress -InterfaceAlias "Management" -ServerAddresses $DNSServers
    #endregion

    # Umbenennen des Hosts und Aufnahme in Active Directory
    Write-Host -ForegroundColor Green "Aufnahme des Servers in die AD"
    Sleep -Seconds 1
        Add-Computer -NewName $Hostname -DomainName $Domainname -Credential $Credentials # -OUPath 'ou=OU'
    # Neustart
    Write-Host -ForegroundColor Green "Neustart des Hosts nach Aufnahme in AD"
    Sleep -Seconds 3
        Restart-Computer
}
else
{
    if ($Abfrage -eq "N")
    {
        # Einrichtung mit eigenen Werten
        $PrefixLength = Read-Host "Geben Sie die Subnetzmaske als Prefix an (24 = 255.255.255.0, usw...)" # "22"
        $DefaultGateway = Read-Host "Geben Sie die Adresse des Standard-Gateway an" # "10.10.10.1"
        $DNSServers = Read-Host "Geben Sie die die DNS-Server ein (Mehrere Adressen mit Komma getrennt, keine Leerzeichen)" # ("10.10.10.2","10.10.10.3")
        $Domainname = Read-Host "Geben Sie den Namen der Domäne inkl. Endung ein (z.B. domain.de)" # "domain.de"

        Write-Host -ForegroundColor Green "Manuelle Einrichtung"
        Write-Host ""
        # Konfiguration der RDS VMs
        #Abfrage der Hostnummer
        Write-Host -ForegroundColor Green "Abfrage des Hostnamen und des Kennworts zur Aufnahme in AD"
        Sleep -Seconds 3
        $HostName = Read-Host "Geben Sie den Hostnamen ein"
        $Credentials = Get-Credential -Message "Domain Join Benutzer" -UserName "domain\Administrator"

        # Löschen von unattend-Datei im Sysprep-Verzeichnis
        Remove-Item "C:\unattend.xml" -Force

        #region Anzeige der Adapter und MAC-Adressen
        Write-Host -ForegroundColor Green "Es folgt eine Auflistung der Netzwerkadapter in dieser VM"
        Write-Host""
            Get-NetAdapter | ft Name, InterfaceDescription, MacAddress
        Write-Host ""
        Write-Host -ForegroundColor Green "Im nächsten Schritt wird der Management-Adapter umbenannt"
            $Adapter1 = Read-Host "Geben Sie den Namen der Karte ein, die in 'Management' umbenannt werden soll"
            Rename-NetAdapter –Name $Adapter1 –NewName Management
        Write-Host ""
            Get-NetAdapter | ft Name, InterfaceDescription, MacAddress
        #endregion

        # Konfiguration der IP-Adressen
        #region Management
        Write-Host -ForegroundColor Green "Konfiguration der IP-Einstellungen"
        Sleep -Seconds 1
            $IPAddress = Read-Host "Bitte geben Sie die IP-Adresse für diesen Server ein"
            Set-NetIPInterface -InterfaceAlias "Management" -dhcp Disabled
            New-NetIPAddress -AddressFamily IPv4 -PrefixLength $PrefixLength -InterfaceAlias "Management" -IPAddress $IPAddress -DefaultGateway $DefaultGateway
            # Set-NetAdapterBinding -Name "Management" -ComponentID ms_tcpip6 -Enabled $False
            Set-DnsClientServerAddress -InterfaceAlias "Management" -ServerAddresses $DNSServers
        #endregion

        # Umbenennen des Hosts und Aufnahme in Active Directory
        Write-Host -ForegroundColor Green "Aufnahme des Servers in die AD"
        Sleep -Seconds 1
            Add-Computer -NewName $Hostname -DomainName $Domainname -Credential $Credentials # -OUPath 'ou=OU'
        # Neustart
        Write-Host -ForegroundColor Green "Neustart des Hosts nach Aufnahme in AD"
        Sleep -Seconds 3
        Restart-Computer
    }
    else
    {
        Write-Host -ForegroundColor Red "Abbruch der Einrichtung!"
        exit
    }
}
#endregion