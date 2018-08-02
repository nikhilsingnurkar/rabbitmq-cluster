#!/bin/bash

source ./config.sh
#epel-url=http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
#erlang-url=https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_20.3-1~centos~7_amd64.rpm
#rabbitmq-url=https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.5/rabbitmq-server-3.7.5-1.el7.noarch.rpm
hostname=$(hostname -s)
host_ip=$(hostname -I)



echo "--> Create rabbitmq directory "
sudo mkdir /rabbitmq

echo "--> Change directory to /rabbitmq"
cd /rabbitmq


echo "--> Download and Install epel repository for OS 7.x"
sudo wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
sudo rpm --install epel-release-7-11.noarch.rpm

echo "--> Download and Install libselinux-python "
sudo yum install libselinux-python socat -y

echo "--> Download and Install Erlang for OS 7.x"
sudo wget https://dl.bintray.com/rabbitmq/rpm/erlang/20/el/7/x86_64/erlang-20.3.6-1.el7.centos.x86_64.rpm
sudo rpm --import https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
sudo rpm --install erlang-20.3.6-1.el7.centos.x86_64.rpm

echo "--> Download RabbitMQ for OS 7.x"
sudo wget https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.5/rabbitmq-server-3.7.5-1.el7.noarch.rpm

echo "--> Import RabbitMQ signing key"
sudo rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc

echo "--> Check if rabbitmq-server.rpm is installed"
rabbitmq-rpm-check="$(sudo rpm -q rabbitmq-server)"

echo "--> Install the RabbitMQ using shell"
sudo rpm -ivh --nodeps /rabbitmq/rabbitmq-server-3.7.5-1.el7.noarch.rpm

echo "--> Start the rabbitmq-server service"
sudo systemctl start rabbitmq-server

echo "--> Enable RabbitMQ Management plugin"
sudo rabbitmq-plugins enable rabbitmq_management

echo "--> Download rabbitmq_delayed_message_exchange Plugin"
sudo wget https://dl.bintray.com/rabbitmq/community-plugins/3.7.x/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip

echo "--> Extract and copy Plugin file to /usr/lib/rabbitmq/lib/rabbitmq_server-3.7.5/plugins"
unzip rabbitmq_delayed_message_exchange-20171201-3.7.x.zip
sudo cp rabbitmq_delayed_message_exchange-20171201-3.7.x.ez /usr/lib/rabbitmq/lib/rabbitmq_server-3.7.5/plugins

echo "--> Enable rabbitmq_delayed_message_exchange Plugin"
sudo rabbitmq-plugins enable rabbitmq_delayed_message_exchange

echo "--> Create RabbitMQ Admin User"
sudo rabbitmqctl add_user rabbitadmin Canopy1!
sudo rabbitmqctl set_user_tags rabbitadmin administrator
sudo rabbitmqctl set_permissions -p / rabbitadmin ".*" ".*" ".*"

echo "--> Restart the rabbitmq-server service"
sudo systemctl restart rabbitmq-server

echo "--> Stop the rabbitmq-server service"
sudo systemctl stop rabbitmq-server

echo "--> check whether /var/lib/rabbitmq/.erlang.cookie exists"
erlang-cookie="$(sudo ls /var/lib/rabbitmq/.erlang.cookie)"

echo "--> change the permissions of /var/lib/rabbitmq/.erlang.cookie to 0600 "
sudo chmod 0666 /var/lib/rabbitmq/.erlang.cookie

echo "--> copy .erlang.cookie into /var/lib/rabbitmq/"
sudo echo BLOLDSCOFFAMQUGVVZBQ > /var/lib/rabbitmq/.erlang.cookie

echo "--> change the permissions of /var/lib/rabbitmq/.erlang.cookie to 0400 "
sudo chmod 0400 /var/lib/rabbitmq/.erlang.cookie

echo "--> Copy rabbitmqadmin file from template to /usr/bin/rabbitmqadmin
#sudo cp /var/lib/rabbitmq/mnesia/rabbit@rabbit1-plugins-expand/rabbitmq_management-3.7.5/priv/www/cli/rabbitmqadmin /usr/bin/
cd /usr/bin
sudo wget http://localhost:15672/cli/rabbitmqadmin
sudo chmod +x rabbitmqadmin

echo "--> set execution permissions for /usr/bin/rabbitmqadmin
sudo chmod +x /usr/bin/rabbitmqadmin

echo "--> Start the rabbitmq-server service"
sudo systemctl start rabbitmq-server

echo "--> Enable chkconfig for RabbitMQ-Server to start on machine boot" 
sudo systemctl enable rabbitmq-server

echo "--> RabbitMQ policy to mirror queues"
#Mirror-all
sudo rabbitmqctl set_policy mirror-all "^[A-Za-z0-9_.]+$" \ '{"ha-mode":"all","ha-sync-mode":"automatic"}'