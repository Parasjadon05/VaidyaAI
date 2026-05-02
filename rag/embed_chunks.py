#!/usr/bin/env python3
"""Add optional MiniLM embeddings to the bundled SQLite knowledge base."""

from __future__ import annotations

import argparse
import pickle
import sqlite3
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", default="app/assets/knowledge_base.sqlite")
    parser.add_argument("--model", default="sentence-transformers/all-MiniLM-L6-v2")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    db_path = Path(args.db)
    if not db_path.exists():
        raise SystemExit(f"Missing database: {db_path}. Run build_knowledge_base.py first.")

    try:
        from sentence_transformers import SentenceTransformer
    except ImportError as exc:
        raise SystemExit("Install sentence-transformers to build embeddings.") from exc

    encoder = SentenceTransformer(args.model)
    with sqlite3.connect(db_path) as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS chunk_embeddings (
                chunk_id TEXT PRIMARY KEY,
                model TEXT NOT NULL,
                embedding BLOB NOT NULL,
                FOREIGN KEY(chunk_id) REFERENCES chunks(id)
            )
            """
        )
        rows = conn.execute("SELECT id, title, text FROM chunks").fetchall()
        for chunk_id, title, text in rows:
            vector = encoder.encode(f"{title}\n{text}", normalize_embeddings=True)
            conn.execute(
                "REPLACE INTO chunk_embeddings VALUES (?, ?, ?)",
                (chunk_id, args.model, pickle.dumps(vector.tolist())),
            )
        conn.commit()
    print(f"Embedded {len(rows)} chunks in {db_path}")


if __name__ == "__main__":
    main()
