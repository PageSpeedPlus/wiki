# Fail2Ban

                         __      _ _ ___ _               
                        / _|__ _(_) |_  ) |__  __ _ _ _  
                       |  _/ _` | | |/ /| '_ \/ _` | ' \ 
                       |_| \__,_|_|_/___|_.__/\__,_|_||_|
                       
## Bannt Hosts, die mehrere Authentifizierungsfehler verursachen.

Fail2Ban scannt Protokolldateien wie `/var/log/auth.log` und verbietet IP-Adressen, die folgende Eigenschaften haben
zu viele fehlgeschlagene Anmeldeversuche. Dies geschieht durch die Aktualisierung der System-Firewall-Regeln.
um neue Verbindungen von diesen IP-Adressen für einen konfigurierbaren Betrag abzulehnen.
der Zeit. Fail2Ban ist sofort einsatzbereit und kann viele Standardprotokolldateien lesen,
wie die für sshd und Apache, und ist einfach zu konfigurieren, um jedes Protokoll zu lesen.
Datei, die Sie wählen, für jeden Fehler, den Sie wählen.

Obwohl Fail2Ban in der Lage ist, die Rate fehlerhafter Authentifizierungen zu reduzieren.
versucht, kann es das Risiko einer schwachen Authentifizierung nicht ausschließen.
Konfigurieren Sie die Dienste so, dass sie nur zwei Faktoren oder eine öffentliche/private Authentifizierung verwenden.
Mechanismen, wenn Sie Dienste wirklich schützen wollen.

Diese README ist eine schnelle Einführung in Fail2ban. Mehr Dokumentation, FAQ, HOWTOs
sind in der `manpage` von Fail2Ban und auf der Website [fail2ban.org](http://www.fail2ban.org) verfügbar.

![fail2ban-logo](https://kk6jyt.com/wp-content/uploads/2015/08/fail2ban-logo.jpg)

## Konfiguration

Fail2Ban hat zwei Konfigurationsdateitypen mit der Endung `.conf` und `.local.` Dateien mit der Endung `.conf` können bei einem Paketupgrade überschrieben werden, daher sind alle Änderungen in entsprechenden `.local`-Dateien vorzunehmen. In diesen müssen lediglich geänderte Werte gespeichert werden, die von den Voreinstellungen abweichen.

### fail2ban.local
In der Datei `/etc/fail2ban/fail2ban.local` werden grundlegende Dinge eingestellt. Im Normalfall reichen die Voreinstellungen aus.

### jail.local

In der Datei `jail.local` werden alle von der `jail.conf` abweichenden Einträge eingestellt. Man kann diese auch kopieren und als Grundlage für eine eigene `jail.local` nutzen. Jedoch müssen auch hier nur geänderte Werte eingetragen werden. Ein 

**Minimalbeispiel:**

```
[ssh]
enable = true
```

Es wird lediglich der SSH-Filter aktiviert. Eine Übersicht der möglichen Werte bietet die `jail.conf `und die nachfolgende Tabelle.

  ignoreip  	|       Leerzeichenseparierte Liste von zu ignorierenden IPs oder Netzwerken.       	| ignoreip = 127.0.0.1/8 192.168.1.33 	|
|:----------:	|:---------------------------------------------------------------------------------:	|:-----------------------------------:	|
|   bantime  	|         Bannzeit in Sekunden. Ein negativer Wert ist ein permanenter Bann.        	|           bantime = 86400           	|
|  maxretry  	|         Die maximale Anzahl an Fehlversuchen, bevor fail2ban die IP bannt.        	|             maxretry = 2            	|
|    port    	| Portdefinition, kann numerisch sein. Mehrere Werte werden durch Kommata getrennt. 	|              port = ssh             	|
| [Jailname] 	|                    Hier kann der Name des jail vergeben werden.                   	|                [ssh]                	|


## Entbannen

Das Entbannen funktioniert über das Programm `fail2ban-client`:

`fail2ban-client set <JAIL> unbanip <IP>`

Beispiel:

`fail2ban-client set ssh unbanip 192.168.16.33`