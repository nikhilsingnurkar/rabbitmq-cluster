#! /bin/bash

source ./config.sh
set -e
q=0

# Read master rabbitmq host
RM=$(sshpass -p $PASS ssh -t -q $TARGET_USER@${LIST_TARGET_NODES[0]} "hostname")
echo -e "RABBIT_MASTER=\"$RM\"" >> ./config.sh
tr -d '\015' <config.sh >file2
mv file2 config.sh
chmod +x config.sh

for TARGET_IP in $LIST_TARGET_IP
do

  sshpass -p $PASS scp -o StrictHostKeyChecking=no "./$SCRIPT_CONFIG" $TARGET_USER@$TARGET_IP:$SCRIPT_PATH
  sshpass -p $PASS scp -o StrictHostKeyChecking=no "./$SCRIPT" $TARGET_USER@$TARGET_IP:$SCRIPT_PATH
  sshpass -p $PASS ssh -t -q $TARGET_USER@$TARGET_IP "cd $SCRIPT_PATH && sh $SCRIPT"

done

for (( node=1; node<${#LIST_TARGET_NODES[@]}; node++ ))
do
  # echo "${LIST_TARGET_NODES[$node]}" 
  sshpass -p $PASS scp -o StrictHostKeyChecking=no "./$SCRIPT_CONFIG" $TARGET_USER@${LIST_TARGET_NODES[$node]}:$SCRIPT_PATH
  sshpass -p $PASS scp -o StrictHostKeyChecking=no "./$SCRIPT_CLUSTER" $TARGET_USER@${LIST_TARGET_NODES[$node]}:$SCRIPT_PATH
  sshpass -p $PASS ssh -t -q $TARGET_USER@${LIST_TARGET_NODES[$node]} "cd $SCRIPT_PATH && sh $SCRIPT_CLUSTER"


done