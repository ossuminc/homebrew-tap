# Homebrew formula for ossum-gen — local RIDDL generation, simulation & codegen.
# To install: brew install ossuminc/tap/ossum-gen
# Or: brew tap ossuminc/tap && brew install ossum-gen
# The sha256 values are updated by ossum-gen's release workflow.

class OssumGen < Formula
  desc "Local RIDDL generation, simulation, and code generation (Scala Native)"
  homepage "https://github.com/ossuminc/ossum-gen"
  version "0.1.0"
  license :cannot_represent # proprietary; not open source

  # Native binary + a vendored libllama (in lib/, found via @rpath/$ORIGIN).
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/ossum-gen/releases/download/#{version}/ossum-gen-#{version}-Darwin-arm64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    depends_on "libidn2"
    depends_on "openssl@3"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ossuminc/ossum-gen/releases/download/#{version}/ossum-gen-#{version}-Linux-x86_64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    depends_on "libidn2"
    depends_on "openssl@3"
  else
    odie "ossum-gen has prebuilt binaries only for macOS arm64 and Linux x86_64"
  end

  def install
    # Keep bin/ and lib/ siblings so the binary's @executable_path/../lib (and
    # $ORIGIN/../lib on Linux) rpath finds the vendored libllama.
    prefix.install "bin"
    prefix.install "lib"
  end

  def caveats
    <<~EOS
      ossum-gen is a native binary; libllama is vendored (no separate install).

      The default AI model is downloaded on first use of `gen riddl`
      (~/.ossum-ai/models). To pre-fetch it:  ossum-gen ... or run the bundled
      fetch-default-model.sh. Override with --model or OSSUM_GEN_MODEL_URL.

      Pro features (simulation, code generation) require a license:
      set OSSUM_GEN_LICENSE or place a token at ~/.ossum-gen/license.

      Verify:  ossum-gen --help
    EOS
  end

  test do
    assert_match "ossum-gen", shell_output("#{bin}/ossum-gen --help 2>&1", 0)
  end
end
