## Performance-Anstieg mit SPDY: Wissenswertes zum neuen Protokoll

> Das von Google entwickelte Netzwerkprotokoll sorgt für zügige Auslieferung der Seiten. Server wie Apache und Nginx unterstützen SPDY bereits.

HTTP-Nachfolger: [SPDY](http://de.wikipedia.org/wiki/SPDY) ist ein auf TCP-aufbauendes Protokoll zur Netzwerkübertragung. Klingt zu technisch und unverständlich? Das Prinzip dahinter kurz zusammengefasst:

* Die Kommunikation zwischen dem heimischen Browser und einem entfernten Server ist stets per SSL/TLS verschlüsselt.
* Der [Geschwindigkeitsvorteil](http://blog.chromium.org/2013/11/making-web-faster-with-spdy-and-http2.html) ([auch in mobilem Web](https://developers.google.com/speed/articles/spdy-for-mobile)) entsteht durch die vereinfachte, komprimierte Kommunikation zwischen Browser und Webserver: Prüfungen, Nachfragen und sogenannte Handshakes auf beiden Seiten wurden auf ein Minimum reduziert. Das verkürzt und beschleunigt den zeitintensiven Hin- und Zurück-Weg.
* Einzelne Verbindungen zu einem SPDY-Server sind in der Lage, uneingeschränkt viele Dateien parallel zu transferieren – dieser Faktor sorgt für einen enormen Performance-Schub. Webseiten mit überdurchschnittlich vielen Ressourcen (Bildern, Videos, CSS und JavaScript) profitieren von SPDY.


### Testlabor

Ladezeiten einer getesteten (E-Commerce) Webseite mit den einzelnen Netzwerkprotokollen im Desktop-Browser:

*   **SPDY**: 593 ms
*   **HTTPS**: 897 ms
*   **HTTP**: 674 ms

Die gleiche Webseite im Chrome für Android:

*   **SPDY**: 5.82s
*   **HTTPS**: 7,76s
*   **HTTP**: 7,23s

Online-Tools zum Ausprobieren:

*   [HTTP vs. HTTPS Test](https://www.httpvshttps.com/)


### Browserkompatibilität

Unternehmen wie Google, [Facebook](http://zoompf.com/blog/2013/03/facebook-adds-spdy-support) und [WordPress.com](http://barry.wordpress.com/2012/06/16/nginx-spdy-and-automattic/) haben die Auslieferung der Webseiten via SPDY bereits in Betrieb genommen. Das bedeutet, die Ladezeit dieser Websites hat sich für Besucher spürbar reduziert – richtiger Browser vorausgesetzt. Denn SPDY wird nicht nur auf dem Server installiert, auch der Browser muss mit neuem Netzwerkprotokoll umgehen können. Erst wenn beide „Parteien“ auf gleicher „Wellenlänge“ sind, klappt es mit der Optimierung.

Aktuell unterstützen folgende Browser das SPDY-Protokoll:

*   [IE 11+](http://blogs.msdn.com/b/ie/archive/2013/07/25/ie11-developer-preview-for-windows-7-enabling-next-generation-sites-and-apps-faster.aspx) (Windows 8.1+)
*   Chrome 4+
*   [Firefox 13+](http://www.heise.de/open/meldung/SPDY-soll-Firefox-13-Schub-geben-1561837.html)
*   [Opera 12.1+](http://my.opera.com/desktopteam/blog/2012/07/06/opera-labs-spdy)
*   Safari 8 (OS X 10.10 / iOS 8)

Je nach Projekt-Zielgruppe und entsprechender Browser-Nutzung kann die SPDY-Akzeptanz zwischen [50 und 80 Prozent](http://caniuse.com/spdy) liegen. Das bedeutet: mehr als die Hälfte der Besucher bzw. Kunden laden die Website schneller. Die restlichen Browser konsumieren den Datenstrom weiterhin via [HTTP](http://de.wikipedia.org/wiki/Hypertext_Transfer_Protocol).


### Installation

Auch wenn es sich auf den ersten Blick nicht unbedingt trivial anhört, die Inbetriebnahme der stabilen SPDY-Module für bekannte Webserver ist denkbar einfach. Jeder Systemadministrator und Entwickler mit Root-Zugängen schafft es, SPDY auf einem Server zu installieren.

*   [mod_spdy](https://developers.google.com/speed/spdy/mod_spdy/) für Apache
*   [ngx_http_spdy_module](http://nginx.org/en/docs/http/ngx_http_spdy_module.html) für Nginx


### SPDY unter Nginx

Für Nginx Webserver ist die Einrichtung von SPDY relativ einfach:

**1\. Nginx installieren**

```nginx
add-apt-repository ppa:nginx/stable
apt-get update
apt-get install nginx && apt-get install nginx-extras
```

**2\. SSL-Zertifikat aufspielen**

Entweder ein [selbstsigniertes](http://wiki.nginx.org/HttpSslModule#Generate_Certificates) oder erworbenes Zertifikat nutzen.


**3\. Konfiguration anpassen**

```nginx
server {
    listen 443 default_server ssl spdy;

    ssl_certificate /usr/local/nginx/conf/server.crt;
    ssl_certificate_key /usr/local/nginx/conf/server.key;
}
```


**4\. Nginx (re)starten**

```nginx
service nginx restart
```

Ab sofort nutzt der Server SPDY-Verbindungen, wenn der Browser danach fragt.


### Tools & Empfehlungen

*   [Unterstützt mein Browser SPDY?](https://ist-spdy-aktiviert.de/)
*   [Unterstützt eine Website SPDY?](http://spdycheck.org/)
*   [SPDY Debugging](http://www.chromium.org/spdy/spdy-tools-and-debugging)
*   [SPDY indicator](https://chrome.google.com/webstore/detail/spdy-indicator/mpbpobfflnpcgagjijhmgnchggcjblin)
*   [SPDY Best Practices](http://www.chromium.org/spdy/spdy-best-practices)


### Einschränkungen

SPDY kann je nach Webanwendung leicht [langsamer](http://www.guypo.com/technical/not-as-spdy-as-you-thought/) werden (siehe [Microsoft Studie](http://research.microsoft.com/apps/pubs/?id=170059) und [Belastungstest](http://web2.sys-con.com/node/2742114)) als nicht verschlüsselte HTTP-Verbindungen. Allerdings geschwinder als die herkömmliche HTTPS-Kommunikation. Ob sich der serverseitige Umstieg auf SPDY bezahlt macht, lässt sich nicht unbedingt pauschal beantworten. Folgende Faktoren spielen bei der Entscheidung eine Rolle:

1.  Ist meine Website SSL-verschlüsselt? Dann lohnt sich der Einsatz von SPDY.
2.  Aktuell kein HTTPS? Werden jedoch sehr viele Dateien vom Server geladen (aus dem HTML-Quelltext heraus) und es spricht nichts gegen eine SSL-Verschlüsselung der Webseiten? Dann ist SPDY eine gute Wahl.

Andernfalls bringt SPDY keinen signifikanten Vorteil mit sich. Kleinere Websites können mithilfe von [Caching](http://cachify.de/) ebenfalls schnell in der Auslieferung sein.
