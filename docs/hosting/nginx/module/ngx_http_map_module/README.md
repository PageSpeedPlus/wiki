## Bot-Zugriffe mithilfe von Nginx und Fail2Ban erkennen und blocken

> Webseitenaufrufe durch Bots sind nervig, belasten den Webserver, kosten Traffic. Fail2Ban weist unerwünschte Bots ab, die Nginx erkannt hat.

Um Bots von der Website fern zu halten, genügen einige Definitionen in Konfigurationsdateien von Nginx und Fail2Ban. Das serverseitige und pflegeleichte Anti-Bot-Mechanismus im Detail:


### Definition der Bots als bots.map

```nginx
map $http_user_agent $is_bot {
    default 0;

    ~Sogou 1;
    ~Abonti 1;
    ~Pixray 1;
    ~Python 1;
    ~Spinn3r 1;
    ~libwww-perl 1;
    ~Wget 1;
    ~Curl 1;
    ~Ezooms 1;
    ~mShots 1;
    ~SemrushBot 1;
    ~Exabot 1;
    ~ZmEu 1;
    ~iCjobs 1;
    ~QuerySeekerSpider 1;
    ~Baiduspider 1;
    ~AhrefsBot 1;
    ~CareerBot 1;
    ~coccoc 1;
    ~MJ12bot 1;
    ~SeznamBot 1;
    ~spbot 1;
    ~ShowyouBot 1;
    ~adressendeutschland 1;
    ~PagesInventory 1;
    ~aboutWebSearch 1;
    ~Java 1;
    ~JCE 1;
    ~bitlybot 1;
    ~WeSEE 1;
    ~updown_tester 1;
    ~200PleaseBot 1;
    ~Nutch 1;
    ~HTTP_Request 1;
    ~AnyOther 1;
    ~Crawler 1;
    ~BLEXBot 1;
    ~yacybot 1;
    ~Cliqzbot 1;
}
```

Der Übersicht und Pflege zuliebe erfolgt die Deklaration der Bots in einer eigenständigen Datei `bots.map`. Zeile für Zeile werden Bot-Kennungen (ermittelt aus dem [User-Agent](http://de.wikipedia.org/wiki/User_Agent) der Zugriffe) hinterlegt.

Das Nginx-Modul [map](http://wiki.nginx.org/HttpMapModule) verantwortet die Zuweisung der Variable `$is_bot`, die je nach Treffer einen Wert von `0` (default = kein Bot) und `1` (Bot erkannt) aufweist.


### Einbindung der Definition in nginx.conf

```nginx
http {
    ###

    include /etc/nginx/conf.d/bots.map;
}
```

Die Nginx-Konfigurationsdatei `nginx.conf` referenziert die Liste mit unerwünschten Bots. Der Dateipfad gehört angepasst, wenn sich die Datei _bots.map_ nicht im Nginx-Verzeichnis befindet.


### Abfrage der Definition im Nginx-Server

```nginx
server {
    ###

    if ( $is_bot ) {
        return 444;
    }
}
```

Innerhalb der virtuellen Server findet die eigentliche Abfrage auf die von Nginx gesetzte Variable `$is_bot` statt. Im Positivfall sendet der Webserver einen [HTTP-Statuscode 444](http://de.wikipedia.org/wiki/HTTP-Statuscode#4xx_.E2.80.93_Client-Fehler) aus: Die Verbindung zum Client wird geschlossen, ohne eine Antwort zu senden.

Diese Technik erlaubt es dem Administrator, jegliche Bot-Zugriffe zu lokalisieren und Verbindungen zu beenden – der Webserver bleibt von der Generierung und Auslieferung der Daten verschont.

Perfekt ist die Abwehrlösung erst dann, wenn bereits abgewiesene Bots durch Fail2Ban auf Dauer gesperrt werden: Die (Aus)Filterung der Anfragen erfolgt auf der Firewall-Ebene des Servers.

Für diesen Zweck überwacht Fail2Ban aktuelle Accesslogs des Webservers auf den Fehlercode 444: Quittiert Nginx eine Anfrage mit 444 (= ist Bot), kriegt Fail2Ban dies via Accesslog-Eintrag mit und merkt die IP bzw. den Host in der Firewall-Blacklist vor.


### Filter-Regel als Fail2Ban-Datei nginx-bots.conf

```bash
# Fail2Ban configuration file
#
# List of bad requests
#
# Server: Nginx
# Author: Sergej Müller
#

[Definition]

# Option:  failregex
# Notes :  Detection of 444 requests.
# Values:  TEXT
#

failregex = ^<HOST> - .+ 444 0 ".+"$

# Option:  ignoreregex
# Notes :  Regex to ignore.
# Values:  TEXT
#

ignoreregex =
```

Im Fail2Ban-Ordner `filter.d` gehört eine weitere Datei `nginx-bots.conf` angelegt. Dort die obige Definition der Erkennungsregel einfügen. Der reguläre Ausdruck innerhalb der Regel überwacht das Accesslog auf das Vorkommen des 444-Statuscodes mit Null Bytes als Rückgabewert.


### Erweiterung der Fail2Ban-Config

```bash
[nginx-bots]

enabled  = true
port = http
filter = nginx-bots
logpath = /var/log/nginx/access.log
maxretry = 0
findtime = 86400
bantime  = -1
```

Die lokale Fail2Ban-Konfigurationsdatei `jail.local` erhält nun eine Referenz zum soeben angelegten Filter (Filtername = Dateiname des Filters). Dazu einige Fail2Ban-Eigenschaften, die dafür Sorge tragen, dass erkannte Bots bis auf Weiteres abgelehnt werden.


### Nginx und Fail2Ban Restart

```bash
sudo nginx -t && sudo service nginx reload
sudo service fail2ban restart
```

Beide Dienste neu starten.

---

###### Fazit

Simple und ausbaufähige Lösung zur Abwehr von lästigen Bots. Die Liste mit unerwünschten Clients kann jederzeit modifiziert und ausgebaut werden.