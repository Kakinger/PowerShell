
# Script zum Export von VMs unter Hyper-V mit Windows Server 2016 oder Windows 10 Pro        
erstellt von Jan Kappen - j.kappen@rachfahl.de					     
Version 0.4.1										     
06. Mai 2017										     
Diese Script wird bereitgestellt wie es ist, ohne jegliche Garantie. Der Einsatz	     
erfolgt auf eigene Gefahr. Es wird jegliche Haftung ausgeschlossen.			     
Wer dem Autor etwas Gutes tun möchte, er trinkt gern ein kaltes Corona :)                  
											     
Dies ist die Hilfe :)									     
											     
www.hyper-v-server.de | www.rachfahl.de						     



# Erklärung der Funktionsweise

Dieses Script exportiert manuell oder per Taskplaner jeweils eine VM. Standardmäßig wird die VM online exportiert. 
Die VM wird alternativ je nach Wunsch gespeichert oder heruntergefahren, die Möglichkeit eines sauberen Shutdown wird getestet, 
indem die Integrationskomponente "Herunterfahren" bzw "Shutdown" abgefragt wird. Dies ist jedoch keine 100%ige Gewährleistung auf eine
vollständige und zuverlässige Unterstützung von einem Shutdown-Vorgang von außerhalb.
Weiterhin kann ein Production Checkpoint erstellt und exportiert werden. Bei diesem Vorgang wird neben einem Checkpoint noch in der VM ein
VSS-Snapshot erzeugt. Dies setzt die VM in einen konsistenten Zustand, die Daten der VM sollten so konsistent gesichert werden.
Wichtig: Die Funktion des Production Checkpoints wird nicht überprüft, dies muss von Ihnen aus konfiguriert werden!
Wenn die Shutdown-Funktion nicht verfügbar ist und kein Speichern der VM ausgewählt wurde, wird das Script beendet. Falls die Komponente aktiviert ist 
kann die VM versucht werden, per "Herunterfahren" von außen sauber heruntergefahren zu werden. Hierbei wird per Parameter ein 
Herunterfahren erzwungen, zum Zeitpunkt offene Dateien verzögern den Vorgang, die VM wird nach einer gewissen Zeit aber trotzdem heruntergefahren.
Sie können einen Pfad auswählen, in dem die Logdatei der Sicherung erstellt wird. Wenn kein Parameter angegeben wird, werden die Logfiles 
im Windows-Log-Verzeichnis (per Standard C:\Windows\Logs\) im Unterordner "HyperVExport" erstellt. Falls dieser Ordner nicht vorhanden ist, wird 
der Ordner erstellt, falls er bereits vorhanden ist wird die Logdatei hier angelegt und gespeichert. Pro Tag wird ein eigenes Logfile erstellt, 
wenn an einem Tag mehrere Aktionen stattfinden werden die Ereignisse in diesem einem Log hintereinander protokolliert, es wird kein Log überschrieben. 
Auf Wunsch kann ein anderer Pfad für die Datei angegeben werden.
Wichtig: Standardmäßig werden die vorhandenen Export-Datei vor einem erneuten Export gelöscht.
Auf Wunsch können Sie sich das Logfile nach der Sicherung per Email schicken lassen. Hierzu ist eine Anpassung des Scripts notwendig, siehe unten.

Die Funktionsweise des Skripts wurde mit einem englischen Windows Server 2016 mit dem Dezember 2016 Patchlevel getestet.


# Mögliche Parameter des Scripts
# Pflicht-Parameter

-VM <Name der VM>
-Exportpfad "D:\Pfad zum gewünschten\Exportordner"


# Optionale Parameter

-Speichern
-Herunterfahren
-ProductionCheckpoint
-Logpfad "D:\Pfad zum gewünschten\Logfileordner"
-statusmail


# Erklaerung der Parameter

-VM: 			Dieser Parameter gibt den Namen des Systems an, welches exportiert werden soll. Dieser Parameter ist notwendig.

-Exportpfad: 		Gibt den Pfad an, in den der Export erstellt wird. Dieser Parameter ist notwendig.

-Speichern: 		Falls die VM nicht online gesichert oder heruntergefahren werden kann oder soll, kann mit diesem Paramater 
			das Speichern der VM erzwungen werden. Diese Option ist keine Pflicht, falls eine VM allerdings keine aktivierten 
			Integrationsdienste hat, wird dieser Parameter (oder Herunterfahren alternativ) verpflichtend.

-Herunterfahren:	Mit diesem Befehl wird die VM vor dem Export heruntergefahren. Dies ist natürlich nur bei VMs möglich, bei denen
			Hyper-V Integrationsdienste verfügbar und eingeschaltet sind. Ist dies nicht der Fall, muss die VM entweder online
			oder im gespeicherten Zustand exportiert werden.

-ProductionCheckpoint:	Mit diesem Parameter wird, wenn möglich, ein Production Checkpoint erstellt, exportiert und danach wieder entfernt.

-Logpfad: 		Falls nicht der Standard-Ort C:\Windows\Logs\HyperVExport genutzt werden soll, kann mit diesem Parameter und 
			der Eingabe eines Pfads die Logdatei an einem anderen Ort gespeichert werden.

-statusmail: 		Durch Angabe dieser Option wird eine Email versendet. Sie müssen für eine korrekte Übermittlung der Email 
			das Script manuell anpassen und die Daten Ihres Mailers sowie die Adresse des Empfängers eintragen. 
			Auf Wunsch kann eine andere Absender-Adresse eingetragen werden. Weitere Informationen finden Sie im Konfigurations-
			Menü dieser Option weiter unten in dieser Hilfe-Datei.


# Beispiele

Einfacher Export einer VM ohne weitere Optionen:
Export.ps1 -VM <VMName> -Exportpfad D:\Exports

Erstellung eines Production Checkpoints und Export von diesem Zustand:
Export.ps1 -VM <VMName> -Exportpfad D:\Exports -ProductionCheckpoint

Speichern einer VM und Export:
Export.ps1 -VM <VMName> -Exportpfad D:\Exports -Speichern

Herunterfahren einer VM und Export:
Export.ps1 -VM <VMName> -Exportpfad D:\Exports -Herunterfahren

Export einer VM und Umlenkung des Logs an einen anderen Speicherort:
Export.ps1 -VM <VMName> -Exportpfad D:\Exports -Logpfad "E:\Logfiles\Hyper-V Export\"


# Konfiguration des Email-Versands


Bearbeiten Sie das PowerShell-Script, ich empfehle hierzu das Programm "PowerShell ISE" oder Notepad++. Sie müssen die Zeilen 29 bis 39 anpassen.
1) Kommentieren Sie Zeile 29 aus, um die Ausgabe der Warnung zu entfernen
2) Entfernen Sie die Auskommentierung von Zeile 30 ($mail = ...) bis! Zeile 39 (Send-MailMessage ...)
3) Tragen Sie in den jeweiligen Zeilen die korrekten Werte ein
4) Speichern Sie die Datei und erlauben Sie den Versand von Emails auf Ihrem Mail-System

Bei dem Bedarf an weiteren Anpassungen schauen Sie sich die Eigenschaften dieses Befehls an, um z.B. die Verbindung per SSL zu erlauben
http://technet.microsoft.com/en-us/library/hh849925.aspx


# ChangeLog

Version 0.4.1:
Logging angepasst, Wechsel auf PowerShell-eigene Transcript-Möglichkeit

Version 0.4:
Möglichkeit eines Production Checkpoints hinzugefügt

Version 0.3:
Log-Verzeichnis nach <X>:\Windows\Logs\HyperVExport verlegt, wenn kein manuelles Verzeichnis angegeben wird
Support für Windows Server 2016
Online Export per Default, Herunterfahren und Speichern möglich
Verbose-Modus entfernt, standardmäßig eingeschaltet
Auslassen der VM nach dem Export entfernt
Abfrage der Shutdown-Integrationskomponenten in Englisch und Deutsch eingebaut
Deutlich schlankerer Code (Man lernt ja dazu ;))
Mail-Versand in eine Funktion ausgelagert

Version 0.2:
Mail-Funktionalität hinzugefügt
Syntax-Fehler in dieser Datei korrigiert

Version 0.1:
Script erstellt
