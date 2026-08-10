"""Generates a small synthetic dataset shaped like Prometheus SRE metrics
(cpu_usage, request_latency_ms, error_rate) with injected anomalies, for
train.py to run against without needing a live stack.

Stdlib-only by design so it needs no dependencies to (re)run:
    python generate_sample_data.py
"""

import csv
import random
from datetime import datetime, timedelta, timezone

random.seed(42)

ROWS = 500
ANOMALY_RATE = 0.05
START = datetime(2026, 8, 1, tzinfo=timezone.utc)


def normal_row():
    return {
        "cpu_usage": round(max(0.0, min(100.0, random.gauss(35, 5))), 2),
        "request_latency_ms": round(max(0.0, random.gauss(120, 15)), 1),
        "error_rate": round(max(0.0, random.gauss(0.5, 0.2)), 3),
    }


def anomalous_row():
    return {
        "cpu_usage": round(max(0.0, min(100.0, random.gauss(93, 4))), 2),
        "request_latency_ms": round(max(0.0, random.gauss(1100, 250)), 1),
        "error_rate": round(max(0.0, random.gauss(9, 3)), 3),
    }


def main():
    rows = []
    for i in range(ROWS):
        is_anomaly = random.random() < ANOMALY_RATE
        metrics = anomalous_row() if is_anomaly else normal_row()
        rows.append(
            {
                "timestamp": (START + timedelta(minutes=i)).isoformat(),
                **metrics,
                "label": 1 if is_anomaly else 0,
            }
        )

    with open("data/sample_metrics.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["timestamp", "cpu_usage", "request_latency_ms", "error_rate", "label"])
        writer.writeheader()
        writer.writerows(rows)

    n_anomalies = sum(r["label"] for r in rows)
    print(f"Wrote {len(rows)} rows ({n_anomalies} labeled anomalies) to data/sample_metrics.csv")


if __name__ == "__main__":
    main()
