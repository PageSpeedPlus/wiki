## E-Mails kostengünstig mit Amazon Simple Email Service verschicken

> Amazon Simple Email Service (Amazon SES) eignet sich perfekt für den E-Mail-Versand aus Apps heraus. Preiswert und unkompliziert via SMTP.

Kaum eine moderne Webapp oder Website kommt heutzutage ohne E-Mail-Kommunikation mit dem Endnutzer aus: Newsletter, Bestätigungen, Erinnerungen und Benachrichtigungen werden weltweit im Sekundentakt auf den Weg geschickt. Serverausfall? E-Mail. Neuzugang im Shop? E-Mail. Reaktion in Social Media? E-Mail.

Der Nachrichtenversand stellt uns, Entwickler, vor der Frage: Welche Lösung passt zum Projekt? Eine einfache Implementierung à la [mail](http://www.php.net/manual/de/function.mail.php)-Funktion? Eigener Mail-Server mit SMTP? Oder doch ein zuverlässiger Drittanbieter wie [Postmark](https://postmarkapp.com/), [Mandrill](http://mandrill.com/), [Mailjet](https://de.mailjet.com/) und [Amazon SES](http://aws.amazon.com/de/ses/)?


### E-Mail-Services

Drittanbieter erlauben es uns, den Versand von Nachrichten in wenigen Minuten in Anspruch zu nehmen – alles ist dafür ausgelegt, schnellstmöglich loszulegen. Als Entwickler benötigt man keinen Mail-Server, die Einrichtung und Administration entfallen. Aufbereitete Statistiken, die SSL-Verschlüsselung und die erhöhte Zustellbarkeit der E-Mails gehören ebenfalls zu den Pluspunkten. Kostenfaktor: Ab USD 0,10 je tausend Nachrichten.

Hat man einen Service-Provider favorisiert, steht die Entscheidung nach dem Transportweg aus: Datenübergabe via API oder SMTP? Nachfolgend wird die Kommunikation via SMTP vorgestellt, da dies der einfachste Weg ist, E-Mail-Nachrichten aus einer App heraus zu verschicken.


### Amazon SES einrichten

Nach erfolgreicher Registrierung bei [Amazon AWS](http://aws.amazon.com/de/) (wenn nicht bereits geschehen) und anschließender Anmeldung in der _Amazon SES_ Management Console kann mit der Einrichtung des Accounts begonnen werden.

- [ ] **E-Mail-Adresse verifizieren**    
Unter „Verified Senders“ wird die E-Mail-Adresse des Absenders hinterlegt und mithilfe einer zugeschickten E-Mail-Nachricht bestätigt.

- [ ] **Domain der E-Mail-Adresse verifizieren**    
Damit zukünftige E-Mails auch tatsächlich von der eigentlichen Domain verschickt und nicht als Spam erkannt werden (Domain der Absender-E-Mail-Adresse ungleich Mail-Server), muss beim Hoster ein winziger DNS-Eintrag vorgenommen werden. _Amazon SES_ beschreibt an der Stelle sehr verständlich, wie und wohin damit.

- [ ] **SMTP-Benutzer anlegen**    
Im Unterpunkt „SMTP Settings“ wird ein neuer Benutzer für SMTP generiert. Bitte Zugangsdaten sichern. Auf der Übersichtsseite des Bereichs hält _Amazon SES_ den [SMTP-Servernamen](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/regions.html) und zuständige Ports parat.

Domain und E-Mail-Adresse verifiziert? Ab sofort kann also via _Amazon SES_ verschickt werden. Aktuell befindet man sich allerdings im sogenannten Sandbox-Modus: E-Mails lassen sich nur an den _Amazon SES_ Mailbox Simulator oder an die verifizierte(n) E-Mail-Adresse(n) zuschicken. Für Testzwecke absolut ausreichend. Der Produktionszugriff wird nach der Testphase angefordert.


### Amazon SES in PHPMailer

Für [PHPMailer](https://github.com/PHPMailer/PHPMailer)-Anwender ist die Nutzung bzw. Integration des _Amazon SES_ SMTP-Protokolls denkbar einfach:

```php
<?php
require 'PHPMailerAutoload.php';

$mail = new PHPMailer;

$mail->isSMTP();
$mail->Host = "email-smtp.eu-west-1.amazonaws.com";
$mail->Port = 465;
$mail->SMTPSecure = 'ssl';
$mail->SMTPAuth = true;
$mail->Username = 'Smtp Username';
$mail->Password = 'Smtp Password';

$mail->From = 'from@example.com';
$mail->FromName = 'Mailer';
$mail->addAddress('ellen@example.com');

$mail->isHTML(true);

$mail->Subject = 'Here is the subject';
$mail->Body    = 'This is the HTML message body';
$mail->AltBody = 'This is the body in plain text';

if ( !$mail->send() ) {
    echo 'Mailer Error: ' . $mail->ErrorInfo;
    exit;
}

echo 'Message has been sent';
```

SSL dient dabei als Netzwerkprotokoll zur sicheren Übertragung von Daten.

---

###### Fazit

_Amazon SES_: Kostensparende, skalierbare, robuste und administrationsarme Lösung für den Versand von E-Mails aus Webapplikationen heraus.