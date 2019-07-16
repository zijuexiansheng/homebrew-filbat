class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "e663d26c28a15fb02b7aa67abfa8f99bcfdf9df5"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.8"

    begin
        Formula["python@2"]
    rescue FormulaUnavailableError
        depends_on "python@2" => :build
    end

    def python2 
        Formula["python@2"].opt_bin/"python"
    end    

    def install
        system "./install.sh", "#{libexec}"
        bin.install "bin/tex2fig"
        libexec.install "libexec/tex2fig.sh", "libexec/tex2fig.tmpl"
    end

    test do
        system python2, opt_bin/"tex2fig", "-h"
    end
end
