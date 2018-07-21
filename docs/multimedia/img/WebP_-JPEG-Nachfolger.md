## JPEG-Nachfolger: Einführung in das sparsame Bildformat WebP

> WebP will die Komprimierung und Optimierung der Bilder im Web revolutionieren: Bessere Qualität wie JPEGs in kleinerer Dateigröße verpackt.

Technikaffine Web-Nutzer haben sicherlich von [WebP](http://de.wikipedia.org/wiki/WebP) gehört – ein von Google [entwickeltes](https://developers.google.com/speed/webp/) Bildformat für überlegene Komprimierung der Fotos. JPEG gilt als veraltet und nicht effizient genug. Mit WebP kommt eine ausgefeilte Alternative auf den Markt, Bilder vorteilhaft zu komprimieren. JPEG vs. WebP: Reduktion der Dateigröße um bis zu 80 % ist keine Seltenheit.


### Browser-Support

Hört sich lukrativ und vielversprechend an: Feinere Qualität wie JPEGs, jedoch deutlich kleinere Datei. Doch wo Licht, da auch Schatten. Die aktuelle [Browser-Unterstützung](http://caniuse.com/#feat=webp) ist zurzeit der größte Nachteil der WebP-Technik: Zum jetzigen Zeitpunkt beherrschen Opera und Chrome das moderne Bildformat. Firefox hat die Unterstützung für WebP-Bilder [angekündigt](http://www.zdnet.de/88150393/mozilla-gibt-googles-bildformat-webp-eine-neue-chance/). Internet Explorer und Safari bleiben komplett außer vor.

Dennoch lohnt es sich, Bilder im WebP-Format für genannte Browser auszuliefern. Noch sind es offiziell zwei, bald sind es schon drei Browser mit dem Support für WebP – wenn Firefox keinen Rückzieher macht. Ein Blick auf die Statistik eigener Website gibt Auskunft, ob es sich rentieren wird, Bilder im Projekt in zwei Dateiformaten zu führen: WebP für Chrome, Opera, (bald) Firefox und JPEG für restliche Browser.


### RewriteRules für .htaccess

Eine Weiterleitungsregel auf der Server-Ebene würde die Verteilung der Anfragen auf das korrekte Dateiformat – abhängig vom Browser – übernehmen. Im Klartext: Die Einbindung der Bilder im HTML-Sourcecode ändert sich in keiner Weise und bleibt unberührt (z.B. `<img src="bild.jpg" />`). Die Auslieferung des richtigen Bildes übernimmt das RewriteRule in der Systemdatei `.htaccess`:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}/$1.webp -f
    RewriteRule ^(wp-content/uploads.+)\.(jpe?g|png)$ $1.webp [T=image/webp,E=accept:1]
</IfModule>

<IfModule mod_headers.c>
    Header append Vary Accept env=REDIRECT_accept
</IfModule>

AddType image/webp .webp
```

Beim Aufruf einer JPEG- bzw. PNG-Grafik im Browser wird diese vom Server gegen WebP ausgetauscht und mit dem [MIME-Type](http://de.wikipedia.org/wiki/Internet_Media_Type) `image/webp` versehen. Die Dateiendung (Dateiformat) ändert sich dabei nicht.

Wichtig: Das Snippet innerhalb von `.htaccess` relativ weit oben platzieren.


### RewriteRules für nginx.conf

Analog zum Apache-Webserver existiert eine Lösung für Nginx:

```nginx
location ~ ^(/wp-content/uploads.+)\.(jpe?g|png)$ {
    if ( $http_accept ~* webp ) {
        set $webp "A";
    }
    if ( $request_filename ~ (.+)\.(png|jpe?g)$ ) {
        set $file_without_ext $1;
    }
    if ( -f $file_without_ext.webp ) {
        set $webp "${webp}E";
    }

    if ( $webp = AE ) {
        add_header Vary Accept;
        rewrite ^(.+)\.(png|jpe?g)$ $1.webp break;
    }
}
```

In diesem Zusammenhang ist der Eintrag `image/webp webp;` in der Nginx-Systemdatei `mime.types` sehr wichtig – auf diese Weise sendet Nginx den korrekten [MIME-Type](http://de.wikipedia.org/wiki/Internet_Media_Type) an den Browser.


### Kosten-Nutzen-Verhältnis

Hochgerechnet: Zwei Bildformate pro Foto. Das dann entsprechend für jede angelegte Bildgröße, wenn es sich um CMS-Systeme wie WordPress handelt. Hört sich umständlich und nach viel Arbeit an. Wozu das ganze? Lohnt sich der Aufwand? Die Entscheidung fällt je nach Projekt und Zielgruppe unterschiedlich aus.

Fakt ist: Geringe Größe der Bilddateien steht für kürzere Ladevorgänge einer Webseite. Dass Website-Performance ein SEO-Faktor ist, wurde mehrmals angesprochen und steht nicht länger zur Debatte. Auch freut sich der Leser über zügige Darstellung der Blogseiten.

Der eingesparte Traffic darf nicht ungeachtet bleiben: Je nach Projekt kommt schnell ein runder Betrag zusammen. Auslieferung weniger Bytes entlastet den Server letztendlich.


### Werkzeuge

Aktuell steht eine durchaus überschaubare Anzahl an Tools für die Generierung von WebP-Grafiken zur Verfügung – verständlich, denn die Methode steckt noch in Kinderschuhen, viele Entwicklungsstände sind als _experimentell_ markiert.

* [Pixelmator](http://www.pixelmator.com/)
* [IrfanView](http://www.irfanview.com/)
* Photoshop mit [WebP-Addon](http://blog.kulturbanause.de/2011/05/webp-grafiken-mit-photoshop-plugin-erstellen/)
* GIMP mit [WebP-Plugin](https://groups.google.com/a/webmproject.org/d/msg/webp-discuss/-3E_t2nhFbk/oCrV5ZHv0UEJ)


### Analyse

Wurden WebP-Varianten der Bilder auf dem Server abgelegt und die Weiterleitungsregel in der Datei `.htaccess` eingefügt, steht einer Auslieferung der optimierten Bilddateien nichts im Weg. Doch wie genau erfolgt die Kontrolle, ob WebP-Bilder auch tatsächlich an ausgewählte Browser gesendet werden? Denn im Browser gibt es ja keinen optischen Unterschied: JPEG- und WebP-Bilder sehen nahezu identisch aus.

Die Antwort ist simpel: Die Rückgabe der Grafiken an den Browser begleitet der Server stets mit der Angabe des [MIME-Types](http://de.wikipedia.org/wiki/Internet_Media_Type): Bei JPEGs ist es `image/jpeg`, bei PNGs `image/png` und bei WebP entsprechend `image/webp`. So lässt sich jedes Grafikformat leicht identifizieren und zuordnen, auch wenn die Datei eine “fremde” Dateiendung aufweist.

Browser wie Chrome und Opera verfügen über sogenannte [Developer Tools](https://developers.google.com/chrome-developer-tools/), die solche Informationen wie MIME-Type einer Datei sichtbar machen.

Aktivierung der Developer Tools in Browsern:  
* **Chrome:** Anzeigen/Entwickler/Entwickler-Tools → Tab _Network_  
* **Opera:** Darstellung/Entwicklerwerkzeuge/Opera Dragenfly → Tab _Netzwerk_


### Zusammenfassung

*   WebP ist von der Dateigröße her kleiner als JPEG
*   WebP sieht auch bei stärkerer Kompression besser aus als JPEG
*   WebP wird von Chrome, Opera und bald Firefox unterstützt
*   WebP beschleunigt Ladezeiten und spart Traffic
*   WebP muss mithilfe von Tools konvertiert werden

Riesiger Vorteil: Mit der Ausgabe der WebP-Bilder im Projekt kann jederzeit begonnen werden: Keine Anpassung an der Einbindung der Grafiken im HTML-Code notwendig. Die oben vorgestellte Weiterleitungsregel für `.htaccess` prüft, ob für die aufgerufene (JPEG-)Bilddatei auf dem Server eine WebP-Variante gibt – im Erfolgsfall wird WebP an unterstützte Browser gesenden, andernfalls kommt das Standard-(JPEG-)Bild zum Einsatz.

---

###### Fazit

Facebook [experimentiert](http://www.zdnet.de/88152324/facebook-testet-googles-jpeg-alternative-webp/) bereits mit der Bildausgabe im WebP-Format. Ob man sich als Entwickler oder Blogger die Mühe macht, Fotos in mehreren Dateiformaten zu führen, hängt stark von der Größe der Website und eingesetzten Werkzeugen ab. Entscheidend dürfte auch die Browser-Nutzung der Leserschaft sein. Kurz: Das Kosten-Nutzen-Verhältnis muss stimmen.