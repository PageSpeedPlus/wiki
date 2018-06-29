# nginx_dynamic_tls_records.patch

## Optimierung von TLS over TCP zur Reduzierung der Latenzzeit

Die geschichtete Natur des Internets (HTTP über einem zuverlässigen Transport (z.B. TCP), TCP über einer Datagrammschicht (z.B. IP), IP über einem Link (z.B. Ethernet)) war sehr wichtig für seine Entwicklung. Verschiedene Verbindungsschichten sind im Laufe der Zeit gekommen und gegangen (alle Leser, die noch 802.5? verwenden) und diese Flexibilität bedeutet auch, dass eine Verbindung von Ihrem Webbrowser Ihr Heimnetzwerk über WiFi, dann über eine DSL-Leitung, über Glasfaser und schließlich über Ethernet an den Webserver übertragen werden kann. Jede Schicht ist sich der Implementierung der darunter liegenden Schicht nicht bewusst.

Aber es gibt einige Nachteile dieses Modells. Im Falle von TLS (dem gebräuchlichsten Standard für das Senden von verschlüsselten Daten im Internet und dem Protokoll, das Ihr Browser beim Besuch einer Website https:// verwendet) kann die Schichtung von TLS auf TCP zu Verzögerungen bei der Auslieferung einer Webseite führen.

Das liegt daran, dass TLS die zu übertragenden Daten in Datensätze einer festen (maximalen) Größe aufteilt und diese dann zur Übertragung an TCP übergibt. TCP teilt diese Datensätze prompt in Segmente auf, die dann übertragen werden. Letztendlich werden diese Segmente innerhalb von IP-Paketen gesendet, die das Internet durchqueren.

Um Staus im Internet zu vermeiden und eine zuverlässige Zustellung zu gewährleisten, sendet TCP nur eine begrenzte Anzahl von Segmenten, bevor der Empfänger bestätigt, dass die Segmente empfangen wurden. Darüber hinaus garantiert TCP, dass die Segmente in der Reihenfolge an die Anwendung geliefert werden. Wenn also ein Paket irgendwo zwischen Sender und Empfänger abgelegt wird, ist es möglich, dass ein ganzes Bündel von Segmenten in einem Puffer gehalten wird, der darauf wartet, dass das fehlende Segment erneut gesendet wird, bevor der Puffer an die Anwendung freigegeben werden kann.

## TLS und TCP

Das bedeutet für TLS, dass ein großer Datensatz, der über mehrere TCP-Segmente verteilt ist, auf unerwartete Verzögerungen stoßen kann. TLS kann nur komplette Datensätze verarbeiten und so verzögert ein fehlendes TCP-Segment den gesamten TLS-Datensatz.

Zu Beginn einer TCP-Verbindung, da der TCP-Langsamstart erfolgt, kann der Datensatz auf mehrere Segmente aufgeteilt werden, die relativ langsam ausgeliefert werden. Während einer TCP-Verbindung kann eines der Segmente, in die ein TLS-Datensatz aufgeteilt wurde, verloren gehen, wodurch der Datensatz verzögert wird, bis das fehlende Segment erneut übertragen wird.

Daher ist es vorzuziehen, keine feste TLS-Datensatzgröße zu verwenden, sondern die Datensatzgröße anzupassen, wenn sich die zugrundeliegende TCP-Verbindung nach oben dreht (und im Falle einer Überlastung nach unten). Beginnend mit einer kleinen Datensatzgröße hilft, die Datensatzgröße an die Segmente anzupassen, die TCP zu Beginn einer Verbindung sendet. Sobald die Verbindung läuft, kann die Datensatzgröße erhöht werden.

CloudFlare verwendet NGINX zur Bearbeitung von Web-Anfragen. Standardmäßig unterstützt NGINX keine dynamischen TLS-Satzgrößen. NGINX hat eine feste TLS-Recordgröße mit einer Voreinstellung von 16KB, die mit dem Parameter ssl_buffer_size angepasst werden kann.

## Dynamische TLS-Sätze in NGINX

Wir haben NGINX modifiziert, um die Unterstützung für dynamische TLS-Datensätze hinzuzufügen, und sind dabei, unseren Patch zu öffnen. Sie finden es hier. Der Patch fügt dem NGINX SSL-Modul Parameter hinzu.

`ssl_dyn_rec_size_lo`: die TLS-Satzgröße für den Anfang. Standardmäßig 1369 Bytes (so ausgelegt, dass der gesamte Datensatz in ein einziges TCP-Segment passt: 1369 = 1500 - 40 (IPv6) - 20 (TCP) - 10 (Zeit) - 61 (Max TLS-Overhead))

`ssl_dyn_rec_size_hi`: die TLS-Recordgröße, auf die man wachsen will. Standardmäßig 4229 Bytes (passend für den gesamten Datensatz in 3 TCP-Segmenten)

`ssl_dyn_rec_threshold`: die Anzahl der zu sendenden Datensätze vor der Änderung der Satzgröße.

Jede Verbindung beginnt mit Datensätzen der Größe `ssl_dyn_rec_size_lo`. Nach dem Senden von `ssl_dyn_rec_threshold` Datensätzen wird die Satzgröße auf `ssl_dyn_rec_size_hi` erhöht. Nach dem Senden eines zusätzlichen `ssl_dyn_rec_threshold`-Datensatzes mit der Größe `ssl_dyn_rec_size_hi` wird die Datensatzgröße auf `ssl_buffer_size` erhöht.

`ssl_dyn_rec_timeout`: wenn die Verbindung länger als diese Zeit (in Sekunden) steht, wird die TLS-Satzgröße auf `ssl_dyn_rec_size_lo` reduziert und die obige Logik wiederholt. Wenn dieser Wert auf 0 gesetzt ist, werden dynamische TLS-Satzgrößen deaktiviert und stattdessen die feste `ssl_buffer_size` verwendet.

**Fazit**

Wir hoffen, dass die Leute unseren NGINX-Patch nützlich finden und würden uns sehr freuen, von Leuten zu hören, die ihn benutzen und/oder verbessern.

- https://github.com/cujanovic/nginx-dynamic-tls-records-patch
