# Generating base with kubekutr

```shell
# cwd: listmonk-infra
$ kubekutr -c kubekutr.yml scaffold -o .

DEBU[2020-03-27T16:30:43+05:30] verbose logging enabled
INFO[2020-03-27T16:30:43+05:30] Starting kubekutr...
2020/03/27 16:30:43 reading config: kubekutr.yml
```

This generates a `base` folder in your current working directory.

```shell
$ tree .
.
├── base
│   └── listmonk
│       ├── app-deployment.yml
│       ├── app-service.yml
│       ├── db-statefulset.yml
│       └── postgres-service.yml
└── kubekutr.yml

2 directories, 5 files
```

Inside `base` a folder for each **workspace** is created. As mentioned earlier, `workspace` contains all the components of an application. The deployments and service manifests are all present here.

> **NOTE**: Remember to not edit these files by hand, as the next time you run `scaffold` on kubekutr, the changes will be overwritten.

Now we have the base manifests ready, but we still need to bring `kustomize` in our toolchain to make use of this. So let's learn more about Kustomize in the next [section](./04_Kustomize.md).