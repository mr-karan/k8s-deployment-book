# Creating a Job

`listmonk` requires us to do the DB migrations before the app can run. The DB migrations are responsible for loading the schema in the Postgres database. Since this is a _one-off_ task, Kubernetes provides a way to run such tasks by creating a `Job` object.

Since at the time of writing this guide `kubekutr` doesn't have support for `Jobs`/`CronJobs`, we can create a raw resource ourselves.

```yml
# vim base/add-db-migration.yml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-init
spec:
  template:
    spec:
      containers:
      - name: listmonk-db-init
        image: localhost:32000/listmonk:0.5
        command: [sh, -c, "yes | ./listmonk --install"]
        envFrom:
          - secretRef:
              name: app-secrets
      restartPolicy: Never
  backoffLimit: 5
  ttlSecondsAfterFinished: 10
  activeDeadlineSeconds: 100
```

When the Job object is applied to the cluster, a `Pod` is created. Just like how `Deployment` targets the Pod with ReplicaSet, `Job` manages the state of the `Pod`. Retry for a job or parallel scheduling can all be controlled with the `Job` spec about which you can read more [here](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).

Every time we add a resource, we must remember to add it to our inventory, which is defined in `kustomization.yml`.

```yml
# vim base/kustomization.yml
resources:
...
- add-db-migration.yml
...
```

Since this resource is now added to our inventory, all our _customisations_ will be applied to the `Job` object as well.

> **Note**: Always remember to add resources to `kustomization.yml` file to keep your inventory up to date. Not doing so, would mean that those resources would be skipped out when building the manifests.
