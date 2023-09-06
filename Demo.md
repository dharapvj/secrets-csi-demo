# Demo Running Steps

## Setup
```shell
make create-kops-cluster
make deploy-ingress-controller deploy-secrets-store-csi-driver deploy-azure-secret-csi-provider deploy-aws-secrets-csi-provider deploy-sealed-secrets-controller 

make deploy-demo-app
# find loadbalancer DNS
k get svc -A | grep Load
```

Wait for ingress to be ready..

Access http://<lb-dns>/reader/
Access http://<lb-dns>/reader-aws/

## Cleanup
k delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/cloud/deploy.yaml
make delete-kops-cluster