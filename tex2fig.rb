class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "753b5d903dfd38623c15d7d0bbdc668b64afff8e"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.2"
    depends_on "python" => :run

    def install
        system "./install.sh", "#{libexec}"
        bin.install "bin/tex2fig"
        libexec.install "script_dir/tex2fig.sh", "script_dir/tex2fig.tmpl"
    end

    test do
        system "tex2fig", "-h"
    end
end
