# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils games

MY_PN="FrozenSynapse"
DESCRIPTION="Frozen Synapse is a thrilling strategy game"
HOMEPAGE="http://www.frozensynapse.com/"

HIBPAGE="http://www.humblebundle.com"
SRC_URI="${P}-linux-bin"
ZIP_OFFSET="192708"

RESTRICT="fetch"
LICENSE=""

SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="amd64? ( app-emulation/emul-linux-x86-sdl )
	 x86? ( media-libs/libsdl[audio,joystick,video] )"

S="${WORKDIR}/data"

GAMEDIR="${GAMES_PREFIX_OPT}/${PN}"

pkg_nofetch() {
	einfo ""
	einfo "Please buy and download \"${SRC_URI}\" from:"
	einfo "  ${HIBPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo ""
}

src_unpack() {
	tail --bytes=+$(( ${ZIP_OFFSET} + 1 )) "${DISTDIR}/${A}" > "${P}.zip" || die "tail \"${DISTDIR}/${A}\" failed"
	unpack "./${P}.zip" || die "unpack \"${P}\" failed"
	rm -f "${P}.zip" || die "remove \"${P}\" failed"
}

src_install() {
	insinto "${GAMEDIR}" || die "insinto \"${GAMEDIR}\" failed"
	exeinto "${GAMEDIR}" || die "exeinto \"${GAMEDIR}\" failed"

	# Install executable
	newexe "${MY_PN}" "${PN}" || die "newexe \"${MY_PN}\" failed"
	rm "${MY_PN}" || die "rm \"${icon}\" failed"

	# Make game wrapper
	games_make_wrapper "${PN}" "./${PN}" "${GAMEDIR}" || die "games_make_wrapper \"./${PN}\" failed"

	# Install icon and desktop file
	local icon="${PN}.png"
	doicon "${icon}" || die "newicon \"${icon}\" failed"
	make_desktop_entry "${PN}" "${MY_PN}" "/usr/share/pixmaps/${icon}" || die "make_desktop_entry failed"
	rm "${icon}" || die "rm \"${icon}\" failed"

	# Install documentation
	find * -maxdepth 0 -type f -iname Readme*.txt -exec dodoc '{}' \; -exec rm '{}' \; || die "dodoc failed"

	# Install data
	find * -maxdepth 0 ! \( -type f -executable -o -iname *.log \) -exec doins -r '{}' \; || die "doins data failed"

	# Setting permissions
	prepgamesdirs
}

pkg_postinst() {
	echo ""
	games_pkg_postinst

	einfo "Please report any bugs here:"
	einfo "   http://bugzilla.icculus.org/"
	echo ""
	einfo "${MY_PN} savegames and configurations are stored in:"
	einfo "   \${HOME}/.local/share/${MY_PN}"
	echo ""
}
