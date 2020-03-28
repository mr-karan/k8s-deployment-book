# Setting up a local registry

Let's pull the image of `listmonk` from [DockerHub](https://hub.docker.com/r/listmonk/listmonk) and tag it locally. The reason to tag an image locally is that this guide is primarily focussed on developers who will be building their apps on the local system and testing the deployment workflow on local systems, so it doesn't make sense for us to use a remote image from Dockerhub as an example.

```shell
docker pull listmonk/listmonk:v0.5.0-alpha
docker tag listmonk/listmonk:v0.5.0-alpha localhost:32000/listmonk:0.5
```

We should have an image `localhost:32000/listmonk:0.5` available locally. You can verify the same by:

```shell
docker images --format "{{.Repository}} : {{.Tag}}"  | grep localhost:32000/listmonk
```

## Local Registry with microK8s

`microk8s` has an `addon` to enable a private Docker registry. The registry is exposed to your node on `localhost:32000`. You can read more about it [here](https://microk8s.io/docs/registry-built-in). This means that we can push our local images to this local registry. This comes super handy in case you want to test your local images.

To enable the local registry addon:

```shell
microk8s enable registry
```

In case you are wondering why `microk8s` isn't available to find the images built locally, it is because `microk8s` runs it's own `containerd` daemon. `containerd` is the container runtime used to manage images in `microk8s`. Docker in your system also uses `containerd` but these two are 2 different services running. The images you tag and build locally, only your local `containerd` (the one which comes with Docker) knows about it. The `containerd` in `microk8s` has no information about this. That's why we use a local registry to push the images on a local registry that `contaienrd` of `microk8s` is aware of.

## Push the image to the local registry

Now that our local Docker registry is running, we simply need to `push` our local tagged image to this registry.

```shell
$ docker push localhost:32000/listmonk

The push refers to repository [localhost:32000/listmonk]
f2851807903a: Layer already exists
c58b6e921dd6: Layer already exists
e6e719f4def9: Layer already exists
5074c9cb3658: Layer already exists
03901b4a2ea8: Layer already exists
0.5: digest: sha256:b9f1c584e1f434eb9de92ec9d2e42da22fa41c831281d6f53888d735b2fb2bb1 size: 1365
```
