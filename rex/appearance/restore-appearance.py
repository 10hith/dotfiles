#!/usr/bin/env python3
"""Merge the saved portable Rex preferences. Quit Rex before running this."""
from pathlib import Path
import argparse
import plistlib
import subprocess
import tempfile
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--apply', action='store_true', help='Write preferences; otherwise only list saved keys')
args = parser.parse_args()
saved = plistlib.loads((Path(__file__).resolve().parent / 'preferences/rex-portable-preferences.plist').read_bytes())
if not args.apply:
    print('Saved portable Rex settings:')
    print('\n'.join(sorted(saved)))
    print('Quit Rex, then run with --apply to merge these settings.')
else:
    result = subprocess.run(['/usr/bin/defaults', 'export', 'com.superlogical.rex', '-'], capture_output=True)
    current = plistlib.loads(result.stdout) if result.returncode == 0 else {}
    current.update(saved)
    with tempfile.TemporaryDirectory(prefix='rex-preferences-') as directory:
        path = Path(directory) / 'merged.plist'
        path.write_bytes(plistlib.dumps(current))
        subprocess.run(['/usr/bin/defaults', 'import', 'com.superlogical.rex', str(path)], check=True)
    print('Merged portable settings; reopen Rex.')
