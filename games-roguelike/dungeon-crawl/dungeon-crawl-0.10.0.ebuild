# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Adapted from something on the forums.

EAPI=3
inherit games

DESCRIPTION="Dungeon Crawl Stone Soup is an open-source, roguelike game of exploration and treasure-hunting."
HOMEPAGE="http://crawl.develz.org/wordpress/"
SRC_URI="http://downloads.sourceforge.net/project/crawl-ref/Stone%20Soup/%{PV}/stone_soup-${PV}-nodeps.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="X"

DEPEND="media-libs/sdl-image"
RDEPEND="${DEPEND}"

S="${WORKDIR}/stone_soup-${PV}/source"

soup_make_arguments() {
	   use X && echo TILES=y
}

src_compile() {
		emake $(soup_make_arguments) || die
}

src_install() {
		emake $(soup_make_arguments) prefix="${D}"/usr/games install || die
}
