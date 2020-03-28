# Tools

You need the following tools for setting up the deployment workflow on Kubernetes **locally**.

## microk8s

> The smallest, fastest, fully-conformant Kubernetes that track upstream releases and makes clustering trivial. MicroK8s is great for offline development, prototyping, and testing.

We'll need a local instance of Kubernetes running so we can deploy the manifests and see if everything is running perfectly. There are a lot of options like `minikube`, `microk8s` `kind` etc. In this guide, we will choose [microk8s](https://microk8s.io/) because it's quite easy to set up and get all components up and running without much pain.

`microk8s` installs a lightweight Kubernetes cluster with bare minimum components required in the control plane. Additional _add-ons_ can be configured with `microk8s enable <addon-name>`.

**NOTE**: I tried other alternatives as well before `microk8s` and here are a few reasons to not go ahead with them:

- `minikube` runs everything in a VM which is quite slow and resource-intensive.
- A minor issue with `kind` is that if you reboot your system, the `docker` container in which the control plane runs is in `stopped` state. There's no `kind restart` as of [yet](https://github.com/kubernetes-sigs/kind/issues/148), so you'll have to re-deploy your app after recreating the cluster.

It's no biggie if you prefer another [CNCF compliant](https://www.cncf.io/certification/software-conformance/) K8s platform of your choice, the rest of the guide remains the same for you.

**Install Instructions**: [microk8s.io/docs](https://microk8s.io/docs/)

Once you've installed `microk8s`, let's verify that our cluster is up.

```shell
$ microk8s.kubectl get nodes
NAME   STATUS   ROLES    AGE     VERSION
work   Ready    <none>   6m22s   v1.17.2
```

## kubectl

> Kubectl is a command-line tool for interacting with the Kubernetes API server and managing the cluster.

You can read more about `kubectl` [here](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Install kubectl

You can find instructions to install `kubectl` in your system [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

### Configure kubectl

`kubectl` looks for `KUBECONFIG` environment variable or `~/.kube/config` for path to `config file`. The config file consists of metadata about the cluster and the user. `kubectl` is a CLI wrapper for HTTP calls to the API server. As you guessed, the API has Authorization and Authentication and if you have multiple users in a cluster to manage you need `kubectl` to tell which user it's going to connect as. This piece of information is called a **context**. `context` holds the cluster name and user name. You can easily switch between `contexts` to log in as a different user or a different cluster altogether. Think of "context" as _profiles_. The context which is active at the moment is called `current-context`.

#### Power tools for kubectl

[kubectx](https://github.com/ahmetb/kubectx) is a nice utility to switch between clusters and namespaces.

## kubekutr

> Cookie cutter templating tool for scaffolding K8s manifests

**Disclaimer**: This is a project which I developed after wrangling a lot of Kubernetes resource manifests by hand.

You can find more details about the project on [GitHub](https://github.com/mr-karan/kubekutr/).

### Install kubekutr

You can download pre-compiled binaries for `kubekutr` from [GitHub](https://github.com/mr-karan/kubekutr/releases).
Grab the latest version from there and put it in your $PATH (e.g. to `/usr/local/bin/kubekutr`)

## kustomize

> Customization of Kubernetes YAML configurations

### Install kustomize

You can find instructions to install `kubectl` in your system [here](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md).
