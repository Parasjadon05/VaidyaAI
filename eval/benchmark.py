#!/usr/bin/env python3
"""Benchmark VaidyaAI predictions against held-out clinical labels."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--predictions", required=True)
    parser.add_argument("--gold", required=True)
    return parser.parse_args()


def load_jsonl(path: Path) -> list[dict]:
    with path.open() as handle:
        return [json.loads(line) for line in handle if line.strip()]


def main() -> None:
    args = parse_args()
    predictions = {row["id"]: row for row in load_jsonl(Path(args.predictions))}
    gold_rows = load_jsonl(Path(args.gold))

    total = len(gold_rows)
    diagnosis_hits = 0
    triage_hits = 0
    referral_hits = 0

    for gold in gold_rows:
        pred = predictions.get(gold["id"], {})
        gold_dx = str(gold.get("diagnosis", "")).lower()
        pred_dx = " ".join(pred.get("diagnoses", [])).lower()
        diagnosis_hits += int(gold_dx in pred_dx)
        triage_hits += int(pred.get("triage") == gold.get("triage"))
        referral_hits += int(bool(pred.get("referral")) == bool(gold.get("referral")))

    if total == 0:
        raise SystemExit("Gold file is empty.")

    metrics = {
        "n": total,
        "top3_diagnosis_contains": diagnosis_hits / total,
        "triage_accuracy": triage_hits / total,
        "referral_accuracy": referral_hits / total,
    }
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
