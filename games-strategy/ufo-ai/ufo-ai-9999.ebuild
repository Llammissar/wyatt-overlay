# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/ufo-ai/ufo-ai-2.2.1.ebuild,v 1.1 2008/10/04 19:46:06 tupone Exp $

inherit eutils autotools games subversion
#MY_P="${P/o-a/oa}"

DESCRIPTION="UFO: Alien Invasion - X-COM inspired strategy game"
HOMEPAGE="http://ufoai.sourceforge.net/"
ESVN_REPO_URI="https://ufoai.svn.sourceforge.net/svnroot/ufoai/ufoai/trunk"
#SRC_URI="mirror://sourceforge/ufoai/${MY_P}-source.tar.bz2
#	mirror://sourceforge/ufoai/${MY_P}-data.tar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug dedicated doc editor i18n maps mmx"

# Dependencies and more instructions can be found here:
# http://ufoai.ninex.info/wiki/index.php/Compile_for_Linux
# Editor dependencies are from:
# http://ufoai.ninex.info/wiki/index.php/Mapping/UFORadiant_Installation
RDEPEND="!dedicated? (
		virtual/opengl
		virtual/glu
		media-libs/libsdl
		media-libs/sdl-ttf
		media-libs/sdl-mixer
		media-libs/jpeg
		media-libs/libpng
		media-libs/libogg
		media-libs/libvorbis
		x11-proto/xf86vidmodeproto
	)
	editor? (
	media-libs/jpeg
	x11-libs/gtk+:2
	x11-libs/gtkglext
	dev-libs/libxml2
	)
	net-misc/curl
	sys-devel/gettext"

DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )"

# S=${WORKDIR}/${MY_P}-source

pkg_setup() {
	echo
	ewarn "WARNING! This is an experimental ebuild of the ${PN} SVN tree. Use at your own risk."
	ewarn "Do _NOT_ file bugs at  bugs.gentoo.org because of this ebuild!"
	echo
	if use dedicated; then
		einfo "You're building the dedicated server version of UFO:AI"
		einfo "If you want to play as a user locally, disable the dedicated USE flag."
	fi
}

#src_prepare() {
#	base_src_prepare
#}

#src_unpack() {
#	unpack ${A}
#	cd "${S}"
#	# move data from packages to source dir
#	mv "${WORKDIR}/base" "${S}"
#
#	# Set basedir & fixes bug in finding text files - it should use fs_basedir
##	epatch "${FILESDIR}"/${P}-gentoo.patch
#
#	sed -i \
#		-e "s:@GENTOO_DATADIR@:${GAMES_DATADIR}/${PN}:" \
#		src/common/files.c \
#		src/tools/gtkradiant/games/ufoai.game \
#		src/client/cl_main.c \
#		src/client/cl_language.c \
#		|| die "sed failed"
#}

src_compile() {
# There's a "paranoid" config option.  No clue what it does though. Ignorinf for
# now.
	egamesconf 
		$(use_enable mmx) \
		$(use_enable debug release no) \  # Disabling release is a debug build
		$(use_enable debug profiling) \   # Debug probably wants profiling, no?
		$(use_enable editor ufo2map) \  # map builder
		$(use_enable editor uforadiant) \  # GTK editor
		--enable-dedicated \  # You always want dedicated at least
		$(use_enable !dedicated client) \
		--with-shaders

	emake lang || die "emake langs failed"

	if use doc ; then
		emake pdf-manual || die "emake pdf-manual failed (USE=doc)"
	fi

	if use i18n ; then
		emake lang || die "emake lang failed (USE=i19n)"
	fi

	if use maps ; then
		emake maps || die "emake maps failed (USE=maps)"
	fi

	if use pk3 ; then
		emake pk3 || die "emake pk3 failed (USE=pk3)"
	fi

	emake || die "emake failed"
}

src_install() {
	# server
	dogamesbin ufoded || die "Failed installing server"
	newicon src/ports/linux/installer/data/ufo.xpm ${PN}.xpm \
		|| die "Failed installing icon"
	make_desktop_entry ${PN}-ded "UFO: Alien Invasion Server" ${PN}.xpm
	if ! use dedicated ; then
		# client
		newgamesbin ufo ${PN} || die "Failed installing client"
		make_desktop_entry ${PN} "UFO: Alien Invasion" ${PN}.xpm
	fi

	if use editor ; then
		dogamesbin ufo2map || die "Failed installing editor"
	fi

	insinto "${GAMES_DATADIR}"/${PN}
	doins -r base || die "doins -r failed"
	if use doc ; then
		dodoc src/docs/tex/ufo-manual_EN.pdf || die "Failed installing manual"
	fi

	prepgamesdirs
}
