## TLS/SSL-Zertifikat für Custom Domains in Amazon S3/CloudFront

> In Amazon S3 gespeicherte Dateien über die eigene Domain HTTPS-verschlüsselt ausliefern. Dank Amazon CloudFront und eigenem SSL-Zertifikat.

Für die Datenauslieferung an einen Client/Browser nutzt [Amazon S3](http://aws.amazon.com/de/s3/) standardmässig HTTPS-Verbindungen. Die Verschlüsselung der Kommunikation geschieht allerdings nur dann, wenn Dateien via kryptische, ellenlange Amazon S3 URLs aufgerufen werden. Soll eine eigene (Sub)Domain zum Einsatz kommen und via CNAME auf ein Amazon S3 Bucket verweisen, erfolgt die Ausgabe über eine gewöhnliche HTTP-Verbindung.

Lösung: [Amazon CloudFront](http://aws.amazon.com/de/cloudfront/) mit der Möglichkeit, benutzerdefinierte Zertifikate für Custom Domains festlegen zu können. Bonus: Vorteile eines [CDN](http://de.wikipedia.org/wiki/Content_Delivery_Network).

Für eine Unmenge an Geld (_Dedicated IP Custom SSL_ für 600 USD pro Monat) lässt sich ein SSL-Zertifikat direkt bei Amazon AWS in Anspruch nehmen. Der preiswertere, doch zugegeben komplexere Weg geht über eine manuelle Installation/Upload eines (eigenen) Zertifikates:

*   TLS/SSL-Zertifikat unabhängig vom Anbieter kaufen
*   TLS/SSL-Zertifikat zu Amazon CloudFront via AWS CLI hochladen
*   TLS/SSL-Zertifikat in der Amazon CloudFront Distribution auswählen

Wie Amazon CloudFront mit Amazon S3 verbunden wird, soll an dieser Stelle nicht näher spezifiziert werden.


### TLS/SSL-Zertifikat erwerben

Bei welchem Anbieter das Zertifikat erworben wird, spielt letztendlich keine Rolle. Aus Erfahrung kann [Namecheap.com](http://www.namecheap.com) empfohlen werden.

Der für die Registrierung eines SSL-Zertifikates notwendige Schlüssel kann im Terminal wie folgt generiert werden:

```bash
openssl req -nodes -newkey rsa:2048 -keyout domain.key -out domain.csr
```

Der abgefragte „Common Name“ muss dem Host der Website entsprechen. Bei Wildcard-Zertifikaten ist _*.domain.de_ entsprechend als Wert einzugeben.

```bash
openssl rsa -in domain.key -text > domain.key.pem
```

Für die spätere Übertragung des Schlüssels zu Amazon AWS wird eine PEM-Variante benötigt und wird hier direkt angefertigt.


### TLS/SSL-Zertifikat hochladen

Für die Übertragung eines Zertifikates nach CloudFront stellt Amazon AWS keine grafische Oberfläche zur Verfügung. Die Abhilfe schafft [AWS CLI](http://aws.amazon.com/de/cli/), die Befehlszeilenschnittstelle.

```bash
brew install awscli
```

1\. [AWS CLI installieren](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

```bash
aws configure
```

2\. [AWS CLI einrichten](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

```
aws iam upload-server-certificate \
    --server-certificate-name domain.de \
    --certificate-body file://domain.de.crt \
    --private-key file://domain.de.key.pem \
    --certificate-chain file://commodo.chain.crt \
    --path /cloudfront/domain.de/
```

3\. [Zertifikat via AWS CLI uploaden](http://docs.aws.amazon.com/cli/latest/reference/iam/upload-server-certificate.html)


### TLS/SSL-Zertifikat auswählen

Wurde das benutzerdefinierte SSL-Zertifikat erfolgreich via _AWS CLI_ übertragen, kann es beim Anlegen oder Editieren einer CloudFront Distribution unter _„SSL Certificate > Custom SSL Certificate (stored in AWS IAM)“_ ausgewählt werden.

Im Bereich _„Custom SSL Client Support“_ wird die Option _„Only Clients that Support Server Name Indication (SNI)“_ gewählt.

---

###### Fazit

Jetzt nur noch die eigene (Sub)Domain in _„Distribution Settings > Alternate Domain Names“_ eingeben, die CNAME-Umstellung (_domain > cloudfront_) beim Domain-Hoster beantragen und den HTTPS-Aufruf der auf Amazon S3 gehosteten Dateien via Custom Domain verifizieren.

Dran denken: Sowohl das Deployment/Verteilen des ausgewählten TLS/SSL-Zertifikates in Amazon CloudFront wie die DNS-Umstellung beim Hoster können eine unbestimmte Zeit in Anspruch nehmen.