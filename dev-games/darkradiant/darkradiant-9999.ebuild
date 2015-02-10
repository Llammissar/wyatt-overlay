# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit base autotools git-2

DESCRIPTION="Open source idTech 4 editor"
HOMEPAGE="http://darkradiant.sourceforge.net"
EGIT_REPO_URI="git://github.com/orbweaver/DarkRadiant.git"
#SRC_URI="https://github.com/orbweaver/DarkRadiant"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="" # Do it later

DEPEND="" # Later
RDEPEND="${DEPEND}"

src_unpack() {
	default
	git-2_src_unpack
	cd "${S}"
}
src_prepare() {
#	if [[ ! -e configure ]] ; then
#		./autogen.sh || die "autogen.sh failed"
#	fi
	eautoreconf || die "configure failed"
}

src_configure() {
	econf
}

src_install() {
	emake DESTDIR="${D}" install || die
}
