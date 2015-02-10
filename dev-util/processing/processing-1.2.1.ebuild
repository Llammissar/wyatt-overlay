# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils java-pkg-2

DESCRIPTION="an open source programming language and environment to program images, animation, and sound"
HOMEPAGE="http://processing.org/"
#SRC_URI="http://processing.org/download/${P}.tgz"
SRC_URI="http://processing.googlecode.com/files/${P}.tgz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND=">=virtual/jdk-1.5"
RDEPEND="
	dev-java/ant-core
	dev-java/antlr
	dev-java/eclipse-ecj
	dev-java/jna
	x11-misc/xdg-utils
	x86? ( 
		>=virtual/jdk-1.5 
		x11-libs/libX11
		x11-libs/libXxf86vm
	)
	amd64? (
		app-emulation/emul-linux-x86-java
		app-emulation/emul-linux-x86-xlibs
	)"

QA_EXECSTACK="usr/share/processing/libraries/serial/library/librxtxSerial.so"

java_prepare() {
	#replace JRE, ANT, Eclipse Java Compiler, JNA with system versions
	rm -r java lib/{ant{,-launcher,lr},ecj,jna}.jar || die
	local my_pkg
	for my_pkg in ant-core antlr "eclipse-$(eselect ecj show)" jna ; do
		java-pkg_jar-from --into lib/ ${my_pkg} || die
	done

	sed -i -e '/^browser.linux/s:mozilla:xdg-open:' lib/preferences.txt || die
	sed -i -e '/^update.check/s:true:false:' lib/preferences.txt || die
}

src_install() {
	java-pkg_addcp '$(java-config --tools)' || die
	java-pkg_dojar lib/*.jar || die
	rm lib/*.jar || die

	insinto "${JAVA_PKG_JARDEST}"
	doins -r lib/* || die

	libopts -m0755
	local my_lib
	for my_lib in $(find libraries -name '*.so') ; do
		java-pkg_sointo "${JAVA_PKG_SHAREPATH}/$(dirname ${my_lib})"
		java-pkg_doso "${my_lib}" || die
		rm "${my_lib}" || die
	done

	insinto "${JAVA_PKG_SHAREPATH}"
	doins -r libraries revisions.txt tools || die

	if use examples ; then
		java-pkg_doexamples examples/* || die
		dosym /usr/share/doc/${PF}/examples "${JAVA_PKG_SHAREPATH}/examples" || die
	fi

	if use doc ; then 
		java-pkg_dohtml -r reference/* || die
		dosym /usr/share/doc/${PF}/html "${JAVA_PKG_SHAREPATH}/reference" || die
	fi

	touch my_launcher_preamble
	if use amd64 ; then
		local my_java=$(dirname $(find /opt/emul-linux-x86-java* -name java | head -n 1))
		ewarn ${my_java}
		echo "export PATH=\"${my_java}\":\${PATH}" >> my_launcher_preamble
	fi 
	java-pkg_dolauncher ${PN} --into /usr/bin \
		--main processing.app.Base --pwd "${JAVA_PKG_SHAREPATH}" \
		-pre my_launcher_preamble
	make_desktop_entry /usr/bin/${PN} "Processing" \
		"${JAVA_PKG_JARDEST}/export/loading.gif" "Development" 
}
