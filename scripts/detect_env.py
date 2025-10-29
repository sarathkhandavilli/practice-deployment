#!/usr/bin/env python3
"""Detect environment (EC2 or local) and write frontend/.env with VITE_API_URL.

Behavior:
- If EC2 metadata public-ipv4 is reachable, use that IP.
- Otherwise use localhost or the host's outbound IP.

This is intentionally small and uses only the Python standard library.
"""
from __future__ import annotations

import socket
import urllib.request
from pathlib import Path
import sys


def get_ec2_public_ip(timeout: float = 0.8) -> str | None:
    url = "http://169.254.169.254/latest/meta-data/public-ipv4"
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            ip = r.read().decode().strip()
            if ip:
                return ip
    except Exception:
        return None


def get_local_outbound_ip() -> str:
    # Creates a UDP socket to determine the outbound IP without sending packets
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            return s.getsockname()[0]
    except Exception:
        return "localhost"


def write_env(ip: str) -> None:
    env_path = Path("frontend/.env")
    env_path.parent.mkdir(parents=True, exist_ok=True)
    env_path.write_text(f"VITE_API_URL=http://{ip}:5000\n", encoding="utf-8")
    print(f"Wrote {env_path} -> VITE_API_URL=http://{ip}:5000")


def main() -> int:
    print("=== Detecting environment ===")
    ip = get_ec2_public_ip()
    if ip:
        print("Detected EC2 environment")
    else:
        # For local development prefer localhost so frontend will call http://localhost:5000
        ip = "localhost"
        print("Detected local environment - using localhost")

    print(f"Using IP: {ip}")
    write_env(ip)
    print("=== Environment setup complete ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
