#!/usr/bin/env bash

LINE="----------------------------------------------------------
"

run() { 
	echo "\$ $@"; 
	"$@";
}

# check if jq is installed
jq_flag=$(which jq)

if [ -z ${jq_flag} ]; then
        echo "jq not found. Please install it first"
fi

usage() {
        echo "usage  [[-s] SUBSCRIPTION]"
        exit 1
}

while getopts "s:" opt; do
        case $opt in
        s)      SUBSCRIPTION_ID=${OPTARG};;
        *)      usage;;
        esac
done
shift $((OPTIND-1))

if [ -z ${SUBSCRIPTION_ID} ]; then
        usage
fi

echo "Setting up the subscription"
echo $LINE
run az account set --subscription="${SUBSCRIPTION_ID}"

CREDENTIALS=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}")

echo "Setting environment variables for Terraform"
echo $LINE

cat > terraform.rc << EOF
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_CLIENT_ID=$(echo $CREDENTIALS | jq .appId)
export ARM_CLIENT_SECRET=$(echo $CREDENTIALS | jq .password)
export ARM_TENANT_ID=$(echo $CREDENTIALS | jq .tenant)
EOF

cat > sp.tfvars << EOF
arm_client_id=$(echo $CREDENTIALS | jq .appId)
arm_client_secret=$(echo $CREDENTIALS | jq .password)
EOF

run source terraform.rc

echo "Here are the Terraform environment variables for your setup"
echo $LINE
cat terraform.rc
echo $LINE
echo "Setup is done. Your Terraform variables were saved on the terraform.rc file."
echo $LINE
echo "The file sp.tfvars contains Service Principal credentials. This can be used at later deployments by passing the `-var-file` flag to `terraform`."
