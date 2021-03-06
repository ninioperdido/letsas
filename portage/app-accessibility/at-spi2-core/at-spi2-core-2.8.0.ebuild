# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-accessibility/at-spi2-core/at-spi2-core-2.8.0.ebuild,v 1.7 2013/12/24 15:08:26 pacho Exp $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2

DESCRIPTION="D-Bus accessibility specifications and registration daemon"
HOMEPAGE="http://live.gnome.org/Accessibility"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
IUSE="+introspection crossdev"

# x11-libs/libSM is needed until upstream #719808 is solved either
# making the dep unneeded or fixing their configure
RDEPEND="
	>=dev-libs/glib-2.28:2
	>=sys-apps/dbus-1
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXtst
	introspection? ( >=dev-libs/gobject-introspection-0.9.6 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

src_prepare() {
	# disable teamspaces test since that requires Novell.ICEDesktop.Daemon
	epatch "${FILESDIR}/${PN}-2.0.2-disable-teamspaces-test.patch"

	gnome2_src_prepare
}

src_configure() {
	# xevie is deprecated/broken since xorg-1.6/1.7
	if use crossdev; then
	    CC=i586-pc-linux-gnu-gcc \
		LD_LIBRARY_PATH="/usr/i586-pc-linux-gnu/usr/lib:/usr/i586-pc-linux-gnu/lib" \
		LIBRARY_PATH="/usr/i586-pc-linux-gnu/usr/lib:/usr/i586-pc-linux-gnu/lib"\
		./configure \
		--build=i586-pc-linux-gnu \
		--host=i586-pc-linux-gnu \
		-n-target=i586-pc-linux-gnu
    else	
		gnome2_src_configure \
			--disable-xevie \
			$(use_enable introspection)
	fi
}
