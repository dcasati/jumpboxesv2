#!/bin/sh
touch /firstboot

cat <<EOF >> /usr/local/etc/rc.d/firstboot
pkg install -y bash socat rust

git clone https://github.com/square/sudo_pair.git
cd sudo_pair
cargo build --release

# modify the stat flags for FreeBSD
sed -i.bak  's/stat -c/stat -f/g' ./sample/bin/sudo_approve

# prepare sudo.conf for FreeBSD
sed '$d' ./sample/etc/sudo.conf
echo "Plugin sudo_pair libsudo_pair.so binary_path=/usr/local/bin/sudo_approve user_prompt_path=/usr/local/etc/sudo.prompt.user pair_prompt_path=/usr/local/etc/sudo.prompt.pair" >> ./sample/etc/sudo.conf

# WARNING: these files may not be set up in a way that is suitable
# for your system. Proceed only on a throwaway host.

# install the plugin shared library
install -o 0 -g 0 -m 0644 ./target/release/libsudo_pair.so /usr/local/libexec/sudo

# create a socket directory
install -o 0 -g 0 -m 0644 -d /var/run/sudo_pair

# install the approval script; as currently configured, it denies access
# to users approving their own sudo session and may lock you out
install -o 0 -g 0 -m 0755 ./sample/bin/sudo_approve /usr/local/bin/sudo_approve

# your /etc/sudo.conf may already have entries necessary for sudo to
# function correctly; if this is the case, the two files will need to be
# merged
install -o 0 -g 0 -m 0644 ./sample/etc/sudo.conf /usr/local/etc/sudo.conf

# if these prompts don't work for you, they're configurable via a simple
# templating language explained later in the README
install -o 0 -g 0 -m 0644 ./sample/etc/sudo.prompt.user /usr/local/etc/sudo.prompt.user
install -o 0 -g 0 -m 0644 ./sample/etc/sudo.prompt.pair /usr/local/etc/sudo.prompt.pair
reboot
EOF
