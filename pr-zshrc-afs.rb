class PrZshrcAfs < Formula
    desc "My private zshrc configuration on my remote AFS"
    homepage "https://bitbucket.org/zijuexiansheng/zshrc-afs"
    keg_only "This is only a script for source"
    url "git@bitbucket.org:zijuexiansheng/zshrc-afs.git", :using => :git
    version "0.1.6"
    depends_on "cmake" => :build

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            is_intel = %x{ lscpu | grep "Intel(R)" }
            if is_intel != ""
                ohai "Install to an Intel(R) computer"
                system "cmake", "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_DIR=${HOME}/loonlocal_intel"
            else
                ohai "Install to an AMD computer"
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

