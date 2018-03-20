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
  * Postgres database server with SSL enabled. Clients may only connect to it
    when SSL handshake authentication. The `psql` client might look like below.
    ```bash
    psql -h localhost -U postgres sslmode=require
    ```
  * To verify that the `sslmode` is indeed used, you may run the following
    ```bash
    psql -h localhost -U postgres sslmode=disable
    ```
    You should observe that the connection cannot be established, with an error
    remark `SSL off`.
  * Custom SSL public and private keys may be used and be placed in
    `postgres-ssl/ssl/`, and the override file
    `docker-compose.override.pg-ssl.yml` should be added. You will need to
    ensure the permissions are set correct on the `server.key`.
    ```bash
    sudo chown 70:70 *
    sudo chmod 600 server.key
    ```
    Note that UID/GID `70` refers `postgres`.
  * The `pg_hba.conf` may also be customized at `data/`. To use the customized
    version, the override file `docker-compose.override.pg-hba.yml` should be
    added.

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
