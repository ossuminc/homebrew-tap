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

### riddl-gen-cli

Document generators for RIDDL models. Generates AsciiDoc,
Hugo, OpenAPI, and Smithy specifications from RIDDL models.

```bash
brew install ossuminc/tap/riddl-gen-cli
```

Or after tapping:

```bash
brew install riddl-gen-cli
```

#### Usage

```bash
# Get help
riddl-gen-cli --help

# Generate documentation from a RIDDL model
riddl-gen-cli generate --help

# Check job status
riddl-gen-cli status --job-id <id>
```

#### Requirements

- **macOS Apple Silicon** or **Linux x86_64**: Native binary, no
  JDK required
- **Other platforms**: Java 25 (automatically installed via
  `openjdk@25` dependency)

## More Information

- [RIDDL Documentation](https://ossum.tech/riddl/)
- [RIDDL GitHub Repository](https://github.com/ossuminc/riddl)
- [Ossum Inc](https://ossuminc.com)
- [Ossum AI](https://ossum.ai)

## License

Apache-2.0
