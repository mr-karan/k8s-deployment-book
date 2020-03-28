# Deploying our App

## A quick recap

Let's take a moment to recap the things we have covered so far.

- Created a base manifest using `kubekutr`.
- Applied patches to the base for configuring the volume mount.
- Created overlays for `local` environment with `kustomize`.
- Used `configMapGenerator` and `secretGenerator` to create these native objects from raw resources.

We are pretty close to a full-fledged deployment of Listmonk. A few more things that we need to cover:

- [Creating a Job](./05_01_Deploying_Job.md): `Job` object helps us to run one-off tasks like DB Migrations, pulling assets from S3, etc.
- [Adding Persistent storage](./05_02_Deploying_Storage.md): `Persistent Volume` helps us back the storage to a Pod which is necessary for stateful workloads like Databases etc.
- [Running on microK8s](./05_03_Deploying_microk8s.md): We will aggregate all the resources and apply the changes to the cluster.
