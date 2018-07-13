### wp config

Generates and reads the wp-config.php file.

~~~
wp config
~~~

#### _Inhaltsverzeichnis_

  * [wp config edit](#)
  * [wp config delete](#)
  * [wp config create](#)
  * [wp config get](#)
  * [wp config has](#)
  * [wp config list](#)
  * [wp config path](#)
  * [wp config set](#)


#### wp config edit

Launches system editor to edit the wp-config.php file.

~~~
wp config edit 
~~~

**EXAMPLES**

    # Launch system editor to edit wp-config.php file
    $ wp config edit

    # Edit wp-config.php file in a specific editor
    $ EDITOR=vim wp config edit



#### wp config delete

Deletes a specific constant or variable from the wp-config.php file.

~~~
wp config delete <name> [--type=<type>]
~~~

**OPTIONS**

	<name>
		Name of the wp-config.php constant or variable.

	[--type=<type>]
		Type of the config value to delete. Defaults to 'all'.
		---
		default: all
		options:
		  - constant
		  - variable
		  - all
		---

**EXAMPLES**

    # Delete the COOKIE_DOMAIN constant from the wp-config.php file.
    $ wp config delete COOKIE_DOMAIN



#### wp config create

Generates a wp-config.php file.

~~~
wp config create --dbname=<dbname> --dbuser=<dbuser> [--dbpass=<dbpass>] [--dbhost=<dbhost>] [--dbprefix=<dbprefix>] [--dbcharset=<dbcharset>] [--dbcollate=<dbcollate>] [--locale=<locale>] [--extra-php] [--skip-salts] [--skip-check] [--force]
~~~

Creates a new wp-config.php with database constants, and verifies that
the database constants are correct.

**OPTIONS**

	--dbname=<dbname>
		Set the database name.

	--dbuser=<dbuser>
		Set the database user.

	[--dbpass=<dbpass>]
		Set the database user password.

	[--dbhost=<dbhost>]
		Set the database host.
		---
		default: localhost
		---

	[--dbprefix=<dbprefix>]
		Set the database table prefix.
		---
		default: wp_
		---

	[--dbcharset=<dbcharset>]
		Set the database charset.
		---
		default: utf8
		---

	[--dbcollate=<dbcollate>]
		Set the database collation.
		---
		default:
		---

	[--locale=<locale>]
		Set the WPLANG constant. Defaults to $wp_local_package variable.

	[--extra-php]
		If set, the command copies additional PHP code into wp-config.php from STDIN.

	[--skip-salts]
		If set, keys and salts won't be generated, but should instead be passed via `--extra-php`.

	[--skip-check]
		If set, the database connection is not checked.

	[--force]
		Overwrites existing files, if present.

**EXAMPLES**

    # Standard wp-config.php file
    $ wp config create --dbname=testing --dbuser=wp --dbpass=securepswd --locale=ro_RO
    Success: Generated 'wp-config.php' file.

    # Enable WP_DEBUG and WP_DEBUG_LOG
    $ wp config create --dbname=testing --dbuser=wp --dbpass=securepswd --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', true );
    PHP
    Success: Generated 'wp-config.php' file.

    # Avoid disclosing password to bash history by reading from password.txt
    # Using --prompt=dbpass will prompt for the 'dbpass' argument
    $ wp config create --dbname=testing --dbuser=wp --prompt=dbpass < password.txt
    Success: Generated 'wp-config.php' file.



#### wp config get

Gets the value of a specific constant or variable defined in wp-config.php file.

~~~
wp config get <name> [--type=<type>]
~~~

**OPTIONS**

	<name>
		Name of the wp-config.php constant or variable.

	[--type=<type>]
		Type of config value to retrieve. Defaults to 'all'.
		---
		default: all
		options:
		  - constant
		  - variable
		  - all
		---

**EXAMPLES**

    # Get the table_prefix as defined in wp-config.php file.
    $ wp config get table_prefix
    wp_



#### wp config has

Checks whether a specific constant or variable exists in the wp-config.php file.

~~~
wp config has <name> [--type=<type>]
~~~

**OPTIONS**

	<name>
		Name of the wp-config.php constant or variable.

	[--type=<type>]
		Type of the config value to set. Defaults to 'all'.
		---
		default: all
		options:
		  - constant
		  - variable
		  - all
		---

**EXAMPLES**

    # Check whether the DB_PASSWORD constant exists in the wp-config.php file.
    $ wp config has DB_PASSWORD



#### wp config list

Lists variables, constants, and file includes defined in wp-config.php file.

~~~
wp config list [<filter>...] [--fields=<fields>] [--format=<format>] [--strict]
~~~

**OPTIONS**

	[<filter>...]
		Name or partial name to filter the list by.

	[--fields=<fields>]
		Limit the output to specific fields. Defaults to all fields.

	[--format=<format>]
		Render output in a particular format.
		---
		default: table
		options:
		  - table
		  - csv
		  - json
		  - yaml
		---

	[--strict]
		Enforce strict matching when a filter is provided.

**EXAMPLES**

    # List constants and variables defined in wp-config.php file.
    $ wp config list
    +------------------+------------------------------------------------------------------+----------+
    | key              | value                                                            | type     |
    +------------------+------------------------------------------------------------------+----------+
    | table_prefix     | wp_                                                              | variable |
    | DB_NAME          | wp_cli_test                                                      | constant |
    | DB_USER          | root                                                             | constant |
    | DB_PASSWORD      | root                                                             | constant |
    | AUTH_KEY         | r6+@shP1yO&$)1gdu.hl[/j;7Zrvmt~o;#WxSsa0mlQOi24j2cR,7i+QM/#7S:o^ | constant |
    | SECURE_AUTH_KEY  | iO-z!_m--YH$Tx2tf/&V,YW*13Z_HiRLqi)d?$o-tMdY+82pK$`T.NYW~iTLW;xp | constant |
    +------------------+------------------------------------------------------------------+----------+

    # List only database user and password from wp-config.php file.
    $ wp config list DB_USER DB_PASSWORD --strict
    +------------------+-------+----------+
    | key              | value | type     |
    +------------------+-------+----------+
    | DB_USER          | root  | constant |
    | DB_PASSWORD      | root  | constant |
    +------------------+-------+----------+

    # List all salts from wp-config.php file.
    $ wp config list _SALT
    +------------------+------------------------------------------------------------------+----------+
    | key              | value                                                            | type     |
    +------------------+------------------------------------------------------------------+----------+
    | AUTH_SALT        | n:]Xditk+_7>Qi=>BmtZHiH-6/Ecrvl(V5ceeGP:{>?;BT^=[B3-0>,~F5z$(+Q$ | constant |
    | SECURE_AUTH_SALT | ?Z/p|XhDw3w}?c.z%|+BAr|(Iv*H%%U+Du&kKR y?cJOYyRVRBeB[2zF-`(>+LCC | constant |
    | LOGGED_IN_SALT   | +$@(1{b~Z~s}Cs>8Y]6[m6~TnoCDpE>O%e75u}&6kUH!>q:7uM4lxbB6[1pa_X,q | constant |
    | NONCE_SALT       | _x+F li|QL?0OSQns1_JZ{|Ix3Jleox-71km/gifnyz8kmo=w-;@AE8W,(fP<N}2 | constant |
    +------------------+------------------------------------------------------------------+----------+



#### wp config path

Gets the path to wp-config.php file.

~~~
wp config path 
~~~

**EXAMPLES**

    # Get wp-config.php file path
    $ wp config path
    /home/person/htdocs/project/wp-config.php



#### wp config set

Sets the value of a specific constant or variable defined in wp-config.php file.

~~~
wp config set <name> <value> [--add] [--raw] [--anchor=<anchor>] [--placement=<placement>] [--separator=<separator>] [--type=<type>]
~~~

**OPTIONS**

	<name>
		Name of the wp-config.php constant or variable.

	<value>
		Value to set the wp-config.php constant or variable to.

	[--add]
		Add the value if it doesn't exist yet.
		This is the default behavior, override with --no-add.

	[--raw]
		Place the value into the wp-config.php file as is, instead of as a quoted string.

	[--anchor=<anchor>]
		Anchor string where additions of new values are anchored around.
		Defaults to "/* That's all, stop editing!".

	[--placement=<placement>]
		Where to place the new values in relation to the anchor string.
		---
		default: 'before'
		options:
		  - before
		  - after
		---

	[--separator=<separator>]
		Separator string to put between an added value and its anchor string.
		The following escape sequences will be recognized and properly interpreted: '\n' => newline, '\r' => carriage return, '\t' => tab.
		Defaults to a single EOL ("\n" on *nix and "\r\n" on Windows).

	[--type=<type>]
		Type of the config value to set. Defaults to 'all'.
		---
		default: all
		options:
		  - constant
		  - variable
		  - all
		---

**EXAMPLES**

    # Set the WP_DEBUG constant to true.
    $ wp config set WP_DEBUG true --raw
