<#    
    .SYNOPSIS
    Erstellung von einem Webserver-Zertifikat mit einer Windows CA
    .DESCRIPTION
    PowerShell Skript zur automatischen Erstellung von einem 
        Webserver-Zertifikat inkl. Key. Mit Hilfe von OpenSSL
        für Windows werden ebenfalls .pem und .key-Dateien ausgegeben
    .EXAMPLE
    C:\tools\CreateWebserverCertificate.ps1
    .NOTES
    Date:    04.12.2019
    Author:  Jan Kappen
    Website: https://www.zueschen.eu
    Twitter: @JanKappen

    Wichtig: Die folgenden Dateien werden benötigt:
        - webserver.json => Diese Datei enthält die Namen für das Zertifikat
        - Request-Certificate.ps1 => Dieses Skript sorgt für die Erstellung der Zertifikate
          Das Skript ist verfügbar über:
          https://gallery.technet.microsoft.com/scriptcenter/Request-certificates-from-b6a07151 oder
          https://github.com/J0F3/PowerShell
        - OpenSSL für Windows
          https://wiki.openssl.org/index.php/Binaries
#>

# Grundparameter
$Sourcefile = "C:\tools\webserver.json"
$PasswortLaenge = "20"


# JSON-Datei einlesen und auswerten
$x = Get-Content -path $Sourcefile | ConvertFrom-Json
$x | Select-Object SubjectName, @{Name = "dns"; Expression={'DNS=' + ($_.DnsNames -join ',DNS=')}} | %{

$CATemplate = "Meine-CA-WebServer"
$CAName = "meineCA.contoso.local\Meine Intermediate CA"
$CommonName = $_.SubjectName.replace("CN=","")
$DNS = $_.dns
$PFX = "C:\cert\$($CommonName).pfx"
$outCER = "C:\cert\$($CommonName).cer"
$outPEM = "C:\cert\$($CommonName).pem"
$outKEY = "C:\cert\$($CommonName).key"



Write-Host "$Commonname SAN: $dns`n"

# Funktion zur Generierung von einem zufälligen Kennwort
Function Get-RandomPassword ([Int32]$Length)
{
    $Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    For ($i = 0; $i -le $Length; $i++) {
        $Password += $Chars[(Get-Random -Maximum $Chars.Length)]
    }
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    Return @{
        Password = $Password
        SecurePassword = $SecurePassword
        }
}

# Funktion zur Entfernung von temporären Zertifikat
Function Clean-CertificateRequest {
    $Certificate = Get-ChildItem -Path cert:\localMachine\my | where subject -eq CN=$CommonName
    Remove-Item $certificate.PSPath
}

# Funktion zur Generierung von Openssl Zertifikaten
Function Create-opensslcertificates {
    $pass = $pfxpwd.Password
    C:\"Program Files"\OpenSSL-Win64\bin\openssl.exe pkcs12 -in $PFX -nocerts -out $outPEM -nodes -passin pass:$pass
    C:\"Program Files"\OpenSSL-Win64\bin\openssl.exe pkcs12 -in $PFX -nokeys -out $outCER -passin pass:$pass
    C:\"Program Files"\OpenSSL-Win64\bin\openssl.exe rsa -in $outPEM -out $outKEY 
}

# Zertifikat anfragen
Write-Host -ForegroundColor Green "Erstellung von Zertifikat"
c:\tools\Request-Certificate.ps1 -CN $CommonName -SAN $DNS -TemplateName $CATemplate -CAName $CAName

# Zertifikat wieder einlesen
$a = Get-ChildItem -Path cert:\localMachine\my | where subject -eq CN=$CommonName

# Kennwort generieren
Write-Host -ForegroundColor Green "Kennwort generieren"
$pfxpwd = Get-RandomPassword -Length $PasswortLaenge

# Ausgabe von Kennwort und Datei
Write-Host -ForegroundColor Green "`nPasswort:" $pfxpwd.Password
Export-PfxCertificate –Cert $a[0] –FilePath "C:\cert\$($CommonName).pfx" -Password $pfxpwd.SecurePassword
$pfxpwd.Password | Out-File -FilePath "C:\cert\$($CommonName).txt" -Encoding ascii

# Temporäres Zertifikat in lokalem Speicher wieder löschen
Write-Host -ForegroundColor Green "Aufräumen"
Clean-CertificateRequest

# Openssl-Zertifikate erstellen
Write-Host -ForegroundColor Green "Openssl Zertifikate erstellen"
Create-opensslcertificates

# Done
Write-Host "`n Vorgang abgeschlossen"
}
