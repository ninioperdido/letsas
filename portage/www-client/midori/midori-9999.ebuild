# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/midori/midori-0.5.8-r1.ebuild,v 1.1 2014/07/22 10:36:03 ssuominen Exp $

EAPI=5

VALA_MIN_API_VERSION=0.16

PYTHON_COMPAT=( python2_7 )

unset _live_inherits

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="git://git.xfce.org/apps/${PN}"
	_live_inherits=git-2
else
	KEYWORDS="~amd64 ~arm ~mips ~x86 ~x86-fbsd"
	SRC_URI="http://www.${PN}-browser.org/downloads/${PN}_${PV}_all_.tar.bz2"
fi

inherit eutils fdo-mime gnome2-utils pax-utils python-any-r1 cmake-utils vala ${_live_inherits}

DESCRIPTION="A lightweight web browser based on WebKitGTK+"
HOMEPAGE="http://www.midori-browser.org/"

LICENSE="LGPL-2.1 MIT"
SLOT="0"
IUSE="deprecated doc granite introspection jit +webkit2 zeitgeist"

RDEPEND=">=dev-db/sqlite-3.6.19:3
	>=dev-libs/glib-2.32.3
	dev-libs/libxml2
	>=net-libs/libsoup-2.38:2.4
	>=net-libs/libsoup-gnome-2.38:2.4
	>=x11-libs/libnotify-0.7
	x11-libs/libXScrnSaver
	webkit2? ( >=net-libs/webkit-gtk-2.2.4 )
	!webkit2? ( >=net-libs/webkit-gtk-1.8.1:2[jit=] )
	granite? ( >=dev-libs/granite-0.2 )
	introspection? ( dev-libs/gobject-introspection )
	zeitgeist? ( >=dev-libs/libzeitgeist-0.3.14 )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	$(vala_depend)
	dev-util/intltool
	gnome-base/librsvg
	sys-devel/gettext
	doc? ( dev-util/gtk-doc )"
REQUIRED_USE="granite? ( !deprecated )
	introspection? ( deprecated )"

S=${WORKDIR}/${P}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-2_src_unpack
	else
		default
	fi
}

src_prepare() {
	vala_src_prepare
	sed -i -e '/install/s:COPYING:HACKING TODO TRANSLATE:' CMakeLists.txt || die
}

src_configure() {
	strip-linguas -i po

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/${PF}
		$(cmake-utils_use_use doc APIDOCS)
		$(cmake-utils_use_use introspection GIR)
		$(cmake-utils_use_use granite)
		$(cmake-utils_use_use zeitgeist)
		-DVALA_EXECUTABLE="${VALAC}"
		)
	
	if ! use webkit2; then
		mycmakeargs+=(
			-DHALF_BRO_INCOM_WEBKIT2=OFF
			)
	else
		$(cmake-utils_use webkit2 HALF_BRO_INCOM_WEBKIT2)
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}