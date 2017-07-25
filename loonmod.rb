class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    keg_only "Don't create soft link for this"
    head "https://github.com/zijuexiansheng/loonmod.git", :revision => "502a36ae7edbe1597342984e926a8fb92bdbd5bb"
    depends_on "python" => :run
    depends_on "cmake"

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
