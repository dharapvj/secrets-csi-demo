create-kind-cluster:
	kind create cluster --config=./cluster-nodeport.yaml --image kindest/node:v1.27.3

create-kops-cluster:
	./bin/kops.sh -p vj -b vj-1111-vj-kops

deploy-ingress-controller:
# Under Kind use this
#	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/kind/deploy.yaml
# Under KOPS use below
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/cloud/deploy.yaml

# Secret CSI driver things
deploy-secrets-store-csi-driver:
	helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
	helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system -f secrets-csi-installation/values-secrets-csi-driver.yaml

deploy-azure-secret-csi-provider:
	helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
	helm upgrade --install azure-secrets-csi  --namespace kube-system -f secrets-csi-installation/values-azure-secrets-csi-provider.yaml csi-secrets-store-provider-azure/csi-secrets-store-provider-azure
	envsubst < secrets-csi-installation/azure-service-principal.yaml | kubectl apply -f -

deploy-aws-secrets-csi-provider:
	kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

deploy-sealed-secrets-controller:
	helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
	helm upgrade --install sealed-secrets-controller --namespace kube-system --version 2.12.0 sealed-secrets/sealed-secrets
# Bug in sealed-secrets-controller deployment
	kubectl -n kube-system patch svc sealed-secrets-controller --type='json' -p='[{"op": "remove", "path": "/spec/ports/0/name"}, {"op": "replace", "path": "/spec/ports/0/targetPort", "value":8080}]'

deploy-external-secrets-operator:
	helm repo add external-secrets https://charts.external-secrets.io
	helm install external-secrets external-secrets/external-secrets \
		-n external-secrets \
		--create-namespace

seal-the-secret:
	kubectl create secret generic sealed-secret-demo -n default --from-file=./kubeseal-secrets/secret-text.txt --dry-run=client -o yaml | kubeseal -n kube-system -o yaml > ./kubeseal-secrets/sealed-secret.yaml
	
deploy-argo:
	kubectl apply -f ./gitcrypt-key.yaml
	helm upgrade --install argocd --version 5.36.10 --namespace argocd --create-namespace argo/argo-cd -f values-argocd.yaml
	kubectl apply -f ./demo-argocd-apps.yaml

# not required due to Argo
# deploy-demo-app:
# 	kubectl apply -f ./secrets-csi-demo-apps/azure-reader-demo.yaml
# 	kubectl apply -f ./secrets-csi-demo-apps/sa.yaml
# 	kubectl apply -f ./secrets-csi-demo-apps/aws-reader-demo.yaml

delete-kops-cluster:
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/cloud/deploy.yaml
	./bin/kops.sh -p vj -a delete -b vj-1111-vj-kops
