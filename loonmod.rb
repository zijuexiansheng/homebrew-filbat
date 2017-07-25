class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    head "https://github.com/zijuexiansheng/loonmod.git", :revision => "502a36ae7edbe1597342984e926a8fb92bdbd5bb"
    depends_on "python" => :run

    def install
        system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        system "make", "install"
        ohai "Install to #{prefix}, run the following two commands before anything else"
        ohai "source #{prefix}/loonmod.zsh"
        ohai "mod_db db create"
    end
end
