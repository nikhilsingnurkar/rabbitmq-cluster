#!/bin/bash

source ./config.sh
hostname=$(hostname -s)
host_ip=$(hostname -I)

echo "--> stop RabbitMQ app"
sudo rabbitmqctl stop_app

echo "--> Reset RabbitMQ app"
sudo rabbitmqctl reset

echo "--> Add node to cluster"
sudo rabbitmqctl join_cluster rabbit@$RABBIT_MASTER

echo "--> Start RabbitMQ app"
sudo rabbitmqctl start_app

echo "--> RabbitMQ Cluster Status"
sudo rabbitmqctl cluster_status
