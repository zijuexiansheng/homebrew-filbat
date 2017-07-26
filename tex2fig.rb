class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "7c783058589dcdc47cf8613b1ba35652993b90e3"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.5"
    depends_on "python" => :run

    def install
        system "./install.sh", "#{libexec}"
        bin.install "bin/tex2fig"
        libexec.install "libexec/tex2fig.sh", "libexec/tex2fig.tmpl"
    end

    test do
        system "tex2fig", "-h"
    end
end
