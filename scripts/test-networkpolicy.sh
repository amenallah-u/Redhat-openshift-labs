#!/usr/bin/env bash
# Partie 3 : le frontend doit joindre le backend, un pod tiers non.
set -uo pipefail

echo "[1] frontend-app -> backend-api (attendu : succès)"
oc rsh deployment/frontend-app curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 5 http://backend-api:8080 \
  || echo "ECHEC"

echo "[2] pod tiers -> backend-api (attendu : timeout)"
oc run tiers --image=quay.io/redhattraining/hello-world-nginx:latest --restart=Never \
  --command -- sleep 300 >/dev/null 2>&1
oc wait --for=condition=Ready pod/tiers --timeout=60s >/dev/null
if oc exec tiers -- curl -s -o /dev/null --max-time 5 http://backend-api:8080; then
  echo "ATTENTION : trafic non bloqué"
else
  echo "Bloqué (OK)"
fi
oc delete pod tiers --now >/dev/null
