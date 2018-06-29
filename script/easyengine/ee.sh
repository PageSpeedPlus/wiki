#!/bin/bash

# EasyEngine update script.
# This script is designed to install latest EasyEngine or
# to update current EasyEngine from 2.x to 3.x

# Define echo function
# Blue color
function ee_lib_echo()
{
    echo $(tput setaf 4)$@$(tput sgr0)
}
# White color
function ee_lib_echo_info()
{
    echo $(tput setaf 7)$@$(tput sgr0)
}
# Red color
function ee_lib_echo_fail()
{
    echo $(tput setaf 1)$@$(tput sgr0)
}

# Checking permissions
if [[ $EUID -ne 0 ]]; then
    ee_lib_echo_fail "Sudo privilege required..."
    ee_lib_echo_fail "Uses: wget -qO ee rt.cx/ee && sudo bash ee"
    exit 100
fi

# Capture errors
function ee_lib_error()
{
    echo "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
    exit $2
}

# Execute: apt-get update
ee_lib_echo "Executing apt-get update, please wait..."
apt-get update &>> /dev/null

# Checking lsb_release package
if [ ! -x /usr/bin/lsb_release ]; then
    ee_lib_echo "Installing lsb-release, please wait..."
    apt-get -y install lsb-release &>> /dev/null
fi

# Define variables for later use
ee_branch=$1
readonly ee_version_old="2.2.3"
readonly ee_version_new="3.8.1"
readonly ee_log_dir=/var/log/ee/
readonly ee_install_log=/var/log/ee/install.log
readonly ee_linux_distro=$(lsb_release -i | awk '{print $3}')
readonly ee_distro_version=$(lsb_release -sc)

# Checking linux distro
if [ "$ee_linux_distro" != "Ubuntu" ] && [ "$ee_linux_distro" != "Debian" ]; then
    ee_lib_echo_fail "EasyEngine (ee) is made for Ubuntu and Debian only as of now"
    ee_lib_echo_fail "You are free to fork EasyEngine (ee): https://github.com/EasyEngine/easyengine/fork"
    ee_lib_echo_fail "EasyEngine (ee) only support Ubuntu 14.04/16.04/18.04 and Debian 8.x"
    exit 100
fi

# EasyEngine (ee) only support all Ubuntu/Debian distro except the distro reached EOL
lsb_release -d | egrep -e "14.04|16.04|18.04|jessie" &>> /dev/null
if [ "$?" -ne "0" ]; then
    ee_lib_echo_fail "EasyEngine (ee) only support Ubuntu 14.04/16.04/18.04 LTS and Debian 8.x"
    exit 100
fi

# Pre checks to avoid later screw ups
# Checking EasyEngine (ee) log directory
if [ ! -d $ee_log_dir ]; then

    ee_lib_echo "Creating EasyEngine log directory, please wait..."
    mkdir -p $ee_log_dir || ee_lib_error "Unable to create log directory $ee_log_dir, exit status " $?

    # Create EasyEngine log files
    touch /var/log/ee/{ee.log,install.log}

    # Keep EasyEngine log folder accessible to root only
    chmod -R 700 /var/log/ee || ee_lib_error "Unable to change permissions for EasyEngine log folder, exit status " $?
fi

# Install Python3, Git, Tar and python-software-properties required packages
# Generate Locale
function ee_install_dep()
{
    if [ "$ee_linux_distro" == "Ubuntu" ]; then
        apt-get -y install build-essential curl gzip python3 python3-apt python3-setuptools python3-dev sqlite3 git tar software-properties-common || ee_lib_error "Unable to install pre depedencies, exit status " 1
    elif [ "$ee_linux_distro" == "Debian" ]; then
        apt-get -y install build-essential curl gzip dirmngr python3 python3-apt python3-setuptools python3-dev sqlite3 git tar python-software-properties || ee_lib_error "Unable to pre depedencies, exit status " 1
    fi

    # Generating Locale
    locale-gen en &>> /dev/null
}

# Sqlite query to create table `sites` into ee.db
# which will be used by EasyEngine 3.x
function ee_sync_db()
{
    if [ ! -f /var/lib/ee/ee.db ]; then
        mkdir -p /var/lib/ee

        echo "CREATE TABLE sites (
           id INTEGER PRIMARY KEY     AUTOINCREMENT,
           sitename UNIQUE,
           site_type CHAR,
           cache_type CHAR,
           site_path  CHAR,
           created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
           is_enabled INT,
           is_ssl INT,
           storage_fs CHAR,
           storage_db CHAR,
           db_name VARCHAR,
           db_user VARCHAR,
           db_password VARCHAR,
           db_host VARCHAR,
           is_hhvm INT INT DEFAULT '0',
           is_pagespeed INT INT DEFAULT '0',
           php_version VARCHAR
        );" | sqlite3 /var/lib/ee/ee.db

        # Check site is enable/live or disable
        for site in $(ls /etc/nginx/sites-available/ | grep -v default);
        do
        if [ -f /etc/nginx/sites-enabled/$site ]; then
            ee_site_status='1'
        else
            ee_site_status='0'
        fi

        # Find out information about current NGINX configuration
        ee_site_current_type=$(head -n1 /etc/nginx/sites-available/$site | grep "NGINX CONFIGURATION" | rev | cut -d' ' -f3,4,5,6,7 | rev | cut -d ' ' -f2,3,4,5)

        # Detect current website type and cache
        if [ "$ee_site_current_type" = "HTML" ]; then
            ee_site_current="html"
            ee_site_current_cache="basic"
        elif [ "$ee_site_current_type" = "PHP" ]; then
            ee_site_current="php"
            ee_site_current_cache="basic"
        elif [ "$ee_site_current_type" = "MYSQL" ]; then
            ee_site_current="mysql"
            ee_site_current_cache="basic"
        # Single WordPress
        elif [ "$ee_site_current_type" = "WPSINGLE BASIC" ]; then
            ee_site_current="wp"
            ee_site_current_cache="basic"

        elif [ "$ee_site_current_type" = "WPSINGLE WP SUPER CACHE" ]; then
            ee_site_current="wp"
            ee_site_current_cache="wpsc"

        elif [ "$ee_site_current_type" = "WPSINGLE W3 TOTAL CACHE" ]; then
            ee_site_current="wp"
            ee_site_current_cache="w3tc"

        elif [ "$ee_site_current_type" = "WPSINGLE FAST CGI" ] || [ "$ee_site_current_type" = "WPSINGLE FASTCGI" ]; then
            ee_site_current="wp"
            ee_site_current_cache="wpfc"

        # WordPress subdirectory
        elif [ "$ee_site_current_type" = "WPSUBDIR BASIC" ]; then
            ee_site_current="wpsubdir"
            ee_site_current_cache="basic"

        elif [ "$ee_site_current_type" = "WPSUBDIR WP SUPER CACHE" ]; then
            ee_site_current="wpsubdir"
            ee_site_current_cache="wpsc"

        elif [ "$ee_site_current_type" = "WPSUBDIR W3 TOTAL CACHE" ]; then
            ee_site_current="wpsubdir"
            ee_site_current_cache="w3tc"

        elif [ "$ee_site_current_type" = "WPSUBDIR FAST CGI" ] || [ "$ee_site_current_type" = "WPSUBDIR FASTCGI" ]; then
            ee_site_current="wpsubdir"
            ee_site_current_cache="wpfc"

        # WordPress subdomain
        elif [ "$ee_site_current_type" = "WPSUBDOMAIN BASIC" ]; then
            ee_site_current="wpsubdomain"
            ee_site_current_cache="basic"

        elif [ "$ee_site_current_type" = "WPSUBDOMAIN WP SUPER CACHE" ]; then
            ee_site_current="wpsubdomain"
            ee_site_current_cache="wpsc"

        elif [ "$ee_site_current_type" = "WPSUBDOMAIN W3 TOTAL CACHE" ]; then
            ee_site_current="wpsubdomain"
            ee_site_current_cache="w3tc"

        elif [ "$ee_site_current_type" = "WPSUBDOMAIN FAST CGI" ] || [ "$ee_site_current_type" = "WPSUBDOMAIN FASTCGI" ]; then
            ee_site_current="wpsubdomain"
            ee_site_current_cache="wpfc"
        fi

        ee_webroot="/var/www/$site"

        # Insert query to insert old site information into ee.db
        echo "INSERT INTO sites (sitename, site_type, cache_type, site_path, is_enabled, is_ssl, storage_fs, storage_db)
        VALUES (\"$site\", \"$ee_site_current\", \"$ee_site_current_cache\", \"$ee_webroot\", \"$ee_site_status\", 0, 'ext4', 'mysql');" | sqlite3 /var/lib/ee/ee.db

        done
    else
        ee_php_version=$(php -v | head -n1 | cut -d' ' -f2 |cut -c1-3)
        ee_lib_echo "Updating EasyEngine Database"
        echo "ALTER TABLE sites ADD COLUMN db_name varchar;" | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN db_user varchar; " | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN db_password varchar;" | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN db_host varchar;" | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN is_hhvm INT DEFAULT '0';" | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN is_pagespeed INT DEFAULT '0';" | sqlite3 /var/lib/ee/ee.db
        echo "ALTER TABLE sites ADD COLUMN php_version varchar DEFAULT \"$ee_php_version\";" | sqlite3 /var/lib/ee/ee.db
    fi
}


function secure_ee_db()
{
    chown -R root:root /var/lib/ee/
    chmod -R 600 /var/lib/ee/
}

function ee_update_wp_cli()
{
    ee_lib_echo "Updating WP-CLI version to resolve compatibility issue."
    PHP_PATH=$(which php)
    WP_CLI_PATH=$(which wp)
    if [ "${WP_CLI_PATH}" != "" ]; then
        # Get WP-CLI version
        WP_CLI_VERSION=$(${PHP_PATH} ${WP_CLI_PATH} --allow-root cli version | awk '{ print $2 }')
        dpkg --compare-versions ${WP_CLI_VERSION} lt 1.4.1
        # Update WP-CLI version
        if [ "$?" == "0" ]; then
           wget -qO ${WP_CLI_PATH} https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
           chmod +x ${WP_CLI_PATH}
        fi
    fi
}

function check_pagespeed()
{
   ee_lib_echo_info "Please Note: We have removed pagespeed from current version of our nginx build."
   ee_lib_echo_info "Verifiying if PageSpeed is not used..."

   if [ -f /etc/nginx/conf.d/pagespeed.conf ]
   then
        PAGESPEEDSITE="$(echo "SELECT sitename FROM sites WHERE is_pagespeed=1;"| sqlite3 /var/lib/ee/ee.db | wc -l)"

        if [ ${PAGESPEEDSITE} -ge 0 ]; then
            ee_lib_echo_fail "Issue: Update script has found PageSpeed on following site"
            echo "SELECT sitename FROM sites WHERE is_pagespeed=1;"| sqlite3 /var/lib/ee/ee.db
            ee_lib_echo_fail "Please remove Pagespeed from above site using:"
            ee_lib_echo_fail "ee site update example.com --pagespeed=off or follow this blog: https://easyengine.io/blog/disabling-pagespeed/ "
            ee_lib_error "Once done, run `ee update` again"
        fi
   else
        ee_lib_echo_info "OK: PageSpeed not Present."
   fi

}

# Install EasyEngine 3.x
function ee_install()
{
    # Remove old clone of EasyEngine (ee) if any
    rm -rf /tmp/easyengine &>> /dev/null

    # Clone EE 3.0 Python ee_branch
    ee_lib_echo "Cloning EasyEngine, please wait..."
    if [ "$ee_branch" = "" ]; then
        ee_branch=master
    fi

    git clone -b $ee_branch https://github.com/EasyEngine/easyengine.git /tmp/easyengine --quiet > /dev/null \
    || ee_lib_error "Unable to clone EasyEngine, exit status" $?

    cd /tmp/easyengine
    ee_lib_echo "Installing EasyEngine, please wait..."
    python3 setup.py install || ee_lib_error "Unable to install EasyEngine, exit status " $?
}

# Update EasyEngine configuration
# Remove EasyEngine 2.x
function ee_update()
{
    # Preserve old configuration
    ee_lib_echo "Updating EasyEngine configuration, please wait..."

    ee_grant_host=$(grep grant-host /etc/easyengine/ee.conf | awk '{ print $3 }' | head -1 )
    ee_db_name=$(grep db-name /etc/easyengine/ee.conf | awk '{ print $3 }')
    ee_db_user=$(grep db-name /etc/easyengine/ee.conf | awk '{ print $3 }')
    ee_wp_prefix=$(grep prefix /etc/easyengine/ee.conf | awk '{ print $3 }')
    ee_wp_user=$(grep 'user ' /etc/easyengine/ee.conf | grep -v db-user |awk '{ print $3 }')
    ee_wp_pass=$(grep password /etc/easyengine/ee.conf | awk '{ print $3 }')
    ee_wp_email=$(grep email /etc/easyengine/ee.conf | awk '{ print $3 }')
    ee_ip_addr=$(grep ip-address /etc/easyengine/ee.conf |awk -F'=' '{ print $2 }')

    sed -i "s/ip-address.*/ip-address = ${ee_ip_addr}/" /etc/ee/ee.conf && \
    sed -i "s/grant-host.*/grant-host = ${ee_grant_host}/" /etc/ee/ee.conf && \
    sed -i "s/db-name.*/db-name = ${db-name}/" /etc/ee/ee.conf && \
    sed -i "s/db-user.*/db-user = ${ee_db_user}/" /etc/ee/ee.conf && \
    sed -i "s/prefix.*/prefix = ${ee_wp_prefix}/" /etc/ee/ee.conf && \
    sed -i "s/^user.*/user = ${ee_wp_user}/" /etc/ee/ee.conf && \
    sed -i "s/password.*/password = ${ee_wp_password}/" /etc/ee/ee.conf && \
    sed -i "s/email.*/email = ${ee_wp_email}/" /etc/ee/ee.conf || ee_lib_error "Unable to update configuration, exit status " $?

    # Remove old EasyEngine
    ee_lib_echo "Removing EasyEngine 2.x"
    rm -rf /etc/bash_completion.d/ee /etc/easyengine/ /usr/share/easyengine/ /usr/local/lib/easyengine /usr/local/sbin/easyengine /usr/local/sbin/ee /var/log/easyengine

    # Softlink to fix command not found error
    ln -s /usr/local/bin/ee /usr/local/sbin/ee || ee_lib_error "Unable to create softlink to old EasyEngine, exit status " $?
}

function ee_upgrade_php(){
    #Upgrade PHP5.6 to a new repo supporting PHP 7.0
   if [ "$ee_distro_version" == "trusty" ]; then
        if [ -f /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list ]; then
           # add-apt-repository -y --remove 'ppa:ondrej/php5-5.6'
            add-apt-repository -y 'ppa:ondrej/php'
            ee_lib_echo "Upgrading required packages, please wait..."
            apt-get update &>> /dev/null
            apt-get -y install php5.6-fpm php5.6-curl php5.6-gd php5.6-imap php5.6-mcrypt php5.6-readline php5.6-mysql php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-bcmath php5.6-recode php5.6-mysql php5.6-opcache php-memcached php-imagick memcached graphviz php-pear php-xdebug php-msgpack php5.6-zip php5.6-xml php5.6-soap php-memcache || ee_lib_error "Unable to install PHP 5.6 packages, exit status " 1
            if [ -e /etc/php5/fpm/pool.d/www.conf -a -e /etc/php5/fpm/pool.d/debug.conf -a -e /etc/php5/fpm/php.ini -a -e /etc/php5/fpm/php-fpm.conf ]; then
                cp -f /etc/php5/fpm/pool.d/www.conf /etc/php/5.6/fpm/pool.d/www.conf &>> /dev/null
                cp -f /etc/php5/fpm/pool.d/debug.conf /etc/php/5.6/fpm/pool.d/debug.conf &>> /dev/null
                cp -f /etc/php5/fpm/php.ini /etc/php/5.6/fpm/php.ini &>> /dev/null
                cp -f /etc/php5/fpm/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf &>> /dev/null
            else
                echo "Some files are missing." || ee_lib_error "Unable to configure PHP5.6 packages, exit status " 1
            fi
            sed -i "s/pid.*/pid = \/run\/php\/php5.6-fpm.pid/" /etc/php/5.6/fpm/php-fpm.conf && \
            sed -i "s/error_log.*/error_log = \/var\/log\/php\/5.6\/fpm.log/" /etc/php/5.6/fpm/php-fpm.conf && \
            sed -i "s/log_level.*/log_level = notice/" /etc/php/5.6/fpm/php-fpm.conf && \
            sed -i "s/include.*/include = \/etc\/php\/5.6\/fpm\/pool.d\/*.conf/" /etc/php/5.6/fpm/php-fpm.conf && \
            sed -i "s/slowlog =.*/slowlog = \/var\/log\/php\/5.6\/slow.log/" /etc/php/5.6/fpm/pool.d/debug.conf || ee_lib_error "Unable to update configuration, exit status " $?
            mkdir -p /var/log/php/5.6/
            touch /var/log/php/5.6/slow.log /var/log/php/5.6/fpm.log
            service php5-fpm stop &>> /dev/null
            service php5.6-fpm restart &>> /dev/null
            rm -f /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list &>> /dev/null
            apt-get remove -y php5-fpm php5-curl php5-gd php5-imap php5-mcrypt php5-common php5-readline php5-mysql php5-cli php5-memcache php5-imagick memcached graphviz php-pear

          #Fix for PHP 5.6 + 7.0 missed packages
        elif [ -f /etc/php/mods-available/readline.ini ]; then
              mkdir -p /tmp/php-conf/5.6
              mkdir -p /tmp/php-conf/7.0
              cp -f /etc/php/5.6/fpm/pool.d/www.conf /tmp/php-conf/5.6 &>> /dev/null
              cp -f /etc/php/5.6/fpm/pool.d/debug.conf /tmp/php-conf/5.6 &>> /dev/null
              cp -f /etc/php/5.6/fpm/php.ini /tmp/php-conf/5.6 &>> /dev/null
              cp -f /etc/php/5.6/fpm/php-fpm.conf /tmp/php-conf/5.6 &>> /dev/null

              cp -f /etc/php/7.0/fpm/pool.d/www.conf /tmp/php-conf/7.0 &>> /dev/null
              cp -f /etc/php/7.0/fpm/pool.d/debug.conf /tmp/php-conf/7.0 &>> /dev/null
              cp -f /etc/php/7.0/fpm/php.ini /tmp/php-conf/7.0 &>> /dev/null
              cp -f /etc/php/7.0/fpm/php-fpm.conf /tmp/php-conf/7.0 &>> /dev/null


            apt-get -y install php5.6-fpm php5.6-curl php5.6-gd php5.6-imap php5.6-mcrypt php5.6-readline php5.6-mysql php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-bcmath php5.6-recode php5.6-mysql php5.6-opcache php-memcached php-imagick memcached graphviz php-pear php-xdebug php-msgpack php5.6-zip php5.6-xml php-memcache || ee_lib_error "Unable to install PHP 5.6 packages, exit status " 1
            dpkg-query -W -f='${Status} ${Version}\n' php7.0-fpm 2>/dev/null | grep installed
            if [ "$?" -eq "0" ]; then
                apt-get -y install php7.0-fpm php7.0-curl php7.0-gd php7.0-imap php7.0-mcrypt php7.0-readline php7.0-common php7.0-recode php7.0-mysql php7.0-cli php7.0-curl php7.0-mbstring php7.0-bcmath php7.0-mysql php7.0-opcache php7.0-zip php7.0-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.0-soap || ee_lib_error "Unable to install PHP 7.0 packages, exit status " 1
                mv -f /tmp/php-conf/7.0/www.conf /etc/php/7.0/fpm/pool.d/www.conf  &>> /dev/null
                mv -f /tmp/php-conf/7.0/debug.conf /etc/php/7.0/fpm/pool.d/debug.conf &>> /dev/null
                mv -f /tmp/php-conf/7.0/php.ini /etc/php/7.0/fpm/php.ini  &>> /dev/null
                mv -f /tmp/php-conf/7.0/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf  &>> /dev/null
                service php7.0-fpm restart &>> /dev/null
            fi

            mv -f /tmp/php-conf/5.6/www.conf /etc/php/5.6/fpm/pool.d/www.conf  &>> /dev/null
            mv -f /tmp/php-conf/5.6/debug.conf /etc/php/5.6/fpm/pool.d/debug.conf &>> /dev/null
            mv -f /tmp/php-conf/5.6/php.ini /etc/php/5.6/fpm/php.ini  &>> /dev/null
            mv -f /tmp/php-conf/5.6/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf  &>> /dev/null

            service php5.6-fpm restart &>> /dev/null
            rm -rf /tmp/php-conf
        fi
   fi

}

function ee_update_latest()
{

if [ -f /etc/nginx/fastcgi_params  ]
then
   cat /etc/nginx/fastcgi_params| grep -q 'HTTP_PROXY'
   if [[ $? -ne 0 ]]; then
	echo "fastcgi_param  HTTP_PROXY         \"\";" >> /etc/nginx/fastcgi_params
    echo "fastcgi_param  HTTP_PROXY         \"\";" >> /etc/nginx/fastcgi.conf
    service nginx restart &>> /dev/null
	fi
fi



if [ -f /etc/ImageMagick/policy.xml  ]
  then
    if [ ! -f /etc/ImageMagick/patch.txt  ]
      then
      echo -e "\t<policy domain="coder" rights="none" pattern="EPHEMERAL" />\n\t<policy domain="coder" rights="none" pattern="URL" />\n\t<policy domain="coder" rights="none" pattern="HTTPS" />\n\t<policy domain="coder" rights="none" pattern="MVG" />\n\t<policy domain="coder" rights="none" pattern="MSL" />" >> /etc/ImageMagick/patch.txt
      sed -i '/<policymap>/r /etc/ImageMagick/patch.txt' /etc/ImageMagick/policy.xml
    fi
  fi

    #Move ~/.my.cnf to /etc/mysql/conf.d/my.cnf
    if [ ! -f /etc/mysql/conf.d/my.cnf ]
    then
        #create conf.d folder if not exist
        if [ ! -d /etc/mysql/conf.d ]; then
            mkdir -p /etc/mysql/conf.d
            chmod 755 /etc/mysql/conf.d
        fi
        if [ -d /etc/mysql/conf.d ]
        then
            if [ -f ~/.my.cnf ]
            then
                cp ~/.my.cnf /etc/mysql/conf.d/my.cnf &>> /dev/null
                chmod 600 /etc/mysql/conf.d/my.cnf
            else
                if [ -f /root/.my.cnf ]
                then
                    cp /root/.my.cnf /etc/mysql/conf.d/my.cnf &>> /dev/null
                    chmod 600 /etc/mysql/conf.d/my.cnf
                else
                    ee_lib_echo_fail ".my.cnf cannot be located in your current user or root."
                fi
            fi
        fi
    fi


    if [ -f /etc/nginx/nginx.conf ]; then
        ee_lib_echo "Updating Nginx configuration, please wait..."
        # From version 3.1.10 we are using Suse builder for repository
        if [ "$ee_distro_version" == "precise" ]; then
            grep -Hr 'http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_12.04/ /' /etc/apt/sources.list.d/ &>> /dev/null
            if [[ $? -ne 0 ]]; then
                if [ -f /etc/apt/sources.list.d/rtcamp-nginx-precise.list ]; then
                    rm -rf /etc/apt/sources.list.d/rtcamp-nginx-precise.list
                fi
                echo -e "\ndeb http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_12.04/ /" >> /etc/apt/sources.list.d/ee-repo.list
                gpg --keyserver "hkp://pgp.mit.edu" --recv-keys '3050AC3CD2AE6F03'
                gpg -a --export --armor '3050AC3CD2AE6F03' | apt-key add -
                if [ -f /etc/nginx/conf.d/ee-nginx.conf ]; then
                    mv /etc/nginx/conf.d/ee-nginx.conf /etc/nginx/conf.d/ee-nginx.conf.old &>> /dev/null
                fi
                mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old &>> /dev/null
                apt-get update
                service nginx stop &>> /dev/null
                DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y install nginx-ee openssl
                service nginx restart &>> /dev/null
            fi
            dpkg --get-selections | grep -v deinstall | grep nginx-common
            if [ $? -eq 0 ]; then
	            apt-get update
	            dpkg --get-selections | grep -v deinstall | grep nginx-mainline
	            if [ $? -eq 0 ]; then
                    apt-get remove -y nginx-mainline
                fi
                service nginx stop &>> /dev/null
	            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y --allow-unauthenticated install nginx-ee nginx-custom
                service nginx restart &>> /dev/null
            fi
            dpkg --get-selections | grep -v deinstall | grep nginx-mainline

          elif [ "$ee_distro_version" == "trusty" ]; then
            grep -Hr 'http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_14.04/ /' /etc/apt/sources.list.d/ &>> /dev/null
            if [[ $? -ne 0 ]]; then
                if [ -f /etc/apt/sources.list.d/rtcamp-nginx-trusty.list ]; then
                    rm -rf /etc/apt/sources.list.d/rtcamp-nginx-trusty.list
                fi
                echo -e "\ndeb http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/xUbuntu_14.04/ /" >> /etc/apt/sources.list.d/ee-repo.list
                gpg --keyserver "hkp://pgp.mit.edu" --recv-keys '3050AC3CD2AE6F03'
                gpg -a --export --armor '3050AC3CD2AE6F03' | apt-key add -
                if [ -f /etc/nginx/conf.d/ee-nginx.conf ]; then
                    mv /etc/nginx/conf.d/ee-nginx.conf /etc/nginx/conf.d/ee-nginx.conf.old &>> /dev/null
                fi
                mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old &>> /dev/null
                apt-get update
                service nginx stop &>> /dev/null
                DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y install nginx-custom nginx-ee
                service nginx restart &>> /dev/null
            fi
            dpkg --get-selections | grep -v deinstall | grep nginx-common
            if [ $? -eq 0 ]; then
	            apt-get update
	            dpkg --get-selections | grep -v deinstall | grep nginx-mainline
	            if [ $? -eq 0 ]; then
                    apt-get remove -y nginx-mainline
                fi
                service nginx stop &>> /dev/null
	            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y --allow-unauthenticated install nginx-ee nginx-custom
                service nginx restart &>> /dev/null
            fi

        elif [ "$ee_distro_version" == "wheezy" ]; then
            grep -Hr 'http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/Debian_7.0/ /' /etc/apt/sources.list.d/ &>> /dev/null
            #grep -Hr "deb http://packages.dotdeb.org wheezy all" /etc/apt/sources.list.d/ee-repo.list &>> /dev/null
            if [[ $? -ne 0 ]]; then
                # if [ -f /etc/apt/sources.list.d/dotdeb-wheezy.list ]; then
                #     rm -rf /etc/apt/sources.list.d/dotdeb-wheezy.list
                # else
                #     sed -i "/deb http:\/\/packages.dotdeb.org wheezy all/d" /etc/apt/sources.list.d/ee-repo.list &>> /dev/null
                # fi
                echo -e "deb http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/Debian_7.0/ /" >> /etc/apt/sources.list.d/ee-repo.list
                gpg --keyserver "hkp://pgp.mit.edu" --recv-keys '3050AC3CD2AE6F03'
                gpg -a --export --armor '3050AC3CD2AE6F03' | apt-key add -
                if [ -f /etc/nginx/conf.d/ee-nginx.conf ]; then
                    mv /etc/nginx/conf.d/ee-nginx.conf /etc/nginx/conf.d/ee-nginx.conf.old &>> /dev/null
                fi
                mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old &>> /dev/null
                mv /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.old &>> /dev/null
                apt-get update
                service nginx stop &>> /dev/null
                DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y install nginx-custom
                service nginx restart &>> /dev/null
            fi
            dpkg --get-selections | grep -v deinstall | grep nginx-common
            if [ $? -eq 0 ]; then
	            apt-get update
	            service nginx stop &>> /dev/null
	            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y install nginx-ee nginx-custom
                service nginx restart &>> /dev/null
            fi
        elif [ "$ee_distro_version" == "jessie" ]; then

            grep -Hr 'http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/Debian_8.0/ /' /etc/apt/sources.list.d/ &>> /dev/null
            #grep -Hr "deb http://packages.dotdeb.org jessie all" /etc/apt/sources.list.d/ee-repo.list &>> /dev/null
            if [[ $? -ne 0 ]]; then
                #sed -i "/deb http:\/\/packages.dotdeb.org jessie all/d" /etc/apt/sources.list.d/ee-repo.list &>> /dev/null
                echo -e "deb http://download.opensuse.org/repositories/home:/rtCamp:/EasyEngine/Debian_8.0/ /" >> /etc/apt/sources.list.d/ee-repo.list
                gpg --keyserver "hkp://pgp.mit.edu" --recv-keys '3050AC3CD2AE6F03'
                gpg -a --export --armor '3050AC3CD2AE6F03' | apt-key add -
                if [ -f /etc/nginx/conf.d/ee-nginx.conf ]; then
                    mv /etc/nginx/conf.d/ee-nginx.conf /etc/nginx/conf.d/ee-nginx.conf.old &>> /dev/null
                fi
                mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old &>> /dev/null
                mv /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.old &>> /dev/null
                apt-get update
                service nginx stop &>> /dev/null
                apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y install nginx-custom
                service nginx restart &>> /dev/null
            fi
            dpkg --get-selections | grep -v deinstall | grep nginx-common
            if [ $? -eq 0 ]; then
	            apt-get update
	            dpkg --get-selections | grep -v deinstall | grep nginx-mainline
	            if [ $? -eq 0 ]; then
                    apt-get remove -y nginx-mainline
                fi
                service nginx stop &>> /dev/null
	            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y --allow-unauthenticated install nginx-ee nginx-custom
                service nginx restart &>> /dev/null
            fi
        fi
    fi

    if [ -f /etc/nginx/nginx.conf ]; then
        sed -i "s/.*X-Powered-By.*/\tadd_header X-Powered-By \"EasyEngine $ee_version_new\";/" /etc/nginx/nginx.conf &>> /dev/null
    fi

    if [ -f /etc/nginx/conf.d/ee-plus.conf ]; then
        sed -i "s/.*X-Powered-By.*/\tadd_header X-Powered-By \"EasyEngine $ee_version_new\";/" /etc/nginx/conf.d/ee-plus.conf &>> /dev/null
    fi

    # Disable Xdebug on old systems if and only if ee debug is off
    if [ -f /etc/php5/mods-available/xdebug.ini ]; then
        ee_debug_value=$(grep -Hr 9001 /etc/nginx/conf.d/upstream.conf | wc -l )
        if [ $ee_debug_value -eq 1 ]; then
            grep -Hr ";zend_extension" /etc/php5/mods-available/xdebug.ini &>> /dev/null
            if [ $? -ne 0 ]; then
                sed -i "s/zend_extension/;zend_extension/" /etc/php5/mods-available/xdebug.ini
            fi
        fi
    fi

    # Fix HHVM autostart on reboot
    dpkg --get-selections | grep -v deinstall | grep hhvm &>> /dev/null
    if [ $? -eq 0 ]; then
        update-rc.d hhvm defaults &>> /dev/null
    fi

    # Fix WordPress example.html issue
    # Ref: http://wptavern.com/xss-vulnerability-in-jetpack-and-the-twenty-fifteen-default-theme-affects-millions-of-wordpress-users
    dpkg --get-selections | grep -v deinstall | grep nginx &>> /dev/null
    if [ $? -eq 0 ]; then
        cp /usr/lib/ee/templates/locations.mustache /etc/nginx/common/locations.conf &>> /dev/null
    fi

    # Fix HHVM upstream issue that was preventing from using EasyEngine for site operations
    if [ -f /etc/nginx/conf.d/upstream.conf ]; then
        grep -Hr hhvm /etc/nginx/conf.d/upstream.conf &>> /dev/null
        if [ $? -ne 0 ]; then
            echo -e "upstream hhvm {\n# HHVM Pool\nserver 127.0.0.1:8000;\nserver 127.0.0.1:9000 backup;\n}\n" >> /etc/nginx/conf.d/upstream.conf
        fi
    fi

    # Fix HHVM server IP
    if [ -f /etc/hhvm/server.ini ]; then
        grep -Hr "hhvm.server.ip" /etc/hhvm/server.ini &>> /dev/null
        if [ $? -ne 0 ]; then
            echo -e "hhvm.server.ip = 127.0.0.1\n" >> /etc/hhvm/server.ini
        fi
    fi


    # Rename Redis Header
    if [ -f /etc/nginx/common/redis-hhvm.conf ]; then
      sed -i "s/X-Cache /X-SRCache-Fetch-Status /g" /etc/nginx/common/redis-hhvm.conf &>> /dev/null
      sed -i "s/X-Cache-2 /X-SRCache-Store-Status /g" /etc/nginx/common/redis-hhvm.conf &>> /dev/null
    fi

    if [ -f /etc/nginx/common/redis.conf ]; then
      sed -i "s/X-Cache /X-SRCache-Fetch-Status /g" /etc/nginx/common/redis.conf &>> /dev/null
      sed -i "s/X-Cache-2 /X-SRCache-Store-Status /g" /etc/nginx/common/redis.conf &>> /dev/null
    fi


    if [ -f /etc/nginx/common/redis-hhvm.conf ]; then
    # Update Timeout redis-hhvm.conf
      grep -0 'redis2_query expire $key 6h' /etc/nginx/common/redis-hhvm.conf &>> /dev/null
      if [ $? -eq 0 ]; then
        sed -i 's/redis2_query expire $key 6h/redis2_query expire $key 14400/g' /etc/nginx/common/redis-hhvm.conf &>> /dev/null
      fi

    #Fix for 3.3.4 redis-hhvm issue
      grep -0 'HTTP_ACCEPT_ENCODING' /etc/nginx/common/redis-hhvm.conf &>> /dev/null
      if [ $? -ne 0 ]; then
        sed -i 's/fastcgi_params;/fastcgi_params;\n  fastcgi_param HTTP_ACCEPT_ENCODING "";/g' /etc/nginx/common/redis-hhvm.conf &>> /dev/null
      fi
    fi

    #Fix Security Issue. commit #c64f28e
    if [ -f /etc/nginx/common/locations.conf ]; then
       grep -0 '$request_uri ~\* \"^.+(readme|license|example)\\.(txt|html)$\"' /etc/nginx/common/locations.conf &>> /dev/null
       if [ $? -eq 0 ]; then
        sed -i 's/$request_uri ~\* \"^.+(readme|license|example)\\.(txt|html)$\"/$uri ~\* \"^.+(readme|license|example)\\.(txt|html)$\"/g' /etc/nginx/common/locations.conf &>> /dev/null
       fi
    fi

    #Fix Redis-server security issue
    #http://redis.io/topics/security
     if [ -f /etc/redis/redis.conf  ]; then
       grep -0 -v "#" /etc/redis/redis.conf | grep 'bind' &>> /dev/null
       if [ $? -ne 0 ]; then
            sed -i '$ a bind 127.0.0.1' /etc/redis/redis.conf &>> /dev/null
            service redis-server restart &>> /dev/null
       fi
     fi

    #Fix For --letsencrypt
    if [ -f /etc/nginx/common/locations.conf ]; then
       grep -0 'location ~ \/\\.well-known' /etc/nginx/common/locations.conf &>> /dev/null
       if [ $? -ne 0 ]; then
        sed -i 's/# Deny hidden files/# Deny hidden files\nlocation ~ \/\\.well-known {\n  allow all;\n}\n /g' /etc/nginx/common/locations.conf &>> /dev/null
       fi
    fi

    # Fix for 3.3.2 renamed nginx.conf
    nginx -V 2>&1 &>>/dev/null
    if [[ $? -eq 0 ]]; then
        nginx -t 2>&1 | grep 'open() "/etc/nginx/nginx.conf" failed' &>>/dev/null
        if [[ $? -eq 0 ]]; then
            if [ -f /etc/nginx/nginx.conf.old ]; then
                if [ ! -f /etc/nginx/nginx.conf ]; then
                    cp /etc/nginx/nginx.conf.old /etc/nginx/nginx.conf
                fi
            fi
        fi
        # Fix for 3.3.2 renamed fastcgi_param
        nginx -t 2>&1 | grep 'open() "/etc/nginx/fastcgi_params" failed' &>>/dev/null
        if [[ $? -eq 0 ]]; then
            if [ -f /etc/nginx/fastcgi_params.old ]; then
                if [ ! -f /etc/nginx/fastcgi_params ]; then
                    cp /etc/nginx/fastcgi_params.old /etc/nginx/fastcgi_params
                fi
            fi
        fi
    fi

    #Fix For ssl_ciphers
    if [ -f /etc/nginx/nginx.conf ]; then
       sed -i 's/HIGH:!aNULL:!MD5:!kEDH;/ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;/' /etc/nginx/nginx.conf
    fi

   #Fix for SSL cert --all
   crontab -l | grep -q '\-\-min_expiry_limit'
   if [[ $? -eq 0 ]]; then
        crontab -l > /var/spool/cron/cron-backup.txt  #backup cron before editing
        crontab -l | sed '/--min_expiry_limit/d' | crontab -
        /bin/bash -c "crontab -l 2> /dev/null | { cat; echo -e \"\n0 0 * * 0 ee site update --le=renew --all 2> /dev/null # Renew all letsencrypt SSL cert. Set by EasyEngine\"; } | crontab -"
   fi



}

# Do git intialisation
function ee_git_init()
{
    # Nginx under git version control
    if [ -d /etc/nginx ];then
        cd /etc/nginx
        if [ ! -d /etc/nginx/.git ]; then
            git init &>> /dev/null
        fi
        git add -A .
        git commit -am "Updated Nginx" > /dev/null
    fi
    # EasyEngine under git version control
    cd /etc/ee
    if [ ! -d /etc/ee/.git ]; then
        git init > /dev/null
    fi
    git add -A .
    git commit -am "Installed/Updated to EasyEngine 3.x" &>> /dev/null

    #PHP under git version control
    if [ -d /etc/php ];then
        cd /etc/php
        if [ ! -d /etc/php/.git ]; then
            git init &>> /dev/null
        fi
        git add -A .
        git commit -am "Updated PHP" > /dev/null
    fi

}

# Update EasyEngine
if [ -f /usr/local/sbin/easyengine ]; then
    # Check old EasyEngine version
    ee version | grep ${ee_version_old} &>> /dev/null
    if [[ $? -ne 0 ]]; then
        ee_lib_echo "EasyEngine $ee_version_old not found on your system" | tee -ai $ee_install_log
        ee_lib_echo "Updating your EasyEngine to $ee_version_old for compability" | tee -ai $ee_install_log
        wget -q https://raw.githubusercontent.com/EasyEngine/easyengine/old-stable/bin/update && bash update
        if [[ $? -ne 0 ]]; then
            ee_lib_echo_fail "Unable to update EasyEngine to $ee_version_old, exit status = " $?
            exit 100
        fi
    fi
    read -p "Update EasyEngine to $ee_version_new (y/n): " ee_ans
    if [ "$ee_ans" = "y" ] || [ "$ee_ans" = "Y" ]; then
        check_pagespeed | tee -ai $ee_install_log
        ee_install_dep | tee -ai $ee_install_log
        ee_sync_db 2&>>1 $EE_INSTALL_LOG
        secure_ee_db | tee -ai $EE_INSTALL_LOG
        ee_upgrade_php | tee -ai $ee_install_log
        ee_install | tee -ai $ee_install_log
        ee_update | tee -ai $ee_install_log
        ee_update_latest | tee -ai $ee_install_log
        ee_git_init | tee -ai $ee_install_log
    else
        ee_lib_error "Not updating EasyEngine to $ee_version_new, exit status = " 1
    fi
elif [ ! -f /usr/local/bin/ee ]; then
    ee_lib_echo "Installing depedencies" | tee -ai $ee_install_log
    ee_install_dep | tee -ai $ee_install_log
    ee_lib_echo "Installing EasyEngine $ee_branch" | tee -ai $ee_install_log
    ee_install | tee -ai $ee_install_log
    ee_lib_echo "Running post-install steps" | tee -ai $ee_install_log
    secure_ee_db | tee -ai $EE_INSTALL_LOG
    ee_git_init | tee -ai $ee_install_log

else
    ee -v 2>&1 | grep $ee_version_new &>> /dev/null
    if [[ $? -ne 0 ]];then
        read -p "Update EasyEngine to $ee_version_new (y/n): " ee_ans
        if [ "$ee_ans" = "y" ] || [ "$ee_ans" = "Y" ]; then
            ee_install_dep | tee -ai $ee_install_log
            ee_sync_db 2&>>1 $EE_INSTALL_LOG
            secure_ee_db | tee -ai $EE_INSTALL_LOG
            ee_upgrade_php | tee -ai $ee_install_log
            ee_install | tee -ai $ee_install_log
            ee_update_latest | tee -ai $ee_install_log
            ee_git_init | tee -ai $ee_install_log
            service nginx reload &>> /dev/null
            if [ "$ee_distro_version" == "trusty" ]; then
                service php5.6-fpm restart &>> /dev/null
            else
                service php5-fpm restart &>> /dev/null
            fi
            ee_update_wp_cli | tee -ai $ee_install_log
        else
            ee_lib_error "Not updating EasyEngine to $ee_version_new, exit status = " 1
        fi
    else
        ee_lib_error "You already have EasyEngine $ee_version_new, exit status = " 1
    fi
fi
ee sync | tee -ai $EE_INSTALL_LOG

echo
ee_lib_echo "For EasyEngine (ee) auto completion, run the following command"
echo
ee_lib_echo_info "source /etc/bash_completion.d/ee_auto.rc"
echo
ee_lib_echo "EasyEngine (ee) installed/updated successfully"
ee_lib_echo "EasyEngine (ee) help: http://docs.rtcamp.com/easyengine/"
