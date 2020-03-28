# Adding storage to DB

Since `listmonk` relies on Postgres as it's storage backend to store email campaigns data, subscriber details, etc we need to attach a Persistent Volume to the pod running the DB. Many cloud providers have plugins baked in the storage provisioner (mentioned via StorageClass) but since we are doing a local deployment, we will make use of `hostpath provisioner` to create storage backed by the node on which the pod is running:

```yml
# vim base/add-db-volume.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-storage
  labels:
    app.kubernetes.io/component: storage
spec:
  storageClassName: microk8s-hostpath
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

And like always, let's add this to the inventory:

```yml
# vim base/kustomization.yml
resources:
- add-db-volume.yml
```
