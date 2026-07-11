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
riddlg help

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

## More Information

- [RIDDL Documentation](https://ossum.tech/riddl/)
- [RIDDL GitHub Repository](https://github.com/ossuminc/riddl)
- [Ossum Inc](https://ossuminc.com)
- [Ossum AI](https://ossum.ai)

## License

The tap itself and the `riddlc` formula are Apache-2.0. The
`riddlg` binary it installs is proprietary software of Ossum Inc.
