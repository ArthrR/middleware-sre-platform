"""Trains an IsolationForest to flag anomalous SRE metrics (cpu/latency/error
rate) and logs the run to MLflow — params, metrics, a plot artifact, and a
registered model.

    python train.py --data data/sample_metrics.csv
"""

import argparse
import os
import tempfile

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import mlflow
import mlflow.sklearn
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.metrics import f1_score, precision_score, recall_score

FEATURES = ["cpu_usage", "request_latency_ms", "error_rate"]
EXPERIMENT_NAME = "prometheus-anomaly-detection"
REGISTERED_MODEL_NAME = "prometheus-anomaly-detector"


def plot_anomalies(df: pd.DataFrame, predicted_col: str) -> str:
    fig, ax = plt.subplots(figsize=(10, 4))
    normal = df[df[predicted_col] == 0]
    anomalies = df[df[predicted_col] == 1]
    ax.plot(normal.index, normal["cpu_usage"], ".", color="tab:blue", label="normal", markersize=3)
    ax.plot(anomalies.index, anomalies["cpu_usage"], "x", color="tab:red", label="flagged anomaly")
    ax.set_xlabel("row index (time order)")
    ax.set_ylabel("cpu_usage (%)")
    ax.set_title("IsolationForest anomaly flags over cpu_usage")
    ax.legend()
    fig.tight_layout()

    path = os.path.join(tempfile.gettempdir(), "anomaly_plot.png")
    fig.savefig(path, dpi=120)
    plt.close(fig)
    return path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", default="data/sample_metrics.csv")
    parser.add_argument("--n-estimators", type=int, default=150)
    parser.add_argument("--contamination", type=float, default=0.05)
    parser.add_argument("--random-state", type=int, default=42)
    parser.add_argument("--tracking-uri", default=os.environ.get("MLFLOW_TRACKING_URI", "http://localhost:5000"))
    args = parser.parse_args()

    mlflow.set_tracking_uri(args.tracking_uri)
    mlflow.set_experiment(EXPERIMENT_NAME)

    df = pd.read_csv(args.data)
    has_labels = "label" in df.columns
    X = df[FEATURES]

    with mlflow.start_run():
        mlflow.log_params(
            {
                "n_estimators": args.n_estimators,
                "contamination": args.contamination,
                "random_state": args.random_state,
                "n_rows": len(df),
                "features": ",".join(FEATURES),
            }
        )

        model = IsolationForest(
            n_estimators=args.n_estimators,
            contamination=args.contamination,
            random_state=args.random_state,
        )
        model.fit(X)

        # IsolationForest: -1 = anomaly, 1 = normal -> remap to 1 = anomaly, 0 = normal
        raw_predictions = model.predict(X)
        df["predicted_anomaly"] = (raw_predictions == -1).astype(int)

        n_anomalies = int(df["predicted_anomaly"].sum())
        anomaly_rate = n_anomalies / len(df)
        mlflow.log_metrics({"anomalies_detected": n_anomalies, "anomaly_rate": anomaly_rate})

        if has_labels:
            precision = precision_score(df["label"], df["predicted_anomaly"], zero_division=0)
            recall = recall_score(df["label"], df["predicted_anomaly"], zero_division=0)
            f1 = f1_score(df["label"], df["predicted_anomaly"], zero_division=0)
            mlflow.log_metrics({"precision": precision, "recall": recall, "f1": f1})
            print(f"precision={precision:.3f} recall={recall:.3f} f1={f1:.3f}")

        plot_path = plot_anomalies(df, "predicted_anomaly")
        mlflow.log_artifact(plot_path, artifact_path="plots")

        mlflow.sklearn.log_model(model, "model", registered_model_name=REGISTERED_MODEL_NAME)

        print(f"Flagged {n_anomalies}/{len(df)} rows as anomalous ({anomaly_rate:.1%}).")
        print(f"Run logged to MLflow at {args.tracking_uri}, experiment '{EXPERIMENT_NAME}'.")


if __name__ == "__main__":
    main()
