# Homebrew formula for riddlg — local RIDDL generation, simulation & codegen
# (the riddl-generator native binary).
# To install: brew install ossuminc/tap/riddlg
# Or: brew tap ossuminc/tap && brew install riddlg
# The sha256 values are updated by the riddl-generator release workflow.

class Riddlg < Formula
  desc "Local RIDDL generation, simulation, and code generation (Scala Native)"
  homepage "https://github.com/ossuminc/riddl-generator"
  version "0.1.0"
  license :cannot_represent # proprietary; not open source

  # Native binary + a vendored libllama (in lib/, found via @rpath/$ORIGIN).
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/riddl-generator/releases/download/#{version}/riddlg-#{version}-Darwin-arm64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    depends_on "libidn2"
    depends_on "openssl@3"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ossuminc/riddl-generator/releases/download/#{version}/riddlg-#{version}-Linux-x86_64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    depends_on "libidn2"
    depends_on "openssl@3"
  else
    odie "riddlg has prebuilt binaries only for macOS arm64 and Linux x86_64"
  end

  def install
    # Keep bin/ and lib/ siblings so the binary's @executable_path/../lib (and
    # $ORIGIN/../lib on Linux) rpath finds the vendored libllama.
    prefix.install "bin"
    prefix.install "lib"
  end

  def caveats
    <<~EOS
      riddlg is a native binary; libllama is vendored (no separate install).

      The default AI model is downloaded on first use of `gen riddl`
      (~/.ossum-ai/models). Override with --model or OSSUM_GEN_MODEL_URL.

      Pro features (simulation, code generation) require a license:
      set OSSUM_GEN_LICENSE or place a token at ~/.ossum-gen/license.

      Verify:  riddlg --help
    EOS
  end

  test do
    assert_match "riddlg", shell_output("#{bin}/riddlg --help 2>&1", 0)
  end
end
