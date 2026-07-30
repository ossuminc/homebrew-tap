# Engineering Notebook — homebrew-tap

Session log for the Ossum Inc Homebrew tap. Newest entry first.

## Session 2026-07-30 — synapify cask, the tap's first Cask

Added `brew install --cask ossuminc/tap/synapify` for Synapify
0.17.0, plus `update-synapify.yml` to regenerate it on a
`repository_dispatch`. This is the first `Casks/` entry in the tap;
Homebrew auto-discovers the directory, so nothing registers it.

### The finding that changed the design

**`ossuminc/synapify` is a private repo.** Its GitHub release assets
404 for anonymous downloads:

```
$ curl -sIL -o /dev/null -w '%{http_code}' \
    https://github.com/ossuminc/synapify/releases/download/0.17.0/Synapify-0.17.0-arm64.dmg
404
```

`gh release view` had listed those assets happily, because `gh`
carries a token — which is exactly how the wrong source got chosen
in the first place. Homebrew fetches anonymously, so every install
would have failed. **Check repo visibility, not just asset
existence, before pointing a formula or cask at GitHub Releases.**

The cask therefore uses the public GCS bucket, as
`Formula/riddlg.rb` already does. Consequences: `livecheck` cannot
use `:github_latest`, so it reads `.version` from the bucket's
`latest.json` via `strategy :json`; and `homepage` is
`https://ossum.ai/products/synapify`, since the GitHub URL 404s for
the public and `brew audit --online` fetches homepages.

### Facts worth not re-deriving

**The dmg has no stapled ticket; the `.app` inside does.** That is
normal electron-builder behaviour — it staples to the bundle, then
wraps it. `xcrun stapler validate` on the dmg says "does not have a
ticket stapled to it" and means nothing. The check that matters:

```
$ spctl -a -vvv -t install /Applications/Synapify.app
accepted
source=Notarized Developer ID
origin=Developer ID Application: Ossum Incorporated (ZJNPJRB7P2)
```

**`depends_on macos: :monterey` means Monterey *or newer*.**
`brew style` autocorrects `">= :monterey"` to the bare symbol, which
looks like it narrows to an exact version. It does not:
`MacOSRequirement#initialize` defaults to `comparator: ">="`, and
`<=` maps to a separate `maximum_macos:` key. The autocorrect is
semantics-preserving.

**arm64-only is a CI consequence, not a decision.** synapify's
release workflow runs its macOS job on a `macos-14` runner and
electron-builder targets the host arch, so no x86_64 artifact
exists to point a cask at. Intel support is a synapify-side change.

### Decisions

**`auto_updates true`.** Synapify self-updates through
electron-updater against the same GCS bucket. Rather than suppress
that for Homebrew installs — which would have meant a code change in
synapify — the cask declares the app self-updating, so `brew
upgrade` skips it absent `--greedy`. The cask version governs fresh
installs only. This is what the `visual-studio-code` and `slack`
casks do.

**No beta cask**, unlike `riddlc-rc`. Synapify shipped `-beta`
prereleases through 0.16.0, but 0.17.0 is final and there are no
beta testers to serve. The guard that keeps a prerelease from
overwriting the stable cask therefore lives on the *sending* side,
as `if: github.event.release.prerelease != true`.

**No `workflow_dispatch` fallback**, for consistency with the two
existing workflows — accepted knowing a lapsed PAT fails silently.

### Method worth reusing

`extract_step.py` (reconstructable, ~40 lines) pulls a named step's
`run:` block scalar out of a workflow by indentation — no PyYAML or
`yq` on this machine — so the tests exercise the real script rather
than a paraphrase. Used to prove:

- the committed `Casks/synapify.rb` is byte-identical to generator
  output
- a malformed sha (`deadbeef`), a path-traversal version
  (`../../.github/workflows/pwned`), and an injection attempt
  (`0.17.0"; rm -rf /tmp/x; #`) each exit 1 and write nothing

Audits ran against a throwaway tap at
`Library/Taps/syntest/homebrew-tap`, per the precedent below, rather
than mutating the real one.

### Unfinished

- **The dispatch is unproven end to end.** `HOMEBREW_TAP_SECRET`
  **does not exist on the synapify repo** (it has `APPLE_*`,
  `CSC_*`, `GCP_*`, `BLOG_DISPATCH` only). Until Reid adds that PAT,
  the dispatch 404s and the cask stays where it is. This is the one
  manual prerequisite.
- **The synapify half is a task handoff**, not done here:
  `synapify/task/2026-07-30-homebrew-cask-dispatch.md`. Its
  `update-homebrew` job must `needs: upload-to-gcs`, *not*
  `build-platform` — gating on the build alone would let the cask
  name a GCS path before the upload job had put the file there.
- **/Applications/Synapify.app was hand-installed at 0.15.0-beta**
  and is now brew-managed at 0.17.0, with Reid's agreement. Settings
  under `~/Library/Application Support/Synapify` were untouched.

## Session 2026-07-29 — riddlc@rc formula for release candidates

Executed the incoming task `2026-07-29-riddlc-rc-formula.md` from the
riddl session. riddl was blocked from cutting its first RC: a
`gh release create --prerelease` still fires riddl's release workflow,
and the tap would have overwritten `Formula/riddlc.rb`, serving a
release candidate to stable users.

Landed in two commits, both pushed:

- `50b2f28` — route RCs to a separate `riddlc@rc` formula
- `abd07b3` — verify installs with `riddlc info`, not `riddlc version`

### What is now true

`update-formula.yml` writes the formula named by
`client_payload.formula`, defaulting to `riddlc` when absent. The name
is **whitelisted** (`riddlc` | `riddlc@rc`), not merely defaulted,
because it becomes a file path and a `repository_dispatch` sender
controls it. All `client_payload.*` fields reach the shell via `env:`
rather than `${{ }}` interpolation.

One template generates both formulae, so the two checked-in files are
byte-identical to generator output and cannot drift from it.

`riddlc@rc` is deliberately **not** `keg_only`. See "Decisions" below.

### Wrong turns worth remembering

**`tr -d ' sha256"'` silently corrupted every sha256.** The set
deletes the characters `s h a 2 5 6`, so hex digits `2`, `5`, `6` and
`a` vanished from the middle of each hash — a plausible-looking but
wrong 40-ish char string. Caught only by diffing the generated file
against `HEAD`. Extract with `grep -o` + `sed`, never a `tr` character
class, and always diff generated artifacts against a known-good source.

**Misattributed commit `8a9ca5c`.** Its subject is "README: riddl**g**
uses --help", not riddlc. On that misreading the formula caveats were
changed from `riddlc help` to `riddlc --help` — backwards. Measuring
the installed 1.31.0 binary settled it: `riddlc help` works and
`riddlc --help` fails with "Unknown option --help". The two tools have
**opposite** help conventions; riddlg is the `--help` one. Note that
`riddlc --help` still **exits 0** while printing an error, so a check
that only tested the exit code would have missed this.

**Two dead ends silencing `FormulaAudit/Conflicts`.** Neither works:

- inline `# rubocop:disable` is itself banned in formulae by
  `Style/DisableCopsWithinSourceCodeDirective`
- a tap-level `.rubocop.yml` exclusion has no effect — Homebrew forces
  its own `FormulaAudit` config. Verified by building a throwaway tap
  under `Library/Taps/rctest/` rather than mutating the real one.

The offense is therefore permanent and by design.

### Method worth reusing

The acceptance test extracted the workflow's `run:` scripts out of the
YAML with a parser, then executed them against a sandboxed copy of
`Formula/` with `IN_*` env vars and a temp `GITHUB_OUTPUT`. That
exercises the real code rather than a paraphrase of it, and it caught
the path-traversal case (`formula=../../.github/workflows/pwned` →
step exits 1, nothing written). Cheap to rebuild; see the session
transcript or reconstruct from `update-formula.yml`.

Paired with it: regenerate the checked-in formulae through the same
scripts and `diff` — proof the committed files match what CI produces.

### Decisions

**`conflicts_with`, not `keg_only :versioned_formula`.** `brew style`
wants an `@`-versioned formula to be `keg_only`; that rule serves
homebrew-core, where versioned formulae exist so several versions can
coexist. An RC exists for the opposite reason — to *be* the `riddlc`
on your PATH while you exercise it — and `keg_only` would leave it
unlinked, reachable only by absolute path. Cost: one advisory
`FormulaAudit/Conflicts` offense that cannot be silenced.

The incoming task file asserted `conflicts_with` is "what Homebrew's
own maintainers recommend". Their linter says the opposite. The
decision stands on the ergonomics argument, not on that claim.

### Unfinished

- **The first real dispatch is unproven.** Everything above is a local
  simulation. When riddl tags `1.32.0-rc.1` as a prerelease, confirm
  the bot commit names `riddlc@rc` and leaves `riddlc.rb` at 1.31.0.
- **Nothing in this repo runs on push.** Both workflows are
  `repository_dispatch` only, so the push triggered no CI and a green
  tick will not appear. Latest runs are from 2026-07-20.
- **`riddlc@rc.rb` currently points at stable 1.31.0**, seeded so the
  tap is coherent before any RC exists. The first RC overwrites it.
- **Pre-existing `stash@{0}`** (`WIP on main: 7975bd8`) predates this
  session and was left untouched.
- **No local `CLAUDE.md`.** The dispatch payload contract and the
  byte-identity invariant currently live in commit messages and
  formula comments. Worth a `CLAUDE.md` if the tap grows.
