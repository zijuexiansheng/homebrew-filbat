class Tex2fig < Formula
    desc "A tool to convert tex to independent figure in PDF format"
    homepage "https://github.com/zijuexiansheng/tex2fig"
    url "https://github.com/zijuexiansheng/tex2fig.git", :using => :git, :revision => "2d29e4935d42a29543b1228a5e9356e904cf3646"
    head "https://github.com/zijuexiansheng/tex2fig.git", :using => :git
    version "0.1.0"
    depends_on "python" => :run

    def loonlocaldir
        HOMEBREW_PREFIX/"loonlocalfiles"
    end

    def loonlocaldir_tex2fig
        loonlocaldir/"tex2fig"
    end

    def install
        system "./install.sh"
        bin.install "bin/tex2fig.py"
        loonlocaldir_tex2fig.install "script_dir/tex2fig.sh", "script_dir/tex2fig.tmpl"
    end
end
