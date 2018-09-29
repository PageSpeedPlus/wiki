## Vorteile der Nutzung von sudo

Es gibt eine Reihe von Vorteilen für Ubuntu, Root-Logins standardmäßig deaktiviert zu lassen, einschließlich:

Der Installateur hat weniger Fragen zu stellen.

Benutzer müssen sich kein zusätzliches Passwort für den gelegentlichen Gebrauch merken (z.B. das Root-Passwort). Wenn sie es täten, würden sie es wahrscheinlich vergessen (oder es unsicher aufnehmen, so dass jeder leicht in sein System eindringen kann).
Es vermeidet standardmäßig die interaktive Anmeldung "Ich kann alles tun". Sie werden nach einem Passwort gefragt, bevor größere Änderungen vorgenommen werden können, was Sie über die Folgen Ihrer Tätigkeit nachdenken lassen sollte.

sudo fügt einen Protokolleintrag der ausgeführten Befehle hinzu (in /var/log/auth.log). Wenn du es vermasselst, kannst du zurückgehen und sehen, welche Befehle ausgeführt wurden.

Auf einem Server weiß jeder Cracker, dass er einen Account namens root hat und wird das zuerst versuchen. Was sie nicht wissen, ist, wie die Benutzernamen Ihrer anderen Benutzer aussehen. Da das Root-Konto-Passwort gesperrt ist, wird dieser Angriff im Wesentlichen bedeutungslos, da es kein Passwort gibt, das man knacken oder erraten kann.

Ermöglicht die einfache Übertragung von Administratorrechten durch Hinzufügen und Entfernen von Benutzern aus Gruppen. Wenn Sie ein einzelnes Root-Passwort verwenden, besteht die einzige Möglichkeit, Benutzer zu deaktivieren, darin, das Root-Passwort zu ändern.
sudo kann mit einer viel feineren Sicherheitsrichtlinie eingerichtet werden.
Das Root-Konto-Passwort muss nicht an alle weitergegeben werden, die eine Art von administrativen Aufgaben auf dem System durchführen müssen (siehe den vorherigen Punkt).
Die Authentifizierung verfällt automatisch nach kurzer Zeit (die auf so wenig wie gewünscht oder 0 eingestellt werden kann); wenn Sie also das Terminal verlassen, nachdem Sie Befehle als root mit sudo ausgeführt haben, werden Sie ein Root-Terminal nicht auf unbestimmte Zeit offen lassen.


## Nachteile der Verwendung von sudo

Obwohl für Desktops die Vorteile der Verwendung von sudo groß sind, gibt es mögliche Probleme, die beachtet werden müssen:

Die Umleitung der Ausgabe von Befehlen, die mit sudo ausgeführt werden, erfordert einen anderen Ansatz. Betrachten Sie zum Beispiel sudo ls > /root/somefile wird nicht funktionieren, da es die Shell ist, die versucht, in diese Datei zu schreiben. Du kannst ls | sudo tee -a /root/somefile zum Anhängen verwenden, oder ls | sudo tee /root/somefile zum Überschreiben von Inhalten. Sie können den gesamten Befehl auch an einen Shell-Prozess übergeben, der unter sudo ausgeführt wird, um die Datei mit root-Rechten schreiben zu lassen, z.B. sudo sh -c "ls > /root/somefile".

In vielen Büroumgebungen ist der EINZIGE lokale Benutzer auf einem System root. Alle anderen Benutzer werden mit Hilfe von NSS-Techniken wie nss-ldap importiert. Um eine Workstation einzurichten oder zu reparieren, ist im Falle eines Netzwerkausfalls, bei dem nss-ldap beschädigt ist, root erforderlich. Dies führt dazu, dass das System unbrauchbar wird, wenn es nicht geknackt wird. Hierfür wird ein zusätzlicher lokaler Benutzer oder ein aktiviertes Root-Passwort benötigt. Das lokale Benutzerkonto sollte sein $HOME auf einer lokalen Festplatte, _nicht_ auf NFS (oder einem anderen vernetzten Dateisystem) und ein.profile/.bashrc haben, das keine Dateien auf NFS-Mounts verweist. Dies ist normalerweise der Fall bei root, aber wenn Sie ein Nicht-Root-Rettungskonto hinzufügen, müssen Sie diese Vorsichtsmaßnahmen manuell treffen. Der Vorteil der Verwendung eines lokalen Benutzers mit sudo besteht jedoch darin, dass Befehle leicht verfolgt werden können, wie in den oben genannten Vorteilen erwähnt.


## Verwendung

Wenn Sie sudo verwenden, wird Ihr Passwort standardmäßig für 15 Minuten gespeichert. Danach müssen Sie Ihr Passwort erneut eingeben.
Ihr Passwort wird während der Eingabe nicht auf dem Bildschirm angezeigt, auch nicht als Sternenreihe (**********). Sie wird bei jedem Tastendruck eingegeben!


### Sudo

Um sudo auf der Befehlszeile zu verwenden, geben Sie den Befehl mit sudo ein, wie unten beschrieben: 

Beispiel #1

sudo chown bob:bob /home/bob/*

Beispiel #2

sudo /etc/init.d/networking restart

Um den zuletzt eingegebenen Befehl zu wiederholen, außer mit vorangestelltem sudo, führen Sie run aus:

sudo !!!!


### Benutzer

Erlaubt anderen Benutzern, sudo auszuführen.

Um einen neuen Benutzer zu sudo hinzuzufügen, öffnen Sie das Werkzeug Benutzer und Gruppen aus dem Menü System->Administration. Klicken Sie zuerst auf Entsperren, dann können Sie einen Benutzer aus der Liste auswählen und auf Eigenschaften klicken. Wählen Sie die Registerkarte Benutzerprivilegien und aktivieren Sie die Option Systemadministration.

Warnung /!\\ Im Terminal (für Precise Pangolin, 12.04.) wäre das:

sudo adduser <username> sudo

wobei Sie <username> durch den Namen des Benutzers ersetzen (ohne das <>).

In der vorherigen Version von Ubuntu

sudo adduser <username> admin

wäre angemessen gewesen, aber die Admin-Gruppe wurde veraltet und existiert nicht mehr in Ubuntu 12.04.


### Anmelden als ein anderer Benutzer

Bitte verwende dies nicht, um root zu werden, siehe weiter unten auf der Seite für weitere Informationen dazu.

sudo -i -i -u <username>

Zum Beispiel, um der Benutzer amanda für die Bandverwaltung zu werden.

sudo -i -i -u amanda

Das Passwort, nach dem du gefragt wirst, ist dein eigenes, nicht das von Amanda.


### Root-Konto


Aktivieren des Root-Kontos

Die Aktivierung des Root-Kontos ist selten notwendig. Fast alles, was Sie als Administrator eines Ubuntu-Systems tun müssen, können Sie über sudo oder gksudo erledigen. Wenn Sie wirklich eine persistente root-Anmeldung benötigen, ist die beste Alternative, eine root-Anmeldeshell mit dem folgenden Befehl zu simulieren.....

sudo -i

So aktivieren Sie das Root-Konto (d.h. setzen Sie ein Passwort) 

sudo passwd root

Die Nutzung erfolgt auf eigene Gefahr! 

Die Anmeldung bei X als root kann zu sehr großen Problemen führen. Wenn Sie glauben, dass Sie ein Root-Konto benötigen, um eine bestimmte Aktion durchzuführen, konsultieren Sie bitte zuerst die offiziellen Support-Kanäle, um sicherzustellen, dass es keine bessere Alternative gibt.


Deaktivieren Sie Ihr Root-Konto erneut.

Wenn Sie aus irgendeinem Grund Ihr Root-Konto aktiviert haben und es wieder deaktivieren möchten, verwenden Sie den folgenden Befehl im Terminal.....

sudo passwd -dl root
