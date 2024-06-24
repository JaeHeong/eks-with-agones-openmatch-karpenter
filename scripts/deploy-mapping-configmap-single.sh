## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0
# set -o xtrace
CLUSTER_NAME_1=$1
ACCELERATOR_1=$2

ACCELERATOR_1_DNS=$(aws globalaccelerator describe-custom-routing-accelerator --region us-west-2 --accelerator-arn $ACCELERATOR_1 --query Accelerator.DnsName --output text)

aws globalaccelerator list-custom-routing-port-mappings --region us-west-2  --accelerator-arn $ACCELERATOR_1  --query 'PortMappings[].[AcceleratorPort,DestinationSocketAddress.IpAddress,DestinationSocketAddress.Port]' | jq -c '.[] | {key: "\(.[1]):\(.[2] | tostring)", value: .[0]}' | jq -s 'from_entries' | gzip > mapping1.gz

kubectl config use-context $(kubectl config get-contexts -o=name | grep ${CLUSTER_NAME_1})
kubectl delete configmap global-accelerator-mapping --namespace agones-openmatch
kubectl create configmap global-accelerator-mapping --namespace agones-openmatch --from-file=mapping1.gz --from-literal=accelerator1="$ACCELERATOR_1_DNS"
rm mapping1.gz