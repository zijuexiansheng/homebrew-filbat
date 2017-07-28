class PrLoontools < Formula
    desc "My private tools"
    homepage "https://bitbucket.org/zijuexiansheng/loontools"
    url "git@bitbucket.org:zijuexiansheng/loontools.git", :using => :git
    version "0.1.1"
    depends_on "cmake" => :build
    depends_on "pr-loonlib" => :build

    def install
        magic_option = "None"
        odie "Please set the magic_option first" if magic_option == "None"
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_BUILD_TYPE=Release", "-DLOONLIB_ROOT_DIR=#{HOMEBREW_PREFIX}", "-D#{magic_option}_INSTALL=ON"
            system "make", "install"
        end
        mv "loontools.zsh", "loontools"
        inreplace "loontools", "=>libexec_dir<=", "#{libexec}"
        bin.install "loontools"
    end
end
