#!/usr/bin/env python3
"""
Kafka Consumer - Simulated Infra Events
Description: Consumes simulated infrastructure events from Kafka and prints
             them, tallying counts by severity.
Usage: python3 consumer.py
"""

import json

from kafka import KafkaConsumer

KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
TOPIC = "infra-events"
GROUP_ID = "infra-events-consumer"


def main():
    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        group_id=GROUP_ID,
        auto_offset_reset="earliest",
        value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    )

    counts = {"info": 0, "warning": 0, "critical": 0}
    print(f"Listening on topic '{TOPIC}' (Ctrl+C to stop)...\n")

    try:
        for message in consumer:
            event = message.value
            counts[event["severity"]] = counts.get(event["severity"], 0) + 1
            print(
                f"[{event['timestamp']}] {event['host']:<14} {event['event_type']:<22} "
                f"severity={event['severity']:<8} value={event['value']}"
            )
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        print(f"\nSeverity counts: {counts}")
        consumer.close()


if __name__ == "__main__":
    main()
