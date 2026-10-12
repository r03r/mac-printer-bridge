class MacPrinterBridge < Formula
  desc "Share local macOS CUPS printers over IPP/Bonjour"
  homepage "https://github.com/r03r/mac-printer-bridge"
  url "https://github.com/r03r/mac-printer-bridge/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "918578d7120d58c8b9480ec477a6c843b1754eff0e7c2ad9f5e8ae3c26a3af51"
  version "1.0.0"
  license "MIT"

  depends_on :macos

  def install
    bin.install "install.sh" => "mac-printer-bridge-setup"
  end

  test do
    assert_match "IPP/Bonjour", shell_output("#{bin}/mac-printer-bridge-setup --help")
  end
end
