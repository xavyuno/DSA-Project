#!/usr/bin/env python3
"""
serve_web.py — tiny static file server for the DSA612S web UI.

Why this exists:
    Live Server in VS Code binds to 127.0.0.1 only, so phones on the same
    Wi-Fi can't reach the page. This script serves the `web/` folder on
    every network interface (0.0.0.0) on port 5500, so both the laptop and
    any device on the same Wi-Fi can open the UI.

Before running:
    1. Start the Ballerina API in another terminal:   bal run
    2. Make sure service.bal's CORS allowOrigins includes the URL this
       script prints (localhost, 127.0.0.1, and/or your LAN IP).
       For a quick demo you can temporarily use allowOrigins: ["*"].

Run:
    python serve_web.py
    python3 serve_web.py    (macOS / Linux)

Then open the URL it prints. Press Ctrl+C to stop.
"""

import http.server
import os
import socket
import sys

# ----- configuration ------------------------------------------------------

PORT = 5500
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "web")

# ----- helpers ------------------------------------------------------------

def lan_ip():
    """Best-effort discovery of the machine's LAN IP.

    Opens a UDP socket to a public address (no packets actually sent)
    and reads back the local address chosen for that route. Works on
    Windows, macOS, and Linux without third-party packages.
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(0.2)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except OSError:
        return "127.0.0.1"


class WebUIHandler(http.server.SimpleHTTPRequestHandler):
    """Serves files from WEB_DIR, preferring index.html for directories.

    SimpleHTTPRequestHandler lists directory contents by default. For a UI
    that's not what we want, so when the resolved path is a directory and
    it contains index.html, we serve that file instead.
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def send_head(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            index = os.path.join(path, "index.html")
            if os.path.exists(index):
                # Rewrite the request path so the parent class finds the file.
                self.path = self.path.rstrip("/") + "/index.html"
        return super().send_head()

    def log_message(self, fmt, *args):
        # Quieter logs: only show non-200s, so demo output isn't buried.
        status = args[1] if len(args) > 1 else "?"
        if not str(status).startswith("2"):
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


# ----- main ---------------------------------------------------------------

def main():
    if not os.path.isdir(WEB_DIR):
        print(f"ERROR: web folder not found at {WEB_DIR}", file=sys.stderr)
        print("Run this script from the repo root, or edit WEB_DIR.", file=sys.stderr)
        sys.exit(1)

    index = os.path.join(WEB_DIR, "index.html")
    if not os.path.exists(index):
        print(f"WARNING: {index} not found. Directory listing will be shown.", file=sys.stderr)

    ip = lan_ip()

    print(f"Serving: {WEB_DIR}")
    print(f"On this machine:   http://localhost:{PORT}/")
    print(f"On this machine:   http://127.0.0.1:{PORT}/")
    if ip != "127.0.0.1":
        print(f"On a phone/tablet: http://{ip}:{PORT}/   (same Wi-Fi)")
    print()
    print("The Ballerina API must be running at http://localhost:9090/api")
    print("and its CORS allowOrigins must include the URL you open above.")
    print("Press Ctrl+C to stop.")
    print()

    try:
        httpd = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), WebUIHandler)
    except OSError as e:
        print(f"ERROR: could not bind to port {PORT}: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        httpd.server_close()


if __name__ == "__main__":
    main()