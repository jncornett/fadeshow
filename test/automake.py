#!/usr/bin/env python3
import argparse
import logging
import os
import re
from subprocess import Popen, PIPE, call


SCRIPT_PATH = os.path.abspath(__file__)
COMMAND = ["fswatch", "-r", "-l", "3"]
MAKE_COMMAND = ["./maketest"]
IGNORES = [
    re.escape(SCRIPT_PATH),
    r"(^|/)\..*$",
    r"(^|/).*~$",
    r"(^|/)\d+$",
    r"(^|/)test/build(/|$)",
]

parser = argparse.ArgumentParser()
parser.add_argument("paths", nargs=argparse.REMAINDER)
parser.add_argument("--debug", action="store_true")
ns = parser.parse_args()

logging.basicConfig(level=logging.DEBUG if ns.debug else logging.INFO)

if not ns.paths:
    raise SystemExit("No paths specified")

paths = list(map(os.path.abspath, ns.paths))
logging.info("Watching %s", ", ".join(paths))

proc = Popen(COMMAND + paths, stdout=PIPE)
try:
    while True:
        path = proc.stdout.readline().decode('utf-8').strip()
        logging.debug("%s changed", path)
        if any(re.search(ignore, path) for ignore in IGNORES):
            logging.debug("%s ignored", path)
        else:
            logging.info("%s changed, running MAKE_COMMAND", path)
            call(MAKE_COMMAND)

except KeyboardInterrupt:
    proc.kill()
    raise
