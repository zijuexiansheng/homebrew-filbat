class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "3b63ad1ccf054ba38e9df78070e46e760d759d63"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.0"
    depends_on "python" => :run

    def tex2fig_aux
        prefix/"script_dir"
    end

    def install
        system "./install", "#{tex2fig_aux}"
        bin.install "bin/tex2fig"
        tex2fig_aux.install "script_dir/tex2fig.sh", "script_dir/tex2fig.tmpl"
    end

    test do
        system "tex2fig", "-h"
    end
end
