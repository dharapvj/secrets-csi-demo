#! /bin/bash
# Step 1: install kops CLI by following https://kops.sigs.k8s.io/getting_started/install/

# USAGE:
# ./kops.sh -p AWS_PROFILE_NAME -b S3_BUCKET -a ACTION -n CLUSTER_NAME (optional. Name of the cluster)
# Mandatory params:
# -p AWS_PROFILE_NAME = Name of AWS profile to connect to AWS
# -b BUCKET_NAME = AWS S3 bucket's name
# 
# Optional params:
# -a ACTION = What do you want to do? 
#       all - start from creation of s3 bucket
#       default - skip s3 bucket creation
#       delete - deletes the kops cluster
# -n CLUSTER_NAME = Name of the kops cluster. must end in k8s.local
#
# e.g ./kops.sh -p vj -n vj.k8s.local -b newbucket1234 -a all

set +x

while getopts p:a:n:b: flag
do
    case "${flag}" in
        p) profile=${OPTARG};;
        a) action=${OPTARG};;
        n) name=${OPTARG};;
        b) bucket=${OPTARG};;
    esac
done

# FIXME - comment out
# bucket=vj-1111-vj-kops
# if action is skipped - use default
if [ -z $bucket ]; then
  echo bucket must be provided. Bucket name must be globally unique
  exit 1
fi

# if action is skipped - use default
if [ -z $action ]; then
  echo action not provided. Assuming default action of installing kops cluster
  action="default"
fi
if [ -z $name ]; then
  echo Cluster name not provided. using kopsdemo.k8s.local
  name="kopsdemo.k8s.local"
fi

printf "\nProvided Params:\n------------------\n";
echo "AWS Profile: $profile";
echo "Action: $action";
echo "Cluster Name: $name";
echo "s3 bucket name: $bucket";
printf "\n";

# Step 2: Only one time
export AWS_PROFILE=${profile}
export KOPS_CLUSTER_NAME=kopsdemo.k8s.local

if [[ $action == "all" ]]; then
    echo running $action
    aws s3api create-bucket --bucket $bucket --region us-east-1 --no-cli-pager
    aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled  --no-cli-pager
else
    # export KOPS_STATE_STORE=s3://vj-1111-vj-kops
    export KOPS_STATE_STORE=s3://$bucket
fi


# # Step 1: Every time you want to install KOPS cluster
if [[ $action == "all" ||  $action == "default" ]]; then
    printf "Install kops cluster!\n"
    kops replace --force -f ./kops/cluster.yaml
    kops create secret --name ${KOPS_CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub
    kops update cluster --yes --admin
    kops validate cluster --wait 10m
fi

# # Step 4: Now use this cluster for ingress learning

if [[ $action == "delete" ]]; then
# # Step 5: destroy KOPS cluster
    kops delete cluster --name ${KOPS_CLUSTER_NAME} --yes
fi