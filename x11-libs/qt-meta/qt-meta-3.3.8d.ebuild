# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"
inherit eutils flag-o-matic toolchain-funcs

SRCTYPE="free"
DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trinitydesktop.org/"

SRC_URI="mirror://tde-mirror/releases/3.5.13/dependencies/qt3-3.3.8.d.tar.gz"

LICENSE="|| ( QPL-1.0 GPL-2 GPL-3 )"

SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE="cups debug doc examples firebird ipv6 mysql nas nis odbc opengl postgres sqlite xinerama"

RDEPEND="
	virtual/jpeg
	media-libs/freetype:2
	media-libs/libmng
	media-libs/libpng
	sys-libs/zlib
	x11-libs/libXft
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libSM
	cups? ( net-print/cups )
	firebird? ( dev-db/firebird )
	mysql? ( virtual/mysql )
	nas? ( >=media-libs/nas-1.5 )
	opengl? ( virtual/opengl virtual/glu )
	postgres? ( dev-db/postgresql-base )
	xinerama? ( x11-libs/libXinerama )"
	
DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xextproto
	xinerama? ( x11-proto/xineramaproto )"

PDEPEND="odbc? ( ~dev-db/qt-unixODBC-$PV )"

S="${WORKDIR}/qt3"

QTBASE="/usr/qt/3"

PATCHES="000-qiconview-finditem.patch
	001-qiconview-rebuildcontainer.patch
	002-qiconview-ctrl_rubber.patch
	003-designer-deletetabs.patch
	004-qvaluelist-streaming-operator.patch
	005-qprogressbar-optimization.patch
	006-qiconview-no-useless-scrollbar.patch
	007-qiconview-rubber_on_move.patch
	008-argb-visual-hack.patch
	009-fix-xinput-clash.patch
	010-buffered-iconview.patch
	011-qlistbox-eyecandy.patch
	013-print-CJK.patch
	015-visibility.patch
	016-gcc4.patch
	gcc46-arch.patch
	qt-3.3.8d-libpng15.patch
	qt-unixodbc.patch"

pkg_setup() {

	export QTDIR="${S}"

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		PLATCXX="g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		PLATCXX="icc"
	else
		die "Unknown compiler ${CXX}."
	fi

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			PLATNAME="freebsd" ;;
		*-openbsd*)
			PLATNAME="openbsd" ;;
		*-netbsd*)
			PLATNAME="netbsd" ;;
		*-darwin*)
			PLATNAME="darwin" ;;
		*-linux-*|*-linux)
			PLATNAME="linux" ;;
		*)
			die "Unknown CHOST, no platform choosed."
	esac

	# probably this should be '*-64' for 64bit archs
	# in a fully multilib environment (no compatibility symlinks)
	export PLATFORM="${PLATNAME}-${PLATCXX}"
}

src_prepare() {

	# auto-accept licence	
	sed -i -e 's:read acceptance:acceptance=yes:' configure

	# Apply patches
	for patch in ${PATCHES};do
		epatch "${FILESDIR}/${patch}";
	done
	
	sed -i -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		   -e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		   -e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		   -e "s:\<QMAKE_CC\>.*=.*:QMAKE_CC=$(tc-getCC):" \
		   -e "s:\<QMAKE_CXX\>.*=.*:QMAKE_CXX=$(tc-getCXX):" \
		   -e "s:\<QMAKE_LINK\>.*=.*:QMAKE_LINK=$(tc-getCXX):" \
		   -e "s:\<QMAKE_LINK_SHLIB\>.*=.*:QMAKE_LINK_SHLIB=$(tc-getCXX):" \
		"${S}"/mkspecs/${PLATFORM}/qmake.conf || die

	if [ $(get_libdir) != "lib" ] ; then
		sed -i -e "s:/lib$:/$(get_libdir):" \
			"${S}"/mkspecs/${PLATFORM}/qmake.conf || die
	fi

	sed -i -e "s:CXXFLAGS.*=:CXXFLAGS=${CXXFLAGS} :" \
		   -e "s:LFLAGS.*=:LFLAGS=${LDFLAGS} :" \
		"${S}"/qmake/Makefile.unix || die
}


src_configure() {
	export SYSCONF="${D}${QTBASE}"/etc/settings

	# Let's just allow writing to these directories during Qt emerge
	# as it makes Qt much happier.
	addwrite "${QTBASE}/etc/settings"
	addwrite "${HOME}/.qt"

	[ "$(get_libdir)" != "lib" ] && myconf="${myconf} -L/usr/$(get_libdir)"

	# unixODBC support is now a PDEPEND on dev-db/qt-unixODBC; see bug 14178.
	use nas		&& myconf+=" -system-nas-sound"
	use nis		&& myconf+=" -nis" || myconf+=" -no-nis"
	use mysql	&& myconf+=" -plugin-sql-mysql -I/usr/include/mysql -L/usr/$(get_libdir)/mysql" || myconf+=" -no-sql-mysql"
	use postgres	&& myconf+=" -plugin-sql-psql -I/usr/include/postgresql/server -I/usr/include/postgresql/pgsql -I/usr/include/postgresql/pgsql/server" || myconf+=" -no-sql-psql"
	use firebird    && myconf+=" -plugin-sql-ibase -I/opt/firebird/include" || myconf+=" -no-sql-ibase"
	use sqlite	&& myconf+=" -plugin-sql-sqlite" || myconf+=" -no-sql-sqlite"
	use cups	&& myconf+=" -cups" || myconf+=" -no-cups"
	use opengl	&& myconf+=" -enable-module=opengl" || myconf+=" -disable-opengl"
	use debug	&& myconf+=" -debug" || myconf+=" -release -no-g++-exceptions"
	use xinerama    && myconf+=" -xinerama" || myconf+=" -no-xinerama"

	myconf="${myconf} -system-zlib -qt-gif"

	use ipv6        && myconf+=" -ipv6" || myconf+=" -no-ipv6"

	export YACC='byacc -d'
	tc-export CC CXX
	export LINK="$(tc-getCXX)"

	./configure -sm -thread -stl -system-libjpeg -verbose -largefile \
		-qt-imgfmt-{jpeg,mng,png} -tablet -system-libmng \
		-system-libpng -xft -platform ${PLATFORM} -xplatform \
		${PLATFORM} -xrender -prefix ${QTBASE} -libdir ${QTBASE}/$(get_libdir) \
		-fast -no-sql-odbc ${myconf} -dlopen-opengl || die
}

src_compile() {
	emake src-qmake src-moc sub-src || die

	export DYLD_LIBRARY_PATH="${S}/lib:/usr/X11R6/lib:${DYLD_LIBRARY_PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	emake sub-tools || die

	if use examples; then
		emake sub-tutorial sub-examples || die
	fi

	# Make the msg2qm utility (not made by default)
	cd "${S}"/tools/msg2qm
	../../bin/qmake
	emake

	# Make the qembed utility (not made by default)
	cd "${S}"/tools/qembed
	../../bin/qmake
	emake

}

src_install() {
	# binaries
	into ${QTBASE}
	dobin bin/*
	dobin tools/msg2qm/msg2qm
	dobin tools/qembed/qembed

	# libraries
	dolib.so lib/lib{editor,qassistantclient,designercore}.a
	dolib.so lib/libqt-mt.la
	dolib.so lib/libqt-mt.so.${PV/d} lib/libqui.so.1.0.0
	cd "${D}"/${QTBASE}/$(get_libdir)

	for x in libqui.so ; do
		ln -s $x.1.0.0 $x.1.0
		ln -s $x.1.0 $x.1
		ln -s $x.1 $x
	done

	# version symlinks - 3.3.5->3.3->3->.so
	ln -s libqt-mt.so.${PV/d} libqt-mt.so.3.3
	ln -s libqt-mt.so.3.3 libqt-mt.so.3
	ln -s libqt-mt.so.3 libqt-mt.so

	# libqt -> libqt-mt symlinks
	ln -s libqt-mt.so.${PV/d} libqt.so.${PV/d}
	ln -s libqt-mt.so.3.3 libqt.so.3.3
	ln -s libqt-mt.so.3 libqt.so.3
	ln -s libqt-mt.so libqt.so

	# plugins
	cd "${S}"
	local plugins=$(find plugins -name "lib*.so" -print)
	for x in ${plugins}; do
		exeinto ${QTBASE}/$(dirname ${x})
		doexe ${x}
	done

	# Past this point just needs to be done once
	is_final_abi || return 0

	# includes
	cd "${S}"
	dodir ${QTBASE}/include/private
	cp include/*\.h "${D}"/${QTBASE}/include/
	cp include/private/*\.h "${D}"/${QTBASE}/include/private/

	# prl files
	sed -i -e "s:${S}:${QTBASE}:g" "${S}"/lib/*.prl
	insinto ${QTBASE}/$(get_libdir)
	doins "${S}"/lib/*.prl

	# pkg-config file
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${S}"/lib/*.pc

	# List all the multilib libdirs
	local libdirs
	for alibdir in $(get_all_libdirs); do
		libdirs="${libdirs}:${QTBASE}/${alibdir}"
	done

	# environment variables
	cat <<EOF > "${T}"/45qt3
PATH=${QTBASE}/bin
ROOTPATH=${QTBASE}/bin
LDPATH=${libdirs:1}
QMAKESPEC=${PLATFORM}
MANPATH=${QTBASE}/doc/man
EOF

	cat <<EOF > "${T}"/50qtdir3
QTDIR=${QTBASE}
EOF

	cat <<EOF > "${T}"/50-qt3-revdep
SEARCH_DIRS="${QTBASE}"
EOF

	insinto /etc/revdep-rebuild
	doins "${T}"/50-qt3-revdep

	doenvd "${T}"/45qt3 "${T}"/50qtdir3

	if [ "${SYMLINK_LIB}" = "yes" ]; then
		dosym $(get_abi_LIBDIR ${DEFAULT_ABI}) ${QTBASE}/lib
	fi

	insinto ${QTBASE}/tools/designer
	doins -r tools/designer/templates

	insinto ${QTBASE}
	doins -r translations

	keepdir ${QTBASE}/etc/settings

	if use doc; then
		insinto ${QTBASE}
		doins -r "${S}"/doc
	fi

	if use examples; then
		find "${S}"/examples "${S}"/tutorial -name Makefile | \
			xargs sed -i -e "s:${S}:${QTBASE}:g"

		cp -r "${S}"/examples "${D}"${QTBASE}/
		cp -r "${S}"/tutorial "${D}"${QTBASE}/
	fi

	# misc build reqs
	insinto ${QTBASE}/mkspecs
	doins -r "${S}"/mkspecs/${PLATFORM}

	sed -e "s:${S}:${QTBASE}:g" \
		"${S}"/.qmake.cache > "${D}"${QTBASE}/.qmake.cache

	dodoc FAQ README README-QT.TXT changes*

}

pkg_postinst() {
	echo
	elog "After a rebuild of Qt, it can happen that Qt plugins (such as Qt/KDE styles,"
	elog "or widgets for the Qt designer) are no longer recognized.  If this situation"
	elog "occurs you should recompile the packages providing these plugins,"
	elog "and you should also make sure that Qt and its plugins were compiled with the"
	elog "same version of GCC.  Packages that may need to be rebuilt are, for instance,"
	elog "kde-base/kdelibs, kde-base/kdeartwork and kde-base/kdeartwork-styles."
	elog "See http://doc.trolltech.com/3.3/plugins-howto.html for more infos."
	echo
}
