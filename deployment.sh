#!/usr/bin/env bash

################################################################################
### Script deploying environment for the OTEL training
###
################################################################################
###########################################################################################################
####  Required Environment variable :
#### ENVIRONMENT_URL=<with your environment URL (with'https'). Example: https://{your-environment-id}.live.dynatrace.com> or {your-domain}/e/{your-environment-id}
#### API_TOKEN : api token with the following right : metric ingest, trace ingest, and log ingest and Access problem and event feed, metrics and topology
#### BASTION_USER: linux user created for the bastion  host
#### K3D: if parameter is not passed then the deployment will happen in k3d
#########################################################################################################
### Pre-flight checks for dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "Please install jq before continuing"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Please install git before continuing"
    exit 1
fi


if ! command -v helm >/dev/null 2>&1; then
    echo "Please install helm before continuing"
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Please install kubectl before continuing"
    exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
  --environment-url)
    ENVIRONMENT_URL="$2"
    shift 2
    ;;
  --api-token)
    API_TOKEN="$2"
    shift 2
    ;;
  --k3d)
    GITCLONE="$2"
    shift 2
    ;;
  *)
    echo "Warning: skipping unsupported option: $1"
    shift
    ;;
  esac
done

if [ -z "$ENVIRONMENT_URL" ]; then
  echo "Error: environment-url not set!"
  exit 1
fi

if [ -z "$API_TOKEN" ]; then
  echo "Error: api-token not set!"
  exit 1
fi



if [ -z "$GITCLONE" ]; then
  GITCLONE=1
fi

################################################################################
### Clone repo
#if [ $GITCLONE -eq 1];
#then
#  git clone https://github.com/henrikrexed/ACE_OTEL_SCRIPT
#  cd ACE_OTEL_SCRIPT
#  K3d_mode=0
  #TODO add the provisionning of the cluster here

#else
#  echo "-- Bringing up a k3d cluster --"
#  k3d cluster create observeK8s --config=/root/k3dconfig.yaml --wait
#  K3d_mode=1
  # Add sleep before continuing to prevent misleading error
#  sleep 10

#  echo "-- Waiting for all resources to be ready (timeout 2 mins) --"
#  kubectl wait --for=condition=ready pods --all --all-namespaces --timeout=2m
#fi


### Depploy Prometheus
echo "start depploying Prometheus"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --set sidecar.datasources.enabled=true --set sidecar.datasources.label=grafana_datasource --set sidecar.datasources.labelValue="1" --set sidecar.dashboards.enabled=true
##wait that the prometheus pod is started
kubectl wait pod --namespace default -l "release=prometheus" --for=condition=Ready --timeout=2m
PROMETHEUS_SERVER=$(kubectl get svc -l app=kube-prometheus-stack-prometheus -o jsonpath="{.items[0].metadata.name}")
echo "Prometheus service name is $PROMETHEUS_SERVER"
GRAFANA_SERVICE=$(kubectl get svc -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}")
echo "Grafana service name is  $GRAFANA_SERVICE"
ALERT_MANAGER_SVC=$(kubectl get svc -l app=kube-prometheus-stack-alertmanager -o jsonpath="{.items[0].metadata.name}")
echo "Alertmanager service name is  $ALERT_MANAGER_SVC"
sed -i "s,PROM_SVC_TO_REPLACE,$PROMETHEUS_SERVER," exercice/auto-instrumentation/k8Sdemo-nootel.yaml

#### Deploy the cert-manager
echo "Deploying Cert Manager ( for OpenTelemetry Operator)"
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
# Wait for pod webhook started
kubectl wait pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --for=condition=Ready --timeout=2m
# Deploy the opentelemetry operator
echo "Deploying the OpenTelemetry Operator"
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

#Deploy the OpenTelemetry Collector
echo "Deploying Otel Collector"
kubectl apply -f kubernetes-manifests/rbac.yaml
sed -i "s,DT_TENANT_URL,$ENVIRONMENT_URL," kubernetes-manifests/openTelemetry-manifest.yaml
sed -i "s,DT_TOKEN,$API_TOKEN," kubernetes-manifests/openTelemetry-manifest.yaml
#wait for the opentelemtry operator webhook to start
kubectl wait pod --namespace default -l app.kubernetes.io/name=opentelemetry-operator -n  opentelemetry-operator-system --for=condition=Ready --timeout=2m
#Deploy demo Application
echo "Deploying Hipstershop"
kubectl create ns hipster-shop
kubectl apply -f kubernetes-manifests/openTelemetry-sidecar.yaml -n hipster-shop
kubectl apply -f kubernetes-manifests/K8sdemo.yaml -n hipster-shop

# Echo environ*
echo "========================================================"
echo "Environment fully deployed "
echo "Online Boutique url: http://demo.$IP.nip.io"
echo "========================================================"


