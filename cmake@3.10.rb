class CmakeAT310 < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://cmake.org/files/v3.10/cmake-3.10.1.tar.gz"
  sha256 "7be36ee24b0f5928251b644d29f5ff268330a916944ef4a75e23ba01e7573284"
  head "https://cmake.org/cmake.git"

  revision 2

  bottle do
    root_url "http://filbat.servequake.com/downloads/bintray/cmake"
    cellar :any_skip_relocation
    ## sha256 "8771baaa9ea698a4aa84045917bd7ffa1834b4f5310b0fb26c279e1160b0dd1e" => :high_sierra
    ## sha256 "4e81dc8263c3affe86e8e7210f3381b533956215f2e425dc250686bc7475f0c4" => :sierra
    ## sha256 "6d321c0cbe941e21ac35f8700231ff02ce1edb1072fd9364d8b288838d103068" => :el_capitan
    sha256 "c5578c2a968c85b4730bd8e3a2b3608ce807c33e07e5d7948149362a04d33cab" => :yosemite
    sha256 "0add61d96d03edd0ceb80be024dab20012fd243d6f897ae436e8e14e03879588" => :x86_64_linux
  end

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew cask install cmake`.


  def install
    version_suffix = version.to_s.slice(/\d+\.\d+/)
    args = %W[
      --prefix=#{prefix}/local
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --system-zlib
      --system-bzip2
      --system-curl
    ]

    system "./bootstrap", *args, "--", "-DCMAKE_BUILD_TYPE=Release"
    system "make"
    system "make", "install"
    bin.mkpath
    Dir.glob(prefix/"local/bin/*") { |file| link_with_suffix file, version_suffix}
    
    ##ln_s prefix/"local/bin/ccmake", bin/"ccmake-#{version_suffix}"
    ##ln_s prefix/"local/bin/cmake", bin/"cmake-#{version_suffix}"
    ##ln_s prefix/"local/bin/cmakexbuild", bin/"cmakexbuild-#{version_suffix}"
    ##ln_s prefix/"local/bin/cpack", bin/"cpack-#{version_suffix}"
    ##ln_s prefix/"local/bin/ctest", bin/"ctest-#{version_suffix}"
  end

  def link_with_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    ln_s file, bin/"#{base}-#{suffix}#{ext}"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake-3.10", "."
  end
end
