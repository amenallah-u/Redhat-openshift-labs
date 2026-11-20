#!/usr/bin/env bash
# Déploie les apps, la route Edge et les NetworkPolicies de base.
set -euo pipefail
cd "$(dirname "$0")/.."

oc apply -f manifests/01-apps/
oc rollout status deployment/backend-api --timeout=120s
oc rollout status deployment/frontend-app --timeout=120s
oc apply -f manifests/02-routes/
oc apply -f manifests/03-networkpolicies/01-deny-by-default.yaml
oc apply -f manifests/03-networkpolicies/02-allow-frontend-to-backend.yaml

echo "Route : $(oc get route frontend-app -o jsonpath='{.spec.host}')"
