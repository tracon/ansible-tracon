#!/bin/bash
set -xueo pipefail

DOCKERCONFIGJSON="$(kubectl get secret -o json con2-harbor | jq -r '.data.".dockerconfigjson"')"

kubectl apply -f - << ENOYAML
apiVersion: v1
kind: Namespace
metadata:
  name: $1
ENOYAML

kubectl apply -n "$1" -f - << ENOYAML
apiVersion: v1
kind: Secret
type: kubernetes.io/dockerconfigjson
metadata:
  name: con2-harbor
data:
  .dockerconfigjson: $DOCKERCONFIGJSON
ENOYAML

kubectl patch serviceaccount default -n "$1" -p '{"imagePullSecrets": [{"name": "con2-harbor"}]}'