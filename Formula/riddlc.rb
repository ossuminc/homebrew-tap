# Homebrew formula for riddlc - the RIDDL compiler
# To install: brew install ossuminc/tap/riddlc
# Or add the tap first: brew tap ossuminc/tap && brew install riddlc

class Riddlc < Formula
  desc "Compiler for RIDDL (Reactive Interface to Domain Definition Language)"
  homepage "https://github.com/ossuminc/riddl"
  version "1.4.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-macos-arm64.zip"
    sha256 "f059ab7b2236d99584526297cf9a8f6b662ee0f0b55214b1402976095c6fa229"
  else
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc.zip"
    sha256 "a35c1ca98cf0105fcd2e7016f3b4e17e3d7489c75b68d9e0010e21ab349cb9b4"
    depends_on "openjdk@21"
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      # Native binary - just install directly
      bin.install "bin/riddlc"
    else
      # JVM version - needs wrapper script
      rm "bin/riddlc.bat"
      libexec.install "lib"
      libexec.install "bin"

      (bin/"riddlc").write <<~EOS
        #!/bin/bash
        export JAVA_HOME="#{Formula["openjdk@21"].opt_prefix}"
        exec "#{libexec}/bin/riddlc" "$@"
      EOS
    end
  end

  def caveats
    if OS.mac? && Hardware::CPU.arm?
      <<~EOS
        riddlc is installed as a native binary. No JDK required.

        To verify the installation:
          riddlc version

        For help:
          riddlc help
      EOS
    else
      <<~EOS
        riddlc requires Java 21. This formula uses openjdk@21.

        To verify the installation:
          riddlc version

        For help:
          riddlc help
      EOS
    end
  end

  test do
    assert_match "riddlc version", shell_output("#{bin}/riddlc version")
  end
end
