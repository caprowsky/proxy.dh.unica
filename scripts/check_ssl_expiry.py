#!/usr/bin/env python3
"""
Controlla la scadenza dei certificati SSL per i virtual host in `sites-enabled/`.

Per ogni file `.conf` prova a leggere `server_name` e `ssl_certificate`.
- Se `ssl_certificate` punta a un file locale esistente, legge la data di scadenza dal file.
- Altrimenti tenta una connessione remota via OpenSSL per ottenere il certificato dal server.

Output: `conf | server_name | source | status | expires (UTC) | days`
"""
from __future__ import annotations

import os
import re
import subprocess
from datetime import datetime, timezone
from glob import glob
from typing import Optional, Tuple, List
import csv
import argparse

BASE = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
SITES_GLOB = os.path.join(BASE, "sites-enabled", "*.conf")

RE_SERVER = re.compile(r"^\s*server_name\s+([^;]+);", re.IGNORECASE)
RE_CERT = re.compile(r"^\s*ssl_certificate\s+([^;]+);", re.IGNORECASE)


def run_cmd(cmd: str) -> Optional[str]:
    try:
        out = subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL)
        return out.decode(errors="ignore").strip()
    except subprocess.CalledProcessError:
        return None


def parse_enddate_from_openssl_output(openssl_out: Optional[str]) -> Optional[datetime]:
    if not openssl_out:
        return None
    m = re.search(r"notAfter=(.+)", openssl_out)
    if not m:
        return None
    s = " ".join(m.group(1).split())
    for fmt in ("%b %d %H:%M:%S %Y %Z", "%b %d %H:%M:%S %Y"):
        try:
            return datetime.strptime(s, fmt).replace(tzinfo=timezone.utc)
        except Exception:
            continue
    return None


def check_cert_file(path: str) -> Optional[datetime]:
    if not os.path.isfile(path):
        return None
    cmd = f"openssl x509 -noout -enddate -in {path}"
    out = run_cmd(cmd)
    return parse_enddate_from_openssl_output(out)


def fetch_remote_enddate(host: str) -> Optional[datetime]:
    # ottiene il certificato remoto via s_client e lo passa a x509
    cmd = (
        f"openssl s_client -connect {host}:443 -servername {host} -showcerts < /dev/null 2>/dev/null"
        " | openssl x509 -noout -enddate -in /dev/stdin"
    )
    out = run_cmd(cmd)
    return parse_enddate_from_openssl_output(out)


def inspect_conf(path: str) -> Tuple[Optional[str], Optional[str]]:
    server_name = None
    cert_path = None
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as fh:
            for line in fh:
                if server_name is None:
                    m = RE_SERVER.match(line)
                    if m:
                        # server_name may contain multiple names; take first
                        server_name = m.group(1).split()[0].strip()
                if cert_path is None:
                    m = RE_CERT.match(line)
                    if m:
                        cert_path = m.group(1).strip()
                if server_name and cert_path:
                    break
    except FileNotFoundError:
        pass
    return server_name, cert_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Check SSL expiry for sites-enabled configs")
    parser.add_argument("--csv", dest="csv_path", help="Write results to CSV file", default=os.path.join(os.path.dirname(__file__), "ssl_expiry_report.csv"))
    parser.add_argument("--local-only", dest="local_only", help="Only check local certificate files, do not query remote servers", action="store_true")
    args = parser.parse_args()

    now = datetime.now(timezone.utc)
    header = ["conf", "server_name", "source", "status", "expires_utc", "days"]
    rows: List[List[str]] = []

    print("conf | server_name | source | status | expires (UTC) | days")
    files = sorted(glob(SITES_GLOB))
    if not files:
        print("Nessun file .conf trovato in sites-enabled/")
        return 0
    for conf in files:
        server_name, cert_path = inspect_conf(conf)
        if not server_name:
            server_name = "-"
        expires = None
        source = "-"
        status = "NO_CERT"

        if cert_path:
            cert_path_exp = os.path.expandvars(os.path.expanduser(cert_path))
            # if absolute and exists
            if os.path.isabs(cert_path_exp) and os.path.exists(cert_path_exp):
                expires = check_cert_file(cert_path_exp)
                source = cert_path_exp
            else:
                # try relative to repo base
                rel = os.path.join(BASE, cert_path_exp.lstrip("/"))
                if os.path.exists(rel):
                    expires = check_cert_file(rel)
                    source = rel

        if expires is None and not args.local_only:
            if server_name not in ("-", "localhost"):
                expires = fetch_remote_enddate(server_name)
                source = f"remote:{server_name}"

        if expires:
            delta = expires - now
            days = delta.days
            if delta.total_seconds() < 0:
                status = f"EXPIRED {abs(days)}d"
            else:
                status = f"OK {days}d"
            exp_str = expires.isoformat()
            days_str = str(days)
        else:
            exp_str = "-"
            days_str = "-"

        line = f"{os.path.basename(conf)} | {server_name} | {source} | {status} | {exp_str} | {days_str}"
        print(line)
        rows.append([os.path.basename(conf), server_name, source, status, exp_str, days_str])

    # write CSV
    try:
        csv_path = args.csv_path
        with open(csv_path, "w", newline="", encoding="utf-8") as cf:
            writer = csv.writer(cf)
            writer.writerow(header)
            for r in rows:
                writer.writerow(r)
        print(f"\nWrote CSV report to: {csv_path}")
    except Exception as e:
        print(f"Errore scrittura CSV: {e}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
