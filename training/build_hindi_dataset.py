#!/usr/bin/env python3
"""Build Hindi DPO pairs from selected MedQA examples."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path


SYSTEM_STYLE = (
    "Translate the clinical case into fluent Hindi for a community health worker. "
    "Generate a chosen answer that is correct, cautious, and referral-aware. "
    "Generate a rejected answer that is overconfident or misses safety flags."
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, help="MedQA-style JSONL input")
    parser.add_argument("--output", default="data/hindi_dpo.jsonl")
    parser.add_argument("--limit", type=int, default=2000)
    parser.add_argument("--model", default="gpt-4o")
    parser.add_argument(
        "--offline-template",
        action="store_true",
        help="Generate deterministic placeholder pairs without calling an API.",
    )
    return parser.parse_args()


def load_rows(path: Path, limit: int) -> list[dict]:
    rows: list[dict] = []
    with path.open() as handle:
        for line in handle:
            if len(rows) >= limit:
                break
            if line.strip():
                rows.append(json.loads(line))
    return rows


def offline_pair(row: dict) -> dict:
    prompt = row.get("question") or row.get("prompt") or ""
    answer = row.get("answer") or row.get("response") or ""
    hindi_prompt = f"हिंदी में चिकित्सा मामला: {prompt}"
    return {
        "prompt": hindi_prompt,
        "chosen": (
            "संभावित निदान सावधानी से समझाएं, खतरे के संकेत हों तो "
            f"PHC/डॉक्टर को रेफर करें. आधार उत्तर: {answer}"
        ),
        "rejected": "यह निश्चित रूप से सामान्य समस्या है. डॉक्टर को दिखाने की जरूरत नहीं.",
    }


def openai_pair(row: dict, model: str) -> dict:
    try:
        from openai import OpenAI
    except ImportError as exc:
        raise SystemExit("Install openai or use --offline-template.") from exc
    if not os.environ.get("OPENAI_API_KEY"):
        raise SystemExit("Set OPENAI_API_KEY or use --offline-template.")

    client = OpenAI()
    prompt = json.dumps(row, ensure_ascii=False)
    response = client.responses.create(
        model=model,
        input=[
            {"role": "system", "content": SYSTEM_STYLE},
            {
                "role": "user",
                "content": (
                    "Return strict JSON with prompt, chosen, rejected for this example:\n"
                    f"{prompt}"
                ),
            },
        ],
    )
    return json.loads(response.output_text)


def main() -> None:
    args = parse_args()
    rows = load_rows(Path(args.input), args.limit)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    with output.open("w") as handle:
        for row in rows:
            pair = offline_pair(row) if args.offline_template else openai_pair(row, args.model)
            handle.write(json.dumps(pair, ensure_ascii=False) + "\n")

    print(f"Wrote {len(rows)} Hindi DPO pairs to {output}")


if __name__ == "__main__":
    main()
