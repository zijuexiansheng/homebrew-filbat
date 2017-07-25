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
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_CACHE=#{HOMEBREW_PREFIX}/loonlocalfiles"
            system "make", "install"
        end
    end

    def post_install
        loonlocaldir.mkpath
        loonlocaldir_loonmod.mkpath
        ENV["LOONMOD_CONFIG"]="#{HOMEBREW_PREFIX}/loonlocalfiles"
        system "#{prefix}/bin/moddb.py db create"
        ohai "Remember to source #{prefix}/bin/loonmod.zsh"
    end
end
