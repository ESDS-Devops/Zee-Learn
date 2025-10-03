#!/bin/bash

BACKUP_DIR="k8s-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

# Get all namespaces
kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' > $BACKUP_DIR/namespaces.txt

# Backup each namespace separately
for ns in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
    echo "Backing up namespace: $ns"
    mkdir -p $BACKUP_DIR/$ns
    
    # Get all resource types in the namespace
    for resource in $(kubectl api-resources --namespaced=true -o name); do
        echo "  Backing up $resource"
        kubectl get $resource -n $ns -o yaml > $BACKUP_DIR/$ns/$resource.yaml 2>/dev/null
    done
done

# Backup cluster-wide resources
echo "Backing up cluster-wide resources"
mkdir -p $BACKUP_DIR/cluster-wide
for resource in $(kubectl api-resources --namespaced=false -o name); do
    echo "  Backing up $resource"
    kubectl get $resource -o yaml > $BACKUP_DIR/cluster-wide/$resource.yaml 2>/dev/null
done

echo "Backup completed in directory: $BACKUP_DIR"
