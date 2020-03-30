# CSS-Sprites: HTTP-Requests einsparen

_02.01.2010 von André Bräkling_
  
Die Ladezeiten einer Webseite sind, wie ich z.B. im Artikel über das Kurzzeitgedächtnis und WebDesign beschrieben habe, enorm wichtig. Neben dem Problem, dass ein Nutzer bei einem lange nicht beachteten Tab vergessen kann, wozu er die Seite besucht hat, neigen viele Surfer dazu möglichst viele Suchergebnisse o.ä. in Tabs zu öffnen. Sie schauen sich dann diejenigen Resultate an, die schnell fertig geladen haben, und können den Rest gleich wieder schließen, wenn sie die gewünschte Information bereits gefunden oder gar das gesuchte Produkt bestellt haben.

Tricks zur Beschleunigung einer Seite gibt es viele. An dieser Stelle möchte ich die mittlerweile recht beliebten und sehr effektiven CSS-Sprites vorstellen. Webseiten bestehen heute aus vielen einzelnen Dateien, z.B. JavaScript, Stylesheets und eben auch Bilder. Bei den Bildern handelt es sich meist auch um wiederkehrende Layout-Elemente, z.B. die einzelnen Seitenstücke und Ecken eines Rahmens. Für jedes dieser Elemente muss ein eigener HTTP-Request durchgeführt werden. Wird kein Caching durchgeführt sind diese Requests sogar bei jedem einzelnen Seitenaufruf notwendig. Dadurch entstehen insbesondere folgende Nachteile:

Die Anzahl der gleichzeitig durchführbaren HTTP-Requests ist beschränkt (i.d.R. weniger als 5), wodurch auch bei noch so hoher Bandbreite ein Flaschenhals entsteht.
Mit jedem Request werden auch wieder Headerdaten versendet, sowohl vom Browser an den Server als auch umgekehrt. Dadurch entsteht für jede kleinste Datei mehrfacher Datenballast.
Alternative Grafiken z.B. für Hovereffekte werden erst später nachgeladen, wodurch für den Nutzer sichtbare Verzögerungen entstehen können.

## CSS-Sprite: Demografik

Hier setzen nun die CSS-Sprites an. Statt jede Grafik als einzelne Datei zu speichern, werden sie in einer großen Grafik zusammengefasst, die dann immer mit dem passenden Ausschnitt gezeigt wird. Das linke Bild soll in diesem Beitrag als Beispiel verwendet werden um einen roten, einen grünen und einen blauen Button zu erzeugen. Einzelne Grafiken dieses Blogs sind auch in einer Spritegrafik zusammengefasst. Folgende Bedingungen sollte eine Grafik erfüllen, um in den Sprite aufgenommen zu werden:

Es handelt sich um eine Grafik, die regelmäßig auf der Webseite verwendet wird. Immerhin wäre es Blödsinn eine Grafik, die nur einmal auf der gesamten Seite auftaucht, ständig via Sprite zu laden.
Ihre Farbpalette passt ungefähr zu den anderen Grafiken im Sprite. Beispielsweise wäre es kontraproduktiv einen Sprite aus 100 schwarz-weiß Icons für ein einzelnes 32-bit Foto komplett als HighColor-Bild zu speichern.
Grundsätzlich sollte man auch einen Blick auf die Größe der Spritegrafik werden und mit der Größe der Einzelgrafiken vergleichen. Sie sollte nur minimal höher sein bzw. in den meisten Fällen sogar niedriger ausfallen. Sonst besteht offenbar noch Optimierungsbedarf.

Um unsere vorgestellte Buttongrafik zu laden ist also nur ein HTTP-Request notwendig, obwohl gleich drei Buttons enthalten sind. Nun muss CSS eingesetzt werden, damit auch wirklich nur der gewünschte Bereich der Grafik dargestellt wird. Eingefügt wird die Grafik als Background-Image, wobei ich in diesem Beispiel DIV als zugehöriges Element wähle:

```html
div.spritebox {
   background: url(/wp-content/uploads/css_sprite_demo.gif) no-repeat top left;
   height:50px;
   width:51px;
}
```

Unser Bild wird also als Hintergrundgrafik ohne Wiederholung an die linke, obere Ecke gesetzt. Höhe und Breite kann ich bereits an dieser Stelle festlegen, da alle drei Bildchen gleich groß sind.

Jetzt sehe ich natürlich nur das erste Element, da dieses genau in den vordefinierten Bereich passt. Um alle anderen enthaltenen Grafiken darstellen zu können, definiere ich eigene CSS-Klassen:

```html
.sprite-red_button {background-position:0 0;}
.sprite-green_button {background-position:-50px 0;}
.sprite-blue_button {background-position:-100px 0;}
```

Dadurch wird die Hintergrundgrafik nun innerhalb meines DIVs verschoben, sozusagen als wenn ich einen Papierstreifen mit den Grafiken hinter einem Sichtfenster (= DIV) durchschiebe. So sähe also der HTML-Part aus:

```html
<div class="spritebox sprite-red_button"></div>
<div class="spritebox sprite-green_button"></div>
<div class="spritebox sprite-blue_button"></div>
```

Und hier das Ergebnis: Drei verschiedene Einzelbilder aus nur einer Spritegrafik:

* Rot (0, 0):
* Grün (-50, 0):
* Blau (-100, 0):

Dieser CSS-Sprite kann jetzt natürlich auch für einen Hover-Effekt ohne Nachladen verwendet werden. Zunächst der CSS-Ausschnitt:

```html
.sprite-hoverbutton {background-position:0 0;}
.sprite-hoverbutton:hover {background-position:-50px 0;}
```

Und natürlich der HTML-Teil:

```html
<div class="spritebox sprite-hoverbutton"></div>
```

Oder in einer Alternative mit JavaScript:

```html
<div
   class="spritebox sprite-red_button"
   onmouseover="javascript:this.style.backgroundPosition='-50px 0';"
   onmouseout="javascript:this.style.backgroundPosition='0 0';"
>
</div>
```

Schon ist der Hover-Effekt fertig (hier via JavaScript implementiert):

Also eigentlich eine ganz einfache Geschichte mit großer Wirkung :) Der einzige Haken ist natürlich die Zusammenstellung der Spritegrafik und der zugehörigen CSS-Klassen und dabei auch die Wartung einer Einzelgrafik. Aber dafür gibt es natürlich hilfreiche Tools wie den Sprite-Generator, der online benutzt werden kann. Einfach ein ZIP-File mit den Einzelbildern hochladen und schon gibt es die Spritegrafik und die zugehörigen CSS-Anweisungen zurück.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTI4OTc5MjY4Ml19
-->