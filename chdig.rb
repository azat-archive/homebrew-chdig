class Chdig < Formula
  desc "Dig into ClickHouse with TUI interface"
  homepage "https://github.com/azat/chdig"
  url "https://github.com/azat/chdig/archive/refs/tags/v24.4.1.tar.gz"
  sha256 "3e8017849224af96a40eecfde375651d9b7c0df44e44f0e2f6bccfa68bc9667b"
  license "MIT"
  head "https://github.com/azat/chdig.git", branch: "main"

  livecheck do
    url :stable
    regex(%r{^chdig/v?(\d+(?:\.\d+)+)$}i)
  end

  depends_on "pyoxidizer" => [:build]
  depends_on "python@3.11" => [:build]
  depends_on "rust" => [:build]

  def install
    # workaround for [1], copy pyoxidizer binary to temporary directory (since
    # sometimes pyoxidizer uses directory where binary lies for temporary data,
    # but you cannot write to under brew, you will got EPERM)
    #
    #   [1]: https://github.com/indygreg/PyOxidizer/issues/730
    mkdir_p ".build"
    pyoxidizer_cmd = which("pyoxidizer")
    ln_sf pyoxidizer_cmd, ".build/pyoxidizer"
    ENV.prepend_path "PATH", "#{buildpath}/.build"

    system "make", "chdig", "build_completion", "deploy-binary"
    bin.install "target/chdig"
    bash_completion.install "target/chdig.bash-completion" => "chdig"
  end

  test do
    # Sometimes even if the compilation is OK, binary may not work, let's try.
    system bin/"chdig", "--help"
  end
end
