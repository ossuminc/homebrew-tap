# Homebrew formula for riddlc - the RIDDL compiler
# To install: brew install ossuminc/tap/riddlc
# Or add the tap first: brew tap ossuminc/tap && brew install riddlc

class Riddlc < Formula
  desc "Compiler for RIDDL (Reactive Interface to Domain Definition Language)"
  homepage "https://github.com/ossuminc/riddl"
  version "1.10.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-macos-arm64.zip"
    sha256 "d554f7fd9e6d2f437aa6eb9fdb43114da1dafe64e3bc3ba6d16e1008ea3762c5"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc-linux-x86_64.zip"
    sha256 "dfb9a51231ed5aaabe52f7863ad206900d3561191b304f7abf5f410ac985e739"
  else
    url "https://github.com/ossuminc/riddl/releases/download/#{version}/riddlc.zip"
    sha256 "990d9f0f5fbb20f04cb71bc1b1472ff360646d55b3e85698ea873ad477821ea0"
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
