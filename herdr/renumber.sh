#!/bin/sh
# Renumber workspace ($num) and agent ($num) sidebar tokens in Herdr.
# Agent numbers match `herdr agent list` order, i.e. the focus_agent 1..9 index.
set -eu

herdr workspace list | python3 -c "
import sys, json, subprocess
for w in json.load(sys.stdin)['result']['workspaces']:
    subprocess.run(['herdr', 'workspace', 'report-metadata', w['workspace_id'],
                    '--source', 'numbering', '--token', f\"num={w['number']}\"], check=True)
"

herdr agent list | python3 -c "
import sys, json, subprocess
for i, a in enumerate(json.load(sys.stdin)['result']['agents'], 1):
    subprocess.run(['herdr', 'pane', 'report-metadata', a['pane_id'],
                    '--source', 'numbering', '--token', f'num={i}'], check=True)
"
