class Rlwrap < Formula
  url "file://#{__FILE__}"
  version "11"

  def install
    mkdir_p bin
    # Just use the one from apt.
    ln_s `which rlwrap`.strip, bin/"rlwrap", verbose: true
  end
end
