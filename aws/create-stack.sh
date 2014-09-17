#!/bin/bash

# From https://github.com/emmanuel/coreos-skydns-cloudformation
SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )

STACK_NAME=${1:-"CoreOS-test-$RANDOM"}
STACK_DISCOVERY_URL=${2:-`curl -s https://discovery.etcd.io/new`}
STACK_INSTANCE_TYPE=${3:-m3.medium}
STACK_CLUSTER_SIZE=${4:-3}
STACK_KEY_PAIR=${5:-coreoscluster01}

aws ec2 describe-key-pairs --key-names $STACK_KEY_PAIR > /dev/null 2>&1 || \
  echo "Keypair $STACK_KEY_PAIR does not exit." && exit 1

echo "Creating CloudFormation Stack with these parameters:"
echo "Name: $STACK_NAME"
echo "Discovery URL: $STACK_DISCOVERY_URL"
echo "Instance Type x Cluster Size: $STACK_INSTANCE_TYPE x $STACK_CLUSTER_SIZE"
echo "EC2 Key Pair: $STACK_KEY_PAIR"

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/cloudformation-template.json \
  --parameters \
    "ParameterKey=InstanceType,ParameterValue=$STACK_INSTANCE_TYPE,UsePreviousValue=false" \
    "ParameterKey=ClusterSize,ParameterValue=$STACK_CLUSTER_SIZE,UsePreviousValue=false" \
    "ParameterKey=DiscoveryURL,ParameterValue=$STACK_DISCOVERY_URL,UsePreviousValue=false" \
    "ParameterKey=AdvertisedIPAddress,ParameterValue=private,UsePreviousValue=false" \
    "ParameterKey=AllowSSHFrom,ParameterValue=0.0.0.0/0,UsePreviousValue=false" \
    "ParameterKey=KeyPair,ParameterValue=$STACK_KEY_PAIR,UsePreviousValue=false"
