class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    keg_only "This is only a script. Read the caveats above and ignore the ones below!!!"
    url "https://github.com/zijuexiansheng/loonmod.git", :using => :git, :revision => "c1883a28493b140325e884281177eb6bf9f4f5c1"
    head "https://github.com/zijuexiansheng/loonmod.git", :using => :git
    version "0.1.4"
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
        ENV["LOONCONFIG"]="#{HOMEBREW_PREFIX}/loonlocalfiles"
        system "#{prefix}/bin/moddb.py db create"
    end

    def caveats
        <<-EOS.undent
            This formula is keg-only, which means brew will not link it.
            In order to use it, you need to add the following to your .bashrc or .zshrc: 
                source #{opt_prefix}/bin/loonmod.zsh

            If you want to use the commands of this module in a bash/zsh script, you also need to add it to your script.
            ================================================================================
        EOS
    end
end
