#!/bin/sh
#-
# 
# yubikey_lockdown - Adds the Yubikey as a required authentication method for SSH on FreeBSD. 
#
# After the setup, to connect via SSH will require the following:
#
# 	1. SSH public key
#	2. The Yubikey used for the setup
#	3. Password
#
# You can remove the Password option by specifying the -P option
# 
# based on the tutorial from http://mjslabs.com/yubihow.html

# Get the API KEY from: https://upgrade.yubico.com/getapikey/
# Replace the CLIENTID and SECRETKEY strings below with the values from 
# the above site

# default values
USERNAME=vmadmin
TOKEN_ID=cccccc
CLIENTID=1234
SECRETKEY=XXXXXX

usage() {
	echo "usage ${0} [-Pz] [-c clientid] [-s secretkey] [-t tokenid] [-u username]"
}

while getopts "c:hs:t:u:zP" opt; do
	case $opt in
	c)	CLIENTID=${OPTARG} ;;
	h)	usage ; exit 0 ;;
	s)	SECRETKEY=${OPTARG};;
	t)	TOKEN_ID=${OPTARG} ;;
	u)	USERNAME=${OPTARG} ;;
	z)	zflag=1 ;;
	P)	NO_PASSWORD=1 ;;
	*)	usage ; exit 1 ;;
	esac
done
shift $(( $OPTIND - 1 ))

if [ $OPTIND = 1 ]; then
	usage
	exit 0
fi

# This option will have everything in place but it will not restart the OpenSSH
# server - which would otherwise lock the user from the VM.
if [ ${z_flag} ]; then
	echo "using the default values. You will need to replace them later"
fi

yum install -y epel-release \
	&& yum install -y openssh-clients openssh-server pam_yubico
# Move the system version of the sshd PAM file out of the way
cp -a /etc/pam.d/sshd /etc/pam.d/sshd.bak

echo "creating the /etc/pam.d/sshd-yubikey file"

PAM_MOD=requisite
if [ ${NO_PASSWORD} ]; then
	PAM_MOD=sufficient
fi

sed -i \
	"1s!^!auth ${PAM_MOD}  pam_yubico.so id=${CLIENTID} key=${SECRETKEY} authfile=/etc/yubikey_mappings!" /etc/pam.d/sshd  

# Back up our sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.pre-yubikey

# Run sshd_config through sed to change everything we need changed
cat /etc/ssh/sshd_config.pre-yubikey | \
sed  -e 's/^#*IgnoreRhosts .*/#IgnoreRhosts yes @AuthenticationMethods publickey,keyboard-interactive:pam/' \
	-e 's/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication yes/' \
	-e 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' \
	-e 's/^#*UsePAM .*/UsePAM yes/' | tr '@' '\n' > /etc/ssh/sshd_config

echo "creating a central yubikey_mappings file"
cat > /etc/yubikey_mappings << EOF
# In the format of username:tokenID
${USERNAME}:${TOKEN_ID}
EOF

# Do not restart sshd if we are just scafolding
if [ -z ${z_flag} ]; then
	service sshd restart
fi

# Allow traffic to api.yubico.com
setsebool -P authlogin_yubikey on

