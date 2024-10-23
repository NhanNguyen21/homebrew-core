class Cake < Formula
  desc "Cross platform build automation system with a C# DSL"
  homepage "https://cakebuild.net/"
  url "https://github.com/cake-build/cake/archive/refs/tags/v4.1.0.tar.gz"
  sha256 "2f666eb901a9e0ec0155fe724876008cae94c542939c5ae989bbd8dcad93949b"
  license "MIT"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "be043f0290cd7508b8a1f72825935e6a100f37420e94b0bff157346c7bc7f7e2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b05bd41b2a72ef0fedec5de35c41480cacb08b5053793ff1d14bd498ffaa4e7f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "c3ffdc8ec23170142eb6a216296b0af43127a892c3cbb7625f8e1868395d6acd"
    sha256 cellar: :any_skip_relocation, sonoma:        "2e5a760d11a3f3b3f7c1ced811373b923c2ef949f75885b726cdaae67df4a3ca"
    sha256 cellar: :any_skip_relocation, ventura:       "f398a348812759267b3b4d1c90ef6bc039581c230d36eab43bc3f276d5c305ae"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7ddcc0abbe06c9376e57ff0061c16f678bfae3e3c2ede7e9ec7c805ec6131fd7"
  end

  depends_on "dotnet"

  conflicts_with "coffeescript", because: "both install `cake` binaries"

  # dotnet sdk version requirement patch, upstream pr ref, https://github.com/cake-build/cake/pull/4377
  patch do
    url "https://github.com/cake-build/cake/commit/92193becffb09dce10fda010a0de03f941919739.patch?full_index=1"
    sha256 "257220fb97858bd80c561be5d342c33eb21709cc76efefe9f8a0a3703e1cc329"
  end

  def install
    dotnet = Formula["dotnet"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
      /p:Version=#{version}
    ]

    system "dotnet", "publish", "src/Cake", *args
    env = { DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}" }
    (bin/"cake").write_env_script libexec/"Cake", env
  end

  test do
    (testpath/"build.cake").write <<~EOS
      var target = Argument ("target", "info");

      Task("info").Does(() =>
      {
        Information ("Hello Homebrew");
      });

      RunTarget ("info");
    EOS
    assert_match "Hello Homebrew\n", shell_output("#{bin}/cake build.cake")
  end
end
