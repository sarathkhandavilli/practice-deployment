#!/usr/bin/env python3
"""Detect environment IP (EC2 public IP or localhost) and write frontend/.env

This script works on both Windows and Ubuntu using only Python stdlib.
It tries EC2 metadata service first; if unavailable, falls back to 'localhost'.
It writes VITE_API_URL to `./frontend/.env`.
"""
from __future__ import annotations

import urllib.request
import urllib.error
from pathlib import Path
import sys


def get_ec2_public_ip(timeout: int = 1) -> str | None:
    url = "http://169.254.169.254/latest/meta-data/public-ipv4"
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            ip = r.read().decode().strip()
            if ip:
                return ip
    except Exception:
        return None


def write_env(ip: str) -> None:
    env_path = Path("./frontend/.env")
    env_path.parent.mkdir(parents=True, exist_ok=True)
    content = f"VITE_API_URL=http://{ip}:5000\n"
    env_path.write_text(content, encoding="utf-8")
    print(f"Wrote {env_path} with: {content.strip()}")


def main() -> int:
    print("=== Detecting Environment ===")
    ip = get_ec2_public_ip() or "localhost"
    if ip == "localhost":
        print("Detected local environment")
    else:
        print("Detected EC2 environment")

    print(f"Using IP: {ip}")
    write_env(ip)
    print(f"Frontend URL: http://{ip}:5173")
    print(f"Backend URL: http://{ip}:5000")
    print("=== Environment Setup Complete ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())