class Ccd < Formula
    desc "A convenient zsh function for cd"
    homepage "https://github.com/zijuexiansheng/convenient_cd"
    keg_only "This is only a script. Read the caveats above and ignore the ones below"
    url "https://github.com/zijuexiansheng/convenient_cd.git", :using => :git
    version "0.1.4"
    
    depends_on "python" => :run

    def loonlocaldir
        var/"loonlocalfiles"
    end

    def loonlocaldir_ccd
        loonlocaldir/"ccd"
    end

    def install
        bin.install "src/ccd"
        libexec.install "src/pyccd.py"
        inreplace "#{bin}/ccd", "=>replace me<=", "#{libexec}/pyccd.py"
        inreplace "#{libexec}/pyccd.py", "=>replace me<=", "#{loonlocaldir_ccd}/ccd.db"
    end

    def post_install
        loonlocaldir_ccd.mkpath
        system "python #{libexec}/pyccd.py create"
    end

    def caveats
        <<-EOS.undent
            This formula is keg-only, which means brew will not link it.
            In order to use it, you need to add the following to your .zshrc:
                autoload -Uz #{opt_prefix}/bin/ccd
                
            =============================================================================
        EOS
    end
end
