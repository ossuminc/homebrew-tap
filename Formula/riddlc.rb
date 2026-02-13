# Homebrew formula for riddlc - the RIDDL compiler
# To install: brew install ossuminc/tap/riddlc
# Or add the tap first: brew tap ossuminc/tap && brew install riddlc

class Riddlc < Formula
  desc "Compiler for RIDDL (Reactive Interface to Domain Definition Language)"
  homepage "https://github.com/ossuminc/riddl"
  version "1.8.2"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-macos-arm64.zip"
    sha256 "a53b0ac84ac36e7dc055397bd0c05cab438eac3c27d0f011a37c7111016113eb"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-linux-x86_64.zip"
    sha256 "9153ab9568b5c6e00a6ce791fda0b39b9f1de7c78d01159331ed4c6016283c48"
  else
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc.zip"
    sha256 "830ecbb04fb672f44a6572b5d2abc0d672ae5a5ada83b383591d1c3b32a8f960"
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
