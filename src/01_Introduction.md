# Introduction

[Kubernetes](https://www.rust-lang.org) has been growing in popularity to orchestrate deployments using containers. While there are a lot of good tutorials and writing material available on how what is Kubernetes or how the internal work, this guide is primarily aimed towards developers who want to get their application up and running on a Kubernetes cluster and further extending the same approach to handle production deployments.

In this guide, we'll talk about how to deploy a real-world OSS application on Kubernetes including all the ancillary components (database, etc). We'll talk about how to organize the manifests, performing deployments to local cluster, using GitOps methodology, create resource manifests for multiple environments & managing application configs and secrets. These tasks cover the majority of real-world use-cases that will be helpful once you decide to go in _production_.

In this guide, we'll talk about how to deploy a real-world OSS application [listmonk](https://listmonk.app/) on Kubernetes which is an open-source + self-hosted mailing list manager to send campaigns/newsletters. While deploying the application on the K8s cluster, we will develop a basic foundation that would help you to get started with Kubernetes. Some of the broader topics we'll learn:

- Building containers and deploying in a local cluster
- Connecting app with a database which is also deployed in K8s
- Handling one-off tasks like DB migrations
- Structuring manifests using `kustomize`
- Managing config and secrets for your applications

## Target Audience

The guide intends to demonstrate how to deploy an application to a Kubernetes cluster running **locally**. The idea behind doing this is to show an example that demonstrates a deployment pattern that can be extended to handle a production deployment as well. This will be most helpful for developers in organizations where the bridge between a **traditional** _Ops_ team and a developer is slim or non-existent.

### What this guide is not

It is not intended to be a tutorial or a course on how Kubernetes works. There is plenty of good writing material available for that already. This guide is not about Containers or Docker as well. The purpose is rather to guide the **developers** to migrate the older applications on a Kubernetes cluster (or deploy new apps) and gather them with all the tools or skills required to deploy/debug changes with confidence. This guide aims to make the developers self-sufficient when it comes to deployment to Kubernetes and let that task not be seen as something which a dedicated Ops team would do.

This guide covers my experience of how I do deployments at my organisation. You may find a lot of different workflows using `Helm` or other tools and you are encouraged to explore what works best for you. This guide in no way tries to _preach_ any tool or a workflow, just demonstrates what works for me and potentially could work for a lot of projects as well.

## Contributions

This guide is written in an open-collaborative form, via the GitHub platform [k8s-deployment-book](https://github.com/mr-karan/k8s-deployment-book). All contributions for future versions are most welcome, in the form of PRs and Issues.

## Structure of the Guide

- We will first install all the tools required to set up a local environment which includes a local Kubernetes cluster as well.
- Then we will further explore how to create resources manifest and organize them.
- We will further look into how to deploy these changes to your Kubernetes clusters.
- As we progress and you get a fair idea of how deployments are done locally, we will demonstrate how to deploy to a local K8s cluster.
- At this point, we would have covered the deployment steps but there are some times when deployment doesn't go as planned so we will look at how to effectively debug applications using different `kubectl` commands.

You can checkout the source code for all the manifests used in this guide [here](https://github.com/mr-karan/listmonk-infra).
