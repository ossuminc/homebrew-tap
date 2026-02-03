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
# Check version
riddlc version

# Get help
riddlc help

# Parse a RIDDL file
riddlc parse myfile.riddl

# Validate a RIDDL file
riddlc validate myfile.riddl
```

#### Requirements

- macOS (Intel or Apple Silicon)
- Java 21 (automatically installed via `openjdk@21` dependency)

## More Information

- [RIDDL Documentation](https://ossum.tech/riddl/)
- [RIDDL GitHub Repository](https://github.com/ossuminc/riddl)
- [Ossum Inc](https://ossuminc.com)

## License

Apache-2.0
