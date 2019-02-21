# Assorted collection of jumpboxes

Goal: To provide an easy, go to selection, of jumpboxes with the bare minimum on them.

TL;DR: These are *NIX VMs or images (for Kubernetes) with ssh access locked to use:

1. A public key
1. MFA such as an Yubikey
1. Password (optional)

Every file that makes the solution are here, including the Dockerfiles for the images,
and they should serve as a base for further experimentation. 

I encourage you to clone this repo and the examples here. All of the commands below will
be referenced in relation to the base cloned directory.

## Virtual Machines

Currently available VMs:

| Operating System | Version |
| - | - |
| FreeBSD | 11.1 |

### Using MFA - Yubikey

Here are the steps needed:

1. Go to https://upgrade.yubico.com/getapikey/ and grab an API key.

  1. Open the `yubikey.tfvars` file and add the following:
  1. Save the `Client ID` to the `client_id` variable
  1. Save the `Secret key` to the `secretkey` variable
  1. Press your Yubikey, and copy the first 12 characters from there.
save the output into `token_id` variable.**

** You can also do this on a terminal:

```bash
$ token_id_base=[press your YUBIKEY now]
$ echo $token_id_base | cut -c '1-12'
```

## Kubernetes

Currently there are two options: CentOS 7 and Ubuntu 16.04.

### Using MFA - Yubikey

Here are the steps needed:

1. Go to https://upgrade.yubico.com/getapikey/ and grab an API key.
  1. Save the `Client ID` to the `yubikeyfiles/client_id` file
  1. Save the `Secret key` to the `yubikeyfiles/secretkey` file
  1. On a text editor, press your Yubikey, and copy the first 12 characters from there.
save the output into `yubikeyfiles/token_id`.**
  1. Open `yubikeyfiles/yubikey_mappings` file and substitute the token_id there.

** You can also do this on a terminal:

```bash
$ token_id_base=[press your YUBIKEY now]
$ token_id=$(echo $token_id_base | cut -c '1-12' | tee yubikeyfiles/token_id)
$ echo root:$token_id > yubikeyfiles/yubikey_mappings
```

### Sharing the files with Kubernetes Secret 

Create the secret to hold the Yubikey files:

```bash
kubectl create secret generic yubikey-secrets --from-file=./yubikeyfiles
```  

We also need to authorize our public key. For that, do the following:

```bash
kubectl create secret generic ssh-key-secret --from-file=authorized_keys=/home/${USER}/.ssh/id_rsa.pub
```

### Deploy to Kubernetes and test

```bash
kubectl apply -f deployment.yaml
```
Finally, test by connecting to the jumpbox with ssh:

1. Identify the LoadBalancer public IP
    ```bash
    $ kubectl get svc                                            
    NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
    jumpbox-loadbalancer   LoadBalancer   10.0.206.249   52.168.90.84   22:31535/TCP   4h
    kubernetes             ClusterIP      10.0.0.1       <none>         443/TCP        4d
    ```
1. Connect

    ```bash
    $ ssh root@52.168.90.84
    YubiKey for `root':		[PRESS YOUR YUBIKEY HERE]
    Last login: Thu Apr 12 21:33:50 2018 from gateway
    [root@centos-jumpbox ~]#
    ```
