#!/usr/bin/env bash
# Partie 1 : résolution DNS interne frontend -> backend.
set -euo pipefail
oc rsh deployment/frontend-app curl -s --max-time 5 http://backend-api:8080
