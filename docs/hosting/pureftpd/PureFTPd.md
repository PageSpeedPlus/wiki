## How to enable verbose logging in pure-ftpd on Debian Linux

To turn on verbose logging (e.g. to debug FTP connection or authentication problems) in  pure-ftpd FTP server on Debian and Ubuntu Linux, execute the following command as root user in the shell:

> echo 'yes' > /etc/pure-ftpd/conf/VerboseLog

and then restart pure-ftpd, for init based systems:

> /etc/init.d/pure-ftpd-mysql restart

For Servers that use systemd:

> service pure-ftpd-mysql restart

The debug output will be logged to Syslog. To view the log content, execute:

> tail -n 100 /var/log/syslog

To disable verbose logging, execute these commands:

> rm -f /etc/pure-ftpd/conf/VerboseLog
> /etc/init.d/pure-ftpd-mysql restart

https://www.faqforge.com/linux/controlpanels/ispconfig3/how-to-enable-debugging-in-pure-ftpd-on-debian-linux/
***
## How to set the PassivePortRange in pure-ftpd on Debian and Ubuntu Linux

If you run a firewall on your Linux server and want to use passive FTP connections, you have to define the passive port range in pure-ftpd and your firewall to ensure that the connections dont get blocked. The following example is for pure-ftpd on Debian or Ubuntu Linux and ISPConfig 3:

### Configure pure-ftpd

> echo "40110 40210" > /etc/pure-ftpd/conf/PassivePortRange
> /etc/init.d/pure-ftpd-mysql restart

### Configure the firewall. 

If you use ISPConfig 3 on my server to configure the bastille firewall, you can add the nescessera port range in the ISPConfig firewall settings.

Change the list of Open TCP ports from:

> 20,21,22,25,53,80,110,143,443,3306,8080,10000

to:

> 20,21,22,25,53,80,110,143,443,3306,8080,10000,40110:40210

and then click on "Save".

***
