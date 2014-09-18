#!/bin/bash
#Provided by http://graylog2.org
# https://gist.github.com/hggh/7492598

# Ubuntu Install Script with Debian Packages

# Install Pre-Reqs
# apt-get -y install git curl libcurl4-openssl-dev libapr1-dev libcurl4-openssl-dev libapr1-dev build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config python-software-properties software-properties-common openjdk-7-jre pwgen
#apt-get -y install git curl build-essential pwgen wget
apt-get -y install git curl build-essential pwgen wget mongodb-server openjdk-7-jre-headless uuid-runtime adduser


#Install Elasticsearch from Upstream
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.10.deb
dpkg -i elasticsearch-0.90.10.deb
sed -i -e 's|# cluster.name: elasticsearch|cluster.name: graylog2|' /etc/elasticsearch/elasticsearch.yml

#Graylog2 Packages
apt-key adv --keyserver pgp.surfnet.nl --recv-keys 016CFFD0
echo 'deb http://finja.brachium-system.net/~jonas/packages/graylog2_repro/ wheezy main' > /etc/apt/sources.list.d/graylog2.list
apt-get update && apt-get install graylog2-server graylog2-web
apt-get install graylog2-stream-dashboard

#enable init script
sed -i 's@no@yes@' /etc/default/graylog2-server
sed -i 's@no@yes@' /etc/default/graylog2-web

#change parameters server
read -s -p "Set the admin password: " pass_secret
sed -i -e 's|password_secret =|password_secret = '$pass_secret'|' /etc/graylog2/server/server.conf
root_pass_sha2=$(echo -n $pass_secret | shasum -a 256)
sed -i -e "s|root_password_sha2 =|root_password_sha2 = ${root_pass_sha2:0:64}|" /etc/graylog2/server/server.conf
sed -i -e 's|elasticsearch_shards = 4|elasticsearch_shards = 1|' /etc/graylog2/server/server.conf
sed -i -e 's|mongodb_useauth = true|mongodb_useauth = false|' /etc/graylog2/server/server.conf
sed -i -e 's|#elasticsearch_discovery_zen_ping_multicast_enabled = false|elasticsearch_discovery_zen_ping_multicast_enabled = false|' /etc/graylog2/server/server.conf
sed -i -e 's|#elasticsearch_discovery_zen_ping_unicast_hosts = 192.168.1.203:9300|elasticsearch_discovery_zen_ping_unicast_hosts = 127.0.0.1:9300|' /etc/graylog2/server/server.conf

# Setting new retention policy setting or Graylog2 Server will not start
sed -i 's|retention_strategy = delete|retention_strategy = close|' /etc/graylog2/server/server.conf

# Setting email transport config
function enable_email_transport {
    sed -i -e 's|transport_email_enabled = false|transport_email_enabled = true|' /etc/graylog2/server/server.conf
    read -p "Set email Hostname: " email_hostname
    sed -i -e 's|transport_email_hostname = mail.example.com|transport_email_hostname = '${email_hostname}'|' /etc/graylog2/server/server.conf
    read -p "Set email port: " email_port
    sed -i -e 's|transport_email_port = 587|transport_email_port = '${email_port}'|' /etc/graylog2/server/server.conf

    loop=1
    while [ $loop -eq 1 ]; do
    loop=0
        read -p "Do you want to use tls? [Y/N]" use_tls
        case ${use_tls} in
            [Yy]* ) sed -i -e 's|transport_email_use_tls = true|transport_email_use_tls = true|' /etc/graylog2/server/server.conf;;
            [Nn]* ) sed -i -e 's|transport_email_use_tls = true|transport_email_use_tls = false|' /etc/graylog2/server/server.conf;echo 'Ok';;
            * ) echo "Please answer yes or no."; loop=1;;
        esac
    done

    read -p "Set auth username: " email_username
    sed -i -e 's|transport_email_auth_username = you@example.com|transport_email_auth_username = '${email_username}'|' /etc/graylog2/server/server.conf
    read -s -p  "Set auth password: " email_password
    sed -i -e 's|transport_email_auth_password = secret|transport_email_auth_password = '${email_password}'|' /etc/graylog2/server/server.conf

break
}

loop=1
while [ $loop -eq 1 ]; do
    loop=0
    read -p "Do you want to configure email transport? [Y/N]" use_email
    case ${use_email} in
        [Yy]* ) enable_email_transport;;
        [Nn]* ) sed -i -e 's|transport_email_enabled = false|transport_email_enabled = false|' /etc/graylog2/server/server.conf;echo 'Ok';;
        * ) echo "Please answer yes or no."; loop=1;;
    esac
done

#change parameters web-interface
sed -i -e 's|graylog2-server.uris=""|graylog2-server.uris="http://127.0.0.1:12900/"|' /etc/graylog2/web/graylog2-web-interface.conf
sed -i -e 's|application.secret=""|application.secret="'$(pwgen -s 96)'"|' /etc/graylog2/web/graylog2-web-interface.conf

#start services
/etc/init.d/graylog2-server start
/etc/init.d/graylog2-web start
/etc/init.d/elasticsearch start





# All Done
echo "Installation has completed!!"
echo "Browse to IP address of this Graylog2 Server Used for Installation"
echo "Browse to http://localhost:9000/"
echo "Login with username: admin"
echo "@jcarrier"
