class Jobqueue < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/jobqueue"
    url "https://github.com/zijuexiansheng/jobqueue.git", :using => :git, :revision => "2e71e61cbef91a898628657a59a557a453b8f0ab"
    head "https://github.com/zijuexiansheng/jobqueue.git", :using => :git
    version "0.1.4"

    begin
        Formula["python@2"]
    rescue FormulaUnavailableError
        depends_on "python@2" => :build
    end

    def python2 
        Formula["python@2"].opt_bin/"python"
    end    

    def loonlocaldir
        var/"loonlocalfiles"
    end

    def loonlocaldir_jobqueue
        loonlocaldir/"jobqueue"
    end

    def install
        loonlocaldir_jobqueue.mkpath
        mv "src/jobqueue.py", "jobqueue"
        inreplace "jobqueue", "=>replace_me<=", "#{loonlocaldir}"
        bin.install "jobqueue"
    end
    def post_install
        system python2, opt_bin/"jobqueue", "create"
    end

    test do
        system python2, opt_bin/"jobqueue", "-h"
    end
end

