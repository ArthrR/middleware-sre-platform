"""Optional 'live' data source for train.py: pulls real metrics from this
lab's own running Prometheus (range query API) into the same CSV shape as
data/sample_metrics.csv, minus the synthetic label column (no ground truth
for real data).

    python export_prometheus_metrics.py --hours 2 --out data/live_metrics.csv
    python train.py --data data/live_metrics.csv
"""

import argparse
import csv
import time

import requests

QUERIES = {
    "cpu_usage": '100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[1m])))',
    "request_latency_ms": (
        "histogram_quantile(0.95, sum(rate(ai_gateway_inference_duration_seconds_bucket[1m])) by (le)) * 1000"
    ),
    "error_rate": "100 * sum(rate(ai_gateway_errors_total[5m])) / (sum(rate(ai_gateway_http_requests_total[5m])) + 1)",
}


def range_query(prometheus_url: str, expr: str, start: float, end: float, step: str) -> dict:
    response = requests.get(
        f"{prometheus_url}/api/v1/query_range",
        params={"query": expr, "start": start, "end": end, "step": step},
        timeout=30,
    )
    response.raise_for_status()
    result = response.json()["data"]["result"]
    if not result:
        return {}
    return {ts: float(val) for ts, val in result[0]["values"]}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prometheus-url", default="http://localhost:9090")
    parser.add_argument("--hours", type=float, default=1.0)
    parser.add_argument("--step", default="60s")
    parser.add_argument("--out", default="data/live_metrics.csv")
    args = parser.parse_args()

    end = time.time()
    start = end - args.hours * 3600

    series = {name: range_query(args.prometheus_url, expr, start, end, args.step) for name, expr in QUERIES.items()}

    timestamps = sorted(set().union(*[s.keys() for s in series.values()])) if any(series.values()) else []
    if not timestamps:
        print("No data returned — is the stack running with the 'ai' profile and some traffic?")
        return

    with open(args.out, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["timestamp", *QUERIES.keys()])
        for ts in timestamps:
            writer.writerow([ts, *[series[name].get(ts, "") for name in QUERIES]])

    print(f"Wrote {len(timestamps)} rows to {args.out}")


if __name__ == "__main__":
    main()
