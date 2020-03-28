# Applying patches

A very important and crucial feature of `kustomize` is its ability to create different _variants_ of our deployment without templating using **patches**.

[patchesStrategicMerge](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/plugins/builtins.md#patchesstrategicmerge) applies patches to list of resources which are matched by some unique identifier (`Group/Version/Kind + Name/Namespace`). The patch contains only a sparse resource spec, omitting the fields that are already defined in the base.

For eg, to change a replica count in Deployment, we will omit all other fields and only have this field listed in the resource spec.

```yml
# vim example-increase-replica.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    tier: api
spec:
  replicas: 1
```

This `patch` targets an object of _kind_ `Deployment` with _apiVersion_ `apps/v1` and _name_ as `app` with labels `tier:api` set. As you can see we only mention the fields that we have to replace which is `.spec.replicas`. `kustomize` will see the patch and only merge the `replicas` YAML key with the old manifest. So, in effect only `replicas` key is changed in the manifest, everything else remains the same.

Now that the basics of how a `patch` works are covered, let's take a look at how we'll use `patchesStrategicMerge` to fill some gaps by `kubekutr`.

Going back to `kubekutr.yml`, we had mentioned the volume mount in the `deployment` field. `listmonk` requires a `config.toml` to source config variables for the app to run. Since `volume` can be of [multiple types](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes) and by design `kubekutr` sticks to a very generic and base config format, specifying the type of volume isn't possible in `kubekutr` as of yet.

No worries, we will use `kustomize` to add any such missing fields.

```shell
mkdir -p base/patches
```

``` yml
# vim base/patches/add-config-volume.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app # Targets the deployment with `name:app`
spec:
  template:
    spec:
      volumes:
        - name: config-dir
          configMap:
            name: app-config
```

Let's add this patch to our _inventory_ defined in `base/kustomization.yml`:

```yml
# vim base/kustomization.yml
patchesStrategicMerge:
  - patches/add-config-volume.yml
```

This will tell `kustomize` to look for a patch present in `patches/` directory and apply the patch.

This was all about **patches** that you needed to know. There are some other strategies for patches to apply in `kustomize` like [patchesJson6902](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/fields.md#patchesjson6902) and [patches](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/fields.md#patches). You can explore them on your own as it is out of scope for this guide.

## Verifying the patch

Now we can test that our overlay along with patches works correctly by **building** it:

```shell
kustomize build overlays/local
```

On inspecting the `Deployment` spec from the output, we can see the volume configured correctly:

```yml
        volumeMounts:
        - mountPath: /etc/listmonk
          name: config-dir
      volumes:
      - configMap:
          name: listmonk-app-config-local-67m56g98mm
        name: config-dir
```

An interesting thing to note here is that `kustomize` applies a random hash to the `ConfigMap` object name as we can see in the above example (`listmonk-app-config-local-67m56g98mm`). You can see that the `ConfigMap` object is created with the same name.

If you're wondering where this is useful, imagine a use-case where let's say the ConfigMap name is `listmonk-app-config` and you change the ConfigMap contents. You'd imagine the app to be restarted for any config changes, but the Deployment controller doesn't track the ConfigMap updates. So since the name is the same in the new ConfigMap (`listmonk-app-config`), just that the contents have changed, the new Deployment is not rolled out.

`kustomize` appends a random hash to the ConfigMap name and whenever the contents of the ConfigMap change, the hash is also changed. Since the name of `ConfigMap` object itself is changed in the Deployment spec, the controller notices the change and schedules a rollout of the new pods with the updated config.

This is just one of the many benefits `kustomize` provides over mangling resources by hand. I hope by now you're seeing the benefits of using `kustomize` and wanting to start using this in your toolchain.
