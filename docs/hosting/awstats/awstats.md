# AWStats

![AWStats - Logo](https://speedwp.github.io/ispconfig-nginx-pagespeed/Logos/AWStats-logo.png)

## Wie Man Den Bildschirmgrösse Und Browser-Funktionen Erhalten Wollen?

### PROBLEM:
Ich sehe in der AWStats-Feature-Liste, dass es die Bildschirmgröße melden kann, die von Besuchern und anderen Browser-Informationen verwendet wird (wie wenn Browser Flash, Java, Javascript, PDF, Macromedia, Audio-Plugins usw. unterstützt). Wie kann ich das machen ?
### LÖSUNG:
AWStats ist ein Protokollanalysator. Um die Bildschirmgröße Ihres Besuchers zu melden, benötigen wir Informationen in der Protokolldatei selbst. Dafür können Sie nur einige HTML-Tags in einigen Ihrer Seiten hinzufügen (die Homepage reicht aus, um die Nutzungsverhältnisse zu ermitteln). Dieses Tag fügt einen Aufruf an ein Javascript hinzu, das Ihren Browser auffordert, eine virtuelle URL zu erhalten, die in seinen Parametern die Bildschirmgrößenauflösung und alle anderen Informationen über Browserfunktionen (Flash, Java, Javascript, PDF, Macromedia, Audio) enthält. .)..

Dies ist der Code, den Sie hinzufügen müssen (z. B. unten auf Ihrer Homepage):

```javascript
<script language="javascript" type="text/javascript" src="/js/awstats_misc_tracker.js" ></script>
```
```html
<noscript><img src="/js/awstats_misc_tracker.js?nojs=y" height="0" width="0" border="0" style="display: none"></noscript>
```

Beachten Sie, dass Sie das Skript awstats_misc_tracker.js (das sich im Verzeichnis / js mit AWStats befindet) auch in einem js-Verzeichnis ablegen müssen, das in Ihrem Web-Root gespeichert ist.
Sobald dies erledigt ist, laden Sie Ihre Startseite mit Ihrem Browser und gehen Sie in Ihrer Protokolldatei nach, ob Sie eine Zeile sehen können, die wie folgt aussieht:
```bash
123.123.123.123 - - [24/Apr/2005:16:09:38 +0200] "GET /js/awstats_misc_tracker.js?screen=800x600&win=724x517&...&sid=awssession_id123 HTTP/1.1" 200 6237 "http://therefererwebsite.com/index.php" "Mozilla/5.0 (Linux) Gecko/20050414 Firefox/1.0.3"
```

Wenn ja, können Sie den AWStats-Update-Prozess ausführen. Bildschirmgrößeninformationen werden analysiert. Alles, was Sie jetzt tun müssen, ist, Ihre Konfigurationsdatei zu bearbeiten, damit AWStats den Bericht zur HTML-Ausgabe hinzufügt. Ändern Sie dazu den Parameter ShowMiscStats.
ShowMiscStats = anjdfrqwp

Hinweis: Wenn Sie das Verzeichnis wechseln, in dem awstats_misc_tracker.js gespeichert ist (woanders als das Verzeichnis / js), müssen Sie gemäß Ihrer Änderung Folgendes ändern:
- Die HTML-Tags hinzugefügt
- die Zeile: `var awstatsmisctrackerurl = "/ js / awstats_misc_tracker.js"`; im Skript awstats_misc_tracker.js
- der Parameter MiscTrackerUrl in der AWStats-Konfigurationsdatei.

[AWStats_FAQ](https://awstats.sourceforge.io/docs/awstats_faq.html#SCREENSIZE)

***
