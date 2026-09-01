#!/usr/bin/env python3
"""
Kafka Producer - Simulated Infra Events
Description: Publishes simulated infrastructure events (host alerts, deploys,
             health check failures) to a Kafka topic, mirroring the RabbitMQ
             setup elsewhere in this lab with a second messaging system.
Usage: python3 producer.py [count]
"""

import json
import random
import sys
import time
from datetime import datetime, timezone

from kafka import KafkaProducer

KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
TOPIC = "infra-events"

EVENT_TYPES = [
    "cpu_high",
    "disk_low",
    "service_restart",
    "deploy_started",
    "deploy_completed",
    "health_check_failed",
]
HOSTS = ["nginx-lb", "tomcat-app", "nodejs-api", "postgres-db", "redis-cache"]
SEVERITIES = ["info", "warning", "critical"]


def build_event() -> dict:
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "host": random.choice(HOSTS),
        "event_type": random.choice(EVENT_TYPES),
        "severity": random.choice(SEVERITIES),
        "value": round(random.uniform(0, 100), 2),
    }


def main():
    count = int(sys.argv[1]) if len(sys.argv) > 1 else 10

    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    )

    print(f"Publishing {count} simulated infra events to topic '{TOPIC}'...")
    for i in range(count):
        event = build_event()
        producer.send(TOPIC, value=event)
        print(f"  [{i + 1}/{count}] sent: {event}")
        time.sleep(0.5)

    producer.flush()
    producer.close()
    print("Done.")


if __name__ == "__main__":
    main()
