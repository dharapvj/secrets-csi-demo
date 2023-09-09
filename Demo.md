# Demo Running Steps

## Setup
```shell
make create-kops-cluster
make deploy-ingress-controller deploy-secrets-store-csi-driver deploy-azure-secret-csi-provider deploy-aws-secrets-csi-provider deploy-sealed-secrets-controller deploy-external-secrets-operator deploy-argo

make seal-the-secret
# find loadbalancer DNS
k get svc -A | grep Load
```


Wait for ingress to be ready..

Access Apps:
```
http://<lb-dns>/plain/
http://<lb-dns>/gitcrypt/
http://<lb-dns>/sealed-secrets/
http://<lb-dns>/external-secrets/
http://<lb-dns>/reader/
http://<lb-dns>/reader-aws/
```

## Cleanup
make delete-kops-cluster
