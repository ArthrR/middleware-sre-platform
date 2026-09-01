# Kafka Producer/Consumer Example

Small scripts that publish and consume simulated infrastructure events (host
alerts, deploys, health check failures) against the `kafka` service in
`docker-compose/docker-compose.yml` — a second messaging system alongside
the existing RabbitMQ setup.

## Setup

```bash
pip install -r requirements.txt
```

## Usage

Kafka is in the core profile, so it comes up with the default stack:

```bash
cd docker-compose
docker compose up -d kafka
```

Run the consumer in one terminal, then the producer in another (or via
`make kafka-consume` / `make kafka-produce` from `docker-compose/`):

```bash
python3 consumer.py
python3 producer.py [count]   # defaults to 10 events
```

Both scripts connect to `localhost:9092`, the host-mapped Kafka listener.
