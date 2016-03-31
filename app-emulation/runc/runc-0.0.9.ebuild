# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

GOLANG_PKG_IMPORTPATH="github.com/opencontainers"
GOLANG_PKG_ARCHIVEPREFIX="v"
GOLANG_PKG_HAVE_TEST=1
GOLANG_PKG_USE_CGO=1

inherit golang-single

DESCRIPTION="A CLI tool for spawning and running containers according to the OCF specs"
HOMEPAGE="http://runc.io"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE+=" seccomp"

RESTRICT+=" test"

src_compile() {
	use seccomp && GOLANG_PKG_TAGS="seccomp"
	golang-single_src_compile
}