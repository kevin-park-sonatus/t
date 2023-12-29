
Sonatus houses multiple tester machines within its infrastructure. This project offers various utilities designed to simplify the management of each machine. Presently, it supports two utilities:

- hello_tester
- hello_ccu


# Hello Tester
The hello_tester script facilitates the copying of the builder's SSH key pair to the tester machine. Once this setup is completed, accessing the tester machine becomes password-free.

Sharing a public key provides a convenient advantage when cloning from GitHub. You no longer need to register additional public keys for each tester on GitHub.

## Example
```
./hello_tester.sh ccu2-tester-27
```

# Hello CCU
The `hello_ccu.sh` script establishes a connection to the CCU board using SSH port forwarding. Additionally, it registers a new hostname, `ccu2-27`, in ~/.ssh/config, enabling straightforward access to the CCU board.

## Example
```
./hello_ccu.sh ccu2-tester-27

ssh root@ccu2-27
scp foo.txt root@ccu2-27:/tmp
```
