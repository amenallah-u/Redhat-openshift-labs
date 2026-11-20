# Architecture détaillée

## Objets Kubernetes / OpenShift créés

| Objet | Nom | Source |
|---|---|---|
| Deployment | backend-api, frontend-app | manifests/01-apps |
| Service (ClusterIP) | backend-api, frontend-app | manifests/01-apps |
| Route (edge) | frontend-app | manifests/02-routes |
| NetworkPolicy | deny-by-default, allow-frontend-to-backend, allow-from-openshift-ingress (optionnelle) | manifests/03-networkpolicies |

## Chaîne de résolution d'une requête externe

1. Le client résout le host de la route vers l'IP du routeur (wildcard `*.apps.<cluster>`).
2. Le routeur HAProxy termine le TLS (Edge) puis sélectionne la Route via l'en-tête SNI/Host.
3. Le routeur envoie la requête en HTTP vers les IP des Endpoints du Service frontend-app, port 8080.
4. Le pod frontend-app répond.

Une erreur 503 apparaît quand l'étape 3 échoue : Endpoints vides, mauvais targetPort, pods en échec ou trafic bloqué par une NetworkPolicy.

## Chaîne d'une requête interne frontend vers backend

1. Le pod frontend interroge CoreDNS pour `backend-api`.
2. CoreDNS répond avec le ClusterIP du Service (`backend-api.<projet>.svc.cluster.local`).
3. Le trafic est traduit vers l'IP du pod backend (Endpoints) par le réseau du cluster (OVN-Kubernetes).
4. La NetworkPolicy `allow-frontend-to-backend` autorise le flux car le pod source porte `app=frontend-app`.

## Labels et sélecteurs

| Objet | Sélecteur | Cible |
|---|---|---|
| Service backend-api | `deployment: backend-api` | pods du Deployment backend-api |
| Service frontend-app | `deployment: frontend-app` | pods du Deployment frontend-app |
| NetworkPolicy allow-frontend-to-backend (cible) | `app: backend-api` | pods backend |
| NetworkPolicy allow-frontend-to-backend (source) | `app: frontend-app` | pods frontend |

Les NetworkPolicies utilisent le label `app`, les Services utilisent le label `deployment`. Un pod sans le bon label est invisible pour la règle correspondante.
