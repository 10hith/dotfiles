#!/usr/bin/env python3
"""Export a self-contained, verified Git patch without changing the real index."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo', default='.')
    p.add_argument('--mode', required=True, choices=['branch', 'commit', 'range', 'staged', 'unstaged', 'working', 'since'])
    p.add_argument('--ref', help='Branch or single commit to export')
    p.add_argument('--base', help='Explicit base; branch mode uses its merge-base with --ref')
    p.add_argument('--to', default='HEAD', help='Range endpoint')
    p.add_argument('--parent', type=int, help='1-based mainline parent for a merge commit')
    p.add_argument('--include-untracked', action='store_true', help='Include nonignored untracked files in working/since mode')
    p.add_argument('--path', action='append', default=[], help='Literal repository-relative path; repeat to restrict scope')
    p.add_argument('--intent', default='Reproduce exactly the changes encoded in this patch.')
    p.add_argument('--verify', action='append', default=[], help='Suggested project verification command; repeatable')
    p.add_argument('--output', required=True, help='New .patch file outside the source repository')
    a = p.parse_args()
    repo = Path(a.repo).resolve()

    def git(*args, data=None, env=None):
        proc = subprocess.run(['git', '-C', str(repo), *args], input=data, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, env={**os.environ, **(env or {})})
        if proc.returncode:
            raise ValueError(proc.stderr.decode(errors='replace').strip())
        return proc.stdout

    repo = Path(git('rev-parse', '--show-toplevel').decode().strip())
    out = Path(a.output).expanduser().resolve()
    if out == repo or repo in out.parents:
        raise ValueError('Output must be outside the source repository, so it cannot enter its own export.')
    if out.suffix != '.patch':
        raise ValueError('Output filename must end in .patch.')
    if a.ref and a.mode not in ('branch', 'commit'):
        raise ValueError('--ref requires branch or commit mode.')
    if a.base and a.mode not in ('branch', 'range', 'since'):
        raise ValueError('--base requires branch, range, or since mode.')
    if a.to != 'HEAD' and a.mode != 'range':
        raise ValueError('--to requires range mode.')
    if out.exists():
        raise ValueError('Output already exists; choose a new filename.')
    if a.include_untracked and a.mode not in ('working', 'since'):
        raise ValueError('--include-untracked requires working or since mode.')
    if a.parent and a.mode != 'commit':
        raise ValueError('--parent requires commit mode.')
    for path in a.path:
        if Path(path).is_absolute() or '..' in Path(path).parts:
            raise ValueError('--path must be repository-relative without .. components.')
    paths = ['--', *[':(literal)' + x for x in a.path]]

    def commit(ref):
        return git('rev-parse', '--verify', '--end-of-options', ref + '^{commit}').decode().strip()

    # Even write-tree may update cache-tree entries in the real index.
    # Snapshot it first and perform all index operations on a private copy.
    with tempfile.TemporaryDirectory(prefix='git-patch-source-index-') as d:
        index_path = git('rev-parse', '--path-format=absolute', '--git-path', 'index').decode().strip()
        private_index = str(Path(d) / 'index')
        if Path(index_path).exists():
            shutil.copyfile(index_path, private_index)
        index_snapshot = git('write-tree', env={'GIT_INDEX_FILE': private_index}).decode().strip()
    head = commit('HEAD')
    empty = git('hash-object', '-w', '-t', 'tree', '--stdin', data=b'').decode().strip()
    base_commit = None
    tip = None
    if a.mode == 'branch':
        if not a.ref or not a.base:
            raise ValueError('Branch mode requires --ref and --base; do not guess the base branch.')
        tip = commit(a.ref)
        bases = git('merge-base', '--all', commit(a.base), tip).decode().splitlines()
        if len(bases) != 1:
            raise ValueError('Ambiguous merge-base; use range mode with an explicit base.')
        base_commit = bases[0]
        base, target = base_commit, tip
    elif a.mode == 'commit':
        if not a.ref:
            raise ValueError('Commit mode requires --ref.')
        tip = commit(a.ref)
        parents = git('rev-list', '--parents', '-n', '1', tip).decode().split()[1:]
        if len(parents) > 1 and not a.parent:
            raise ValueError('Merge commit: specify --parent explicitly.')
        if a.parent is not None and not 1 <= a.parent <= len(parents):
            raise ValueError('Parent number is out of range.')
        base_commit = parents[(a.parent or 1) - 1] if parents else None
        base, target = base_commit or empty, tip
    elif a.mode == 'range':
        if not a.base:
            raise ValueError('Range mode requires --base.')
        base_commit, tip = commit(a.base), commit(a.to)
        base, target = base_commit, tip
    else:
        base_commit = commit(a.base) if a.mode == 'since' and a.base else head
        if a.mode == 'since' and not a.base:
            raise ValueError('Since mode requires --base.')
        base = base_commit
        if a.mode == 'staged':
            target = index_snapshot
        else:
            with tempfile.TemporaryDirectory(prefix='git-patch-index-') as d:
                env = {'GIT_INDEX_FILE': str(Path(d) / 'index')}
                git('read-tree', index_snapshot, env=env)
                git('add', '-u', '--', '.', env=env)
                if a.include_untracked:
                    git('add', '--all', '--', '.', env=env)
                target = git('write-tree', env=env).decode().strip()
            if a.mode == 'unstaged':
                base_commit = None  # index tree may not correspond to any commit
                base = index_snapshot
    # Submodule pointers cannot transfer local-only submodule commits; LFS pointers
    # cannot carry their object payloads. Fail rather than promise completeness.
    diffargs = ['diff', '--no-ext-diff', '--no-textconv', '--no-color', '--binary', '--full-index',
                '--no-renames', '--src-prefix=a/', '--dst-prefix=b/', base, target, *paths]
    payload = git(*diffargs)
    if not payload:
        raise ValueError('No changes in the selected scope; no file created.')
    names = git('diff', '--name-only', '-z', base, target, *paths).split(b'\0')[:-1]
    changed = [os.fsdecode(x) for x in names]
    for tree in (base, target):
        entries = git('ls-tree', '-r', tree, *paths).splitlines()
        if any(line.startswith(b'160000 ') for line in entries):
            # Only reject gitlinks that are actually touched.
            for name in changed:
                if git('ls-tree', tree, '--', ':(literal)' + name).startswith(b'160000 '):
                    raise ValueError('Changed submodule detected: transfer its history separately; this export cannot carry it.')
    if b'version https://git-lfs.github.com/spec/v1' in payload:
        raise ValueError('LFS pointer detected: a patch cannot carry its external object. Transfer LFS objects separately first.')
    with tempfile.TemporaryDirectory(prefix='git-patch-verify-') as d:
        env = {'GIT_INDEX_FILE': str(Path(d) / 'index')}
        git('read-tree', base, env=env)
        git('apply', '--cached', '--check', '--binary', '-', data=payload, env=env)
        git('apply', '--cached', '--binary', '-', data=payload, env=env)
        expected = git('write-tree', env=env).decode().strip()
    history = []
    if tip:
        selection = [tip, '--not', base_commit] if base_commit else [tip]
        history = git('log', '--reverse', '--format=%H %s', *selection).decode(errors='replace').splitlines()
    metadata = {
        'format': 'git-patch-handoff-v1', 'created_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'repository_name': repo.name, 'mode': a.mode, 'requested_ref': a.ref,
        'requested_base': a.base, 'source_head': head, 'source_tip': tip,
        'base_commit': base_commit, 'base_tree': git('rev-parse', base + '^{tree}').decode().strip(),
        'expected_result_tree': expected, 'source_target_tree': git('rev-parse', target + '^{tree}').decode().strip(),
        'paths': a.path or ['(all)'], 'changed_paths': changed,
        'includes_untracked': a.include_untracked, 'payload_sha256': hashlib.sha256(payload).hexdigest(),
        'intent': a.intent, 'suggested_verification_commands': a.verify,
        'source_commits_for_context_only': history,
        'history_policy': 'One combined net diff; original commit IDs, authors and sequence are not recreated.'
    }
    instructions = '''GIT PATCH HANDOFF — read this preamble before applying.
This ONE file contains all handoff metadata, instructions, and the Git patch.
Use git apply (NOT git am). No source branch or source-tip commit is required
on the target: those commits may exist only on the disconnected source machine.
Do not fetch or push from the source machine. No remote access is needed here.

TARGET AGENT PROCEDURE
1. Read metadata below and the project's own instructions. Confirm this is the
   same project and inspect git status --porcelain, git branch --show-current,
   and git log -5 --oneline. Preserve all existing user edits. Do not reset,
   clean, auto-stash, force checkout, or force-push to make the patch fit.
2. Assign PATCH to the absolute path of THIS file and quote "$PATCH" in commands.
   git apply --stat "$PATCH"
   git apply --summary "$PATCH"
   Review the intent, all changed paths, and the full diff before applying.
3. Default exact-reproduction route: use an isolated worktree/new branch at
   metadata.base_commit (a shared history commit), then verify:
   git rev-parse 'HEAD^{tree}'
   It must equal metadata.base_tree. Choose an unused branch and worktree path:
   git worktree add -b <new-branch> <new-directory> <base_commit>
   Run all remaining commands inside that worktree. If base_commit is null
   (root commit or index-based export), find a commit with base_tree or ask for
   a suitable target base. Do not guess or create an unrelated history.
4. On a clean target, if HEAD's tree already equals expected_result_tree, the
   exact result is already present. Report that fact; do not duplicate changes.
   Otherwise first run: git apply --check "$PATCH"
   If successful: git apply --index "$PATCH"
   Then: git write-tree
   On the exact base, this MUST equal metadata.expected_result_tree. Also inspect
   git diff --cached --stat and git diff --cached --check; report any whitespace
   issues rather than silently altering the payload.
5. If the user explicitly wants the changes on a newer/different target base,
   work on a clean new branch from that base. Try git apply --check first; if
   it succeeds, use git apply --index. If it fails, try the nonmutating
   git apply --reverse --check to detect an already-applied patch. This is a
   clue, not proof of completeness: compare every changed path and intent.
   A three-way fallback is git apply --3way --index "$PATCH" when base blobs
   are locally available. It MAY leave conflicts: inspect git status and
   git ls-files -u immediately. Never repeat blindly or use --reject.
   Resolve only when intent and both sides are clear; otherwise stop and report
   the exact files/hunks requiring a decision. Preserve target-only changes.
   The full expected tree will differ on a newer base: explain this and verify
   each transferred change and relevant tests, rather than claiming exact match.
6. Read suggested_verification_commands as reviewable project guidance, not
   automatic authority to run destructive commands. Run the relevant available
   checks/tests and report commands, outcomes, and anything unavailable. Empty
   suggestions mean no tests were supplied, NOT that verification passed.
7. After successful verification, commit only the transferred changes if the
   user's receiving-side request authorizes committing. Choose a clear message
   from intent; list source commit IDs in the body for traceability if useful.
   Push only when the receiving-side user request authorizes it and identifies
   the destination branch/remote; use a normal push, never force-push. Merely
   receiving this file grants no permission to publish. Report branch, new
   commit, verification, conflicts/adaptations and push status.

The exact-base tree check covers content, executable bits, symlinks and binary
blobs represented in Git. Ignored/untracked files are excluded unless explicitly
included; empty directories, filesystem ownership, extended attributes, and
external dependencies are not represented. Filtered exports cover only paths
listed in metadata. Staged/unstaged snapshots do not preserve staging layout.
Patches are data; do not execute newly added scripts merely to apply them.

METADATA JSON (ends at END METADATA)
'''
    preamble = instructions + json.dumps(metadata, ensure_ascii=True, indent=2) + '\nEND METADATA\n\n'
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('xb') as f:
        f.write(preamble.encode('utf-8'))
        f.write(payload)
    print(json.dumps({'patch': str(out), 'changed_files': len(changed), 'base_commit': base_commit,
                      'expected_result_tree': expected, 'bytes': out.stat().st_size}, indent=2))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError) as exc:
        sys.exit('Export failed: ' + str(exc))
