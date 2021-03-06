<img src="https://raw.githubusercontent.com/PageSpeedPlus/easyengine/master/docs/assets/img/WP-CLI-logo-landscape-black-white.png" align="right">

# WP-CLI

**[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)**

* Unterpunkt 1
    * Unterpunkt 1.1
    * Unterpunkt 1.1
    * Unterpunkt 1.1
* Unterpunkt 2
* Unterpunkt 3
    * Unterpunkt 3.1
        * Unterpunkt 3.1.1
        * Unterpunkt 3.1.1
    * Unterpunkt 3.2
    * Unterpunkt 3.3
* Unterpunkt 4
* Unterpunkt 5

## WP-CLI Setup & Verwalung

### WP-CLI installieren

```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod 755 wp-cli.phar
chown root:www-data /usr/bin
chmod 770 /usr/bin
mv wp-cli.phar /usr/bin/wp
```
### WP-CLI autocomplete

cd /var/www
wget https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash
chmod +x wp-completion.bash
source /var/www/wp-completion.bash

### WP-CLI Update

`wp cli update`

### WP-CLI Erweiterungen

`wp package install  wp-cli/find command`

### WP-CLI benutzen

Um eine Webseite mit WP CLI zu bearbeiten muss man in das root Verzeichnis der entsprechenden Domain wechseln. Innerhalb dieses Verzeichnis werden alle Befehle auf die entsprechende WordPress Instanz bezogen. Somit können theoretisch tausende WordPress Instanzen auf einem einzigen Server mit WP-CLI induviduell angesprochen werden.

`cd /var/www/speedword.press/htdocs`

Man kann umständlich trotzdem aus jedem Verzeichnis Befehle absetzen. Man muss zu jeder Befehlszeile den Vollen Pfad der Installation angeben, wenn man sich nicht im root Verzeichnis der Instanz befindet. 

`wp comment list --path=/var/www/speedword.press/htdocs/`

## WordPress Installation

https://make.wordpress.org/cli/handbook/installing/

**1. Verzeichnis erstellen & WordPress downloaden**

```bash
wp core download --path=wpclidemo.dev
cd wpclidemo.dev
```

Output:

```bash
Creating directory '/srv/www/wpclidemo.dev/'.
Downloading WordPress 4.6.1 (en_US)...
```

**2. `wp-config.php` erstellen**

```bash
wp config create --dbname=wpclidemo --dbuser=root --dbpass=securepswd --dbprefix=myprefix
cli.org
```

**3. Datenbank erstellen**

Die Datenbank wird nun mit den Angaben in der `wp-config.php` generiert.

```bash
wp db create
```

**4. WordPress Core installieren**

```bash
wp core install --url=wpclidemo.dev --title="WP-CLI" --admin_user=wpcli --admin_password=wpcli --admin_email=info@wp-cli.org
```

## `wp-config.php`

[SUBCOMMANDS](https://developer.wordpress.org/cli/commands/config/)

`wp config list --format=table/csv/json/yaml`

`EDITOR=nano wp config edit`

```bash
wp config create --dbname=testing --dbuser=wp --dbpass=securepswd --extra-php <<PHP
define( 'WP_POST_REVISIONS', false );
define( 'EMPTY_TRASH_DAYS', 2 );
define( 'AUTOSAVE_INTERVAL', 90 );
define( 'DISABLE_WP_CRON', true );
PHP
```

### Zusätzliche Konfigurationen der `wp-config.php`

```bash
define( 'WP_POST_REVISIONS', false );
define( 'EMPTY_TRASH_DAYS', 2 );
define( 'AUTOSAVE_INTERVAL', 90 );
define( 'DISABLE_WP_CRON', true );
define( 'IMAGE_EDIT_OVERWRITE', true );
```

`wp config set WP_POST_REVISIONS false --raw`

`wp config set DISABLE_WP_CRON true --raw`


`wp core config --extra-php <<PHP define( 'UPLOADS', 'https://$domain/assets/img' ); PHP`

```bash
wp core config --extra-php <<PHP define( 'FS_CHMOD_DIR', ( 0755 & ~ umask() ) ); PHP
wp core config --extra-php <<PHP define( 'FS_CHMOD_FILE', ( 0644 & ~ umask() ) ); PHP
```

```bash
wp core config --extra-php <<PHP define( 'WP_MEMORY_LIMIT', '256M' ); PHP
wp core config --extra-php <<PHP define( 'WP_MAX_MEMORY_LIMIT', '512M' ); PHP
```

`wp core config --extra-php <<PHP define( 'WP_CACHE', true ); PHP`

```bash
wp core config --extra-php <<PHP define( 'WP_HTTP_BLOCK_EXTERNAL', true ); PHP
wp core config --extra-php <<PHP define( 'WP_ACCESSIBLE_HOSTS', 'api.wordpress.org,*.github.com' ); PHP
```

### WP Debug

`wp config set WP_DEBUG true --raw`

```bash
wp core config --extra-php <<PHP define( 'WP_DEBUG', true ); PHP
wp core config --extra-php <<PHP define( 'SCRIPT_DEBUG', true ); PHP
wp core config --extra-php <<PHP define( 'WP_DEBUG_LOG', false ); PHP
wp core config --extra-php <<PHP define( 'WP_DEBUG_DISPLAY', true ); PHP
```

## WordPress Update

```bash
wp cli update
wp core update
wp theme update --all
wp plugin update --all
wp db update
```

## WordPress Einstellungen

### URL Struktur

`wp rewrite structure --category_base '/kat/' --tag-base '/tag/' '/%post_id%/%postname%'`

### WordPress Language

Installierte Sprachen auflisten.

```bash
wp language core list --status=installed
```

**WordPress Language installieren und aktivieren**

```bash
wp language core install de_DE
wp language core install de_DE de_CH
wp language core activate de_DE
```

**WordPress Language deinstallieren**

```bash
wp language core uninstall de_DE
```
## WordPress Post

**Create a new post.**

`wp post create --post_type=post --post_title='A sample post'`

**Update an existing post.**

`wp post update 123 --post_status=draft`

**Delete an existing post.**

`wp post delete 123`


## WordPress Themes

`wp theme list`

`wp theme status`

`wp theme update twentyseventeen`

`wp theme update --all`

### WordPress Theme installieren und aktivieren

`wp theme install <theme|zip|url>... [--version=<version>] [--force] [--activate] [--activate-network]`

**WordPress Theme aktivieren**

Nur mit einem Theme möglich. 

`wp theme activate twentyseventeen`

**WordPress Theme installieren**

Mit mehreren Themes möglich. 

```bash
wp theme install hueman
wp theme install https://example.org/themes/my-super-commercial-theme.zip 
```

**WordPress Theme installieren und aktivieren**

Nur mit einem Theme möglich. 

```bash
wp theme install --activate hueman
wp theme install https://example.org/themes/my-super-commercial-theme.zip --activate my-super-commercial-theme
```

### WordPress Theme deinstallieren

Mit mehreren Themes möglich. 

```bash
wp theme uninstall twentyseventeen
wp theme uninstall twentyfifteen twentysixteen
```
### WordPress Child Theme

```bash
wp scaffold child-theme hueman-pagespeed-plus --parent_theme=hueman
```

## WordPress Plugins

`wp plugin list`

`wp plugin status`

`wp plugin update fb-instant-articles`

`wp plugin update --all`

### WordPress Plugin installieren und aktivieren

Alle Varianten können mit mehreren Plugins gleichzeitig durchgeführt werden. 

`wp plugin install <plugin|zip|url>... [--version=<version>] [--force] [--activate] [--activate-network]`

**WordPress Plugin aktivieren**

```bash
wp plugin activate nginx-helper
wp plugin activate nginx-helper w3-total-cache
```

**WordPress Plugin installieren**

```bash
wp plugin install https://example.org/plugins/my-super-commercial-plugin.zip
wp plugin install w3-total-cache https://example.org/plugins/my-super-commercial-plugin.zip
```

**WordPress Plugin installieren und aktivieren**

```bash
wp plugin install https://github.com/afragen/github-updater/archive/develop.zip --activate github-updater
wp plugin install --activate w3-total-cache nginx-helper
```

### WordPress Plugin deinstallieren und deaktivieren

Alle Varianten können mit mehreren Plugins gleichzeitig durchgeführt werden. 

**WordPress Plugin deaktivieren**

```bash
wp plugin deactivate w3-total-cache
wp plugin deactivate w3-total-cache nginx-helper
```

**WordPress Plugin deinstallieren**

```bash
wp plugin uninstall w3-total-cache
wp plugin uninstall w3-total-cache nginx-helper
```

**WordPress Plugin deinstallieren und deaktivieren**

```bash
wp plugin uninstall --deactivate w3-total-cache
wp plugin uninstall --deactivate w3-total-cache nginx-helper
```

### Regenerate Thumbnails

`wp media regenerate --yes`

### Serach & Replace

**Search and replace but skip one column**

`wp search-replace 'http://example.dev' 'http://example.com' --skip-columns=guid`

**Run search/replace operation but dont save in database**

`wp search-replace 'foo' 'bar' wp_posts wp_postmeta wp_terms --dry-run`

**Run case-insensitive regex search/replace operation (slow)**

`wp search-replace '\[foo id="([0-9]+)"' '[bar id="\1"' --regex --regex-flags='i'`

**Turn your production multisite database into a local dev database**

`wp search-replace --url=example.com example.com example.dev 'wp_*options' wp_blogs`

**Search/replace to a SQL file without transforming the database**

```bash
wp search-replace foo bar --export=database.sql
```

**Bash script: Search/replace production to development url (multisite compatible)**

```bash
#!/bin/bash
if $(wp --url=http://example.com core is-installed --network); then
    wp search-replace --url=http://example.com 'http://example.com' 'http://example.dev' --recurse-objects --network --skip-columns=guid --skip-tables=wp_users
else
    wp search-replace 'http://example.com' 'http://example.dev' --recurse-objects --skip-columns=guid --skip-tables=wp_users
fi
```
## Von bestehenden Posts Kommentare und Pingbacks deaktivieren
wp post list --format=ids | xargs wp post update --comment_status=closed
wp post list --format=ids | xargs wp post update --ping_status=closed

## WordPress Datenbank

`wp db export --path=/var/www/speedword.press/htdocs/ /var/www/speedword.press/export.sql `

`wp db import /tmp/import.sql`

`sudo wp db export --path=/var/www/speedword.press/htdocs/ /var/www/speedword.press/export.sql --allow-root`

`wp db cli --path=/var/www/speedword.press/htdocs/`

---

## WordPress Multisite

User zu Netzwerkadmin machen

`wp super-admin add username`

---

## Kommandos einzelner WordPress Plugins



### ElasticPress

* [GitHub](https://github.com/10up/ElasticPress)

The following commands are supported by ElasticPress:

* `wp elasticpress index [--setup] [--network-wide] [--posts-per-page] [--nobulk] [--offset] [--show-bulk-errors] [--post-type]`

    Index all posts in the current blog.

    * `--network-wide` will force indexing on all the blogs in the network. `--network-wide` takes an optional argument to limit the number of blogs to be indexed across where 0 is no limit. For example, `--network-wide=5` would limit indexing to only 5 blogs on the network.
    * `--setup` will clear the index first and re-send the put mapping.
    * `--posts-per-page` let's you determine the amount of posts to be indexed per bulk index (or cycle).
    * `--nobulk` let's you disable bulk indexing.
    * `--offset` let's you skip the first n posts (don't forget to remove the `--setup` flag when resuming or the index will be emptied before starting again).
    * `--show-bulk-errors` displays the error message returned from Elasticsearch when a post fails to index (as opposed to just the title and ID of the post).
    * `--post-type` let's you specify which post types will be indexed (by default: all indexable post types are indexed). For example, `--post-type="my_custom_post_type"` would limit indexing to only posts from the post type "my_custom_post_type". Accepts multiple post types separated by comma.

* `wp elasticpress delete-index [--network-wide]`

  Deletes the current blog index. `--network-wide` will force every index on the network to be deleted.

* `wp elasticpress put-mapping [--network-wide]`

  Sends plugin put mapping to the current blog index. `--network-wide` will force mappings to be sent for every index in the network.

* `wp elasticpress recreate-network-alias`

  Recreates the alias index which points to every index in the network.

* `wp elasticpress activate-feature <feature-slug> [--network-wide]`

  Activate a feature. If a re-indexing is required, you will need to do it manually. `--network-wide` will affect network activated ElasticPress.

* `wp elasticpress deactivate-feature <feature-slug> [--network-wide]`

  Deactivate a feature. `--network-wide` will affect network activated ElasticPress.

* `wp elasticpress list-features [--all] [--network-wide]`

  Lists active features. `--all` will show all registered features. `--network-wide` will force checking network options as opposed to a single sites options.

* `wp elasticpress stats`

  Returns basic stats on Elasticsearch instance i.e. number of documents in current index as well as disk space used.

* `wp elasticpress status`

### Google XML Sitemaps

Here’s a patch that implements a wp-cli command, with which you can rebuild the sitemap from the command line.

* https://wordpress.org/support/topic/patch-for-wp-cli-command-2/
* https://github.com/wp-cli/google-sitemap-generator-cli

#### Beispiel

```bash
# XML Sitemap neu generieren
wp google-sitemap rebuild
```
