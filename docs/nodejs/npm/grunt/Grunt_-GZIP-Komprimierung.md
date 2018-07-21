## Grunt: GZIP für CSS und JS mit Zopfli

Heutzutage gehört es zum guten (Webperformance-)Ton, SVG-, JS- und CSS-Dateien noch vor der Auslieferung an den Client serverseitig zu komprimieren. In der Regel übernehmen Webserver den notwendigen Komprimierungsprozess (Stichwort [mod_deflate](http://httpd.apache.org/docs/2.2/mod/mod_deflate.html)): Statische Ressourcen werden bei jeder Anfrage on-the-fly verkleinert und geschwind an den Browser gesendet.

Bei hochfrequentierten Projekten stößt diese Technik an ihre Grenzen: Ununterbrochene Dateikomprimierung belastet den Server, da wirklich jeder Request an JavaScript und CSS letztendlich eine GZIP-Ausführung mit sich bringt.

Es existieren mehrere Methoden, die für das Server-Caching der bereits generierten GZIP-Dateien zuständig sind. An dieser Stelle soll gezeigt werden, wie JS- und CSS-Dateien im Vorfeld mithilfe von [Grunt](http://gruntjs.com) erzeugt werden, um den Webserver von dieser Aufgabe zu befreien. Der einzige Job, den der Webserver in diesem Zusammenhang noch zu erledigen hätte, wäre die Auslieferung der GZ-Dateien, sofern sie verfügbar sind.

### 1. Grunt-Task

[Zopfli](https://de.wikipedia.org/wiki/Zopfli) als Datenkompressions-Algorithmus eignet sich perfekt, um eine Datenmenge richtig klein zu bekommen und dabei kompatibel zu bleiben. [grunt-zopfli-native](https://github.com/pierreinglebert/grunt-zopfli-native) ist das passende Werkzeug für Grunt. Installieren, einrichten und bei größeren Quelldateien vielleicht nicht unbedingt im Watcher laufen lassen, da die Komprimierung nicht unbedingt die schnellste ist.

```javascript
module.exports = {
    deploy: {
        files: [
            {
                expand: true,
                cwd: "/js/",
                src: [ "*.min.js" ],
                dest: "/js/"
            },
            {
                expand: true,
                cwd: "/css/",
                src: [ "*.css" ],
                dest: "/css/"
            }
        ]
    }
}
```


### 2. Deploy

Durch Grunt angefertigte GZIP-Dateien werden zusammen mit minimierten CSS- und JS-Dateien auf den Webserver hochgeladen.

### 3. .htaccess

Damit GZIP-Dateien im HTML-Markup nicht direkt referenziert werden müssen, wird die Apache-Systemdatei `.htaccess` um eine Regel erweitert, die auf gewünschte CSS- und JS-Dateien lauscht und bei gestellten Anfragen prüft, ob für eine angeforderte Datei auch tatsächlich eine GZIP-Variante vorliegt. Existiert das passende GZIP-File, so wird es ausgegeben. Im Fehlerfall gibt Apache die angeforderte CSS- bzw. JS-Datei zurück.

```apache
## GZ HANDLING
<FilesMatch "\.(js|css)\.gz$">
    Header append Content-Encoding gzip
    Header append Vary Accept-Encoding
</FilesMatch>

RewriteCond %{REQUEST_URI} \/(css|js)\/
RewriteCond %{HTTP:Accept-encoding} gzip
RewriteCond %{REQUEST_FILENAME}\.gz -s
RewriteRule ^(.*)\.(css|js)$ $1\.$2\.gz [QSA]

RewriteRule \.css\.gz$ - [T=text/css,E=no-gzip:1]
RewriteRule \.js\.gz$ - [T=application/javascript,E=no-gzip:1]
```

#### Tipp
Ob Apache die reguläre JS/CSS-Datei oder wie erwartet die vorkomprimierte GZ-Datei an den Browser sendet, erkennt man am _Content-Length_-Wert in Developer-Tools.