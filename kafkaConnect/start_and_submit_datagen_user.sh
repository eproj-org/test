#!/bin/bash

set -v
set -x
helm upgrade --install kafka-connect  licenseware/kafka-connect --version 0.2.1 -f ~/k3d/redpandaBroker/kafkaConnect/values.yaml
sleep 60
HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "datagen-campaign_finance",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "kafka.topic": "campaign_finance",
    "quickstart": "campaign_finance",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "max.interval": 2000,
    "tasks.max": "1"
  }
}
EOF
)

PORT_NODE=$(kubectl get service  kafka-connect --output jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
curl -vvv -k -X POST -H "${HEADER}" --data "${DATA}" --cacert ../../python-getting-started/ca.crt -u admin:change-me http://kafka-connect.mydomain.com:"${PORT_NODE}"/connectors
set +x
set +v
