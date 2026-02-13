# Homebrew formula for riddlc - the RIDDL compiler
# To install: brew install ossuminc/tap/riddlc
# Or add the tap first: brew tap ossuminc/tap && brew install riddlc

class Riddlc < Formula
  desc "Compiler for RIDDL (Reactive Interface to Domain Definition Language)"
  homepage "https://github.com/ossuminc/riddl"
  version "1.8.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-macos-arm64.zip"
    sha256 "b70e2fbb33c4b6b769b0071bff283e03a43cbe7518877bd0f63167ef2cb6d0b6"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-linux-x86_64.zip"
    sha256 "903920b3afa31dfbaa65746bb4615b95a191292280777cabaa88b231241f9f30"
  else
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc.zip"
    sha256 "b3f9eef8b1dfb2d5c311d73036a74cef062ca10087c257cc906c610115f36e05"
    depends_on "openjdk@21"
  end

  def install
    if (OS.mac? && Hardware::CPU.arm?) || (OS.linux? && Hardware::CPU.intel?)
      # Native binary - Homebrew strips the single top-level "bin/" dir
      bin.install "riddlc"
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
    if (OS.mac? && Hardware::CPU.arm?) || (OS.linux? && Hardware::CPU.intel?)
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
