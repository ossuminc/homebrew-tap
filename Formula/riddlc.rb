# Homebrew formula for riddlc - the RIDDL compiler
# To install: brew install ossuminc/tap/riddlc
# Or add the tap first: brew tap ossuminc/tap && brew install riddlc

class Riddlc < Formula
  desc "Compiler for RIDDL (Reactive Interface to Domain Definition Language)"
  homepage "https://github.com/ossuminc/riddl"
  version "1.2.2"
  license "Apache-2.0"

  url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc.zip"
  sha256 "19e5cc8e72d7934b18a6f3a6890f70fef9d5c5f981a539aeefd4c47052c1e6a9"

  depends_on "openjdk@21"

  def install
    # Remove Windows batch file
    rm "bin/riddlc.bat"

    # Install the lib directory with all JARs
    libexec.install "lib"

    # Install the bin script and create wrapper
    libexec.install "bin"

    # Create a wrapper script that sets JAVA_HOME
    (bin/"riddlc").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Formula["openjdk@21"].opt_prefix}"
      exec "#{libexec}/bin/riddlc" "$@"
    EOS
  end

  def caveats
    <<~EOS
      riddlc requires Java 21. This formula uses openjdk@21.

      To verify the installation:
        riddlc version

      For help:
        riddlc help
    EOS
  end

  test do
    assert_match "riddlc version", shell_output("#{bin}/riddlc version")
  end
end
