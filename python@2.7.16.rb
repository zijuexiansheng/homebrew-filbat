class PythonAT2716 < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/2.7.16/Python-2.7.16.tar.xz"
  sha256 "f222ef602647eecb6853681156d32de4450a2c39f4de93bd5b20235f2e660ed7"
  head "https://github.com/python/cpython.git", :branch => "2.7"

  bottle do
    rebuild 3
    sha256 "df7b4c37f703122b0689808d7d66dc99dbf693d7bdcc1bc924a1a3b2053495eb" => :x86_64_linux
  end

  # setuptools remembers the build flags python is built with and uses them to
  # build packages later. Xcode-only systems need different flags.
  pour_bottle? do
    reason <<~EOS
      The bottle needs the Apple Command Line Tools to be installed.
        You can install them, if desired, with:
          xcode-select --install
    EOS
    satisfy { !OS.mac? || MacOS::CLT.installed? }
  end

  depends_on "pkg-config" => :build
  depends_on "gdbm"
  depends_on "openssl"
  depends_on "readline"
  depends_on "sqlite"
  unless OS.mac?
    depends_on "tcl-tk"
    depends_on "linuxbrew/xorg/xorg" if build.with? "tcl-tk"
    depends_on "bzip2"
    depends_on "ncurses"
    depends_on "zlib"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip"
    sha256 "a222d126f5471598053c9a77f4b5d4f26eaa1f150ad6e01dcf1a42e185d05613"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/93/ab/f86b61bef7ab14909bd7ec3cd2178feb0a1c86d451bc9bccd5a1aedcde5f/pip-19.1.1.tar.gz"
    sha256 "44d3d7d3d30a1eb65c7e5ff1173cdf8f7467850605ac7cc3707b6064bddd0958"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/1d/b0/f478e80aeace42fe251225a86752799174a94314c4a80ebfc5bf0ab1153a/wheel-0.33.4.tar.gz"
    sha256 "62fcfa03d45b5b722539ccbc07b190e4bfff4bb9e3a4d470dd9f6a0981002565"
  end

  if OS.mac?
    # Fixes finding zlib from within the CLT SDK.
    # https://bugs.python.org/issue37285
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/519bb6f33c6d5948b1dbae0964599028b9a3a995/python%402/clt-sdk-path-lookup.patch"
      sha256 "b8b82f7ef45054aca02ce5e24b0f8dd0b6d5cbc4142707ffd1d720ff6ace2162"
    end
  end

  # First install everything into `brew --prefix`/Cellar/python@2.7.16/2.7.16/local
  # Then change the suffix of each executable and then install them to bin/
  def prefix_local
    prefix / "local"
  end

  def lib_cellar
    prefix_local / (OS.mac? ? "Frameworks/Python.framework/Versions/2.7" : "") /
      "lib/python2.7"
  end

  def site_packages_cellar
    lib_cellar/"site-packages"
  end

  # The HOMEBREW_PREFIX location of site-packages.
  def site_packages
    var/"loonlocalfiles/python2.7/lib/python2.7/site-packages"
  end

  def loon_frameworks
    var/"loonlocalfiles/python2.7/Frameworks"
  end

  def install
    # Unset these so that installing pip and setuptools puts them where we want
    # and not into some other Python the user has installed.
    ENV["PYTHONHOME"] = nil
    ENV["PYTHONPATH"] = nil

    args = %W[
      --prefix=#{prefix_local}
      --enable-ipv6
      #{OS.mac? ? "--enable-framework=#{prefix_local}/Frameworks" : "--enable-shared"}
      --without-ensurepip
    ]

    # See upstream bug report from 22 Jan 2018 "Significant performance problems
    # with Python 2.7 built with clang 3.x or 4.x"
    # https://bugs.python.org/issue32616
    # https://github.com/Homebrew/homebrew-core/issues/22743
    if DevelopmentTools.clang_build_version >= 802 &&
       DevelopmentTools.clang_build_version < 902
      args << "--without-computed-gotos"
    end

    args << "--without-gcc" if ENV.compiler == :clang

    cflags   = []
    ldflags  = []
    cppflags = []

    if OS.mac? && MacOS.sdk_path_if_needed
      # Help Python's build system (setuptools/pip) to build things on SDK-based systems
      # The setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
      cflags  << "-isysroot #{MacOS.sdk_path}" << "-I#{MacOS.sdk_path}/usr/include"
      ldflags << "-isysroot #{MacOS.sdk_path}"
      # For the Xlib.h, Python needs this header dir with the system Tk
      # Yep, this needs the absolute path where zlib needed a path relative
      # to the SDK.
      cflags  << "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"
    end

    # Python's setup.py parses CPPFLAGS and LDFLAGS to learn search
    # paths for the dependencies of the compiled extension modules.
    # See Homebrew/linuxbrew#420, Homebrew/linuxbrew#460, and Homebrew/linuxbrew#875
    unless OS.mac?
      if build.bottle?
        # Configure Python to use cc and c++ to build extension modules.
        ENV["CC"] = "cc"
        ENV["CXX"] = "c++"
      end
      cppflags << ENV.cppflags << " -I#{HOMEBREW_PREFIX}/include"
      ldflags << ENV.ldflags << " -L#{HOMEBREW_PREFIX}/lib"
    end

    # Avoid linking to libgcc https://code.activestate.com/lists/python-dev/112195/
    args << "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"

    # We want our readline and openssl! This is just to outsmart the detection code,
    # superenv handles that cc finds includes/libs!
    inreplace "setup.py" do |s|
      s.gsub! "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')",
              "do_readline = '#{Formula["readline"].opt_lib}/libhistory.dylib'"
      s.gsub! "/usr/local/ssl", Formula["openssl"].opt_prefix
    end

    inreplace "setup.py" do |s|
      s.gsub! "sqlite_setup_debug = False", "sqlite_setup_debug = True"
      s.gsub! "for d_ in inc_dirs + sqlite_inc_paths:",
              "for d_ in ['#{Formula["sqlite"].opt_include}']:"

      # Allow sqlite3 module to load extensions:
      # https://docs.python.org/library/sqlite3.html#f1
      s.gsub! 'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))', ""
    end

    # Allow python modules to use ctypes.find_library to find homebrew's stuff
    # even if homebrew is not a /usr/local/lib. Try this with:
    # `brew install enchant && pip install pyenchant`
    inreplace "./Lib/ctypes/macholib/dyld.py" do |f|
      f.gsub! "DEFAULT_LIBRARY_FALLBACK = [", "DEFAULT_LIBRARY_FALLBACK = [ '#{HOMEBREW_PREFIX}/lib',"
      f.gsub! "DEFAULT_FRAMEWORK_FALLBACK = [", "DEFAULT_FRAMEWORK_FALLBACK = [ '#{loon_frameworks}',"
    end

    if build.with? "tcl-tk"
        tcl_tk = Formula["tcl-tk"].opt_prefix
        cppflags << "-I#{tcl_tk}/include"
        ldflags << "-L#{tcl_tk}/lib"
    end

    args << "CFLAGS=#{cflags.join(" ")}" unless cflags.empty?
    args << "LDFLAGS=#{ldflags.join(" ")}" unless ldflags.empty?
    args << "CPPFLAGS=#{cppflags.join(" ")}" unless cppflags.empty?

    system "./configure", *args
    system "make"

    ENV.deparallelize do
      # Tell Python not to install into /Applications
      system "make", "install", "PYTHONAPPSDIR=#{prefix_local}"
      system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{prefix_local}/share/python@2.7.16" if OS.mac?
    end

    # Fixes setting Python build flags for certain software
    # See: https://github.com/Homebrew/homebrew/pull/20182
    # https://bugs.python.org/issue3588
    inreplace lib_cellar/"config/Makefile" do |s|
      s.change_make_var! "LINKFORSHARED",
        "-u _PyMac_Error $(PYTHONFRAMEWORKINSTALLDIR)/Versions/$(VERSION)/$(PYTHONFRAMEWORK)"
    end if OS.mac?

    if OS.mac?
      # Prevent third-party packages from building against fragile Cellar paths
      inreplace [lib_cellar/"_sysconfigdata.py",
                 lib_cellar/"config/Makefile",
                 prefix_local/"Frameworks/Python.framework/Versions/Current/lib/pkgconfig/python-2.7.pc"],
                prefix_local, opt_prefix/"local"
    end

    # Symlink the pkgconfig files into HOMEBREW_PREFIX so they're accessible.
    # TODO: the following may not work well!!!
    (lib/"pkgconfig").install_symlink prefix_local/"Frameworks/Python.framework/Versions/Current/lib/pkgconfig/python-2.7.pc" => "python-2.7.16.pc"

    # Remove 2to3 because Python 3 also installs it
    rm bin/"2to3"

    # Remove the site-packages that Python created in its Cellar.
    site_packages_cellar.rmtree

    (libexec/"setuptools").install resource("setuptools")
    (libexec/"pip").install resource("pip")
    (libexec/"wheel").install resource("wheel")

    {
      "easy_install" => "easy_install-2.7.16",
      "pip" => "pip-2.7.16",
      "python" => "python-2.7.16",
      "python-config" => "python-2.7.16-config",
      "pythonw" => "pythonw-2.7.16",
      "smtpd.py" => "smtpd-2.7.16.py",
    }.each do |unversioned_name, versioned_name|
      bin.install_symlink prefix_local/"bin"/unversioned_name => versioned_name
    end    
  end

  def post_install
    # Avoid conflicts with lingering unversioned files from Python 3
    rm_f %W[
      #{HOMEBREW_PREFIX}/bin/easy_install
      #{HOMEBREW_PREFIX}/bin/pip
      #{HOMEBREW_PREFIX}/bin/wheel
    ]

    # Fix up the site-packages so that user-installed Python software survives
    # minor updates, such as going from 2.7.0 to 2.7.1:

    # Create a site-packages in HOMEBREW_PREFIX/lib/python2.7/site-packages
    site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    site_packages_cellar.unlink if site_packages_cellar.exist?
    site_packages_cellar.parent.install_symlink site_packages

    # Write our sitecustomize.py
    rm_rf Dir["#{site_packages}/sitecustomize.py[co]"]
    (site_packages/"sitecustomize.py").atomic_write(sitecustomize) if OS.mac?

    # Remove old setuptools installations that may still fly around and be
    # listed in the easy_install.pth. This can break setuptools build with
    # zipimport.ZipImportError: bad local file header
    # setuptools-0.9.5-py3.3.egg
    rm_rf Dir["#{site_packages}/setuptools*"]
    rm_rf Dir["#{site_packages}/distribute*"]
    rm_rf Dir["#{site_packages}/pip[-_.][0-9]*", "#{site_packages}/pip"]

    setup_args = ["-s", "setup.py", "--no-user-cfg", "install", "--force",
                  "--verbose",
                  "--single-version-externally-managed",
                  "--record=installed.txt",
                  "--install-scripts=#{preifx_local}/bin",
                  "--install-lib=#{site_packages}"]

    (libexec/"setuptools").cd { system "#{bin}/python-2.7.16", *setup_args }
    (libexec/"pip").cd { system "#{bin}/python-2.7.16", *setup_args }
    (libexec/"wheel").cd { system "#{bin}/python-2.7.16", *setup_args }

    # When building from source, these symlinks will not exist, since
    # post_install happens after linking.
    %w[pip easy_install wheel].each do |e|
      (HOMEBREW_PREFIX/"bin").install_symlink prefix_local/"bin"/e => "#{e}-2.7.16"
    end

    # Help distutils find brewed stuff when building extensions
    include_dirs = [HOMEBREW_PREFIX/"include", Formula["openssl"].opt_include,
                    Formula["sqlite"].opt_include]
    library_dirs = [HOMEBREW_PREFIX/"lib", Formula["openssl"].opt_lib,
                    Formula["sqlite"].opt_lib]

    cfg = lib_cellar/"distutils/distutils.cfg"
    cfg.atomic_write <<~EOS
      [install]
      prefix=#{var}/loonlocalsfiles/python2.7

      [build_ext]
      include_dirs=#{include_dirs.join ":"}
      library_dirs=#{library_dirs.join ":"}
    EOS
  end

  def sitecustomize
    <<~EOS
      # This file is created by Homebrew and is executed on each python startup.
      # Don't print from here, or else python command line scripts may fail!
      # <https://docs.brew.sh/Homebrew-and-Python>
      import re
      import os
      import sys

      if sys.version_info[0] != 2:
          # This can only happen if the user has set the PYTHONPATH for 3.x and run Python 2.x or vice versa.
          # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
          # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
          # built only for a specific version of Python and will fail with cryptic error messages.
          # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
          exit('Your PYTHONPATH points to a site-packages dir for Python 2.x but you are running Python ' +
               str(sys.version_info[0]) + '.x!\\n     PYTHONPATH is currently: "' + str(os.environ['PYTHONPATH']) + '"\\n' +
               '     You should `unset PYTHONPATH` to fix this.')

      # Only do this for a brewed python:
      if os.path.realpath(sys.executable).startswith('#{rack}'):
          # Shuffle /Library site-packages to the end of sys.path and reject
          # paths in /System pre-emptively (#14712)
          library_site = '/Library/Python/2.7/site-packages'
          library_packages = [p for p in sys.path if p.startswith(library_site)]
          sys.path = [p for p in sys.path if not p.startswith(library_site) and
                                             not p.startswith('/System')]
          # .pth files have already been processed so don't use addsitedir
          sys.path.extend(library_packages)

          # the Cellar site-packages is a symlink to the HOMEBREW_PREFIX
          # site_packages; prefer the shorter paths
          long_prefix = re.compile(r'#{rack}/[0-9\._abrc]+/Frameworks/Python\.framework/Versions/2\.7/lib/python2\.7/site-packages')
          sys.path = [long_prefix.sub('#{site_packages}', p) for p in sys.path]

          # LINKFORSHARED (and python-config --ldflags) return the
          # full path to the lib (yes, "Python" is actually the lib, not a
          # dir) so that third-party software does not need to add the
          # -F/#{HOMEBREW_PREFIX}/Frameworks switch.
          try:
              from _sysconfigdata import build_time_vars
              build_time_vars['LINKFORSHARED'] = '-u _PyMac_Error #{opt_prefix}/Frameworks/Python.framework/Versions/2.7/Python'
          except:
              pass  # remember: don't print here. Better to fail silently.

          # Set the sys.executable to use the opt_prefix
          sys.executable = '#{opt_bin}/python2.7'
    EOS
  end

  def caveats; <<~EOS
    Pip and setuptools have been installed. To update them
      pip-2.7.16 install --upgrade pip setuptools

    You can install Python packages with
      pip-2.7.16 install <package>

    They will install into the site-package directory
      #{site_packages}

    See: https://docs.brew.sh/Homebrew-and-Python
    [WARNING]: there might be some trouble related to "pkgconfig" on Mac OSX. If
               this is the case, then the best way is probably disable installation
               of this package on Mac OSX    
  EOS
  end

  test do
    # Check if sqlite is ok, because we build with --enable-loadable-sqlite-extensions
    # and it can occur that building sqlite silently fails if OSX's sqlite is used.
    system "#{bin}/python-2.7.16", "-c", "import sqlite3"
    # Check if some other modules import. Then the linked libs are working.
    system "#{bin}/python-2.7.16", "-c", "import Tkinter; root = Tkinter.Tk()" if OS.mac?
    system "#{bin}/python-2.7.16", "-c", "import gdbm"
    system "#{bin}/python-2.7.16", "-c", "import zlib"
    system bin/"pip-2.7.16", "list", "--format=columns"
  end
end
