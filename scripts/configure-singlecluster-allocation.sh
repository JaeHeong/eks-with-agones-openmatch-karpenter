## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: MIT-0
set -o xtrace
export CLUSTER1=$1
export ROOT_PATH=$3
kubectl config use-context $(kubectl config get-contexts -o=name | grep ${CLUSTER1})
export ALLOCATOR_IP_CLUSTER1=$(kubectl get services agones-allocator -n agones-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
kubectl apply -f ${ROOT_PATH}/manifests/multicluster-allocation-1.yaml
