# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Toolkit for graphical applications"
HOMEPAGE="http://libagar.org"

SRC_URI="http://stable.csoft.org/agar/${P}.tar.gz"

# The package uses its own license:
# http://libagar.org/license.html
# (slightly modified BSD)
LICENSE="Agar"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="debug jpeg nls opengl truetype"

RDEPEND=" 
	jpeg?		( >=media-libs/jpeg-6b-r7 )
	nls?		( >=sys-devel/gettext-0.16.1-r1 )
	opengl?		( >=virtual/opengl-7.0 )
	truetype?	( >=media-libs/freetype-2.1.10-r3 )
				>=media-libs/libsdl-1.2.11-r2 
		"
DEPEND="${RDEPEND}"

src_unpack() {
	
	unpack ${A}
	cd ${S}
	
	# patches:
	# the ./configure script does not recognize few econf arguments,
	# to simplyfy configuration phase, we just patch the script
	# not to break if unknown argument was defined.
	epatch ${FILESDIR}/agar-1.3.2_configure.patch	

}


src_compile() {
	
	econf \
		$(use_enable debug ) \
		$(use_enable debug lockdebug ) \
		$(use_enable debug warnings ) \
		$(use_enable nls ) \
		\
		$(use_with jpeg) \
		$(use_with nls gettext) \
		$(use_with opengl gl) \
		$(use_with truetype freetype) \
			|| die "econf failed"
			
	emake depend all || die "emake depend failed"

}

src_install() {

	# Makefile never heard about DESTDIR
	# We must overwrite variables in Makefile.config
	prefix="${D}"/usr
	emake \
		PREFIX="${prefix}" \
		MANDIR="${prefix}"/share/man \
		INFODIR="${prefix}"/share/info \
		BINDIR="${prefix}"/bin \
		SHAREDIR="${prefix}"/share/"${P}" \
		LOCALEDIR="${prefix}"/share/"${P}"/locale \
		SYSCONFDIR="${D}"/etc \
		TTFDIR="${prefix}"/share/"${P}"/fonts \
		INCLDIR="${prefix}"/include \
		LIBDIR="${prefix}"/$(get_libdir) \
			install || die "emake install failed"

}

pkg_postinst() {

	elog
	elog "Agar developers kindly ask to let them know"
	elog "of successful compilation: compile@libagar.org."
	elog

}
