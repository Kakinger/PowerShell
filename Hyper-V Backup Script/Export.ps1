#region
##############################################################################################
# Script zum Export von VMs unter Hyper-V mit Windows Server 2016 oder Windows 10 Pro        #
# erstellt von Jan Kappen - j.kappen@rachfahl.de                                             #
# Version 0.4.1                                                                              #
# 06. Mai 2017                                                                               #
# Diese Script wird bereitgestellt wie es ist, ohne jegliche Garantie. Der Einsatz           #
# erfolgt auf eigene Gefahr. Es wird jegliche Haftung ausgeschlossen.                        #
# Wer dem Autor etwas Gutes tun möchte, er trinkt gern ein kaltes Corona :)                  #
#                                                                                            #
# Dieses Script beinhaltet keine Hilfe. RTFM.                                                #
#                                                                                            #
# www.hyper-v-server.de | www.rachfahl.de                                                    #
#                                                                                            #
##############################################################################################
#endregion

Param(
	[string] $VM ="",
	[string] $Exportpfad = "",
	[string] $Logpfad = "",
	[switch] $Speichern,
    [switch] $ProductionCheckpoint,
    [switch] $Herunterfahren,
    [switch] $statusmail
)

function Mail
{
    Write-Host -ForegroundColor Red (Get-Date) "Die Mail-Konfiguration muss angepasst werden, sonst ist kein Mailversand möglich!"
    # $mail = @{
    #    SmtpServer = 'mailer.domain.loc'
    #    Port = 25
    #    From = 'backupskript@rachfahl.de'
    #    To = 'empfaenger@domain.loc'
    #    Subject = "'Script-Sicherung der VM' $VM"
    #    Body = "'Anbei das Log der Export-Sicherung von VM' $VM"
    #    Attachments = "$Logdatei"
    # }
    # Send-MailMessage @mail
}

#region Logdatei
$LogDateiDatum = Get-Date -Format yyyy-MM-dd
if (!$Logpfad) {
                    $LogPfadVorhanden = Test-Path ${env:homedrive}\windows\Logs\HyperVExport\
                    if ($LogPfadVorhanden -eq $False) { new-item ${env:homedrive}\windows\Logs\HyperVExport\ -itemtype directory }
                    $Logdatei = "${env:homedrive}\windows\Logs\HyperVExport\$LogDateiDatum.log" 
                }
                else 
                { $Logdatei = "$Logpfad\$LogDateiDatum.log" }
# Start logging
Start-Transcript -Path $Logdatei -Append
#endregion

#region Abfrage auf benötigte Parameter
if (!$VM) { 
              Write-Host -ForegroundColor Red (Get-Date) "Parameter -VM muss vorhanden sein und einen Namen enthalten. Abbruch!"
              exit 
          }
if (!$Exportpfad) { 
                      Write-Host -ForegroundColor Red (Get-Date)  "Parameter -RemotePfad muss vorhanden sein und einen Pfad enthalten. Abbruch!"
                      exit
                  }
#endregion

#region Export der VM
if ($Speichern -match "true")
{
    Write-Host -ForegroundColor Green (Get-Date) "VM wird gespeichert"
    Save-VM -Name $VM -verbose
    Write-Host -ForegroundColor Green (Get-Date) "Export der VM"
    $ZielPfadVorhanden = Test-Path $Exportpfad\$VM
    if 
        ($ZielPfadVorhanden -eq $False) { Export-VM -Name $VM -Path $Exportpfad -verbose }
    else 
        { Remove-Item -Recurse -Force $Exportpfad\$VM -verbose; Export-VM -Name $VM -Path $Exportpfad -verbose }
    Write-Host -ForegroundColor Green (Get-Date) "Export abgeschlossen, VM wird wieder eingeschaltet"
    Start-VM -Name $VM -verbose
    if ($statusmail -match "true")
        { Mail; exit }
    else
        { exit }
}

if ($Herunterfahren -match "true")
{
    $ShutdownStatus = get-vm -Name $VM | Get-VMIntegrationService | where { $_.Name -EQ "Shutdown" -or $_.Name -EQ "Herunterfahren" }
    if ($ShutdownStatus.Enabled -eq "True")
    {
        Write-Host -ForegroundColor Green (Get-Date) "Export scheint möglich zu sein, VM wird heruntergefahren"
        Stop-VM -Name $VM -Force -verbose
        Write-Host -ForegroundColor Green (Get-Date) "Export der VM"
        $ZielPfadVorhanden = Test-Path $Exportpfad\$VM
        if 
            ($ZielPfadVorhanden -eq $False) { Export-VM -Name $VM -Path $Exportpfad -verbose }
        else 
            { Remove-Item -Recurse -Force $Exportpfad\$VM -verbose; Export-VM -Name $VM -Path $Exportpfad -verbose }
        Write-Host -ForegroundColor Green (Get-Date) "VM wird wieder eingeschaltet"
        Start-VM -Name $VM -verbose
        if ($statusmail -match "true")
            { Mail; exit }
        else
            { exit }
    }
    else
    {
        Write-Host -ForegroundColor Red (Get-Date) "Export scheint nicht möglich zu sein, Vorgang wird abgebrochen!"
        exit
    }
}

if ($ProductionCheckpoint -match "true")
{
    $SnapshotName = "ExportScriptCheckpoint"
    Write-Host -ForegroundColor Green (Get-Date) "Checkpoint wird erstellt"
    $ZielPfadVorhanden = Test-Path $Exportpfad\$VM
    if 
        ($ZielPfadVorhanden -eq $False) 
        { Checkpoint-VM -Name $VM -SnapshotName $SnapshotName -verbose
          Export-VMSnapshot -VMName $VM -Name $SnapshotName -Path $Exportpfad -verbose
          Remove-VMSnapshot -VMName $VM -Name $SnapshotName -verbose
        }
    else 
        { Remove-Item -Recurse -Force $Exportpfad\$VM -verbose
          Checkpoint-VM -Name $VM -SnapshotName $SnapshotName -verbose
          Export-VMSnapshot -VMName $VM -Name $SnapshotName -Path $Exportpfad -verbose
          Remove-VMSnapshot -VMName $VM -Name $SnapshotName -verbose
        }
    Write-Host -ForegroundColor Green (Get-Date) "Export abgeschlossen"
    if ($statusmail -match "true")
        { Mail; exit }
    else
        { exit }
}
else
{
    Write-Host -ForegroundColor Green (Get-Date) "VM wird online exportiert"
    Write-Host -ForegroundColor Green (Get-Date) "Export der VM"
    $ZielPfadVorhanden = Test-Path $Exportpfad\$VM -verbose
    if 
        ($ZielPfadVorhanden -eq $False) { Export-VM -Name $VM -Path $Exportpfad -verbose }
    else 
        { Remove-Item -Recurse -Force $Exportpfad\$VM -verbose; Export-VM -Name $VM -Path $Exportpfad -verbose }
    Write-Host -ForegroundColor Green (Get-Date) "Export der VM $VM abgeschlossen"
    if ($statusmail -match "true")
        { Mail; exit }
    else
        { exit }
}
#endregion