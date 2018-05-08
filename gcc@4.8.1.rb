class GccAT481 < Formula
    desc "GCC 4.8.1 for systems that has only older gcc compilers"
    homepage "https://ftp.gnu.org/gnu/gcc/gcc-4.8.1/"
    keg_only "This version of gcc is only used for building newer version of gcc"
    url "https://ftp.gnu.org/gnu/gcc/gcc-4.8.1/gcc-4.8.1.tar.gz"
    sha256 "10584b98da894b05dfb3c5b08900b1d584d466249044bb790bd699c25d25c593"
    version "4.8.1"

    def install
        system "./contrib/download_prerequisites"
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "../configure", "--prefix=#{prefix}", "--enable-languages=c,c++,fortran,go", "--disable-multilib"
            system "make"
            system "make", "install"
        end
    end

    def caveats
        <<<~EOS
            Use the following command to use this formula.
            TBA
        EOS
    end
end
