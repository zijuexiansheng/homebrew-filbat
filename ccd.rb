class Ccd < Formula
    desc "A convenient zsh function for cd"
    homepage "https://github.com/zijuexiansheng/convenient_cd"
    keg_only "This is only a script. Read the caveats above and ignore the ones below"
    url "https://github.com/zijuexiansheng/convenient_cd.git", :using => :git
    version "0.1.8"
    
    depends_on "python" => :run

    def loonlocaldir
        var/"loonlocalfiles"
    end

    def loonlocaldir_ccd
        loonlocaldir/"ccd"
    end

    def ccd_completion
        libexec/"completion"
    end

    def install
        bin.install "src/ccd"
        libexec.install "src/pyccd.py"
        ccd_completion.install "src/_ccd"
        inreplace "#{bin}/ccd", "=>replace me<=", "#{libexec}/pyccd.py"
        inreplace "#{libexec}/pyccd.py", "=>replace me<=", "#{loonlocaldir_ccd}/ccd.db"
        inreplace "#{ccd_completion}/_ccd", "=>replace me<=", "#{libexec}/pyccd.py"
    end

    def post_install
        loonlocaldir_ccd.mkpath
        system "python #{libexec}/pyccd.py create"
    end

    def caveats
        <<~EOS
            This formula is keg-only, which means brew will not link it.
            In order to use it, you need to add the following to your .zshrc:
                fpath=(#{opt_prefix}/bin #{opt_prefix}/libexec/completion $fpath)
                autoload -Uz ccd compinit
                compinit
                
            =============================================================================
        EOS
    end
end
