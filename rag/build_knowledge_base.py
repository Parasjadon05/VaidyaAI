#!/usr/bin/env python3
"""Build the bundled SQLite knowledge base from curated guideline chunks."""

from __future__ import annotations

import argparse
import json
import sqlite3
from pathlib import Path


SCHEMA = """
CREATE TABLE IF NOT EXISTS chunks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    language TEXT NOT NULL,
    condition_tags TEXT NOT NULL,
    red_flags TEXT NOT NULL,
    actions TEXT NOT NULL,
    source TEXT NOT NULL,
    text TEXT NOT NULL
);
CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
    id UNINDEXED,
    title,
    condition_tags,
    red_flags,
    text
);
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="app/assets/rag/guideline_chunks.json")
    parser.add_argument("--output", default="app/assets/knowledge_base.sqlite")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    chunks = json.loads(input_path.read_text())
    with sqlite3.connect(output_path) as conn:
        conn.executescript(SCHEMA)
        conn.execute("DELETE FROM chunks")
        conn.execute("DELETE FROM chunks_fts")
        for chunk in chunks:
            conn.execute(
                """
                INSERT INTO chunks VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    chunk["id"],
                    chunk["title"],
                    chunk["language"],
                    json.dumps(chunk["conditionTags"], ensure_ascii=False),
                    json.dumps(chunk["redFlags"], ensure_ascii=False),
                    json.dumps(chunk["actions"], ensure_ascii=False),
                    chunk["source"],
                    chunk["text"],
                ),
            )
            conn.execute(
                "INSERT INTO chunks_fts VALUES (?, ?, ?, ?, ?)",
                (
                    chunk["id"],
                    chunk["title"],
                    " ".join(chunk["conditionTags"]),
                    " ".join(chunk["redFlags"]),
                    chunk["text"],
                ),
            )
        conn.commit()
    print(f"Wrote {len(chunks)} chunks to {output_path}")


if __name__ == "__main__":
    main()
