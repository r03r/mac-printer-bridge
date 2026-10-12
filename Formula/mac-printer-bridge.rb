class MacPrinterBridge < Formula
  desc "Share local macOS CUPS printers over IPP/Bonjour"
  homepage "https://github.com/r03r/mac-printer-bridge"
  url "https://github.com/r03r/mac-printer-bridge/archive/refs/tags/v1.0.0.tar.gz"
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
