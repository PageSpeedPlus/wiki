# Debian 9 (Stretch)

### _Inhaltsverzeichnis:_

* [1. Installation des Debian 9 Minimal Server](#installation-des-debian-9-minimal-server)
  * [1.1. Anforderungen](#anforderungen)
  * [1.2. Vorbemerkung](#vorbemerkung)
  * [1.3. Das Debian-Basissystem](#das-debian-basissystem)
* [2. Konfigurieren Sie das Netzwerk](#konfigurieren-sie-das-netzwerk)

## Installation des Debian 9 Minimal Server

Dieses Tutorial zeigt, wie man einen Debian 9 (Stretch) Minimal Server installiert. Der Zweck dieses Leitfadens ist es, ein minimales Debian-Setup bereitzustellen, das als Grundlage für unsere anderen Debian-9-Tutorials und die perfekten Server-Anleitungen hier bei howtoforge.com verwendet werden kann.

### Anforderungen

Die Debian Stretch-Netzwerkinstallations-CD ist hier verfügbar:

* [Debian 9 (Stretch) - Neuste Version - 32Bit](https://cdimage.debian.org/debian-cd/current/i386/iso-cd)
* [Debian 9 (Stretch) - Neuste Version - 64Bit](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/)

Die 32Bit Version ist vorallem für ältere Systeme. Da sich hier alles um High Performence dreht und Sie wahrscheinlich eher einen Virtuellen Server als dedizierte Hardware einsetzen um zu hosten. Können Sie grundsätzlich immer die 64Bit Version anstreben. Sehr alte Hardware die das 32Bit ISO braucht ist nicht für diesen Zweck geeignet. Verkaufen Sie am besten die Hardware und starten Sie mit einem praktischen und günstigen Virtual Server bei dem Anbieter Ihres Vertrauens. Debian 9 sollte jeder haben.

### Vorbemerkung
In diesem Tutorial verwende ich den Hostnamen server1.example.com mit der IP-Adresse 192.168.1.100 und dem Gateway 192.168.1.1. Diese Einstellungen können sich für Sie unterscheiden, daher müssen Sie sie gegebenenfalls ersetzen.

### Das Debian-Basissystem
Legen Sie Ihre Debian 9 (Stretch) Netzwerkinstallations-CD in Ihr System ein und booten Sie von dort. Wenn Sie eine Virtualisierungssoftware wie VMware oder Virtualbox verwenden, wählen Sie die minimale ISO-Datei von Debian 9 als Quelldatei für das DVD-Laufwerk der VM aus, Sie müssen sie nicht zuerst auf eine CD oder DVD brennen.
![Debian 9 (Stretch) Installationsstart](https://www.howtoforge.com/images/debian_stretch_minimal_server/debian-9-server-img-1.png)

Wählen Sie Install (dies startet den Text Installer - wenn Sie ein grafisches Installationsprogramm bevorzugen, wählen Sie Graphical install):

## Konfigurieren Sie das Netzwerk

Standardmäßig sind Netzwerk-Tools wie ifconfig nicht verfügbar. Installieren Sie das Paket mit:
```bash
apt-get -y install net-tools
```

```bash
nano /etc/network/interfaces
```
### Schnellster DNS Resolver der Welt nutzen

Nutzen Sie die schnellsten Resolver der Welt von CloudFlare. Weiter Features sind:

* Query Minimization RFC7816,
* DNS-over-TLS (Transport Layer Security) RFC7858,
* DNS-over-HTTPS protocol DoH,
* Aggressive negative answers RFC8198,

Sie können in **statischen sowie in dynamischen Netzwerken** einfach folgende Zeile in `/etc/network/interfaces`

```bash
dns-nameservers  1.1.1.1 1.0.0.1
```


[Introducing DNS Resolver, 1.1.1.1 ](https://blog.cloudflare.com/dns-resolver-1-1-1-1/)

### Dynamisches Netzwerk (DHCP)

Da das Debian 9-Installationsprogramm unser System so konfiguriert hat, dass es seine Netzwerkeinstellungen per DHCP erhält, müssen wir dies jetzt ändern, da ein Server eine statische IP-Adresse haben sollte. Bearbeiten Sie / etc / network / interfaces und passen Sie es an Ihre Bedürfnisse an (in diesem Beispiel wird die IP-Adresse 192.168.1.100 verwendet) (bitte beachten Sie, dass ich allow-hotplug ens33 durch automatisches ens33 ersetze; andernfalls funktioniert das Netzwerk nicht neu und wir müssten das ganze System neu starten):

Die Interface-Datei mit aktiviertem DHCP wird vom apt-Installationsprogramm erstellt:

```bash
# Diese Datei beschreibt die auf Ihrem System verfügbaren Netzwerkschnittstellen und deren Aktivierung. Weitere Informationen finden Sie unter Schnittstellen.

source /etc/network/interfaces.d/*

# Die Loopback-Netzwerkschnittstelle
auto lo
iface lo inet loopback
       dns-nameservers  1.1.1.1 1.0.0.1

# Die primäre Netzwerkschnittstelle
allow-hotplug ens33
iface ens33 inet dhcp
```
### Statisches Netzwerk

Und hier die bearbeitete Interfaces-Datei mit der statischen IP 192.168.1.100 konfiguriert.

```bash
# Diese Datei beschreibt die auf Ihrem System verfügbaren Netzwerkschnittstellen und deren Aktivierung. Weitere Informationen finden Sie unter Schnittstellen.

source /etc/network/interfaces.d/*

# Die Loopback-Netzwerkschnittstelle
auto lo
iface lo inet loopback
       dns-nameservers  1.1.1.1 1.0.0.1

# Die primäre Netzwerkschnittstelle
auto ens33
iface ens33 inet static
        address 192.168.1.100
        netmask 255.255.255.0
        network 192.168.1.0
        broadcast 192.168.1.255
        gateway 192.168.1.1
```
Dann starte dein Netzwerk neu:
```bash
service networking restart
```


##  Hostname Eintrag setzen

Wir werden "app.ispconf.tk" als Hostname verwenden. 

### Setzten Sie nur "app" als interner Hostname.

```bash
echo "app" > /etc/hostname
```
Nun wird die neue Konfig noch geladen durch folgenden Befehl:

```bash
/etc/init.d/hostname.sh start
```

### Passen Sie nun den externen Hostnamen via `nano /etc/hosts` an.

Vergessen Sie IPv6 nicht anzugeben, falls vorhanden. 

```bash
127.0.0.1 localhost.localdomain localhost
185.100.249.250 app.ispconf.tk app
2001:db8:0:8d3:0:8a2e:70:7344 app.ispconf.tk app
```

**Es muss nun eine Reboot statt finden bevor der Hostname aktualisert wird.** Nun sollten wir nach dem Hostname Fragen können und die korrekte Antwort erhalten.

```bash
hostname = app
hostname -f = app.ispconf.tk
```

***

## Erstellen eines Unix Benutzer mit sudo Privilegien

Als erstes wird der Root Login zu gemacht. Dazu erstellen wir einen normalen User der die Rechte besitzt sich zum Root zu machen. Dann können wir uns mit dem neuen User einloggen und dann zu root werden. Das blockieren des Root Login ist sehr wichtig. Root und Port 22 könnte man als den default Eintrag eines jeden Brute Force App erstellen. 

Stellen Sie zuerst sicher das `sudo` installiert ist.

```bash
apt-get -y install sudo
```

Dannach können sie mit `adduser` einen Benutzer erfassen und mit `usermod -a -G sudo` befähigen Sie Ihn Befehle als root auszuführen oder mit `su root` zu diesem zu werden.

**Benutzer erstellen**

```bash
adduser demouser
usermod -a -G sudo demouser
```
**Benutzer löschen**
```bash
deluser demouser
```

Nun sind Sie in der Lage, sich als User "demouser" und dem eben vergebenen Passwort per SSH anzumelden.
Einmal angemeldet ist es Ihnen nun erlaubt innerhalb von SSH zwischen Nutzern zu wechseln. Als Benutzer "demouser" kann `su root` ausgeführt werden. Nun wird noch das Passwort des root Nutzers verlangt. Falls Sie es vergessen haben können Sie als "demouser" `sudo root passwd` eingeben. Beim ersten Befehl mit `sudo` als Prefix wird das Passwort von "demouser" verlangt. Dannach können Sie ein neues Passwort für root setzen und zu diesem wechseln. Als root können Sie sich das ständige sudo vor Befehlen sparen.

Nun haben wir einen User mit sudo Rechten. Wenn Sie sich nun als user "isp" anmelden können Sie mit 'su root' > -> innerhalb von SSH zwischen Nutzern zu wechseln. Dabei wird jedoch das root Passwort velangt. Passen Sie dieses vorher gegebenen falls an: `passwd root'

***

## Login mit Passwort als `root `verbieten.

Dies ist eine wichtige Schutzmassnahme. Brute Force mit root auf Port 22 ist wird infaltionär betrieben. Root gar kein Login zu gewähren hält die Brute Force Attacken zwar nicht fern, stellt aber sicher das 99 % der Versuche auf jeden Fall in leere laufen.
1. Öffnen Sie die Konfigurationsdatei mit einem Editor: `nano /etc/ssh/sshd_config` 
2. Suchen Sie folgende Zeile: `PermitRootLogin yes` 
3. Ändern Sie diese Zeile wie folgt: `PermitRootLogin without-password`
4. Starten Sie den SSH Dienst neu: `/etc/init.d/ssh restart`

Nun können Sie sich nicht mehr via Passwort mit dem Root-Konto anmelden. Um die Attacken auf einem Minimum zu reduzieren sollten Sie Port 22 wechseln und Fail2Ban sehr aggressiv einstellen um die Blacklisten zu füllen.
 
### Nur ausgewählte User zulassen

Wer nur bestimmte Benutzer explizit für SSH freischalten will kann mit `nano /etc/ssh/sshd_config` eine Zeile anhängen welche alle User definiert die sich via Passwort anmelden dürfen. 
```bash
AllowUsers username1 username2 username3
```
Starten Sie den SSH Dienst neu um die Änderungen aktiv zu machen: 
```bash
/etc/init.d/ssh restart
```
Gleiches ist mit Gruppen mittels der Verwendung von AllowGroups sinngemäß auf gleiche Weise möglich. Am besten parallel in einer anderen Session einloggen und testen ob alles so funktioniert wie es auch soll, ansonsten sperrt man sich bei einem Tippfehler im Benutzernamen in der Konfigurationsdatei schnell mal selbst aus und muss dann den Server ins Rescue-System rebooten um den Fehler zu beheben.

***

## Lokale IP ausgeben lassen

```bash
ip addr show
```

***

## Ändern des OpenSSH-Anmeldebanners

Standardmäßig deaktiviert der sshd Server diese Funktion. Melden Sie sich als root-Benutzer an. Erstellen Sie Ihre Anmeldebanner-Datei:

```bash
nano /etc/ssh/sshd-banner` 
```

Beispielsweise mit ASCII ART:

```bash
     ____________________________________________________
   /                                                     \
   |    _____________________________________________     |
   |   |                                             |    |
   |   |  C:\> _   PageSpeed+ ...                    |    |
   |   |                                             |    |
   |   |                                             |    |
   |   |    -> Daniel Bieli		             |    |
   |   |                                             |    |
   |   |    -> NGiNX PageSpeed, HTTP/2, Brotli       |    |
   |   |                                             |    |
   |   |    -> ISPConfig 3, PHP 7.0-7.2, HHVM        |    |
   |   |                                             |    |
   |   |    -> Elastic Search                        |    |
   |   |                                             |    |
   |   |_____________________________________________|    |
   |                                                      |
   \_____________________________________________________/
	 \_______________________________________/

```

Öffnen Sie die sshd-Konfigurationsdatei `/etc/sshd/sshd_config` mit einem Texteditor:

```bash
nano /etc/sshd/sshd_config
```
Hinzufügen/Bearbeiten Sie die folgende Zeile:
```bash
Banner `/etc/ssh/sshd-banner`
```
Datei speichern und den sshd-Server neu starten:

```bash
/etc/init.d/sshd restart`
```
Testen Sie Ihr neues Banner (von einer Linux- oder UNIX-Workstation oder verwenden Sie einen anderen ssh-Client):

***

## Software Pakete verwalten - [apt-get](https://wiki.ubuntuusers.de/apt/apt-get/)

Allgemein besteht ein apt-get-Befehl aus den Optionsschaltern, dem "command" (Kommando) und gegebenenfalls aus einem oder mehreren Paketnamen. Manche Kommandos benötigen keine Angabe von Paketnamen. Allerdings benötigt apt-get außer im Fall von -h oder --help die Angabe eines Kommandos. Ein Paketname besteht nur aus dem Namen des Pakets ohne Versionsangabe.

### apt-get update
update liest alle in der `/etc/apt/sources.list` und in `/etc/apt/sources.list.d/` eingetragenen Paketquellen neu ein. Hierbei erfolgt eine Prüfung auf die Signatur der Paketlisten. update benötigt keine Angabe von Paketnamen.

Dieser Schritt ist vor einem upgrade, dist-upgrade oder nach dem Hinzufügen einer neuen Quelle zu empfehlen, um die aktuellsten Informationen zu den verfügbaren Paketen zu erhalten.

`sudo apt-get [Option(en)] update`

### apt-get upgrade
upgrade bringt die installierten Pakete auf den neuesten in den Paketquellen verfügbaren Stand. Hierbei werden weder neue Pakete installiert noch durch neue Abhängigkeiten unnötig gewordene Pakete deinstalliert. upgrade benötigt keine Angabe von Paketnamen.

`sudo apt-get [Option(en)] upgrade `

### apt-get dist-upgrade
dist-upgrade bringt die installierten Pakete auf den neuesten in den Paketquellen verfügbaren Stand. Hierbei werden im Gegensatz zu upgrade neue Pakete installiert und durch neue Abhängigkeiten unnötig gewordene Pakete ersetzt, auch wenn dies alte Abhängigkeiten beeinflusst. dist-upgrade benötigt keine Angabe von Paketnamen.

`sudo apt-get [Option(en)] dist-upgrade  `
Hinweis:
dist-upgrade führt kein Upgrade auf eine neue Ubuntu-Version durch.

### apt-get install
install lädt das Paket bzw. die Pakete inklusive der noch nicht installierten Abhängigkeiten (und eventuell der vorgeschlagenen weiteren Pakete) herunter und installiert diese. Wendet man install auf ein bereits installiertes Paket an, wird dieses unabhängig vom aktuellen Status als "manuell installiert" markiert. install benötigt die Angabe mindestens eines Paketnamens, es können beliebig viele Pakete gleichzeitig angegeben werden. Diese werden durch ein Leerzeichen voneinander getrennt.

`sudo apt-get [Option(en)] install PAKET1 [PAKET2]  `
Es lässt sich auch eine bestimmte verfügbare Version eines Paketes angeben:

`sudo apt-get [Option(en)] install PAKET1=VERSION [PAKET2=VERSION] `
### apt-get clean
clean löscht die bereits heruntergeladenen Installationsdateien aus dem Paket-Cache /var/cache/apt/archives/ und gibt so Festplattenspeicher frei. clean benötigt keine Angabe von Paketnamen.

`sudo apt-get [Option(en)] clean  `

### apt-get autoclean
autoclean löscht alle heruntergeladenen Paketinstallationsdateien, die aktuell nicht mehr in den Quellen verfügbar sind (Unterschied: clean löscht ausnahmslos alle Installationsdateien). autoclean benötigt keine Angabe von Paketnamen:

`sudo apt-get [Option(en)] autoclean`

### apt-get remove
remove deinstalliert ein oder mehrere Paket(e). Die Konfigurationsdateien, die durch die manuelle oder Autokonfiguration des Pakets erstellt wurden, bleiben erhalten. remove benötigt die Angabe mindestens eines Paketnamens. Wenn mehrere Pakete gleichzeitig gelöscht werden sollen, müssen diese durch Leerzeichen voneinander getrennt werden.

`sudo apt-get [Option(en)] remove PAKET1 [PAKET2]  `

### apt-get autoremove
autoremove deinstalliert nicht mehr benötigte Pakete, die als Abhängigkeit installiert wurden. autoremove kann auf zwei Arten verwendet werden:

Ohne Angabe eines Paketnamens. Hierbei werden alle zur Zeit nicht mehr benötigten Abhängigkeiten deinstalliert (remove)

Mit Angabe eines oder mehrerer Paketnamen. Hierbei wird zuerst das oder die angegebenen Paket(e) deinstalliert (remove), dann die frei gewordenen Abhängigkeiten deinstalliert.

autoremove benötigt keine Angabe von Paketnamen:

`sudo apt-get [Option(en)] autoremove [PAKET1] [PAKET2]  `
### apt-get purge
purge kann auf zwei Arten verwendet werden:

Zur Deinstallation eines Pakets inklusive Löschung der globalen Konfiguration. Dies entspricht remove mit dem Parameter `--purge`

Zum Löschen der globalen Konfiguration eines Pakets nach der Deinstallation mit remove

purge benötigt die Angabe mindestens eines Paketnamens. Sollen mehrere Pakete und ihre globalen Konfigurationsdateien gelöscht werden, werden diese durch Leerzeichen voneinander getrennt. Der gleiche Effekt lässt sich mit dem Kommando remove `--purge` erzielen.

`sudo apt-get [Option(en)] purge PAKET1 [PAKET2] `

### apt-get build-dep
build-dep installiert die zum Erstellen von Paket aus dem Quelltext nötigen Abhängigkeiten. build-dep benötigt die Angabe mindestens eines Paketnamens.

`sudo apt-get [Option(en)] build-dep PAKET1 [PAKET2]  `

### apt-get check
check überprüft die Liste der installierten Pakete auf Abhängigkeitsfehler. check benötigt keine Angabe eines Paketnamens.

`sudo apt-get [Option(en)] check  `
### apt-get source
source lädt das Quelltext-Paket des Pakets in das aktuelle Verzeichnis herunter, entpackt es und wendet evtl. vorhandene Patches an. source benötigt die Angabe mindestens eines Paketnamens, aber keine Root-Rechte.

`apt-get [Option(en)] source PAKET1 … `
### apt-get help
help zeigt den Hilfetext an. Er kann auch via Option -h oder --help aufgerufen werden. Eine ausführliche Informationsseite findet man in der Manpage zu apt-get.

`apt-get help `
### apt-get dselect-upgrade
dselect-upgrade führt die von dselect gemachten oder manuell markierten Änderungen aus. dselect-upgrade benötigt keine Angabe eines Paketnamens.

`sudo apt-get [Option(en)] dselect-upgrade  `
### apt-get markauto
markauto markiert die übergebenen Pakete als automatisch installiert. markauto benötigt die Angabe mindestens eines Paketnamens.

`sudo apt-get [Option(en)] markauto PAKET1 [PAKET2] `
Dies gilt jedoch als veraltet, es sollte stattdessen verwendet werden:

`sudo apt-mark auto PAKET1 [PAKET2] `
### apt-get unmarkauto
unmarkauto markiert die übergebenen Pakete als "manuell installiert". unmarkauto benötigt die Angabe mindestens eines Paketnamens.

`sudo apt-get [Option(en)] unmarkauto PAKET1 [PAKET2] `
Dies gilt jedoch als veraltet, es sollte stattdessen verwendet werden:

`sudo apt-mark manual PAKET1 [PAKET2] `
### apt-get changelog
changelog lädt den Änderungsbericht (Changelog) des angegebenen Paket herunter und zeigt ihn an. changelog benötigt sinnvollerweise die Angabe eines Paketnamens, aber keine Root-Rechte.

`apt-get [Option(en)] changelog PAKET `
### apt-get download
download funktioniert erst ab Ubuntu 11.04 und lädt die Installationsdateien des angegebenen Pakets in das aktuelle Verzeichnis herunter. download benötigt die Angabe mindestens eines Paketnamens, aber ebenfalls keine Root-Rechte.

`apt-get [Option(en)] download PAKET1 [PAKET2] `
Unter älteren Ubuntu-Versionen kann man stattdessen die Option -d (siehe unten) verwenden:

`sudo apt-get -d --reinstall install PAKET1 [PAKET2] `
Die heruntergeladenen Pakete sind dann im Ordner /var/cache/apt/archives/ zu finden.

#### [Optionen](https://wiki.ubuntuusers.de/apt/apt-get/)
| **Lange Option**        | **Kürzel** | **Beschreibung**                                                                                 |
|-------------------------|------------|--------------------------------------------------------------------------------------------------|
| --arch-only             |            | Nur Pakete mit der zum System passenden Architektur werden heruntergeladen.                      |
| --assume-yes --yes      | -y         | Interaktive Fragen werden automatisch mit "YES"/"JA" beantwortet                                 |
| --compile --build       | -b         | Den Quelltext kompilieren, nachdem er heruntergeladen wurde. Benutzung in Verbindung mit source. |
| --config-file           | -c         | Die angegebene Konfigurationsdatei benutzen, die die Standardkonfiguration ersetzt.              |
| --diff-only             |            | Nur das Diff-File eines Patchsets herunterladen.                                                 |
| --download-only         | -d         |                                                                                                  |
| --fix-broken            | -f         |                                                                                                  |
| --fix-missing           | -m         |                                                                                                  |
| --ignore-missing        |            |                                                                                                  |
| --force-yes             |            |                                                                                                  |
| --ignore-hold           |            |                                                                                                  |
| --install-suggests      |            |                                                                                                  |
| --list-cleanup          |            |                                                                                                  |
| --no-install-recommends |            |                                                                                                  |
| --no-list-cleanup       |            |                                                                                                  |
| --no-upgrade            |            |                                                                                                  |
| --only-upgrade          |            |                                                                                                  |
| --option                | -o         |                                                                                                  |
| --print-uris            |            |                                                                                                  |
| --purge                 |            |                                                                                                  |
| --quiet                 | -q         |                                                                                                  |
| --reinstall             |            |                                                                                                  |
| --show-upgraded         | -u         |                                                                                                  |
| --simulate              | -s         |                                                                                                  |
| --just-print            |            |                                                                                                  |
| --dry-run               |            |                                                                                                  |
| --recon                 |            |                                                                                                  |
| --no-act                |            |                                                                                                  |
| --tar-only              |            |                                                                                                  |
| --target-release        | -t         |                                                                                                  |
| --default-release       |            |                                                                                                  |
| --trivial-only          |            |                                                                                                  |
| --verbose-versions      | -V         |                                                                                                  |

#### Beispielskripte
Der Ablauf eines "update"-Vorgangs lässt sich als Skript abbilden und zum Beispiel mit cron aufrufen. Hier werden einige Beispiele je nach gewünschtem Ergebnis gezeigt, die allerdings nur einen kleinen Teil der Möglichkeiten von apt nutzen.

##### Halbautomatische Aktualisierung
Falls man bei einem selten kontrollierten Rechner die Aktualisierungen vor dem Einspielen zwar einsehen möchte, aber den Zeitaufwand möglichst gering halten will, bietet sich (von diversen Automatismen abgesehen) folgender Ablauf an:

```bash
#!/bin/bash
apt-get update
apt-get -d dist-upgrade
apt-get autoclean
```
Hier werden zuerst die Paketlisten auf den neuesten Stand gebracht, dann vorhandene Aktualisierungspakete heruntergeladen und schließlich in den Quellen nicht mehr vorhandene Pakete aus dem Cache gelöscht, um Speicherplatz zu sparen. Dieser Ablauf kann automatisiert werden, so dass bei der nächsten Anmeldung die nötigen Pakete für einen "update"-Vorgang bereits vorliegen.

##### Automatische Sicherheitsaktualisierung
Zusätzlich zum zuvor beschriebenen Verfahren kann man auch sicherheitskritische Aktualisierungen sofort einspielen:

```bash
#!/bin/bash
apt-get update
apt-get -yt $(lsb_release -cs)-security dist-upgrade
apt-get -d dist-upgrade 
apt-get autoclean
```
##### Automatische Sicherheitsaktualisierung mit Einspielen unkritischer Pakete
Zusätzlich kann man unkritische Aktualisierungen auch automatisch einspielen und nur noch diejenigen Pakete manuell aktualisieren, die eine Nachfrage stellen:

```bash
#!/bin/bash
apt-get update
apt-get -yt $(lsb_release -cs)-security dist-upgrade
apt-get --trivial-only dist-upgrade 
apt-get autoclean
```

***

## Software Pakete von Updates aussschliessen

Oft ist es sinnvoll die Aktualisierung eines Paketes zu verhindern oder etwas zu verzögern. Um Trotzdem wie gewohnt den Paketmanager zu nutzen, müssen wir die Paket von der Aktualisierung ausschliessen. Das funktioniert, indem wir ihm den Status hold verpassen.

### Pakete auf `hold` setzen

**dpkg (apt-get)**
```bash
echo "nginx hold"|dpkg --set-selections
```
**aptitude**
```bash
aptitude hold nginx
```

### Auflisten der Paket die auf hold gesetzt sind

Um eine Übersicht zu erhalten, welche Pakete wir ausgeschlossen haben, verwenden wir:

**dpkg (apt-get)**
```bash
dpkg --get-selections |awk '$2 == "hold" { print $1 }'
```
**aptitude**
```bash
aptitude search ~ahold
```

### Paket auf `unhold` setzen

Um das Paket wieder in das regelmäßige Update aufzunehmen setzen wir den Satus wieder in den Ausgangszustand.

**dpkg (apt-get)**
```bash
echo "nginx install"|dpkg --set-selections
```
**aptitude**
```bash
aptitude unhold nginx
```

***

## Kurz Tipps

### `man`Pages

Mit dem Befehl `man name_des_programms` kann man sich zu dem jeweiligen Programm eine Erklärung anzeigen lassen. Diese ist oft hilfreich. In Debian sowie Ubuntu sollte `man` standartmässig installiert sein. Sonst kann man es einfach via Standart Repo nach installieren.

**Um die `man` Pages auf Deutsch zu bekommen muss man noch ein extra Paket installieren**

```bash
apt-get -y install manpages-de 
```

[man Artikel im Ubuntu Wiki](https://wiki.ubuntuusers.de/man/)

***
