#!/usr/bin/env sh
USER=admin
PW=admin

RETRY_COUNT=2
GRAFANA_URL=http://grafana:3000
ELASTICSEARCH_URL=http://elasticsearch:9200

is_valid_health_status() {
    status=`curl -s -u $USER:$PW -H "Content-Type: application/json" \
        -X GET $GRAFANA_URL/api/health \
        --retry $RETRY_COUNT | jq -r '.database'`
    echo "$status"
}

# check for health status before running the data source + dashboard imports
is_valid=""
until [ "$is_valid" = "ok" ]; do
    sleep 1
    is_valid=$(is_valid_health_status)
done

# for index logstash-*
curl -s -i -u $USER:$PW -H "Content-Type: application/json" \
    -X POST $GRAFANA_URL/api/datasources \
    -d '
    {
        "name":"elasticsearch",
        "type":"elasticsearch",
        "url":"'$ELASTICSEARCH_URL'",
        "access":"proxy",
        "database":"logstash-*",
        "jsonData":{"timeField":"datetime"}
    }' \
    --retry $RETRY_COUNT > /dev/null

# for index docker-*
curl -s -i -u $USER:$PW -H "Content-Type: application/json" \
    -X POST $GRAFANA_URL/api/datasources \
    -d '
    {
        "name":"elasticsearch-docker",
        "type":"elasticsearch",
        "url":"'$ELASTICSEARCH_URL'",
        "access":"proxy",
        "database":"docker-*",
        "jsonData":{"timeField":"@timestamp"}
    }' \
    --retry $RETRY_COUNT > /dev/null

# import storage monitoring dashboard
curl -s -i -u $USER:$PW -H "Content-Type: application/json" \
    -X POST $GRAFANA_URL/api/dashboards/import \
    -d '
    {
        "overwrite":true,
        "inputs":[{
            "name":"DS_ELASTICSEARCH",
            "type":"datasource",
            "pluginId":"elasticsearch",
            "value":"elasticsearch"
        }],
        "dashboard":'"`cat /monitoring-dashboard.json | jq . -c`"'
    }' \
    --retry $RETRY_COUNT > /dev/null

# import docker logs dashboard
curl -s -i -u $USER:$PW -H "Content-Type: application/json" \
    -X POST $GRAFANA_URL/api/dashboards/import \
    -d '
    {
        "overwrite":true,
        "inputs":[{
            "name":"DS_ELASTICSEARCH-DOCKER",
            "type":"datasource",
            "pluginId":"elasticsearch",
            "value":"elasticsearch-docker"
        }],
        "dashboard":'"`cat /docker-logs.json | jq . -c`"'
    }' \
    --retry $RETRY_COUNT > /dev/null
