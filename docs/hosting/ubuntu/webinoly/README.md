# Webinoly ![CI status](https://img.shields.io/badge/build-passing-brightgreen.svg)

Optimized LEMP Web Server.

Linux Ubuntu + Nginx + MySQL (MariaDB) + PHP is one of the most reliable and powerful configurations to host your websites.

With Webinoly you can set up your web server in just one step.

Webinoly provides a set of tools and commands that facilitate the web server administration.
- Unique commands to create, delete, disable sites.
- Free SSL certificates for your sites with Let’s Encrypt and automatic server configuration.
- HTTP/2 dramatically increase the speed of serving your content.
- PHP v7.2 and support for previous versions if necessary (5.6, 7.0 and 7.1).
- FastCgi Cache and Redis Object Cache for your WordPress sites.
- Get an A+ grade on [Qualys (SSL Labs) Test](https://www.ssllabs.com/ssltest/).
- Log viewer in real time.

### Requirements
* Ubuntu 16.04 or 18.04

## Usage

```bash
# Install Webinoly and LEMP
wget -qO weby qrok.es/wy && sudo bash weby 3

# Create your first site.
sudo site example.com -wp
```

## Documentation
For complete documentation, please [visit our site](https://webinoly.com/en/).

## Webinoly GitHub Repos

### [Webinoly](https://github.com/QROkes/webinoly) 

- https://github.com/QROkes/webinoly

### [VirtuBox](https://github.com/VirtuBox)

- https://github.com/VirtuBox/debian-ubuntu-mariadb-backup
- https://github.com/VirtuBox/wp-optimize
