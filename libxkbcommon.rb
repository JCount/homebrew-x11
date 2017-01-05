class Libxkbcommon < Formula
  desc "Keyboard handling library"
  homepage "https://xkbcommon.org/"
  url "https://xkbcommon.org/download/libxkbcommon-0.7.0.tar.xz"
  sha256 "09351592312d67b438655f54da5b67853026662c4a57e6be4d225f04a9989798"

  bottle do
    sha256 "c138b2459677414251a3a904d51a3151a90f0a32909641b7ca003241c70ceb1c" => :yosemite
    sha256 "65335a728e42b65b02d50508c1dcfea2f1173ab675b319d7060dcab464d9aa11" => :mavericks
    sha256 "b04ed8bb44caee806c2fdb8a7b364ca556d26495a28099ce918f5a9ac3d73885" => :mountain_lion
  end

  head do
    url "https://github.com/xkbcommon/libxkbcommon.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on :x11
  depends_on "bison" => :build
  depends_on "pkg-config" => :build

  def install
    system "./autogen.sh" if build.head?
    inreplace "configure" do |s|
      s.gsub! "-version-script $output_objdir/$libname.ver", ""
      s.gsub! "$wl-version-script", ""
    end
    inreplace %w[Makefile.in Makefile.am] do |s|
      s.gsub! "-Wl,--version-script=${srcdir}/xkbcommon.map", ""
      s.gsub! "-Wl,--version-script=${srcdir}/xkbcommon-x11.map", ""
    end

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
    #include <stdlib.h>
    #include <xkbcommon/xkbcommon.h>
    int main() {
      return (xkb_context_new(XKB_CONTEXT_NO_FLAGS) == NULL)
             ? EXIT_FAILURE
             : EXIT_SUCCESS;
    }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lxkbcommon", "-o", "test"
    system "./test"
  end
end
