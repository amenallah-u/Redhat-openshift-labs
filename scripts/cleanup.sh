#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
oc delete -f manifests/03-networkpolicies/ --ignore-not-found
oc delete -f manifests/02-routes/ --ignore-not-found
oc delete -f manifests/01-apps/ --ignore-not-found
