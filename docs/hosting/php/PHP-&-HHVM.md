## Gefährliche PHP Funktionen deaktivieren

You can use the disable_functions = directive to disable potentially dangerous PHP functions
such as `exec, passthru, popen, ini_set, system,` but only in `/etc/php5/apache2/php.ini` and `/etc/php5/cgi/php.ini`
 
e.g. as follows:

- `echo "disable_functions = exec,passthru,popen,ini_set,system,show_source,shell_exec,proc_open,phpinfo" >> /etc/php5/cgi/php.ini`


## Optimale PHP-Einstellungen vornehmen

Wenn Sie eine Website in ISPConfig anlegen oder bearbeiten, haben Sie auf dem Optionen-Reiter die Möglichkeit, die PHP-Einstellungen anzupassen. Um möglichst wenig Ressourcen (wie z.B. Arbeitsspeicher) zu belegen und die Bearbeitung von PHP-Anfragen zu beschleunigen, empfehlen wir die folgenden Einstellungen:

Machen Sie einen Haken in das Feld Benutze Socket für PHP-FPM. Sockets sind schneller als TCP-Verbindungen.
PHP-FPM FastCGI Prozess Manager: Wählen Sie ondemand aus (damit wird ein PHP-Prozeß nur bei Bedarf gestartet und belegt in der restlichen Zeit keinen Arbeitsspeicher).

## PHP Erweiterungen

cURL
libxml
SimpleXML
xmlreader
xmlwriter
ZipArchive

## PHP.ini Konfiguration

* PHP-FPM pm.max_children: 500
* PHP-FPM pm.process_idle_timeout: 5s
* PHP-FPM pm.max_requests: 0
***
* PHP Memory Limit: 256M
* PHP Upload Max Size: 2M
* PHP Post Max Size: 8M
* PHP Upload Max Filesize:2M
* PHP Time Limit: 30
* PHP Max Input Vars: 1000
* PHP Arg Separator: &
* PHP Allow URL File Open: Yes

### Maximum Input Variables (PHP): 

Dies wird in der php.ini mit max_input_vars festgelegt. Er bestimmt die maximale Anzahl von Eingabevariablen, die PHP zulässt. Nach unseren Erfahrungen reichen 6000 aus, aber Sie sollten diese Grenze erhöhen, wenn Sie eine große Menge an Produktattributen importieren.

### Maximum Upload File Size (PHP): 

Dies wird in php.ini mit upload_max_filesize festgelegt. Er bestimmt die maximale Dateigröße, die Ihr Server hochladen darf. Dieser Wert muss größer als die Größe der Datei sein, die Sie in WP All Import hochladen möchten.

### Maximum Post Size (PHP): 

Dies wird in php.ini mit post_max_size eingestellt. Es bestimmt die maximale Dateigröße, die im PHP-Prozess verwendet werden darf. Dies sollte höher als upload_max_filesize gesetzt werden.

### Memory Limit (PHP): 

Dies wird in php.ini mit memory_limit gesetzt. Es bestimmt, wie viel Speicher ein Skript zuweisen kann. Dies sollte höher als post_max_size gesetzt werden.

### Maximum Execution Time (PHP): 

Dies wird in der php.ini mit max_execution_time eingestellt. Es bestimmt, wie lange ein Prozess ausgeführt werden darf, bevor er beendet wird. Sie können Ihren Gastgeber bitten, das Limit zu erhöhen, aber zuerst sollten Sie die Einstellung "Datensätze pro Iteration" in WP All Import verringern.
