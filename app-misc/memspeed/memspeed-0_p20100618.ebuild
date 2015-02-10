# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils toolchain-funcs

DESCRIPTION="Benchmark the speed main memory (RAM)"
HOMEPAGE="http://mama.indstate.edu/users/ice/progs.html"
SRC_URI="http://mama.indstate.edu/users/ice/progs/${PN}.c -> ${P}.c"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	echo $(tc-getCC) ${CFLAGS} ${LDFLAGS} -o ${PN} "${DISTDIR}"/${P}.c
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o ${PN} "${DISTDIR}"/${P}.c || die
}

src_install() {
	dobin ${PN} || die
}
