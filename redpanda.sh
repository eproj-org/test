#!/bin/bash
k3d cluster create --k3s-arg "--disable=traefik@server:0" -a 2
helm repo add redpanda https://charts.redpanda.com
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager  --set installCRDs=true --namespace cert-manager  --create-namespace

helm upgrade --install redpanda redpanda/redpanda  --namespace redpanda  --create-namespace -f redpanda/values.yaml

kubectl config set-context --current --namespace='redpanda'
kubectl cp redpanda-0:/etc/tls/certs/external/..data/ca.crt ../python-getting-started/ca.crt
