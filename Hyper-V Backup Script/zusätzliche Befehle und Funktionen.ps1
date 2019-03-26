#region Test auf Integrationskomponente "Herunterfahren"
function ComponentFunction
{
    $vmShutdownIC = get-vm -Name $VM | Get-VMIntegrationService
    if ($vmShutdownIC.name -eq "Shutdown")
    {
        $lang = "ENG"
        write-host $lang
    }
    else
    {
        if ($vmShutdownIC.name -eq "Herunterfahren")
        {
            $lang = "DEU"
            write-host $lang
        }
        else
        {
            write-host -ForegroundColor Red "Abbruch"
        }
    }
}
#endregion
############################################################
#region Überprüfung auf shutdown - ALT!
$vmShutdownIC = Get-VM –Name $VM | Get-VMIntegrationService –Name Herunterfahren
if($vmShutdownIC.enabled -match "True")
    {
    if ($verbose -eq $true) { Write-Host (Get-Date) "Der Integrationsdienst 'Herunterfahren' ist aktiviert" }
                              $temp1 = (Get-Date)
                              $temp2 = "Der Integrationsdienst 'Herunterfahren' ist aktiviert"
                              "$temp1 - $temp2" | Out-File $Logdatei -Append
    }
    else
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "Der Integrationsdienst 'Herunterfahren' ist NICHT aktiviert. VM kann nur gespeichert werden!" }
                                  $temp1 = (Get-Date)
                                  $temp2 = "Der Integrationsdienst 'Herunterfahren' ist NICHT aktiviert. VM kann nur gespeichert werden!"
                                  "$temp1 - $temp2" | Out-File $Logdatei -Append
            if($Speichern.IsPresent -match "True") { 
                                                     if ($verbose -eq $true) { Write-Host (Get-Date) "VM kann trotzdem exportiert werden, da sie gespeichert wird" }
                                                     $temp1 = (Get-Date)
                                                     $temp2 = "VM kann trotzdem exportiert werden, da sie gespeichert wird"
                                                     "$temp1 - $temp2" | Out-File $Logdatei -Append
                                                   }
            else
            { 
            if ($verbose -eq $true) { Write-Host (Get-Date) "Vm wird nicht exportiert, Abbruch!" }
            $temp1 = (Get-Date)
            $temp2 = "Vm wird nicht exportiert, Abbruch!"
            $temp3 = "---------------------------------"
            "$temp1 - $temp2" | Out-File $Logdatei -Append
            "$temp3" | Out-File $Logdatei -Append
            exit 
            }
    }
#endregion

#region Status der VM
$vmstatus = Get-VM –Name $VM
    if($vmstatus.State -match "Running")
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "VM ist eingeschaltet" }
                                $temp1 = (Get-Date)
                                $temp2 = "VM ist eingeschaltet"
                                "$temp1 - $temp2" | Out-File $Logdatei -Append
        #################################
        # Abfrage auf Speichern-Zustand #
    	#################################
        if($Speichern.IsPresent -match "True")
            {
        ####################
        # Speichern der VM #
    	####################
                if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird gespeichert" }
                                        $temp1 = (Get-Date)
                                        $temp2 = "VM wird gespeichert"
                                        "$temp1 - $temp2" | Out-File $Logdatei -Append
            Save-VM -Name $VM
               }
            else
            {
        #########################################
        # Kein Speichern, Herunterfahren der VM #
    	#########################################
                if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird heruntergefahren" }
                                        $temp1 = (Get-Date)
                                        $temp2 = "VM wird heruntergefahren"
                                        "$temp1 - $temp2" | Out-File $Logdatei -Append
            ################################
            # Warten auf ausgeschaltete VM #
    	    ################################
            Stop-VM -Name $VM -Force
            }
        }
    else
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "VM ist bereits ausgeschaltet" }
                                $temp1 = (Get-Date)
                                $temp2 = "VM ist bereits ausgeschaltet"
                                "$temp1 - $temp2" | Out-File $Logdatei -Append
    }
#endregion
########################################
#region Start der VM
if ($verbose -eq $true) { Write-Host (Get-Date) "Ueberpruefung auf Startverhalten nach Export" }
                        $temp1 = (Get-Date)
                        $temp2 = "Ueberpruefung auf Startverhalten nach Export"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
        ###################################
        # Ueberpruefung auf Stop-Schalter #
        ###################################
        if ($Auslassen.IsPresent -eq $False)
            { if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird eingeschaltet" }
                                    $temp1 = (Get-Date); $temp2 = "VM wird eingeschaltet"; "$temp1 - $temp2" | Out-File $Logdatei -Append
            Start-VM -Name $VM }
        else
            { if ($verbose -eq $true) { Write-Host (Get-Date) "VM bleibt ausgeschaltet" }
                                    $temp1 = (Get-Date)
                                    $temp2 = "VM bleibt ausgeschaltet"
                                    $temp3 = "---------------------------------"
                                    "$temp1 - $temp2" | Out-File $Logdatei -Append
                                    "$temp3" | Out-File $Logdatei -Append }
#endregion
#################################################
function MailFunction
{
    if ($verbose -eq $true) { Write-Host (Get-Date) "Ueberpruefung auf Sendung einer Status-Mail" }
                        $temp1 = (Get-Date)
                        $temp2 = "Ueberpruefung auf Sendung einer Status-Mail"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
###########################################################################

        if ($statusmail.IsPresent -eq $False)
            { if ($verbose -eq $true) { Write-Host (Get-Date) "Es wird keine Email versendet" }
                                    $temp1 = (Get-Date)
                                    $temp2 = "Es wird keine Email versendet"
                                    "$temp1 - $temp2" | Out-File $Logdatei -Append }
        else
##################################
# Email versenden mit Status-Log #
##################################
         { if ($verbose -eq $true) { Write-Host (Get-Date) "Es wird eine Email versendet" }
                                   $temp1 = (Get-Date)
                                   $temp2 = "Es wird eine Email versendet"
                                   "$temp1 - $temp2" | Out-File $Logdatei -Append

########################################################################
# Ab hier muessen die persoenlichen Einstellungen konfiguriert werden! #
########################################################################

{ if ($verbose -eq $true) { Write-Host (Get-Date) "Diese Zeile muss auskommentiert werden!" }

# $mail = @{
#    SmtpServer = 'mailer.domain.loc'
#    Port = 25
#    From = 'backupskript@rachfahl.de'
#    To = 'empfaenger@domain.loc'
#    Subject = "'Script-Sicherung der VM' $VM"
#    Body = "'Anbei das Log der Export-Sicherung von VM' $VM"
#    Attachments = "$Logdatei"
# }
# Send-MailMessage @mail }
} }
}
#endregion

