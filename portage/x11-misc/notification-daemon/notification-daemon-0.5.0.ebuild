# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/notification-daemon/notification-daemon-0.5.0.ebuild,v 1.14 2014/06/02 17:56:49 ssuominen Exp $

EAPI=5
GCONF_DEBUG=no
GNOME2_LA_PUNT=yes
GNOME_TARBALL_SUFFIX=bz2

inherit autotools eutils gnome2

DESCRIPTION="Notification daemon"
HOMEPAGE="http://git.gnome.org/browse/notification-daemon/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2
	>=x11-libs/gtk+-2.18:2
	>=dev-libs/dbus-glib-0.100
	>=sys-apps/dbus-1
	media-libs/libcanberra
	x11-libs/libnotify
	x11-libs/libwnck:1
	x11-libs/libX11
	!x11-misc/notify-osd
	!x11-misc/qtnotifydaemoni
	=gnome-base/gconf-2.32.4-r1"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.50
	gnome-base/gnome-common
	>=sys-devel/gettext-0.18
	virtual/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-libnotify-0.7.patch \
		"${FILESDIR}"/${P}-underlinking.patch

	eautoreconf

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure --disable-static
}