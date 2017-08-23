class PrLoonlib < Formula
    desc "My private library"
    homepage "https://bitbucket.org/zijuexiansheng/loonlib"
    url "git@bitbucket.org:zijuexiansheng/loonlib.git", :using => :git
    version "0.1.7"
    depends_on "cmake" => :build

    def install
        magic_number = 0
        logger_level = 0
        odie "Please set your magic number" if magic_number == 0
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_BUILD_TYPE=Release", "-DLOGGER_LEVEL=#{logger_level}", "-DLOONPRIVATE_RAND_SHIFT=#{magic_number}"
            system "make", "install"
        end
    end
end
