#!/usr/bin/env python3
"""Cross-platform wrapper to run Docker Compose (tries v2 'docker compose' then 'docker-compose').

Usage examples:
  python scripts/compose.py build
  python scripts/compose.py up -d
  python scripts/compose.py down
  python scripts/compose.py logs -f

This avoids Makefile shell differences between Windows and Linux.
"""
from __future__ import annotations

import shutil
import subprocess
import sys


def run_cmd(cmd: list[str]) -> int:
    try:
        proc = subprocess.run(cmd)
        return proc.returncode
    except FileNotFoundError:
        return 127


def main(argv: list[str]) -> int:
    if not argv:
        print("Usage: python scripts/compose.py <compose-args...>")
        return 2

    # Try docker compose (v2)
    cmd_v2 = ["docker", "compose"] + argv
    rc = run_cmd(cmd_v2)
    if rc == 0:
        return 0

    # If command not found or failed, try legacy docker-compose
    cmd_v1 = ["docker-compose"] + argv
    rc2 = run_cmd(cmd_v1)
    if rc2 == 0:
        return 0

    # Neither worked; print helpful diagnostics
    print("Failed to run 'docker compose' and 'docker-compose'.")
    print("Tried:")
    print("  ", " ".join(cmd_v2))
    print("  ", " ".join(cmd_v1))
    return rc if rc != 127 else rc2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
