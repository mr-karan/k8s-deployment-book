# Creating Overlays

Let's create a folder for an **overlay**. In this guide, we will follow the naming convention of naming the overlays folder based on the environment name. For eg, if we need an overlay for `local` env, we will make a directory `local` with `kustomization.yml` present at the root of this folder.

```shell
mkdir -p overlays/local
```

As mentioned earlier, `kustomization.yml` should be present in the **root** of the `overlay` folder, so let's create that:

```yml
# vim overlays/local/kustomization.yml
resources:
- ../../base

namespace: listmonk-local

# Common Prefix to be applied to all resources
namePrefix: listmonk-
nameSuffix: -local
# Common Labels applied to all resources
commonLabels:
  app.kubernetes.io/managed-by: team-listmonk

configMapGenerator:
  - name: app-config
    files:
      - config.toml=configs/config.toml

secretGenerator:
  - name: app-secrets
    literals:
      - LISTMONK_db__host=listmonk-postgres-local
  - name: db-secrets
    literals:
      - POSTGRES_PASSWORD=listmonk
      - POSTGRES_USER=listmonk
      - POSTGRES_DB=listmonk
```

In the above configuration we make use of `kustomize` field spec to apply certain changes:

- **resources**: This references the `base` we created in the previous step. Without a `base` an overlay is useless since it has nothing to target.
- **namespace**: Name of the K8s _namespace_, where all resources will be deployed.
- **namePrefix**: Prepends `listmonk-` to each resource name.
- **nameSuffix**: Appends `-local` to each resource name.
- **commonLabels**: Applies a set of same labels to each resource.
- **configMapGenerator**: List of `configmaps` to be generated. Here, we use a file generator to create the ConfigMap object for us.
- **secretGenerator**: List of `secrets` to be generated. Here, we rely on environment variables to create a secret.

You can read more about the `kustomization.yml` field spec in the official [docs](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/fields.md).

## Generating ConfigMap

`kustomize` lets us build a **ConfigMap** object from raw files, literal strings or environment variables. Since `listmonk` expects a `config.toml` configuration to start the application, we will use the [configMapGenerator](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/plugins/builtins.md#field-name-configMapGenerator) for the same.

```yml
# vim overlays/local/kustomization.yml
configMapGenerator:
  - name: app-config
    files:
      - config.toml=configs/config.toml
```

In the field `files`, the `key` (_config.toml_) is the key used in `ConfigMap` while mounting the volume. For eg, in our `kubekutr.yml` we mentioned the following information for the _Deployment_ spec:

```yml
volumeMounts:
  - name: config-dir
    mountPath: /etc/listmonk
```

This basically mounts all the keys present in `config-dir` _ConfigMap_ object inside `/etc/listmonk` directory. In our case, we only have one file `config.toml` though.

We will need to place the sample config file for `listmonk` so that `kustomize` can create the object:

```shell
mkdir -p overlays/local/configs
```

```toml
# vim overlays/local/configs/config.toml
[app]
# Interface and port where the app will run its webserver.
address = "0.0.0.0:9000"

# Public root URL of the listmonk installation that'll be used
# in the messages for linking to images, unsubscribe page, etc.
root = "https://listmonk.mysite.com"

# (Optional) full URL to the static logo to be displayed on
# user facing view such as the unsubscription page.
# eg: https://mysite.com/images/logo.svg
logo_url = "https://listmonk.mysite.com/public/static/logo.png"

# (Optional) full URL to the static favicon to be displayed on
# user facing view such as the unsubscription page.
# eg: https://mysite.com/images/favicon.png
favicon_url = "https://listmonk.mysite.com/public/static/favicon.png"

# The default 'from' e-mail for outgoing e-mail campaigns.
from_email = "listmonk <from@mail.com>"

# List of e-mail addresses to which admin notifications such as
# import updates, campaign completion, failure etc. should be sent.
# To disable notifications, set an empty list, eg: notify_emails = []
notify_emails = ["admin1@mysite.com", "admin2@mysite.com"]

# Maximum concurrent workers that will attempt to send messages
# simultaneously. This should depend on the number of CPUs the
# machine has and also the number of simultaneous e-mails the
# mail server will
concurrency = 100

# The number of errors (eg: SMTP timeouts while e-mailing) a running
# campaign should tolerate before it is paused for manual
# investigation or intervention. Set to 0 to never pause.
max_send_errors = 1000


[privacy]
# Allow subscribers to unsubscribe from all mailing lists and mark themselves
# as blacklisted?
allow_blacklist = false

# Allow subscribers to export data recorded on them?
allow_export = false

# Items to include in the data export.
# profile            Subscriber's profile including custom attributes
# subscriptions      Subscriber's subscription lists (private list names are masked)
# campaign_views     Campaigns the subscriber has viewed and the view counts
# link_clicks        Links that the subscriber has clicked and the click counts
exportable = ["profile", "subscriptions", "campaign_views", "link_clicks"]

# Allow subscribers to delete themselves from the database?
# This deletes the subscriber and all their subscriptions.
# Their association to campaign views and link clicks are also
# removed while views and click counts remain (with no subscriber
# associated to them) so that stats and analytics aren't affected.
allow_wipe = false


# Database.
[db]
host = "demo-db"
port = 5432
user = "listmonk"
password = "listmonk"
database = "listmonk"
ssl_mode = "disable"

# Maximum active and idle connections to pool.
max_open = 50
max_idle = 10

# SMTP servers.
[smtp]
    [smtp.my0]
        enabled = true
        host = "my.smtp.server"
        port = "25"

        # cram | plain | empty for no auth
        auth_protocol = "cram"
        username = "xxxxx"
        password = ""

        # Optional. Some SMTP servers require a FQDN in the hostname.
        # By default, HELLOs go with "localhost". Set this if a custom
        # hostname should be used.
        hello_hostname = ""

        # Maximum time (milliseconds) to wait per e-mail push.
        send_timeout = 5000

        # Maximum concurrent connections to the SMTP server.
        max_conns = 10

    [smtp.postal]
        enabled = false
        host = "my.smtp.server2"
        port = "25"

        # cram or plain.
        auth_protocol = "plain"
        username = "xxxxx"
        password = ""

        # Maximum time (milliseconds) to wait per e-mail push.
        send_timeout = 5000

        # Maximum concurrent connections to the SMTP server.
        max_conns = 10

# Upload settings
[upload]
# Provider which will be used to host uploaded media. Bundled providers are "filesystem" and "s3".
provider = "filesystem"

# S3 Provider settings
[upload.s3]
# (Optional). AWS Access Key and Secret Key for the user to access the bucket. Leaving it empty would default to use
# instance IAM role.
aws_access_key_id = ""
aws_secret_access_key = ""
# AWS Region where S3 bucket is hosted.
aws_default_region="ap-south-1"
# Specify bucket name.
bucket=""
# Path where the files will be stored inside bucket. Empty value ("") means the root of bucket.
bucket_path=""
# Bucket type can be "private" or "public".
bucket_type="public"
# (Optional) Specify TTL (in seconds) for the generated presigned URL. Expiry value is used only if the bucket is private.
expiry="86400"

# Filesystem provider settings
[upload.filesystem]
# Path to the uploads directory where media will be uploaded. Leaving it empty ("") means current working directory.
upload_path=""
# Upload URI that's visible to the outside world. The media uploaded to upload_path will be made available publicly
# under this URI, for instance, list.yoursite.com/uploads.
upload_uri = "/uploads"
```

> **Note**:  `kustomize` appends a random hash string to the name of `ConfigMap` or `Secret` object if their content changes, thus triggering a new deployment automatically. A feature that K8s still doesn't have and people resort to hacks like these even in Helm :). Be careful about garbage collection with this as old ConfigMaps and Secret objects need to purged to not take up _ever increasing_ space in your `etcd` cluster.

## Building the overlay

At this point, we can test that our overlay works correctly by **building** it:

```shell
kustomize build overlays/local
```

You should see an output of all manifest files aggregated with our _customisations_ applied on the base. Let's proceed on how to create a patch [here](./04_02_Kustomize_Patches.md)
