class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "2d29e4935d42a29543b1228a5e9356e904cf3646"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.0"
    depends_on "python" => :run

    def tex2fig_aux
        prefix/"script_dir"
    end

    def install
        system "./install"
        inreplace "bin/tex2fig", /os.path.join(os.environ[.*],.*)/, "#{tex2fig_aux}"
        bin.install "bin/tex2fig"
        tex2fig_aux.install "script_dir/tex2fig.sh", "script_dir/tex2fig.tmpl"
    end

    def caveats
        <<-EOS.undent
            Use "echo $LOONCONFIG" command to see if you have defined this environment variable.
            If the output is empty, please set "export $LOONCONFIG=#{loonlocaldir}" in your .zshrc or .bashrc before using tex2fig
        EOS
    end
end
