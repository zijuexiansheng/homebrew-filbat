class PrZshrcMac < Formula
    desc "My private zshrc configuration on my Mac OSX"
    homepage "https://bitbucket.org/zijuexiansheng/bash_rc"
    keg_only "This is only a script for source"
    url "git@bitbucket.org:zijuexiansheng/bash_rc.git", :using => :git, :branch => "macosx"
    version "0.1.3"
    depends_on "cmake" => :build

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_DIR=${HOME}/loonlocal"
            system "make", "install"
        end
    end

    def caveats
        <<-EOS.undent
            This formula is keg-only, which means that brew will not link it.
            In order to use it, you need to add the following to your .zshrc:
                source #{opt_prefix}/bin/loonzsh.zsh

            Please Ignore the following caveats
            =================================================================
        EOS
    end
end
