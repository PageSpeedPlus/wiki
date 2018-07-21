# Rootkit Hunter - rkhunter

> Copyright (c) 2003-2017, Michael Boelen

Wenn Ihre Frage nicht in den FAQ oder im Archiv der Mailingliste beantwortet wird, melden Sie sich bitte bei der Mailingliste rkhunter-users an (abonnieren) und fragen Sie nach.

Wenn Sie nur über Updates auf dem Laufenden gehalten werden möchten, können Sie die `rkhunter-announce` Mailingliste abonnieren. 

Wenn Sie einen Fehler melden, oder ein Patch zur Verfügung stellen wollen, verwenden Sie bitte den Rootkit Hunter Bugtracker. Wenn Sie sich nicht sicher sind, überprüfen Sie bitte zuerst die Mailingliste `rkhunter-users`.

* [Offiziele Installationsanleitung](https://sourceforge.net/p/rkhunter/rkh_code/ci/master/tree/files/README#l26)
* [Rootkit Hunter FAQ](https://sourceforge.net/p/rkhunter/rkh_code/ci/master/tree/files/FAQ)
* [rkhunter-users Mailingliste](https://sourceforge.net/projects/rkhunter/lists/rkhunter-users)
* [rkhunter-announce Mailingliste - Nur Updates](https://sourceforge.net/projects/rkhunter/lists/rkhunter-announce)
* [Offizielle Website](http://rkhunter.sourceforge.net/)

## Anforderungen

Bitte beachten Sie, dass Rootkit Hunter (rkhunter) einige Voraussetzungen hat:

Folgende Pogramme müssen installiert sein:

* `cat`
* `sed`
* `head`
* `tail`

**Wenn ein Befehl fehlt, dann wird Rootkit Hunter (rkhunter) nicht korrekt funktionieren.**

Ein Tool sollte vorhanden sein, mit dem Dateiupdates heruntergeladen werden können. Unterstützt werden derzeit:
 
* `wget`
* `curl`
* `links`
* `lynx`
* `GET`

## Rootkit Hunter (rkhunter) installieren

### Installation aus Debian Repo

Sie können den Rootkit Hunter (rkhunter) via Debian Pakete installieren:

```bash
apt-get install -y rkhunter
```

### Source Installation

Hier finden Sie die Offizielle Bezugsquelle von Rootkit Hunter (rkhunter).

* [rkhunter SourceForge](https://sourceforge.net/projects/rkhunter/files/latest/download)

Beim Entpacken der TAR-Datei sollte ein einziges Verzeichnis mit dem Namen `rkhunter- <Version>` erstellt werden. In diesem Verzeichnis befindet sich das Installationsskript mit dem Namen `installer.sh`.

Um eine Standardinstallation von Rootkit Hunter (rkhunter) durchzuführen, entpacken Sie einfach den Tarball und
führen Sie als `root` das Installationsskript aus:

```bash
tar zxf rkhunter- <version> .tar.gz
CD rkhunter- <Version>
chmod +x installer.sh
./installer.sh --install
```

Die Rootkit Hunter (rkhunter)-Installation unterstützt benutzerdefinierte Layouts. Sie können damit die Installationspfade selber bestimmen.

```bash 
./installer.sh --example
```

Das Installskript hat auch eine Hilfeoption. Mit dieser werden Ihnen alle Optionen zur Installation angezeigt und erklärt:

```bash
./installer.sh --help
```

Der Standardinstallationsprozess installiert eine Konfigurationsdatei, genannt `rkhunter.conf`, in das Verzeichnis `/etc/rkhunter`. Erstellen Sie eine lokale Konfigurationsdatei für Ihre eigenen Einstellungen. Diese Datei muss `rkhunter.conf.local` heissen und sich im selben Verzeichnis befinden wie die Hauptkonfigurationsdatei. Alternativ oder zusätzlich, wenn gewünscht, können Sie ein Verzeichnis mit dem Namen `rkhunter.d ` erstellen. Die Files innerhalb von `rkhunter.d` müssen mit `.conf` enden. 

Sie sollten die Konfigurationsdatei (`/etc/rkhunter/rkhunter.d/rkhunter.conf`) entsprechend Ihren eigenen System Anforderungen bearbeiten. 

Hinweis: Wenn das Installationsprogramm eine vorhandene Datei `rkhunter.conf.local` erkennt, oder ein `rkhunter.d` Verzeichnis, dann werden diese zum Hauptverzeichnis hinzugefügt, für die Überwachung von `rkhunter`.

Wenn das Installationsprogramm auf eine vorhandene Datei `rkhunter.conf` stößt, wird dies ausgeführt und nicht überschrieben. Stattdessen erstellt das Installationsprogramm eine neue Konfigurationdatei, aber mit einer eindeutigen Nummer als Suffix. Bitte prüfen Sie die neue Konfigurationsdatei und kopieren Sie alle Änderungen an der bestehenden Hauptdatei zu Ihrer lokalen Konfigurationsdatei.

Das Haupt-Rootkit Hunter (rkhunter)-Skript wird in `/usr/local/bin` installiert, oder dort wo Sie mit '--layout' gewählt haben. `man` Seiten werden in `/usr/local/share/man` installiert werden, und andere Dokumentationen werden in das Verzeichnis `/usr/local/share/doc `installiert. Rootkit Hunter (rkhunter)-Dateien, Sprachunterstützung und ein Verzeichnis für temporäre Dateien werden installiert in `/var/lib/rkhunter`. Schließlich werden Rootkit Hunter (rkhunter)-Support-Skripte installiert in `/usr/local/lib/rkhunter/scripts`, oder, wenn ein x86_64 System, in `/usr/local/lib64/rkhunter/scripts`. Alle Verzeichnisse, außer 'lib64', werden bei Bedarf erstellt.

**Standardmäßig wird die Protokolldatei `/var/log/rkhunter.log` erstellt. In dieser Datei finden Sie die Scan Ergebnisse.**

## Datenbank mit Dateieigenschaften füllen

Bevor Sie Rootkit Hunter (rkhunter) ausführen, müssen Sie die Datenbank mit den Dateieigenschaften füllen:

```bash
rkhunter --propupd
```

Beachten Sie, dass Sie dass Sie Ihr Paketverwaltungstool angeben müssen. Beispiel hier ist RPM.

```bash
rkhunter --propupd --pkgmgr RPM
```

## Hilfe zu den Befehlen

```bash
rkhunter --help
```

Oder sehen Sie sich die `rkhunter`-Manpage an.

```bash
man rkhunter
```

## System scannen mit dem Rootkit Hunter (rkhunter)

Um Rootkit Hunter (rkhunter) als root auszuführen, geben Sie einfach folgenden Befehl ein:

```bash
rkhunter --check
```


***

## Befehle

|**Befehl**|**Flag**|**Beschreibung**|                                                                                                  
|----------	|-------------------	|----------------------------------------------------------------------------------------------------------------------	|
| `rkhunter `	| `-c`                	| Kompletter Systemscan                                                                                                	|
| `rkhunter` 	| `--rwo`             	| Gibt nur Befunde aus ("report warnings only"); vermeidet überlange Ausgabe-Listen...                                 	|
| `rkhunter` 	| `--display-logfile` 	| Zeigt eine Zusammenfassung des Scans am Ende.                                                                        	|
| `rkhunter` 	| `--skip-keypress`   	| Man muss zwischen den einzelnen Scan-Abschnitten nicht mehr Enter drücken.                                           	|
| `rkhunter` 	| `--update`          	| Führt ein Update der known-bad Hash-Datenbank durch.                                                                 	|
| `rkhunter` 	| `--propupd`         	| Führt ein Update der known-good Hash-Datenbank durch (nur bei der manuell installierten Version bzw. > 1.3 möglich). 	|
| `rkhunter` 	| `--versioncheck`         	| Prüft auf eine neue rkhunter-Version der Scan-Engine. 	|
| `rkhunter` 	| `--help`         	| Hilfe zu den Befehlen anzeigen. 	|




## Automatische Scans und Signatur-Aktualisierungen per Cron-Job einrichten

Gerade bei Servern ist es nicht immer möglich, von einer Live-CD zu booten und dann nach Rootkits zu fanden. Hierfür haben die Programmierer die Möglichkeit geschaffen, sowohl rkhunter täglich als auch die Signatur-Aktualisierung automatisch als Cron-Job auszuführen.

Bevor man rkhunter als Cron-Job einplant, sollte man sich jedoch sicher sein, das Programm auf einem nicht kompromittierten System zu installieren, um die entsprechenden MD5-Fingerprints ("Checksummen") anzulegen (zum Beispiel direkt nach einer Neuinstallation).

## Nach der Installation von rkhunter sollte man zuerst

`rkhunter --propupd --update  `

ausführen, um das Programm auf den aktuellen Stand zu bringen.

`rkhunter -c  `

startet dann einen umfassenden interaktiven Prüflauf. Hierbei kann es durchaus zu Fehlalarmen kommen. Diese überprüft man in der Logdatei `/var/log/rkhunter.log` und passt gegebenenfalls die Konfigurationsdatei `/etc/rkhunter.conf` an, zum Beispiel, um inetd-Dienste wie „swat“ hinzuzufügen.

Falsche Warnungen durch Whitelist-Einträge beseitigen
Nach dem ersten Scan sollte man `/var/log/rkhunter.log` genau ansehen und alle Warnungen genauer untersuchen.

Dann kann man die Konfigurations-Datei `/etc/rkhunter.conf` so ändern, dass keine Warnungen mehr kommen ("Whitelisting").

Das folgendes Skript (das aus der FAQ von rkhunter entstanden ist) vereinfacht diese Arbeit, indem es für jede in der Log-Datei vorhandenen Warnung eine Whitelist-Konfigurations-Zeile am Bildschirm ausgibt.

Für die falschen Warnungen kopiert man dann die passenden Konfigurations-Zeilen ans Ende der Konfigurations-Datei.

## cron-Job und E-Mail-Benachrichtigung aktivieren

Wer aus den Paketquellen installiert hat, muss die cron-Job-Datei `/etc/cron.daily` nicht mehr manuell modifieren (das hat die Installation bereits erledigt).

Bei einer manuellen Installation von rkhunter kann man rkhunter zur regelmäßigen automatischen Ausführung als Cron-Job in `/etc/crontab` eintragen:

`10 3    * * *   root    /usr/bin/rkhunter --cronjob `

rkhunter kann per E-Mail Status-Meldungen schicken. Man erhält z. B. täglich eine E-Mail über die Scan-Ergebnisse.

Wer automatische Scan-Läufe und E-Mail-Benachrichtigungen erhalten möchte, muss noch folgendes Paket installieren:

`apt-get -y install mailutils`

## Bugfix für das ISPConfig Dashboard.

```bash
wget https://raw.githubusercontent.com/PageSpeed-Ninjas/kit/master/rkhunter.sh; chmod +x rkhunter.sh; bash rkhunter.sh
```

[Bug](https://debianforum.de/forum/viewtopic.php?t=166137)

Alle Werte in `/etc/rkhunter.conf` mit dem Befehl `nano /etc/rkhunter.conf` anpassen.

| **IST**| **SOLL**|
|----------------------|------------------|
| UPDATE_MIRRORS=0 | UPDATE_MIRRORS=1 |
| MIRRORS_MODE=1 | MIRRORS_MODE=0 |
| WEB_CMD="/bin/false" | WEB_CMD="" |

Nun sollte der Output von `rkhunter --update` folgendermassen aussehen:

```bash
[ Rootkit Hunter version 1.4.4 ]
Checking rkhunter data files...
   Checking file mirrors.dat                                  [ No update ]
   Checking file programs_bad.dat                             [ No update ]
   Checking file backdoorports.dat                            [ No update ]
   Checking file suspscan.dat                                 [ No update ]
   Checking file i18n/cn                                      [ Skipped ]
   Checking file i18n/de                                      [ Skipped ]
   Checking file i18n/en                                      [ No update ]
   Checking file i18n/tr                                      [ Skipped ]
   Checking file i18n/tr.utf8                                 [ Skipped ]
   Checking file i18n/zh                                      [ Skipped ]
   Checking file i18n/zh.utf8                                 [ Skipped ]
   Checking file i18n/ja           
```