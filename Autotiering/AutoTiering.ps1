# Defrag Script to catch Output of Autotiering Job
# Version 1.1 by c.rachfahl@rachfahl.de http://www.hyper-v-server.de
# Version 1.2 by j.kappen@rachfahl.de http://www.hyper-v-server.de

# if you want to get the results mailed, configure $SMTPServer
[string]$SMTPServer = ""
[string]$ToEMail = ""
[string]$FromEMail = ""
#[string]$SMTPServer = "yourmail.server.com"
#[string]$ToEmail = "Support <support@yourdomain.com>"
#[string]$FromEmail = "Autotiering Script $env:computername <Autotiering@" + ($env:computername).ToLower() + "." + ($env:USERDNSDOMAIN).ToLower() + ">"

# where should the logfile be saved?
[String]$LogFile = "C:\Windows\Logs\AutotieringReport.log"

# create tempfiles
[string]$TmpFile = [System.IO.Path]::GetTempFileName()
[string]$TmpFile2 = [System.IO.Path]::GetTempFileName()

# defrag options for autotiering optimization
$os = (Get-WmiObject -class Win32_OperatingSystem).Caption
if ($os -match "Windows Server 2012 R2") { [String]$DefragOptions = "-c -h -g -#" }
else
{ if ($os -match "Windows Server 2016")
{ [String]$DefragOptions = "-c -h -g -# -m 8 -i 13500" }
else
{ exit }
}

# set Get-Date output format (infos: http://msdn.microsoft.com/en-us/library/system.globalization.datetimeformatinfo(VS.85).aspx)
[String]$DateOutputFormat = "dddd, dd MMMM yyyy HH:mm:ss"

# write the start timestamp into $Tmpfile
$startDateStr = Get-Date -Format $DateOutputFormat
Write-Output "`n" | Out-File $TmpFile
Write-Output "Defrag started at: $startDateStr" | Out-File $TmpFile -Append
Write-Output "`n" | Out-File $TmpFile -Append

# start the Autotiering optimisation and log it into $Tmpfile2
Start-Process -FilePath "C:\windows\System32\Defrag.exe" -ArgumentList "$DefragOptions" -NoNewWindow:$true -Wait -RedirectStandardOutput $TmpFile2

# append $TmpFile2 to $TmpFile
Get-Content $TmpFile2 | Out-File $TmpFile -Append

# get the last Eventlog in the Storage-Tiering Eventlog
#$eventLog = (Get-WinEvent -LogName "Microsoft-Windows-Storage-Tiering/Admin" | Select-Object -First 1).Message
$eventLog = Get-WinEvent -LogName "Microsoft-Windows-Storage-Tiering/Admin" | Select-Object -First 2
Write-Output "`n" | Out-File $TmpFile -Append
Write-Output "Last Entrys in Eventlog (Microsoft-Windows-Storage-Tiering/Admin):" | Out-File $TmpFile -Append
for ($i = 0; $i -lt $eventLog.count; $i++)
{
    $eventTime = $eventLog[$i].TimeCreated
    $eventMessage = $eventLog[$i].Message
    Write-Output "`n" | Out-File $TmpFile -Append
    Write-Output "$eventTime,  $eventMessage" | Out-File $TmpFile -Append
}

# write the stop timestamp into the $TmpFile
$stopDateStr = Get-Date  -Format $DateOutputFormat
Write-Output "`n`n" | Out-File $TmpFile -Append
Write-Output "Defrag finished at: $stopDateStr" | Out-File $TmpFile -Append

# apend TmpFile to LogFile
Get-Content $TmpFile | Out-File $LogFile -Append

# mail the result if $SMTPServer is not empty
if(($SMTPServer -ne "") -and ($ToEMail -ne "") -and ($FromEMail -ne "")){

    $Message = Get-Content $TmpFile
    $MailBody = $Message | Out-String 
    Send-MailMessage -SmtpServer $SMTPServer -From $FromEMail -To $ToEmail -Subject "Results of storage spaces autotiering optimizer on $env:computername" -Body $MailBody
}