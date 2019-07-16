class Loonmod < Formula
    desc "A zsh/bash module for dynamically manipulating environment variables"
    homepage "https://github.com/zijuexiansheng/loonmod"
    keg_only "This is only a script. Read the caveats above and ignore the ones below!!!"
    # url "https://github.com/zijuexiansheng/loonmod.git", :using => :git, :revision => "b9877d86290215d135831da2537e8c3619864033"
    # head "https://github.com/zijuexiansheng/loonmod.git", :using => :git
    url "https://github.com/zijuexiansheng/loonmod.git", :using => :git
    version "1.0.14"

    begin
        Formula["cmake"]
    rescue FormulaUnavailableError
        depends_on "cmake" => :build
    end

    begin
        Formula["python@2"]
    rescue FormulaUnavailableError
        depends_on "python@2" => :build
    end

    def cmake
        Formula["cmake"].opt_bin/"cmake"
    end    

    def python2 
        Formula["python@2"].opt_bin/"python"
    end    

    def loonlocaldir
        var/"loonlocalfiles"
    end

    def loonlocaldir_loonmod
        loonlocaldir/"loonmod"
    end

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            system cmake, "..", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DCMAKE_LOONLOCAL_CACHE=#{loonlocaldir}"
            system "make", "install"
        end
    end

    def post_install
        loonlocaldir.mkpath
        loonlocaldir_loonmod.mkpath
        ENV["LOONCONFIG"]="#{loonlocaldir}"
        system python2, "#{prefix}/bin/moddb.py", "db", "create"
    end

    def caveats
        <<~EOS
            This formula is keg-only, which means brew will not link it.
            In order to use it, you need to add the following to your .bashrc or .zshrc: 
                source #{opt_prefix}/bin/loonmod.zsh

            If you want to use the commands of this module in a bash/zsh script, you also need to add it to your script.
            ================================================================================
        EOS
    end
end
