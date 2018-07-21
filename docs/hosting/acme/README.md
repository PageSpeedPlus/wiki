# acme.sh

**[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)**

- [GitHub](https://github.com/Neilpang/acme.sh) 

## Installation

```bash
wget -O -  https://get.acme.sh | sh
source ~/.bashrc 
```

```bash
root@ee:~# acme.sh --list
Main_Domain  KeyLength  SAN_Domains   Created                       Renew
wpnginx.tk   "ec-384"   *.wpnginx.tk  Tue May 29 09:46:46 UTC 2018  Sat Jul 28 09:46:46 UTC 2018
```

## Kommandos

Usage: `acme.sh  command ...[parameters]....`

```bash
Commands:
  --help, -h               Show this help message.
  --version, -v            Show version info.
  --install                Install acme.sh to your system.
  --uninstall              Uninstall acme.sh, and uninstall the cron job.
  --upgrade                Upgrade acme.sh to the latest code from https://github.com/Neilpang/acme.sh.
  --issue                  Issue a cert.
  --signcsr                Issue a cert from an existing csr.
  --deploy                 Deploy the cert to your server.
  --install-cert           Install the issued cert to apache/nginx or any other server.
  --renew, -r              Renew a cert.
  --renew-all              Renew all the certs.
  --revoke                 Revoke a cert.
  --remove                 Remove the cert from list of certs known to acme.sh.
  --list                   List all the certs.
  --showcsr                Show the content of a csr.
  --install-cronjob        Install the cron job to renew certs, you don't need to call this. The 'install' command can automatically install the cron job.
  --uninstall-cronjob      Uninstall the cron job. The 'uninstall' command can do this automatically.
  --cron                   Run cron job to renew all the certs.
  --toPkcs                 Export the certificate and key to a pfx file.
  --toPkcs8                Convert to pkcs8 format.
  --update-account         Update account info.
  --register-account       Register account key.
  --deactivate-account     Deactivate the account.
  --create-account-key     Create an account private key, professional use.
  --create-domain-key      Create an domain private key, professional use.
  --createCSR, -ccsr       Create CSR , professional use.
  --deactivate             Deactivate the domain authz, professional use.

Parameters:
  --domain, -d   domain.tld         Specifies a domain, used to issue, renew or revoke etc.
  --challenge-alias domain.tld      The challenge domain alias for DNS alias mode: https://github.com/Neilpang/acme.sh/wiki/DNS-alias-mode
  --domain-alias domain.tld         The domain alias for DNS alias mode: https://github.com/Neilpang/acme.sh/wiki/DNS-alias-mode
  --force, -f                       Used to force to install or force to renew a cert immediately.
  --staging, --test                 Use staging server, just for test.
  --debug                           Output debug info.
  --output-insecure                 Output all the sensitive messages. By default all the credentials/sensitive messages are hidden from the output/debug/log for secure.
  --webroot, -w  /path/to/webroot   Specifies the web root folder for web root mode.
  --standalone                      Use standalone mode.
  --stateless                       Use stateless mode, see: https://github.com/Neilpang/acme.sh/wiki/Stateless-Mode
  --apache                          Use apache mode.
  --dns [dns_cf|dns_dp|dns_cx|/path/to/api/file]   Use dns mode or dns api.
  --dnssleep  [120]                  The time in seconds to wait for all the txt records to take effect in dns api mode. Default 120 seconds.

  --keylength, -k [2048]            Specifies the domain key length: 2048, 3072, 4096, 8192 or ec-256, ec-384.
  --accountkeylength, -ak [2048]    Specifies the account key length.
  --log    [/path/to/logfile]       Specifies the log file. The default is: "/home/ee/.acme.sh/acme.sh.log" if you don't give a file path here.
  --log-level 1|2                   Specifies the log level, default is 1.
  --syslog [0|3|6|7]                Syslog level, 0: disable syslog, 3: error, 6: info, 7: debug.

  These parameters are to install the cert to nginx/apache or anyother server after issue/renew a cert:

  --cert-file                       After issue/renew, the cert will be copied to this path.
  --key-file                        After issue/renew, the key will be copied to this path.
  --ca-file                         After issue/renew, the intermediate cert will be copied to this path.
  --fullchain-file                  After issue/renew, the fullchain cert will be copied to this path.

  --reloadcmd "service nginx reload" After issue/renew, it's used to reload the server.

  --server SERVER                   ACME Directory Resource URI. (default: https://acme-v01.api.letsencrypt.org/directory)
  --accountconf                     Specifies a customized account config file.
  --home                            Specifies the home dir for acme.sh .
  --cert-home                       Specifies the home dir to save all the certs, only valid for '--install' command.
  --config-home                     Specifies the home dir to save all the configurations.
  --useragent                       Specifies the user agent string. it will be saved for future use too.
  --accountemail                    Specifies the account email, only valid for the '--install' and '--update-account' command.
  --accountkey                      Specifies the account key path, only valid for the '--install' command.
  --days                            Specifies the days to renew the cert when using '--issue' command. The max value is 60 days.
  --httpport                        Specifies the standalone listening port. Only valid if the server is behind a reverse proxy or load balancer.
  --local-address                   Specifies the standalone/tls server listening address, in case you have multiple ip addresses.
  --listraw                         Only used for '--list' command, list the certs in raw format.
  --stopRenewOnError, -se           Only valid for '--renew-all' command. Stop if one cert has error in renewal.
  --insecure                        Do not check the server certificate, in some devices, the api server's certificate may not be trusted.
  --ca-bundle                       Specifies the path to the CA certificate bundle to verify api server's certificate.
  --ca-path                         Specifies directory containing CA certificates in PEM format, used by wget or curl.
  --nocron                          Only valid for '--install' command, which means: do not install the default cron job. In this case, the certs will not be renewed automatically.
  --no-color                        Do not output color text.
  --force-color                     Force output of color text. Useful for non-interactive use with the aha tool for HTML E-Mails.
  --ecc                             Specifies to use the ECC cert. Valid for '--install-cert', '--renew', '--revoke', '--toPkcs' and '--createCSR'
  --csr                             Specifies the input csr.
  --pre-hook                        Command to be run before obtaining any certificates.
  --post-hook                       Command to be run after attempting to obtain/renew certificates. No matter the obtain/renew is success or failed.
  --renew-hook                      Command to be run once for each successfully renewed certificate.
  --deploy-hook                     The hook file to deploy cert
  --ocsp-must-staple, --ocsp        Generate ocsp must Staple extension.
  --always-force-new-domain-key     Generate new domain key when renewal. Otherwise, the domain key is not changed by default.
  --auto-upgrade   [0|1]            Valid for '--upgrade' command, indicating whether to upgrade automatically in future.
  --listen-v4                       Force standalone/tls server to listen at ipv4.
  --listen-v6                       Force standalone/tls server to listen at ipv6.
  --openssl-bin                     Specifies a custom openssl bin location.
  --use-wget                        Force to use wget, if you have both curl and wget installed.
  --yes-I-know-dns-manual-mode-enough-go-ahead-please  Force to use dns manual mode: https://github.com/Neilpang/acme.sh/wiki/dns-manual-mode
  --branch, -b                      Only valid for '--upgrade' command, specifies the branch name to upgrade to.
  ```
