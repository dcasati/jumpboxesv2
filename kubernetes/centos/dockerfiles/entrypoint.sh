#!/bin/bash 

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

mkdir -p {/var/run/sshd,/root/.ssh/,/etc/yubikey} \
    && touch /root/.ssh/authorized_keys

chmod 0744 /root/.ssh/

CLIENT_ID=$(cat /etc/yubikey/client_id)
YUBI_SECRET=$(cat /etc/yubikey/secretkey)

sed -i \
    "1s!^!auth sufficient pam_yubico.so id=${CLIENT_ID} key=${YUBI_SECRET} authfile=/etc/yubikey/yubikey_mappings!" /etc/pam.d/sshd

sed -i \
    "s/PermitRootLogin prohibit-password/PermitRootLogin yes/;  \
    s/^#*PasswordAuthentication .*/PasswordAuthentication no/; \
    s/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication yes/;  \
    s/^#*IgnoreRhosts.*/AuthenticationMethods publickey,keyboard-interactive:pam/; \
    s/^#*UsePAM .*/UsePAM yes/" /etc/ssh/sshd_config

/usr/sbin/sshd -D
