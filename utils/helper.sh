
tester_to_ccu() {
  tester=$1
  echo "$tester" | sed 's/tester-//'
}


tester_validate() {
  tester=$1
  # validate tester
  if ! grep -q $(tester_to_ccu $tester) /qatools/share/board_info.json; then
    return 255
  else
    return 0
  fi
}

get_password() {
  # NOTE: keyring is not installed in builder(specifically, its backend - dbus). If it supports, could be improved
  key_filepath=~/.hello/key
  if [ -f $key_filepath ]; then
    pw=$(cat $key_filepath)
  else
    read -s -p "Please input your password(Or create ~/.hello/key with your password): " pw
    mkdir -p $(dirname "$key_filepath")
    echo ${pw} > $key_filepath
  fi
  echo $pw
}

tester_port_forwarding() {

  # Params
  host=$1
  src_port=$2 # builder is going to connect
  tgt_port=$3 # tester is going to connect

  id=$(whoami)
  target=$id@$host
  execute="ssh $target"

  # sshd config change to allow accesssing from external
  config=/etc/ssh/sshd_config
  if $execute "grep -qE \"#AllowTcpForwarding no|#GatewayPorts no\" $config";then
    echo "Editing sshd_config"
    rule_1='s/#AllowTcpForwarding yes/AllowTcpForwarding yes/'
    $execute "sudo sed -i \"$rule_1\" $config"
    rule_2='s/#GatewayPorts no/GatewayPorts yes/'
    $execute "sudo sed -i \"$rule_2\" $config"
    echo "Restart sshd"
    $execute "sudo systemctl restart sshd"
  fi

  # port forwarding
  if ! $execute "sudo netstat -tunlp | grep -q $src_port"; then
    echo "Port Forwarding from a tester:${src_port} to a ccu:${tgt_port}"
    $execute "ssh-keygen -qR localhost; ssh-keyscan localhost >> ~/.ssh/known_hosts 2>/dev/null"
    $execute "ssh -fN -R 0.0.0.0:$src_port:10.0.6.0:$tgt_port localhost"
  fi
}


# add ccu info
ssh_register_host_if_not_exist() {
  host=$1
  host_name=$2
  port=$3
  ssh_conf_file=~/.ssh/config

  if grep -q $host_name $ssh_conf_file; then
    return
  fi

  echo -e "\nHost $host_name" >> $ssh_conf_file
  echo    "    HostName $host" >> $ssh_conf_file
  echo    "    Port $port" >> $ssh_conf_file
}


ssh_key_filepath=~/.ssh/id_rsa

ssh_create_key_if_not_exist() {
  if [ -f ${ssh_key_filepath} ]; then
    return
  fi

  echo "Creating ssh key pair..."
  ssh-keygen -t rsa -b 4096 -f "${ssh_key_filepath}" -n ""
}

ssh_register_known_host() {
  host=$1
  # Register an authorized tester from builder.
  ssh-keygen -q -R $host &>/dev/null
  ssh-keyscan $host >> ~/.ssh/known_hosts 2>/dev/null
}

ssh_validate_authentication_from() {
  host=$1
  ssh -o PasswordAuthentication=no -q $host exit
}

ssh_copy_id_if_not_exist() {
  host=$1

  ssh_validate_authentication_from $host
  if [ $? -eq 0 ];then
    return
  fi

  # register pub key as authorized
  echo "Register curret public id..."
  ssh-copy-id -f ${id}@$host
}

ssh_copy_key_pair_if_not_exist() {
  host=$1

  # Assume that ssh key pairs are already copied if we could connect
  ssh_validate_authentication_from $host
  if [ $? -eq 0 ];then
    return 0
  fi

  sshpass="sshpass -p $(get_password)"
  id=$(whoami)
  target=$id@$host

  echo "Overriding ssh key pair in the $host"
  $sshpass scp -r ~/.ssh $target:~/
}
