#!/usr/bin/env python3
"""Export the final LoRA-merged model to 4-bit GGUF for on-device serving."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model-path", default="checkpoints/stage3")
    parser.add_argument("--output-path", default="models/vaidya_e4b_q4.gguf")
    parser.add_argument("--quantisation", default="q4_k_m")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the export command without executing it.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output = Path(args.output_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "python",
        "-m",
        "unsloth.export",
        "--model_path",
        args.model_path,
        "--output_path",
        args.output_path,
        "--quantisation",
        args.quantisation,
    ]
    print(" ".join(command))
    if not args.dry_run:
        subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
