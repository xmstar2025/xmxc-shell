"""Create private, persistent HY2 server and client configurations."""

import argparse
import ipaddress
import json
import os
from pathlib import Path
import secrets
from urllib.parse import quote


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("address", type=ipaddress.IPv4Address)
    parser.add_argument("--port", type=int, default=29885)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("port must be between 1 and 65535")
    os.umask(0o077)
    root = Path("/etc/xmxc-hy2")
    root.mkdir(parents=True, exist_ok=True)
    config_path = root / "config.json"
    address = str(args.address)
    password = secrets.token_urlsafe(32)
    if config_path.exists():
        password = json.loads(config_path.read_text())["inbounds"][0]["users"][0]["password"]
    cert = root / "letsencrypt" / "live" / address
    config = {
        "log": {"level": "info", "timestamp": True},
        "inbounds": [{
            "type": "hysteria2", "tag": "hy2", "listen": "0.0.0.0",
            "listen_port": args.port, "up_mbps": 1000, "down_mbps": 1000,
            "users": [{"name": "ds09-hy2", "password": password}],
            "tls": {"enabled": True, "alpn": ["h3"],
                    "certificate_path": str(cert / "fullchain.pem"),
                    "key_path": str(cert / "privkey.pem")},
        }],
        "route": {"rules": [{"action": "sniff", "timeout": "1s"}]},
    }
    client = {
        "log": {"level": "info"},
        "inbounds": [{"type": "socks", "listen": "127.0.0.1", "listen_port": 19090}],
        "outbounds": [{"type": "hysteria2", "tag": "ds09-hy2", "server": address,
            "server_port": args.port, "up_mbps": 1000, "down_mbps": 1000,
            "password": password, "tls": {"enabled": True, "alpn": ["h3"]}}],
    }
    uri = f"hysteria2://{quote(password, safe='')}@{address}:{args.port}/#ds09-HY2"
    clash = {"proxies": [{"name": "ds09-HY2", "type": "hysteria2", "server": address,
        "port": args.port, "password": password, "up": "1000 Mbps", "down": "1000 Mbps",
        "alpn": ["h3"], "skip-cert-verify": False}]}
    for name, value in [("config.json", config), ("client-sing-box.json", client),
                        ("client-mihomo.json", clash)]:
        path = root / name
        temp = root / (name + ".tmp")
        temp.write_text(json.dumps(value, indent=2) + "\n")
        temp.chmod(0o600)
        temp.replace(path)
    (root / "client-uri.txt").write_text(uri + "\n")
    (root / "client-uri.txt").chmod(0o600)
    print(f"Configured {address}:{args.port}; private clients saved in {root}")


if __name__ == "__main__":
    main()
