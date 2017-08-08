class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/jobqueue"
    url "https://github.com/zijuexiansheng/jobqueue.git", :using => :git, :revision => "cd9ffe16877b3f638323687402cb754f91b7bebd"
    head "https://github.com/zijuexiansheng/jobqueue.git", :using => :git
    version "0.1.0"
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

    test do
        system "jobqueue", "-h"
    end
end

