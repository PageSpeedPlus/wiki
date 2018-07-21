## Berechtigungen für Webverzeichnis

- `chown -R www-data:www-data /var/www/`
- `find /var/www/ -type f -exec chmod 644 {} +`
- `find /var/www/ -type d -exec chmod 755 {} +`

***

## WordPress Core

Als eine der ersten Massnahmen bei einer neuen WordPress Seite sollte man gleich ein Mal Balast abwerfen. Keines der folgenden „Features“ ist nützlich, oder sonst irgendwie sinnvoll. Im Gegenteil der Unsinn frisst nicht nur Performence sondern ist stellt auch ein Sicherheitsrisiko dar. Da Mann folgenden Module leider im Core verankert hat, bleibt nichts ausser zu deaktivieren. Ausser der Kommentar Funktion, gehört alles nicht in den Core. Ein Plugin das niemand brauchen würde hätte gereicht und wäre wohl vor sich hingestorben. Nun dafür gibt es heute haufen Plugins die WP Embeds, Header Links oder die Emojis wieder deaktivieren.

* [How To Set Up Password Authentication with Nginx](https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-nginx-on-ubuntu-14-04)

### WP-Cron - Durch einen echten Cronjob System entlasten.

Der Cornjob von WordPress kümmert sich beispielsweise um Updates. Dieser PHP Cronjob `wp_cron` ist als echter Linux Cronjob um einiges performanter. Also deaktivieren wir die PHP Version in der `wp-config.php` Datei und übernehmen ihn im Linux System.

Um in der Linux Shell einen Cronjob hinzufügen zu können wird folgender Befehl benötigt:

```bash
crontab -e
```
Nun einfach folgende Zeile kopieren und zu den anderen Cronjobs hinzufügen:

```bash
*/10 * * * * curl http://example.com/wp-cron.php?doing_wp_cron > /dev/null 2>&1`
```

Alle 10 Minuten wird nun `wp-cron.php` vom System aufgerufen während sich PHP nicht mehr darum kümmern muss.

Um nun WP_Cron zu deaktivieren, fügen Sie die folgende Zeile zu Ihrer `wp-config.php` hinzu:

```php
define('DISABLE_WP_CRON', true);
```

Dann alle 15 Minuten manuell einen Cron-Job (sollte für die meisten Websites ausreichen):

```bash
*/15 * * * * wget -q -O - http://www.website.com/wp-cron.php?doing_wp_cron &>/dev/null
```

via `curl`:

```bash
*/15 * * * * curl http://www.website.com/wp-cron.php?doing_wp_cron &>/dev/null
```

oder mit `php-cli`:

```bash
*/15 * * * * cd /home/user/public_html; php wp-cron.php &>/dev/null
```

Bevorzugen Sie `wget `und `curl` vor `php-cli`. Stellen Sie sicher, dass Ihre Aufgaben auch nach dieser Änderung noch laufen!

#### WP Crontrol

Wer kein Zugriff auf System Cron Jobs hat der kann immerhin mit dem Plugin die PHP Variante regulieren.

[WP Crontrol](https://wordpress.org/plugins/wp-crontrol/)


***


## Theme

### Child Theme

#### WP-CLI

```bash
wp scaffold child-theme hueman-pagespeed-plus --parent_theme=hueman--author=nikeo
```

#### Datein aus dem child theme Verzeichnis laden.

```php
<?php get_stylesheet_directory_uri(); ?>

/*  Template Datei einbinden */
include( get_stylesheet_directory() . 'template-sitemap.php' );
	
/*  Image Datei einbinden */
<img src="<?php echo get_stylesheet_directory_uri(); ?>/images/aternus.png" alt="" width="" height="" />
```

***

	

	
	
	


## Grafikoptimierung

### [Retina](https://github.com/stefanledin/responsify-wp#retina-1)

[Responsify-WP](https://github.com/stefanledin/responsify-wp)


***




# WordPress Performence Knowledge Base

## WordPress Core

### WP Emojis

* [How to Add EmojiOne Support to Your WordPress Site](https://perfmatters.io/docs/disable-emojis-wordpress/)

### Heartbeat API

* [Diagnose admin-ajax.php Causing Slow Load Times in WordPres](https://woorkup.com/diagnose-admin-ajax-php-causing-slow-load-times-wordpress/)

## Die besten WordPress Plugin

Perlen aus einer Sammlung der besten verfügbaren Plugins: https://www.pinterest.ch/danielbieli6/wordpress-plugin/

### WordPress Core & Skript Manager

- [perfmatters](https://perfmatters.io/features/)
- [Autoptimize criticalcss.com power-up](https://wordpress.org/plugins/autoptimize-criticalcss/)

### Cache

- [Cache Enabler](https://woorkup.com/wordpress-cache-enabler/)

### Multimedia

- [Lazy Load for Videos](https://woorkup.com/decrease-load-times-lazy-load-videos-plugin/)
- [BJ Lazy Load](https://wordpress.org/plugins/bj-lazy-load/)
- [Responsify WP](https://github.com/stefanledin/responsify-wp)
- [Optimus – WordPress Image Optimizer](https://wordpress.org/plugins/optimus/)

### Development/Troubleshooting

- [Plugin Detective](https://wordpress.org/plugins/plugin-detective/)
- [Query Monitor](https://de.wordpress.org/plugins/query-monitor/) [GitHub](https://github.com/johnbillion/query-monitor)