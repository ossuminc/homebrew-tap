# Engineering Notebook — homebrew-tap

Session log for the Ossum Inc Homebrew tap. Newest entry first.

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
