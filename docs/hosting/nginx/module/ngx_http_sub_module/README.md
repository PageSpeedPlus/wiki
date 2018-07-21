## Nginx: CSS- und JavaScript-Ressourcen in HTML inline einbinden

> Nginx liest im HTML hinterlegte Pfade zu CSS und JS-Dateien automatisiert ein und gibt den Code direkt im Quelltext der Webseiten aus.

Um die Anzahl der Requests vom Client zum Server auf ein Minimum zu reduzieren, kann eine direkte Ausgabe von CSS und JavaScript im HTML-Quelltext vorteilhaft sein. Das lohnt sich zum Beispiel bei vielen kleineren Dateien (wenn diese nicht gebündelt werden), aber auch bei „[Above the fold](https://de.onpage.org/blog/above-the-fold-webseiten-richtig-aufbauen)“-Ressourcen – Google nennt diese Technik „[CSS-Bereitstellung optimieren](https://developers.google.com/speed/docs/insights/OptimizeCSSDelivery)“. Statt auf eine Ressource zu verweisen, wird der Inhalt im Quelltet inline positioniert.

### Task Runner: Grunt und Gulp

Arbeitet man als Entwickler mit Tools wie [Grunt](http://gruntjs.com/) und [Gulp](http://gulpjs.com/), so übernehmen Module wie „[grunt-inline](https://www.npmjs.org/package/grunt-inline)“ und „[gulp-inline-source](https://www.npmjs.org/package/gulp-inline-source)“ das dynamische Einlesen und die flexible Ausgabe des Ressourcen-Contents. Muss bei einem Projekt ohne Build-Systeme ausgekommen werden, so springt [Nginx](http://nginx.org/) als Unterstützer ein. Das Beste am Vorhaben: Der Original-HTML-Quelltext wird in keiner Weise verändert.

### Magie mit Server Side Includes

Webentwickler aus den 90ern erinnern sich an [SSI](http://de.wikipedia.org/wiki/Server_Side_Includes) (Server Side Includes) – einzelne Dateien lassen sich ohne Skriptsprachen in HTML-Seiten einbinden. Es spricht also nichts dagegen, SSI als Methode zur Einbindung von CSS- und JavaScript-Ressourcen zu verwenden.

Der nicht unwichtige Punkt: SSI setzt auf eigene Syntax (_<!–# include file= …_) voraus, die mit der HTML-Syntax für die Einbindung von Stylesheets (_<link href= …_) und JavaScript (_<script src= …_) nicht unbedingt übereinstimmt. Die Nginx-Erweiterung [sub_filter](http://nginx.org/en/docs/http/ngx_http_sub_module.html) hilft aus der Klemme und schreibt den Aufruf nach Wünschen des Entwicklers um.

```nginx
location ~* \.html$ {
    ssi on;

    sub_filter
        '<link href="/styles.css" rel="stylesheet" />'
        '<style><!--# include file="/styles.css" --></style>';

    ...
}
```

Nach dem Restart von Nginx findet die Ausgabe der CSS-Datei direkt an der erwarteten Position im Markup statt.

Sollten im HTML-Quelletxt mehrere Ressourcen-Aufrufe ersetzt bzw. inline eingebunden werden, muss auf [subs_filter](/nginx-filter-module/) (_s_ in _subs_ ist wichtig) statt auf _sub_filter_ (ohne _s_ in _subs_) zurückgegriffen werden. Mithilfe von _subs_filter_ sind Mehrfachersetzungen samt RegEx möglich.
```nginx
location ~* \.html$ {
    ssi on;

    subs_filter '<link href="(.*)" rel="stylesheet" />' '<style><!--# include file="$1" --></style>' ir;
    subs_filter '<script src="(.*)"></script>' '<script><!--# include file="$1" --></script>' ir;

    ...
}
```
Einbettung mehrerer Stylesheet- und JavaScript-Dateien möglich.

---

###### Fazit

Wichtig ist bei dieser Technik, nicht zu übertreiben: Inline-Einbindungen monströser CSS- oder JS-Ressourcen beflügeln eine Webseite keinesfalls. Punktuelle, dezente Einbettung an der richtigen Stelle sorgt für einen Performance-Gewinn.