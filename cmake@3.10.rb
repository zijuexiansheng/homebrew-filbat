class CmakeAT310 < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://cmake.org/files/v3.10/cmake-3.10.1.tar.gz"
  sha256 "7be36ee24b0f5928251b644d29f5ff268330a916944ef4a75e23ba01e7573284"
  head "https://cmake.org/cmake.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8771baaa9ea698a4aa84045917bd7ffa1834b4f5310b0fb26c279e1160b0dd1e" => :high_sierra
    sha256 "4e81dc8263c3affe86e8e7210f3381b533956215f2e425dc250686bc7475f0c4" => :sierra
    sha256 "6d321c0cbe941e21ac35f8700231ff02ce1edb1072fd9364d8b288838d103068" => :el_capitan
  end

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew cask install cmake`.

  version_suffix = version.to_s.slice(/\d+\.\d+/)

  def install
    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --system-zlib
      --system-bzip2
      --system-curl
    ]

    system "./bootstrap", *args, "--", "-DCMAKE_BUILD_TYPE=Release"
    system "make"
    system "make", "install"
    mv bin/"ccmake", bin/"ccmake-#{version_suffix}"
    mv bin/"cmake", bin/"cmake-#{version_suffix}"
    mv bin/"cmakexbuild", bin/"cmakexbuild-#{version_suffix}"
    mv bin/"cpack", bin/"cpack-#{version_suffix}"
    mv bin/"ctest", bin/"ctest-#{version_suffix}"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake-#{version_suffix}", "."
  end
end
