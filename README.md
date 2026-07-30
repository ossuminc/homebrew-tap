# Ossum Inc Homebrew Tap

This is the official Homebrew tap for Ossum Inc software.

## Installation

```bash
brew tap ossuminc/tap
```

## Available Formulae

### riddlc

The RIDDL compiler - a tool for the Reactive Interface to Domain Definition Language.

```bash
brew install ossuminc/tap/riddlc
```

Or after tapping:

```bash
brew install riddlc
```

#### Usage

```bash
# Check version, license, build date, etc. 
riddlc info

# Get help
riddlc help

# Parse a RIDDL file
riddlc parse myfile.riddl

# Validate a RIDDL file
riddlc validate myfile.riddl
```

#### Requirements

- **macOS Apple Silicon** or **Linux x86_64**: Native binary, no
  JDK required
- **Other platforms**: Java 21 (automatically installed via
  `openjdk@21` dependency)

### riddlc-rc

Release candidates of `riddlc`, for trying a release before it
ships. Opt in by name — nothing installs an RC unless you ask
for it by this name:

```bash
brew install ossuminc/tap/riddlc-rc
```

An RC installs `riddlc` onto your PATH exactly as the stable
formula does, so the two **cannot be installed at the same
time**. Homebrew will tell you if the other one is present:

```bash
brew uninstall riddlc && brew install ossuminc/tap/riddlc-rc
```

To go back to the stable release:

```bash
brew uninstall riddlc-rc && brew install ossuminc/tap/riddlc
```

`brew upgrade` tracks the two independently, so an RC install
keeps getting RCs and never silently jumps to a stable release.
Usage and requirements are identical to `riddlc` above; check
what you have with `riddlc info`.

Between release candidates this formula may point at the latest
stable release. It is updated automatically when riddl publishes
a GitHub prerelease.

### riddlg

The RIDDL generator - validates RIDDL models and generates
documentation, API specifications, and code from them, including
AI generation of RIDDL from natural language (runs entirely
locally via llama.cpp).

```bash
brew install ossuminc/tap/riddlg
```

Or after tapping:

```bash
brew install riddlg
```

#### Usage

```bash
# Check version, build info, and detected GPUs
riddlg info

# Get help
riddlg --help

# Validate a RIDDL file
riddlg validate myfile.riddl

# Generate a RIDDL model from a description (AI, local)
riddlg gen riddl "an order-management system" -o orders.riddl

# Generate documentation from a RIDDL model
riddlg gen docs myfile.riddl -f mkdocs -o site/
```

See the [riddlg documentation](https://ossum.tech/riddl/tools/riddlg/)
for installation details, hardware recommendations, the full command
reference, and how to use alternative AI models.

#### Requirements

- **macOS Apple Silicon** (Metal GPU) or **Linux x86_64**
- AI generation commands need a GPU; other commands run anywhere
- riddlg is proprietary software (free tier + licensed Pro
  features); the binary download is free

## Available Casks

### synapify

Synapify — the Solution Architect's Workbench. A visual RIDDL
editor for designing distributed, reactive, cloud-native systems.
Unlike the formulae above it is a macOS application, so it
installs as a cask:

```bash
brew install --cask ossuminc/tap/synapify
```

Or after tapping:

```bash
brew install --cask synapify
```

#### Requirements

- **macOS Apple Silicon only** — there is no Intel build
- **macOS 12 (Monterey) or later**

#### Updates

Synapify updates itself. `brew upgrade` deliberately leaves it
alone, so `brew list --cask --versions synapify` reports the
version Homebrew installed rather than the version you are
running — check the app's own About window for that. To force
Homebrew to reinstall at the cask's version:

```bash
brew upgrade --cask --greedy synapify
```

#### Uninstalling

```bash
brew uninstall --cask synapify           # remove the app
brew uninstall --zap --cask synapify     # also remove settings, caches, logs
```

## More Information

- [RIDDL Documentation](https://ossum.tech/riddl/)
- [RIDDL GitHub Repository](https://github.com/ossuminc/riddl)
- [Ossum Inc](https://ossuminc.com)
- [Ossum AI](https://ossum.ai)

## License

The tap itself and the `riddlc` formula are Apache-2.0. The
`riddlg` binary it installs is proprietary software of Ossum Inc.,
as is the `synapify` application — both are commercial software,
not open source.
