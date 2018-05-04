class Jobqueue < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/jobqueue"
    url "https://github.com/zijuexiansheng/jobqueue.git", :using => :git, :revision => "2e71e61cbef91a898628657a59a557a453b8f0ab"
    head "https://github.com/zijuexiansheng/jobqueue.git", :using => :git
    version "0.1.4"
    depends_on "zijuexiansheng/filbat/python@2.7.14" => :recommended

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
        system "jobqueue", "create"
    end

    test do
        system "jobqueue", "-h"
    end
end

