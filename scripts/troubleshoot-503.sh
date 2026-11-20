#!/usr/bin/env bash
# Partie 4 : diagnostic d'une erreur 503 (de l'extérieur vers l'intérieur).
# Usage : ./troubleshoot-503.sh [nom-app]   (défaut : frontend-app)
APP="${1:-frontend-app}"

echo "== 1. Route =="
oc get route "$APP"

echo "== 2. Endpoints du service (vide => sélecteur sans pod) =="
oc get endpoints "$APP"

echo "== 3. Service : selector et targetPort =="
oc get svc "$APP" -o jsonpath='selector={.spec.selector}{"\n"}targetPort={.spec.ports[*].targetPort}{"\n"}'

echo "== 4. Port d'écoute déclaré dans le Deployment =="
oc get deploy "$APP" -o yaml | grep -i port

echo "== 5. Pods (CrashLoopBackOff ?) =="
oc get pods -l deployment="$APP"

echo "== 6. Derniers événements =="
oc get events --sort-by=.lastTimestamp | tail -n 10

echo "== 7. NetworkPolicies (le routeur est-il autorisé ?) =="
oc get networkpolicies
