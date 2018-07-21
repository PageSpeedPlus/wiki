## Dateiverkleinerung mit Nginx-Modul nginx_substitutions_filter

> Minimierung der Dateigröße durch Entfernung von Leerzeichen, Tabs und Zeilenumbrüche übernimmt in Nginx das nginx_substitutions_filter Modul.

Die Entfernung unnötiger Zeichen (dazu gehören Tabulatoren, Zeilenumbrüche, Quelltext-Kommentare) aus HTML-, CSS-, JavaScript- und XML-Files reduzieren die Ausgangsgröße dieser Dateien. Weniger “Gewicht” bedeutet eine zügige Auslieferung an den Browser – ein Performance-Kriterium. Je nach Dateigröße lassen sich somit mehrere KB an Daten einsparen.


### Nginx als Minifier

Es existieren mehrere Möglichkeiten, dynamisch erzeugte Inhalte durch die Entfernung überflüssiger Zeichen zu minimieren: [PHP](http://stackoverflow.com/questions/6225351/how-to-minify-php-page-html-output) und [Caching-Plugins](http://cachify.de/) stellen hierfür Werkzeuge zur Verfügung. Die Aufgabe lässt sich aber auch direkt auf der Server-Ebene erledigen – vorausgesetzt, der installierte Webserver spielt mit. Nginx eignet sich perfekt für das geschilderte Vorhaben.

Das Prinzip der Minimierung ist denkbar einfach: Den Dateiinhalt nach überflüssigen Zeichen durchsuchen, Fundstellen durch einen leeren String ersetzen. Nginx wendet die Suchen-Ersetzen-Prozedur vor der Ausgabe an den Browser an.


### Nginx-Filter-Module

Je nach Nginx-Kompilierung ist das Nginx-Modul [ngx_http_sub_module](http://nginx.org/en/docs/http/ngx_http_sub_module.html) installiert. Das Modul erlaubt schlichte Wort/Zeichen-Ersetzungen für Response-Inhalte. Die praktische Nginx-Erweiterung können wir in diesem Fall jedoch nicht gebrauchen, da es ausschließlich mit statischen Strings/Werten umgehen kann. Gebraucht wird allerdings eine Lösung mit nativer Unterstützung von Regulären Ausdrücken.

Das Nginx-Modul [nginx_substitutions_filter](https://github.com/yaoweibin/ngx_http_substitutions_filter_module) kommt nicht selten im Lieferumfang von Nginx (Debian- und Ubuntu-Pakete) mit und kann ohne weitere Kompilierung direkt verwendet werden. Mit welchen Modulen die Nginx-Installation “zusammengebaut” wurde, erfährt der Administrator mithilfe des Befehls `nginx -V`

Ist das _nginx_substitutions_filter_ Modul auf dem Server installiert, geht die Implementierung ganz schnell und unproblematisch. Um beispielsweise die Ausgabe der PHP-Dateien zu minimieren, genügt ein übersichtlicher Einzeiler:

```nginx
location ~ \.php$ {
    ### ... ###

    subs_filter "[\n\t]" "" ir;

    ### ... ###
}
```

Der reguläre Ausdruck `[\n\t]` kann auf Wunsch ausgebaut werden, um beispielsweise HTML-Kommentare aus dem Markup zu eliminieren. Achtung, an [Conditional Comments](http://de.wikipedia.org/wiki/Conditional_Comments) denken.

---

###### Fazit

Das _nginx_substitutions_filter_ Modul verfügt über weitere hilfreiche Befehle, die in der Dokumentation beschrieben sind: Zusätzliche Dateitypen lassen sich hinzufügen (_subs_filter_types_), das Suchverhalten kann manipuliert (_subs_filter_) und Filter-Ausnahmen definiert (_subs_filter_bypass_) werden.

In Verbindung mit [Nginx FastCGI-Caching](https://plus.google.com/+SergejMüller/posts/LP2vMGZGPmt) ist die Minify-Methode eine sinnvolle Möglichkeit der Dateiverkleinerung on-the-fly, unabhängig von der PHP/Frontend-Applikation.


