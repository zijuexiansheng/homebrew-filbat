class PrZshrcAfs < Formula
    desc "My private zshrc configuration on my remote CRC"
    homepage "https://bitbucket.org/zijuexiansheng/bash_rc"
    keg_only "This is only a script for source"
    url "git@bitbucket.org:zijuexiansheng/bash_rc.git", :using => :git, :branch => "crc"
    version "0.1.0"
    depends_on "cmake" => :build

    option "with-intel", "Build for intel architecture. If not set, build for AMD"

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            if build.with? "intel"
                system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_DIR=${HOME}/loonlocal_intel"
            else
                system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_DIR=${HOME}/loonlocal"
            end
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
