class Pybind11AT2 < Formula
    desc "Seamless operability between C++11 and Python"
    homepage "https://github.com/pybind/pybind11"
    url "https://github.com/pybind/pybind11/archive/v2.2.1.tar.gz"
    sha256 "f8bd1509578b2a1e7407d52e6ee8afe64268909a1bbda620ca407318598927e7"

    depends_on "zijuexiansheng/filbat/cmake@3.10" => :build
    depends_on "python" => :run

    def install
        Dir.mkdir "build"
        Dir.chdir "build" do
            system "cmake-3.10", "..", "-DCMAKE_INSTALL_PREFIX=#{libexec}", "-DCMAKE_BUILD_TYPE=Release", "-DPYBIND11_PYTHON_VERSION=2.7"
            system "make", "check"
            system "make", "install"
        end
        cmake_first_part = <<~EOM
            #!/usr/bin/env zsh
            
            if [[ "$#" -lt "2" ]]; then
                echo "Usage: $(basename $0) <source path> <install prefix> [other parameters]"
                exit 1
            fi

            source_path=$1
            install_prefix=$2
            shift
            shift

            cmake-3.10 ${source_path} -DCMAKE_INSTALL_PREFIX=${install_prefix} -DCMAKE_BUILD_TYPE=Release \\
        EOM
        cmake_python2 = "-DPYBIND11_PYTHON_VERSION=2.7 \\\n"
        cmake_last_part = "-Dpybind11_DIR=#{libexec}/share/cmake/pybind11 $@ \n\n"
        cmake_hint = <<~EOM
            #!/usr/bin/env zsh

            echo "python 2.7"
            echo "    -DPYBIND11_PYTHON_VERSION=2.7"
            echo "cmake find_package():"
            echo "    -Dpybind11_DIR=#{libexec}/share/cmake/pybind11"
        EOM

        File.open("py2bind11_cmake", "w"){|file| file.write(cmake_first_part + cmake_python2 + cmake_last_part)}
        File.open("py3bind11_cmake", "w"){|file| file.write(cmake_first_part + cmake_last_part)}
        File.open("pybind11_hint", "w"){|file| file.write(cmake_hint)}
        bin.install "py2bind11_cmake"
        bin.install "py3bind11_cmake"
        bin.install "pybind11_hint"

    end
end

