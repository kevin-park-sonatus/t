#!/usr/bin/bash

# To debug this script, Uncomment the below line.
# echo "Debugging..."
# set -x

# Includes helper
source ./utils/helper.sh

# Paramenter
tester=$1

# Validate
tester_validate $tester
if [ $? -ne 0 ];then
  echo Error. Invalid tester name. tester=$tester, status=$?
  exit
fi

# Setup builder ssh key.
ssh_create_key_if_not_exist
ssh_register_known_host localhost
ssh_copy_id_if_not_exist localhost

# Register an authorized tester from builder.
ssh_register_known_host $tester

# Copy ssh key pair to tester
ssh_copy_key_pair_if_not_exist $tester
if [ $? -ne 0 ];then
  echo Error. Can not finish greeting. tester=$tester, status=$?
  exit
fi

echo Done. You can now access to the $tester without password.
echo Try \"ssh $(whoami)@$tester\"


