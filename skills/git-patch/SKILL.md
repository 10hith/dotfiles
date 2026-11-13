---
name: git-patch
description: Export local Git commits, branches, ranges, or working changes as one self-contained patch with embedded instructions for an agent on another machine with shared Git history. Also use to receive and apply these patches; no source push is needed.
---

# Git Patch

Produce **one `.patch` file** containing a plain-English receiving procedure, JSON metadata, and a binary-capable combined Git diff. The target agent must be able to use this file without this skill, its helper, source-only commits, or network access. The source project and target project share history; source changes may be exclusively local commits.

## Decide the scope

Inspect repository instructions, status, current branch, local refs/upstreams and recent history. Do not fetch, push, stage the real index, commit, or change branches merely to export. Use the user's requested scope; do not silently include unrelated edits.

- One commit ID means **that commit only**, relative to its parent. For a merge ask which mainline parent to use. A root commit is supported, but its target needs an explicitly chosen matching empty-tree starting point.
- A branch means changes from its **merge-base with a base branch** to its tip. Infer the base from reliable project/user context or the local remote HEAD symbolic ref, explain the choice, and pass it explicitly. An upstream pointing to the same feature branch does not establish its integration base. Ask if the base is ambiguous.
- “Since commit X” means X to the requested endpoint, NOT X alone. Use range for committed endpoints, since for the current working snapshot.
- Branch/range exports combine the net changes into **one patch**, including merged changes. They do not retain individual commits, authorship, commit messages as commits, or source commit IDs on the target. Explain this if commit preservation is requested; do not silently replace that requirement with a combined patch.
- Uncommitted exports distinguish staged, unstaged, and working (staged plus unstaged tracked changes). Include nonignored untracked files only if requested, or after establishing that those files belong to the requested changes. Ignored files are excluded. Inspect untracked filenames before including them.
- Path filters restrict every mode to literal repo-relative files/directories. They may omit dependencies; inspect the result against the user's intent.

The supplied exporter is preferred over improvised shell concatenation: it uses a temporary index, preserves binaries/modes/symlinks, resolves full object IDs, validates application against its base, and embeds target instructions. It refuses empty exports and overwriting files. It refuses changed submodules and detected LFS pointers because the patch cannot transfer their external objects. Do not bypass those refusals and claim a complete transfer.

## Export

Run `python3 <this-skill>/scripts/export_patch.py --help` if needed. Replace `<this-skill>` with this skill's absolute directory. Always pass a useful `--intent`, relevant known `--verify` commands (repeatable), and `--output` ending in `.patch` **outside the source repository**. In Codex prefer the current chat's outputs directory when outside that repository. Never embed credentials or credential-bearing remote URLs in the handoff. Review the selected diff for actual secrets before delivery, especially in dotfiles; do not redact executable changes silently.

```bash
# One local commit
python3 <this-skill>/scripts/export_patch.py --repo /project --mode commit --ref abc123 --output /exports/change.patch

# Feature branch since divergence from main (works without pushing it)
python3 <this-skill>/scripts/export_patch.py --repo /project --mode branch --ref feature --base main --output /exports/feature.patch

# Exact endpoint comparison: changes AFTER base through to (base is excluded)
python3 <this-skill>/scripts/export_patch.py --repo /project --mode range --base BASE --to TIP --output /exports/range.patch

# Staged / unstaged / combined tracked working changes relative to HEAD
python3 <this-skill>/scripts/export_patch.py --repo /project --mode staged --output /exports/staged.patch
python3 <this-skill>/scripts/export_patch.py --repo /project --mode unstaged --output /exports/unstaged.patch
python3 <this-skill>/scripts/export_patch.py --repo /project --mode working --output /exports/working.patch

# Local commits since shared base, plus current tracked edits and intended new files
python3 <this-skill>/scripts/export_patch.py --repo /project --mode since --base BASE --include-untracked --output /exports/all.patch
```

Options: `--parent 1` chooses the merge commit's first parent; `--path src --path tests` restricts paths; `--include-untracked` is valid only with working/since; `--intent 'Explain the change'`; `--verify 'npm test'` (repeatable). Revisions can be full IDs, unambiguous abbreviations, tags or branch names, resolved to commits. `--to` applies to range only. A conflicted index cannot be exported.

Equivalent Git primitives for understanding/manual fallback:

| Scope | Command |
| --- | --- |
| Single non-root commit | `git diff --binary --full-index COMMIT^ COMMIT` |
| Root commit | `git diff-tree --root -p --binary --full-index COMMIT` |
| Branch since divergence | `git diff --binary --full-index BASE...BRANCH` |
| Exact range | `git diff --binary --full-index FROM TO` |
| Staged changes | `git diff --cached --binary --full-index` |
| Unstaged tracked changes | `git diff --binary --full-index` |
| All tracked changes since commit | `git diff --binary --full-index COMMIT` |

These raw commands alone do not meet the self-contained handoff requirement and ordinary diff excludes untracked files. Do not use `git add -A` on the real index as an export shortcut. `git format-patch --stdout BASE..TIP > series.patch` is a different, mailbox format consumed by `git am`, potentially preserving a linear commit sequence; it is NOT the default combined format here and does not fully represent merges.

## Verify and deliver

The helper validates the raw payload with `git apply --cached` in a temporary index and records the resulting Git tree. Also verify the **finished file with its preamble** using `git apply --stat /absolute/export.patch` and, where practical, `git apply --check` in an isolated worktree at its recorded base. Confirm the real working files and staging state remain unchanged. Review the metadata scope, changed paths, base, expected result, intent and test guidance. Report one clickable patch link, scope, file count, and any limitations; do not create a separate handoff file.

A branch/range based on a shared commit is the preferred receiving route. An unstaged-only patch can depend on a source index tree absent from target history; explicitly flag that limitation and prefer a working or committed-range export when the user needs a straightforward transfer. The target needs the base, not the source tip.

## Receive a patch

Read its embedded procedure and metadata. Follow project instructions as well. Prefer a new branch/worktree at the shared base and compare `git write-tree` after applying to the recorded expected tree. Use **git apply, not git am** for this format. A different target base needs per-change validation; a whole-tree hash mismatch there does not by itself mean failure. Never discard target edits or blindly reapply after conflicts. An export request does not authorize committing or pushing on either machine; receiving-side authorization determines those actions. Push normally only after successful review/tests and explicit receiving-side push instructions.
