# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://haxe.googlecode.com/svn/tags/v2-10"
ESVN_PROJECT="${P}"

inherit eutils subversion

DESCRIPTION="An object-oriented universal language for JavaScript, Flash, and Neko."
HOMEPAGE="http://haxe.org/"

LICENSE="GPL"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/ocaml sys-libs/zlib"
RDEPEND=""
#S="${WORKDIR}"

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	emake libs || die "emake failed"
	emake haxe || die "emake failed"
}

src_install() {
	dobin haxe
	dodir /usr/lib/haxe/std
	cp -pPR std ${D}/usr/lib/haxe/
	dodoc doc/*.txt

	local envfilename="50haxe"
	HAXE_LIBRARY_PATH=/usr/lib/haxe/std:.
	echo "HAXE_LIBRARY_PATH=$HAXE_LIBRARY_PATH" > ${envfilename}
# It's not clear HAXE_HOME is serving a purpose
#	HAXE_HOME=/usr/local/haxe
#	echo "HAXE_HOME=$HAXE_HOME" >> ${envfilename}
#	echo "PATH=$HAXE_LIBRARY_PATH:$HAXE_HOME/bin" >> ${envfilename}
	echo "PATH=$HAXE_LIBRARY_PATH" >> ${envfilename}
	doenvd ${envfilename}
}
