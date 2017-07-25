class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    keg_only "This script is only source by user, don't make a soft link for it"
    head "https://github.com/zijuexiansheng/loonmod.git", :revision => "a3950a8e660f7dd5e7b45b842954e02c6d03215b"
    depends_on "python" => :run
    depends_on "cmake" => :build

    def loonlocaldir
        HOMEBREW_PREFIX/"loonlocalfiles"
    end

    def loonlocaldir_loonmod
        loonlocaldir/"loonmod"
    end

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}" "-DCMAKE_LOONLOCAL_CACHE=#{HOMEBREW_PREFIX}/loonlocalfiles"
            system "make", "install"
        end
        ohai "Install to #{prefix}, run the following two commands before anything else"
        ohai "source #{prefix}/loonmod.zsh"
    end

    def post_install
        loonlocaldir.mkpath
        loonlocaldir_loonmod.mkpath
        ohai "Init database"
    end
end
