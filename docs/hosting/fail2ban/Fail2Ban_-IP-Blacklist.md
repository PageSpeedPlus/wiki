## Benutzerdefinierte Firewall-IP-Blacklist mit Fail2Ban realisieren

> Manuell erstellte, pflegeleichte Liste mit IP-Adressen als Quelle für Fail2Ban. Unerwünschte IPs auf der Firewall-Ebene zurückweisen.

Die serverseitige Applikation [Fail2Ban](http://www.fail2ban.org/wiki/index.php/FAQ_german) dient als wachsamer Torwächter: Logdateien werden permanent überwacht, bei Auffälligkeiten und Missbrauch landen IP-Adressen der Zugriffe auf die Sperrliste der Server-Firewall. Der gesamte Ablauf – angefangen mit der Erkennung bis zur Sperrung der Bösewichte – erfolgt automatisiert.


### Bestimmte IPs mit Fail2Ban blockieren

Fail2Ban fehlt jedoch die Möglichkeit, händisch hinterlegte IP-Adressen sperren zu lassen. Nicht selten gehört ein Bot oder Client vom Server ausgesperrt. Webserver wie Nginx und Apache könnten das Blacklisting ebenfalls übernehmen, doch das wäre ein Kettenglied zu spät.

Die Vision: Eine Blacklist-Datei für Fail2Ban, wo zu blockierende IPs zeilenweise hinterlegt werden. Vorteile: Kinderleichte Bedienung, hervorragende Übersicht an gesperrten Adressen, keine [Shell](http://de.wikipedia.org/wiki/Unix-Shell)-Befehle für [iptables](http://de.wikipedia.org/wiki/Iptables) notwendig.

Der Lösungsansatz besteht aus drei Dateien bzw. Fail2Ban-Komponenten:

1.  Erweiterung der Datei `jail.local` um das zuständige Fail2Ban-Jail
2.  Filter-Definition als Datei `ip-blacklist.conf` im Fail2Ban-Ordner `filter.d`
3.  Eigentliche IP-Blacklist `ip.blacklist` im gleichen Verzeichnis wie `jail.local`


### Fail2Ban-Datei jail.local

```bash
[ip-blacklist]

enabled   = true
banaction = iptables-allports
port      = anyport
filter    = ip-blacklist
logpath   = /etc/fail2ban/ip.blacklist
maxretry  = 0
findtime  = 15552000
bantime   = -1
```

Das Blacklist-Jail (= Snippet) erweitert die Liste mit bereits vorhandenen Jails innerhalb der Datei `jail.local`. Zugriffe mit IP-Adressen aus der Blacklist werden für immer geblockt, dafür sorgt der Parameter `bantime = -1`.


### Konfigurationsdatei ip-blacklist.conf

```bash
[Definition]

# Option:  failregex
# Notes :  Detection of blocked ip addresses.
# Values:  TEXT
#

failregex = ^<HOST> \[.*\]$

# Option:  ignoreregex
# Notes :  Regex to ignore.
# Values:  TEXT
#

ignoreregex =
```

Die Fail2Ban-Filterregel zur Erkennung von IP-Adressen in der manuell angelegten Blacklist. Keine Anpassung der Datei notwendig.


### Blacklist-Datei ip.blacklist

```bash
5.9.111.18 [29/12/2013 12:00:00]
5.9.152.104 [30/12/2013 12:00:00]
```

IP-Adressen, die in die Server-Firewall eingetragen werden sollen, werden hier zeilenweise dokumentiert. Wichtig sind das Format und Datum:

*   Das Format nutzt Fail2Ban zum Parsen (Verstehen) der Datensätze
*   Datumseinträge werden herangezogen, um das Alter zu ermitteln

Fügt man der Blacklist also eine weitere IP-Adresse hinzu, so gehört auch das (aktuelle) Datum in eckigen Klammern angepasst. Mit dem Parameter `findtime` im Fail2Ban-Jail (Snippet oben) lässt sich der Zeitraum der zu berücksichtigten IP-Adressen bestimmen. Aktueller Wert von `15552000` entspricht einem halben Jahr – ältere Datensätze werden ignoriert.


### Administration

Nach dem Neustart des Fail2Ban-Dienstes via `sudo service fail2ban restart` berücksichtigt die Firewall nun die in der Blacklist gelisteten IP-Adressen. Die Logdatei `fail2ban.log` müsste dies protokolliert haben.

Bei Neuzugängen innerhalb der Blacklist genügt der Speichervorgang der Datei `ip.blacklist` – kein Fail2Ban-Restart vonnöten. Fail2Ban erkennt die Änderung und fügt die neue IP-Adresse der Firewall automatisch hinzu. Wurde dagegen ein Datensatz aus der Liste entfernt, so gehört Fail2Ban neu gestartet.

---

###### Fazit

Bequeme, unkomplizierte, dateibasierte Lösung für die Sperrung benutzerdefinierter IP-Adressen auf der Server-Ebene. Dank Fail2Ban.