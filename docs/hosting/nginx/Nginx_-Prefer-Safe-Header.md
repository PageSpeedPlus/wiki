## Jugendschutz: Prefer:Safe Header-Abfrage in Nginx, Apache und PHP

> Ist im Betriebssystem der Jugendschutz aktiv, senden Browser den HTTP-Header „Prefer:Safe“ - Signal für die Steuerung sensibler Webinhalte.

Jugendschutz ist und bleibt ein wichtiges Thema im Web (Stichwort [JMStV](http://de.wikipedia.org/wiki/Jugendmedienschutz-Staatsvertrag)): Bestimmte Inhalte oder gar komplette Websites dürfen an Kinder und Jugendliche nicht (ohne Weiteres) ausgeliefert werden. Inhaber dieser Angebote stehen jedoch vor dem Problem zuverlässiger Alter-Identifizierung.

Einen Ausweg verspricht der HTTP-Header [Prefer:Safe](http://tools.ietf.org/html/draft-nottingham-safe-hint-01), den einige Browser an den Server der aufgerufenen Webseite senden, sobald der Besucher im Jugendschutz-Modus des Betriebssystems ([Jugendschutz in Windows](http://windows.microsoft.com/de-de/windows/set-parental-controls), [Kindersicherung in OS X](http://support.apple.com/kb/PH14414?viewlocale=de_DE)) surft. Auf diese Weise leitet der Browser das vom OS gesetzte Schutzmerkmal an die Webapplikation weiter.

Auf der Server-Ebene werden Anfragen dieser Art erkannt und auf präparierte Ziele umgeleitet. Steuerung der Inhalte ist in diesem Context ebenfalls denkbar.


### Prefer:Safe mit Nginx abfragen

```nginx
location / {
    if ( $http_prefer = safe ) {
        return 403;
    }

    ### ... ###
}
```

Prüfung des `$http_prefer` Nginx-Wertes innerhalb der Seitenaufrufe.


### Prefer:Safe mit Apache abfragen

```apache
<IfModule mod_rewrite.c>
    RewriteCond %{HTTP:prefer} =safe
    RewriteRule ^ - [F,L]
</IfModule>
```

Abgleich der `HTTP:prefer` Apache-Variable bei aktiviertem `mod_rewrite`-Modul.


### Prefer:Safe mit PHP abfragen

```php
if ( ! empty($_SERVER['HTTP_PREFER']) &&
             $_SERVER['HTTP_PREFER'] === 'safe' ) {
    header( 'HTTP/1.1 403 Forbidden' );
    exit();
}
```

(Re)Aktion nach der Übereinstimmung der Server-Variable `HTTP_PREFER` in PHP.


### Browser-Support

*   [Internet Explorer 11](http://support.microsoft.com/kb/2980016)
*   [Firefox 31](https://blog.mozilla.org/privacy/2014/07/22/prefersafe-making-online-safety-simpler-in-firefox/)

---

###### Fazit

Ob man im Fall des gesendeten „Prefer:Safe“ Headers einen 403-Statuscode zurückgibt (wie in den Beispielen oben) oder auf eine Landingpage weiterleitet, spielt an dieser Stelle keine Rolle. Wichtig ist die korrekte Nutzung der Header-Variable für die Abwicklung des Jugendschutzes.