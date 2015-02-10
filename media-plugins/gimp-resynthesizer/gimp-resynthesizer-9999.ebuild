# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gimp-resynthesizer/gimp-resynthesizer-0.16.ebuild,v 1.2 2010/03/27 22:19:12 spatz Exp $

EAPI=2

inherit eutils toolchain-funcs autotools git-2

MY_PN="${PN#gimp-}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="GIMP plug-ing for texture synthesis"
HOMEPAGE="http://www.logarithmic.net/pfh/resynthesizer"
#SRC_URI="http://www.logarithmic.net/pfh-files/${MY_PN}/${MY_P}.tar.gz"
EGIT_REPO_URI="git://github.com/bootchk/resynthesizer.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-gfx/gimp"
RDEPEND="${DEPEND}"

#S="${WORKDIR}/${MY_P}"
S=${WORKDIR}

src_unpack() {
	default
	git-2_src_unpack
	cd "${S}"
	pwd
}

src_prepare() {
#	epatch "${FILESDIR}/${P}-makefile.patch"
#	if has_version ">=dev-libs/glib-2.32"; then
#		epatch "${FILESDIR}"/${PN}-glib-232.patch
#	fi
#	AC_CONFIG_SUBDIRS="src"
#	eautoconf | die "autoconf failed"
#	eautomake | die "automake failed"
	eautoreconf | die "configure failed"
	#eautoreconf
	echo "AFTER AUTORECONF"
	tc-export CXX
}

src_install() {
#	exeinto $(gimptool-2.0 --gimpplugindir)/plug-ins
#	doexe resynth || die
	emake DESTDIR="$(gimptool-2.0 --gimpplugindir)/plug-ins" install || die
#	insinto $(gimptool-2.0 --gimpdatadir)/scripts
#	doins smart-enlarge.scm smart-remove.scm || die

	dodoc README || die
}

pkg_postinst() {
	elog "The Resynthesizer plugin is accessible from the menu:"
	elog "* Filters -> Map -> Resynthesize"
	elog "* Filters -> Enhance -> Smart enlarge/sharpen"
	elog "* Filters -> Enhance -> Heal selection"
}
