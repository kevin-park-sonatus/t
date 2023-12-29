#!/bin/bash

# set -x

source ./utils/helper.sh

tester=$1

# Validate
tester_validate $tester
if [ $? -ne 0 ];then
  echo Error. Invalid tester name. tester=$tester, status=$?
  exit
fi

ssh_validate_authentication_from $tester
if [ $? -ne 0 ];then
  echo Error. Not yet ready to connect to $tester.
  echo Please do \"hello_tester.sh $tester\".
  exit
fi

# To access from builder to ccu, tester fowards one of port to 22 port of ccu
ssh_port=13408
tester_port_forwarding $tester $ssh_port 22

# Add host info of ccu to ~/.ssh/config
ccu=$(tester_to_ccu $tester)
ssh_register_host_if_not_exist $ccu $tester $ssh_port

# Report
echo Done. You can now access to the $ccu.
echo Try \"ssh root@$ccu\"
exit

