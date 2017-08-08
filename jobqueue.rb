class Jobqueue < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/jobqueue"
    url "https://github.com/zijuexiansheng/jobqueue.git", :using => :git, :revision => "cd70a80093586ff3dda47bea0737c56c4c7bc843"
    head "https://github.com/zijuexiansheng/jobqueue.git", :using => :git
    version "0.1.1"
    depends_on "python" => :run

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

