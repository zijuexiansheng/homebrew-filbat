class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    keg_only "This script is only source by user, don't make a soft link for it"
    head "https://github.com/zijuexiansheng/loonmod.git", :revision => "8f4135aab9fe3bef0ebb74415b57c20cd92cd0c3"
    depends_on "python" => :run
    depends_on "cmake" => :build

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}"
            system "make", "install"
        end
        ohai "Install to #{prefix}, run the following two commands before anything else"
        ohai "source #{prefix}/loonmod.zsh"
        ohai "mod_db db create"
    end
end
