# Munin 
![Munin Logo](https://raw.githubusercontent.com/munin-monitoring/munin/master/logo.svg)

Munin ist eine umfassende und sehr einfach zu bedienende Rechner-Überwachungssoftware. Verschiedene Informationen wie die Prozessorauslastung, Festplattenbelegungen oder auch Zugriffe auf Serverdienste eines oder mehrerer Rechner werden permanent gesammelt und können über eine Weboberfläche betrachtet werden.

Munin selber ist als Master/Client-Anwendung aufgebaut. Der Master-Rechner kann den "Munin-Node" auf weiteren Rechnern im Netzwerk abfragen und so diese Informationen mit anzeigen. Munin eignet sich daher für die Überwachung eines einzigen Rechners wie auch für die Überwachung eines ganzen Rechnerparks. Ein Beispiel einer Munin-Installation zur Überwachung eines ganzen Rechnerfuhrparks findet man hier.

Alternativen zu Munin sind Nagios und Icinga.

## Installation

`Munin `kann aus den Paketquellen installiert werden. Dazu müssen je nach Bedarf die Pakete. Je nach Einsatz sollte nur `Munin `bzw. `Munin-node` installiert werden.

### Munin

`Munin-node` sammelt nur die Daten.

### Munin-node

installiert werden.  die dann von `munin `abgerufen und über einen Webserver dargestellt werden.

Bei der Installation von `munin `ist zu beachten, dass ein Webserver auf dem Rechner bereits eingerichtet sein sollte, damit die Informationen auch abgerufen werden können. Ebenso muss der Cron-Daemon installiert sein, damit `munin `auch die Serverstatistiken erstellt (Der Master und der Client erstellen dazu in /etc/cron.d/ je einen Cron-Job). Anschließend kann man die Statistiken unter der Adresse http://<Servername oder -IP>/munin/ abrufen.

### Munin steuern

Wie alle anderen Dienste bringt Munin Start/Stop-Skripte mit. Diese Skripte lassen sich natürlich auch zum Kontrollieren des Dienstes gebrauchen.

```bash
/etc/init.d/munin-node restart
/etc/init.d/munin restart 
```
## Munin - Plugin Gallery

Dies ist der Ort, wo Sie Beschreibung und Grafiken für unsere Munin Plugins durchsuchen können. Es ist noch nicht fertig und fertig. Beispielgraphbilder fehlen immer noch und viele Plugins haben keine Perdoc-Sections. Hilfe von Mitwirkenden ist willkommen :-)

Die Galerie hat zwei Ausstellungsräume. Eine namens Core Collection für die Plugins, die wir mit der Distribution von Munin-Node und eine namens 3rd-Party Collection für die Plugins aus der freien Wildbahn liefern, die in unser Contrib-Repository hochgeladen wurden. Besonders die spätere Dokumentation benötigt viel Arbeit und wir freuen uns, wenn Sie dem contrib Repo Informationen im perldoc-Format und repräsentative Grafikbeispiele hinzufügen. Je beschreibender Inhalt vorhanden ist, desto hilfreicher ist die Plugin-Galerie

Schauen Sie sich unsere Anleitung im Munin Wiki an

Und jetzt beginnen Sie die Plugin-Sammlung mit einem Klick auf die Kategorie im linken Menü zu durchsuchen.

http://gallery.munin-monitoring.org/

## 

https://guide.munin-monitoring.org/en/latest/example/index.html#examples-from-munin-wiki