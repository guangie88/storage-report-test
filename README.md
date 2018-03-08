# storage-report-test

The `docker-compose.yml` contains all the services to run in order to observe
the log output of the storage diagnostics from `rs-*fs-report` repositories. All
services are meant to run on `localhost`.

## Supported service(s)

* [`rs-hdfs-report`](https://github.com/guangie88/rs-hdfs-report)

## What to run

Run the following:

```sh
docker-compose up --build -d
```

to start all the services. The services are as follow:

* `fluentd`
  * Log interface for `rs-*fs-report`
* `elasticsearch`
  * Log backend for storage
* `grafana`
  * Log visualization for observing storage diagnostics
* `grafana-import`
  * Add `elasticsearch` into `grafana`, and import dashboard for log
    visualization.
  * Non-persistent, spins up and immediately spins down.
* `hdfs-krb5`
  * HDFS + Kerberos server to performing the `hdfs dfs` commands on.
  * The keytab file in `rs-hdfs-report.toml` matches the one used in this
    server.
* `postgres-ssl`

  * Postgres database server with SSL encryption enabled.
  * The certificate and private key for the SSL handshaking are available in
    `postgres-ssl/ssl/`. These are the same files as the ones used in
    this image by default.
  * For persisting the Postgres data and replacing the private key for the
    running container, first create the volume:

    ```bash
    docker volume create postgres-ssl-data
    ```

    then ensure that the `server.key` has the correct ownership and permissions:

    ```bash
    sudo chown 999.docker server.key
    sudo chmod 600 server.key
    ```

    then perform

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.pgoverride.yml \
      up --build -d
    ```

## How to observe

Open <http://localhost:3000> and log in with:

* Username: `admin`
* Password: `admin`

Open up `Diagnostics` dashboard. If `rs-*fs-report` service(s) is/are already
running, you should see new log points on the respective panels at every 10
second refresh.

## How to spin down

Run the following:

```sh
docker-compose down -v
```

This stops all services and removes all local volumes, i.e. previous logs and
imports are removed, making the session ephemeral.
