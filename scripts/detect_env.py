#!/usr/bin/env python3
import os
import requests

ENV_FILE = "frontend/.env"

def is_ec2_instance() -> bool:
    """Detect if running inside an EC2 instance by checking metadata service."""
    try:
        token = requests.put(
            "http://169.254.169.254/latest/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "60"},
            timeout=1
        ).text
        return bool(token)
    except Exception:
        return False

def get_ec2_ip() -> str:
    """Fetch the EC2 public IPv4 address."""
    try:
        token = requests.put(
            "http://169.254.169.254/latest/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "60"},
            timeout=1
        ).text
        ip = requests.get(
            "http://169.254.169.254/latest/meta-data/public-ipv4",
            headers={"X-aws-ec2-metadata-token": token},
            timeout=1
        ).text
        return ip
    except Exception:
        return "127.0.0.1"

def write_env(host: str, port: int = 5000):
    os.makedirs(os.path.dirname(ENV_FILE), exist_ok=True)
    with open(ENV_FILE, "w") as f:
        f.write(f"VITE_BACKEND_URL=http://{host}:{port}\n")
    print(f"[detect-env] Wrote VITE_BACKEND_URL=http://{host}:{port} to {ENV_FILE}")

def main():
    if is_ec2_instance():
        ip = get_ec2_ip()
        write_env(ip, 5000)
    else:
        write_env("localhost", 5000)

if __name__ == "__main__":
    main()