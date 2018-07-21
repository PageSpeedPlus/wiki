## Sicherheit und Spam-Schutz: Fail2Ban installieren und einrichten

> Fail2Ban überwacht Logfiles, erkennt bösartige Zugriffe und blockt IPs für eine bestimmte Zeit. Ausbaufähig, pflegeleicht und verlässlich.

In einem Beitrag auf [Google+](https://plus.google.com/110569673423509816572/posts/VLNUE2AFx9S) wurden zahlreiche Module für Webserver Apache und Nginx zusammengefasst, die der Sicherheit von Websites dienen: Anhand der global verfügbaren Datenbasis an gemeldeten Spam-IPs erkennen diese Server-Erweiterungen maschinelle Spam-Angriffe und weisen sie nach Möglichkeit zurück. Der Schutz ist so effektiv wie die Aktualität des IP-Datenbestandes.


### Framework zur Vorbeugung von Einbrüchen

Mit [Fail2Ban](http://www.fail2ban.org/wiki/index.php/FAQ_german) existiert seit nun fast 10 Jahren ein spannendes Server-Modul, welches mit installiertem Webserver (Apache, Nginx) perfekt kooperiert. [Fail2Ban](http://de.wikipedia.org/wiki/Fail2ban) arbeitet mit Logfiles, welche der Webserver und das Betriebssystem automatisiert erzeugen und auf der Server-Festplatte ablegen. In Logfiles fahnden _Fail2Ban_-Filter nach bestimmten Mustern, erkennen böswillige Zugriffe und sperren extrahierte IPs für einen festgelegten Zeitraum. Die Abwehr findet also auf der Server-Ebene statt. Automatisiert.

_Fail2Ban_ bringt ein gutes Dutzend an vorgefertigten Filtern mit. Nach der Aktivierung überwachen sie die gewünschten Bereiche: So werden auf Wunsch mehrfache IMAP-Logins, [Brute-Force-Attacken](http://de.wikipedia.org/wiki/Brute-Force-Methode) per SSH ([Auszug](http://pastebin.com/raw.php?i=jaX44hVL)), wiederholte Skript-Ausführungen, gezielte Suchanfragen nach Dateien mit bekannten Sicherheitslücken erkannt und blockiert. _Fail2Ban_ ist so schlau wie die Effizienz seiner Erkennungsfilter. Technisch versierte Nutzer sollten in der Lage sein, eigene Muster in Error- bzw. [Access-Logs](http://httpd.apache.org/docs/2.2/logs.html#accesslog) zu erkennen und weitere Firewall-Regeln zur Abweisung von Schädlingen anzulegen.


### Installation

Die Inbetriebnahme von _Fail2Ban_ ist auf Debian/Ubuntu denkbar einfach und in nur einem Befehl durchgeführt:

```bash
sudo apt-get install fail2ban
```

Nach der erfolgreichen Installation ist _Fail2Ban_ im Verzeichnis `/etc/fail2ban` installiert. Die Konfigurationsdatei `jail.conf` beinhaltet verfügbare Modul-Optionen. Idealerweise dupliziert man die Datei und arbeitet an lokaler Kopie, wo eigene Änderungen vor Updates sicher sind.

```bash
cd /etc/fail2ban
sudo cp jail.conf jail.local
```

Je nach Protokoll und Bereich können nun einzelne Filter mithilfe von `enabled = true` eingeschaltet werden. Beispiel: Ist auf dem Server kein SSH-Zugang freigeschaltet, benötigt man auch keine SSH-Filter (_[ssh]_, _[ssh-ddos]_). Kein IMAP? Keine Aktivierung des _Fail2Ban_-IMAP-Filters. Und so weiter.

Ist Apache als Webserver installiert, empfiehlt es sich, mitgelieferte Apache-Filter auf Aktiv zu setzen.


### Fail2Ban Jail-Parameter

Die Konfigurationsdatei besteht aus einzelnen Regeln, sogenannten _Jails_. Diese bilden eine Gruppe aus mächtigen Parametern:

*   `enabled` – Aktive / Inaktive Regel (true/false)
*   `filter` – Filter-Name aus gleichnamiger Datei unter `/etc/fail2ban/filter.d`
*   `port` – Möglicher Port (ssh, http, https, etc.)
*   `logpath` – Logdateien für die Überwachung
*   `maxretry` – Anzahl der Treffer im findtime-Zeitraum
*   `findtime` – Zeitraum in Sekunden, der berücksichtigt wird
*   `bantime` – Zeitraum in Sekunden, für den geblockt wird (-1 = für immer)

Zum Verständnis ein Beispiel-Jail:

```bash
[nginx-badrequests]
enabled  = true
filter = nginx-badrequests
port = http,https
logpath = /var/log/nginx*/access*.log
maxretry = 1
findtime = 86400
bantime  = 2592000
```

Die Regel ist eingeschaltet und bindet die Datei `nginx-badrequests.conf` aus `/etc/fail2ban/filter.d` mit definierten regulären Ausdrücken ein. Nach RegExp-Mustern wird in Logfiles `/var/log/nginx*/access*.log` gesucht. Und zwar im Zeitraum von einem Tag (`findtime = 86400`). Sobald mindestens ein Treffer (`maxretry = 1`) lokalisiert wurde, wird _Fail2Ban_ die IP für einen Monat (`bantime = 2592000`) sperren.

Wichtig zu verstehen ist, dass _Fail2Ban_ nicht irgendwelche IP-Adressen auf die interne Blacklist setzt, sondern ausschließlich die, die dem regulären Ausdruck aus dem Jail-Filter entsprechen. Daher sollte man sehr vorsichtig mit Filter-Definitionen hantieren und diese mit [fail2ban-regex](http://www.fail2ban.org/wiki/index.php/MANUAL_0_8) umgehend testen.


### Fail2Ban Start und Analyse

Prozess-Start bzw. Stop:

```bash
service fail2ban start
service fail2ban stop
```

Reload und Überprüfung der Optionen, Reset der Blacklist:

```bash
service fail2ban reload
```

Ausgabe von Ban-/Unban/Info-Meldungen:

```bash
tail -100f /var/log/fail2ban.log
```

Einblick in die Fail2Ban-Ausgabe:

```
WARNING [nginx-badrequests] Ban 27.159.122.174
WARNING [nginx-badrequests] 27.159.122.174 already banned
WARNING [nginx-badrequests] Ban 185.25.51.34
WARNING [nginx-badrequests] Ban 96.47.225.82
WARNING [ssh] Ban 59.53.94.9
WARNING [ssh] Ban 46.105.230.237
WARNING [nginx-badrequests] Ban 96.47.225.170
WARNING [nginx-badrequests] Ban 50.117.80.56
WARNING [nginx-badrequests] Ban 113.212.70.27
WARNING [ssh] Ban 222.89.166.16
```

Interessanterweise lässt sich der _Fail2Ban_-Logfile ebenfalls überwachen, um daraus weitere Regel für Sperrlisten zu gewinnen: „[Monitoring the fail2ban log](http://www.the-art-of-web.com/system/fail2ban-log/)“.


### Manuelle IP-Sperre in Fail2Ban

Je nach Anwendungsfall kann es notwendig sein, bestimmte IP-Adressen in _Fail2Ban_ manuell zu sperren. Um die Übersicht zu erhalten und die Pflege der Einträge so einfach wie möglich zu halten, empfiehlt sich eine IP-Blacklist als Datei.

Eine eigen für diesen Zweck erstellte Lösung kommt an der Stelle zum Einsatz: IP-Datensätze werden aus der angelegten Datei `ip.blacklist` extrahiert und in der Firewall eingetragen. Das How-to zu Einrichtung einer _Fail2Ban_-Blacklist: [[Firewall-Blacklist mit Fail2Ban|Fail2Ban: IP Blacklist]].

Der Vorteil dieser Lösung im Vergleich zu „[Set a permanent ban per IP](http://www.mauromascia.com/blog/fail2ban-set-permanent-ban-per-ip/)“ ist die Update-Resistenz, da nutzerspezifische Jails nie überschrieben werden.


### Fail2Ban und WordPress

##### Spam-Schutz

Ist im WordPress-Plugin [Antispam Bee](http://antispambee.de/) die Option “Erkannten Spam kennzeichnen, nicht löschen” _deaktiviert_, so versieht das Antispam-Plugin jeden Spam-Kommentar mit dem Status-Code [403 Forbidden](http://en.wikipedia.org/wiki/HTTP_403). Nach diesem Muster lässt sich im Access Log jeder POST-Zugriff auf die Datei `wp-comments-post.php` als Spam identifizieren, wenn der Request mit einem 403-Code endet.

Perfekte Möglichkeit also, Spammer bereits auf der Server-Ebene zu lokalisieren, indem eine passende _Fail2Ban_-Regel erstellt wird. Eine mögliche Implementierung der Lösung liegt als [Gist](https://gist.github.com/sergejmueller/5630584) bereit.

Als alternative Herangehensweise eignet sich die von Antispam Bee generierte Logdatei mit erkannten Spam-Kommentaren. Das optional verfügbare Logfile kann genutzt werden, um _Fail2Ban_ auf Spam-Hosts hinzuweisen und entsprechend zu trainieren. Weitere Details rund um das Logging und die Verknüpfung mit _Fail2Ban_ befinden sich im [Antispam Bee Handbuch](http://playground.ebiene.de/antispam-bee-wordpress-plugin/).

##### Angriffsschutz
Nach analogem Prinzip erkennt _Fail2Ban_ fehlerhafte Anmeldeversuche in WordPress, wenn eine entsprechende [Erweiterung](https://plus.google.com/110569673423509816572/posts/T1gnqbiYjZZ) integriert wurde. Der in WordPress eingebundene [Zugriffsschutz](http://playground.ebiene.de/initiative-wordpress-sicherheit/) würde dagegen einen Status-Code 401 ausgeben. Ein entsprechender [Jail](https://gist.github.com/sergejmueller/8562240) erkennt und blockt solche Zugriffe.


### Performance

_Fail2Ban_ läuft auf dem Server als eigenständiger [Daemon](http://de.wikipedia.org/wiki/Daemon). Entsprechend werden Ressourcen benötigt, um jeden Request an den Server durch Filter zu überprüfen. Je nach Hardware und Größe der Website ist mit leichtem Anstieg der CPU-Auslastung zu rechnen.

---

###### Fazit

Durch die Sperrung verdächtiger IP-Adressen durch _Fail2Ban_ kann der Server enorm entlastet werden. In Verbindung mit Antispam Bee werden Spammer bereits beim Zugriff auf die Webseite erkannt und abgewehrt.