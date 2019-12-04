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
    $Certificate = Get-ChildItem -Path cert:\localMachine\my | where subject -match CN=$shortname
    Remove-Item $certificate.PSPath
}

# Werte einlesen
$x = Get-Content -path C:\tools\user.json | ConvertFrom-Json
$CATemplate = "Meine-CA-Benutzer-Zertfikat-exportierbar"
$CAName = "meineCA.contoso.local\Meine Intermediate CA"
$CommonName = $x.SubjectName.replace("CN=","")
$shortname = $CommonName.Split(",")
$shortname = $shortname[0]

Write-Host -ForegroundColor Green "$Commonname"`n

# Zertifikat anfragen
Write-Host -ForegroundColor Green "`nErstellung von Zertifikat"
c:\tools\Request-Certificate.ps1 -CN $CommonName -TemplateName $CATemplate -CAName $CAName

# Zertifikat wieder einlesen
$a = Get-ChildItem -Path cert:\LocalMachine\my | where subject -match CN=$shortname

# Kennwort generieren
Write-Host -ForegroundColor Green "`nKennwort generieren"
$pfxpwd = Get-RandomPassword -Length 20

# Ausgabe von Kennwort und Datei
Write-Host -ForegroundColor Green "`nPasswort:" $pfxpwd.Password
Export-PfxCertificate –Cert $a[0] –FilePath "C:\cert\$($shortname).pfx" -Password $pfxpwd.SecurePassword
$pfxpwd.Password | Out-File -FilePath "C:\cert\$($shortname).txt" -Encoding ascii

# Temporäres Zertifikat in lokalem Speicher wieder löschen
Write-Host -ForegroundColor Green "`nAufräumen"
Clean-CertificateRequest

Write-Host -ForegroundColor Green "`n Vorgang abgeschlossen"
