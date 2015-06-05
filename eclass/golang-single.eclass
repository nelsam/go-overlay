# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: golang-single.eclass
# @MAINTAINER:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @AUTHOR:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @BLURB: An eclass for Golang packages not installed inside GOPATH/GOBIN.
# @DESCRIPTION:
# This eclass allows to install arbitrary packages written in Golang which
# don't support being installed inside the Go environment.
# This mostly includes traditional packages (C/C++/GUI) embedding tools written
# in Golang, and Golang packages that need to be compiled with gcc instead of
# the standard Go interpreter.
#
# @EXAMPLE:
# Typical ebuild using golang-single.eclass:
#
# @CODE
# EAPI=5
#
# GOLANG_PKG_IMPORTPATH="github.com/captObvious"
# GOLANG_PKG_SUFFIX=".zip"
# GOLANG_PKG_HAVE_TEST
# inherit golang-single qt4-r2
#
# DESCRIPTION="Foo bar application"
# HOMEPAGE="http://example.org/foo/"
#
# LICENSE="MIT"
# KEYWORDS="~amd64 ~x86"
# SLOT="0"
# IUSE="debug doc qt4"
#
# CDEPEND="
#   qt4? (
#       dev-qt/qtcore:4
#       dev-qt/qtgui:4
#   )"
# RDEPEND="${CDEPEND}
#   !media-gfx/bar"
# DEPEND="${CDEPEND}
#   doc? ( app-doc/doxygen )"
#
# DOCS=(AUTHORS ChangeLog README "Read me.txt" TODO)
#
# PATCHES=(
#   "${FILESDIR}/${P}-qt4.patch" # bug 123458
#   "${FILESDIR}/${P}-as-needed.patch"
# )
#
# src_install() {
#   use doc && HTML_DOCS=("${BUILD_DIR}/apidocs/html/")
#   autotools-utils_src_install
#   if use examples; then
#       dobin "${BUILD_DIR}"/foo_example{1,2,3} \\
#           || die 'dobin examples failed'
#   fi
# }
#
# @CODE


inherit base multiprocessing

RESTRICT+="mirror"

QA_FLAGS_IGNORED="usr/bin/.*
	usr/sbin/.*"

EXPORT_FUNCTIONS pkg_setup src_unpack src_configure src_compile src_install src_test

# @ECLASS-VARIABLE: GOLANG_PKG_DEPEND_ON_GO_SUBSLOT
# @DESCRIPTION:
# Set to ensure the package does depend on the dev-lang/go subslot value.
# Possible values: {yes,no}
GOLANG_PKG_DEPEND_ON_GO_SUBSLOT=${GOLANG_PKG_DEPEND_ON_GO_SUBSLOT:="no"}


# Silence repoman warnings
case "${EAPI:-0}" in
	5)
		case "${GOLANG_PKG_DEPEND_ON_GO_SUBSLOT:-yes}" in
			yes)
				GO_DEPEND="dev-lang/go:0="
				;;
			*)
				GO_DEPEND="dev-lang/go:*"
				;;
		esac
		;;
	*)
		die "EAPI=${EAPI} is not supported by golang-single.eclass"
		;;
esac
DEPEND+=" ${GO_DEPEND}"

S="${WORKDIR}/gopath"

# @ECLASS-VARIABLE: GOLANG_PKG_NAME
# @DESCRIPTION:
# Sets the Golang name for the generated package.
# GOLANG_PKG_NAME="${PN}"
GOLANG_PKG_NAME="${GOLANG_PKG_NAME:-${PN}}"

# @ECLASS-VARIABLE: GOLANG_PKG_VERSION
# @DESCRIPTION:
# Sets the Golang version for the generated package.
# GOLANG_PKG_VERSION="${PV}"
GOLANG_PKG_VERSION="${GOLANG_PKG_VERSION:-${PV/_pre/.pre}}"

# @ECLASS-VARIABLE: GOLANG_PKG_IMPORTPATH
# @DESCRIPTION:
# Sets the remote import path for the generated package.
# GOLANG_PKG_IMPORTPATH="github.com/captObvious/"
GOLANG_PKG_IMPORTPATH="${GOLANG_PKG_IMPORTPATH:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_IMPORTPATH_ALIAS
# @DESCRIPTION:
# Sets an alias of the remote import path for the generated package.
# GOLANG_PKG_IMPORTPATH_ALIAS="privaterepo.com/captObvious/"
GOLANG_PKG_IMPORTPATH_ALIAS="${GOLANG_PKG_IMPORTPATH_ALIAS:="${GOLANG_PKG_IMPORTPATH}"}"

# @ECLASS-VARIABLE: GOLANG_PKG_PREFIX
# @DESCRIPTION:
# Sets the tarball prefix for the file URI of the package.
# Most projects hosted on GitHub's mirrors provide tarballs with prefix as
# 'v' or 'source-', other hosted services offer different archive formats.
# This eclass defaults to an empty prefix.
GOLANG_PKG_PREFIX="${GOLANG_PKG_PREFIX:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_SUFFIX
# @DESCRIPTION:
# Sets the tarball suffix for the file URI of the package.
# Most projects hosted on GitHub's mirrors provide tarballs with suffix as
# '.tar.gz' or '.zip', other hosted services offer different archive formats.
# This eclass defaults to '.tar.gz'.
GOLANG_PKG_SUFFIX="${GOLANG_PKG_SUFFIX:=".tar.gz"}"

# @ECLASS-VARIABLE: GOLANG_PKG_OUTPUT_NAME
# @DESCRIPTION:
# TODO
GOLANG_PKG_OUTPUT_NAME="${GOLANG_PKG_OUTPUT_NAME:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_OUTPUT_NAME
# @DESCRIPTION:
# TODO
GOLANG_PKG_BUILDPATH="${GOLANG_PKG_BUILDPATH:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_HAVE_TEST
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to enable the execution of automated testing.

# @ECLASS-VARIABLE: GO
# @DEFAULT_UNSET
# @DESCRIPTION:
# The absolute path to the current Golang interpreter.
#
# This variable is set automatically after calling golang-single_pkg_setup().
#
# Default value:
# @CODE
# /usr/bin/go
# @CODE

# @ECLASS-VARIABLE: EGO
# @DEFAULT_UNSET
# @DESCRIPTION:
# The executable name of the current Golang interpreter.
#
# This variable is set automatically after calling golang-single_pkg_setup().
#
# Default value:
# @CODE
# go
# @CODE


if [[ -z ${GOLANG_PKG_IMPORTPATH} ]]; then
	eerror "The remote import path for this package has not been declared"
	die "Mandatary variable GOLANG_PKG_IMPORTPATH is unset"
fi

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
if [[ ${GOLANG_PKG_SUFFIX/.*} == "xz" ]]; then
	DEPEND+=" app-arch/xz-utils"
fi

if [[ -n ${GOLANG_PKG_HAVE_TEST} ]]; then
	IUSE+=" test"
fi

# We use GOLANG_PKG_IMPORTPATH to populate SRC_URI
SRC_URI="https://${GOLANG_PKG_IMPORTPATH}/${GOLANG_PKG_NAME}/archive/${GOLANG_PKG_PREFIX}${GOLANG_PKG_VERSION}${GOLANG_PKG_SUFFIX} -> ${P}${GOLANG_PKG_SUFFIX}"

# We use GOLANG_PKG_IMPORTPATH associative array to populate SRC_URI with
# the snapshots of the required golang depencies
if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then

	for module in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

		# Strip all the white spaces
		local DEPENDENCY="${GOLANG_PKG_DEPENDENCIES[$module]//\ /}"

		# Strip the alias
		DEPENDENCY="${DEPENDENCY%%->*}"

		# Determine the import path and revision tag
		local _importpath="${DEPENDENCY%:*}"
		local _revision="${DEPENDENCY#*:}"

		debug-print "${FUNCNAME}: DEPENDENCY = {DEPENDENCY}"
		debug-print "${FUNCNAME}: importpath = ${_importpath}"
		debug-print "${FUNCNAME}: revision = ${_revision}"

		SRC_URI+=" https://${_importpath}/archive/${_revision}${GOLANG_PKG_SUFFIX} -> ${PN}-${_importpath//\//-}-${_revision}${GOLANG_PKG_SUFFIX}"
	done
fi


# @FUNCTION: golang-single_pkg_setup
# @DESCRIPTION:
# Runs pkg_setup.
# Determine where is the Golang implementation and set Golang build environment.
golang-single_pkg_setup() {
	debug-print-function ${FUNCNAME} "${@}"

	# Keep /usr/bin/go as index [0] and never overwrite it,
	# always append other binary paths after the index [0]
	local GOLANG_BINS=(
		/usr/bin/go
		/usr/bin/gofmt
	)

	unset EGO

	# Determine is the golang interpreter is working
	local IS_EXECUTABLE=1
	for binary in "${GOLANG_BINS[@]}"; do
		debug-print "${FUNCNAME}: Cheching ... ${binary}"

		[[ -x "${EPREFIX}/${binary}" ]] && continue
		IS_EXECUTABLE=0
		ewarn "It seems that the binary '${binary}' is not executable."
	done

	# dev-lang/go isn't installed or one of its binaries aren't executable.
	# Either way, the gentoo box is screwed; no need to setup up the golang env.
	[[ ${IS_EXECUTABLE} == 0 ]] && exit

	# dev-lang/go is available and working.
	# Exports EGO/GO global variables
	export GO="${GOLANG_BINS[0]}"
	debug-print "${FUNCNAME}: GO = ${GO}"
	export EGO="$( basename ${GOLANG_BINS[0]} )"
	debug-print "${FUNCNAME}: EGO = ${EGO}"

	# Determines go interpreter version
	local GOLANG_VERSION="$( ${GO} version )"
	GOLANG_VERSION="${GOLANG_VERSION/go\ version\ go}"
	GOLANG_VERSION="${GOLANG_VERSION%\ *}"
	einfo "Found Golang version: ${GOLANG_VERSION}"

	# Sets the build environment inside Portage's WORKDIR
	ebegin "Setting up Golang build environment"
		export GOPATH="${WORKDIR}/gopath"
		debug-print "${FUNCNAME}: GOPATH = ${GOPATH}"
		export GOBIN="${WORKDIR}/gobin"
		debug-print "${FUNCNAME}: GOBIN = ${GOBIN}"
		mkdir -p "${GOPATH}"/src || die
	eend
}


# @FUNCTION: golang-single_src_unpack
# @DESCRIPTION:
# Unpack the source archive.
golang-single_src_unpack() {
	debug-print-function ${FUNCNAME} "${@}"

	base_src_unpack

	einfo "Preparing Golang build environment in ${GOPATH}/src"

	# If the ebuild declares some Golang package deps, then they need to be
	# correctly installed into the local Golang build environment which was
	# set up automatically during pkg_setup() phase
	if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then
		# move Golang dependencies from WORKDIR into GOPATH
		for module in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

			# Strip all the white spaces
			local DEPENDENCY="${GOLANG_PKG_DEPENDENCIES[$module]//\ /}"

			# Determine the alias of the import path
			local _importpathalias="${DEPENDENCY##*->}"

			# Strip the alias
			DEPENDENCY="${DEPENDENCY%%->*}"

			# Determine the import path, package name, and revision tag
			local _importpath="${DEPENDENCY%:*}"
			local _pkg_name="${_importpath##*/}"
			local _revision="${DEPENDENCY#*:}"

			# When the alias is not specified, then we set the alias as equal to
			# the import path minus the package name
			[[ $DEPENDENCY == $_importpathalias ]] && _importpathalias="${_importpath%/*}"

			debug-print "${FUNCNAME}: index = ${_pkg_name}"
			debug-print "${FUNCNAME}: importpath = ${_importpath}"
			debug-print "${FUNCNAME}: importpathalias = ${_importpathalias}"
			debug-print "${FUNCNAME}: revision = ${_revision}"

			# Create the import path in GOPATH
			mkdir -p "${GOPATH}"/src/${_importpathalias} || die
			#einfo "\n${GOPATH}/src/${_importpathalias}"

			# Move package source from WORKDIR into GOPATH
			local _message="Moving ${_importpath}"
			[[ "${_importpath}" != "${_importpathalias}/${_pkg_name}" ]] && _message+=" as ${_importpathalias}/${_pkg_name}"
			ebegin "${_message}"
				mv ${_pkg_name}-${_revision}* "${GOPATH}"/src/${_importpathalias}/${_pkg_name} || die
			eend
		done
	fi

	# move Golang main package from WORKDIR into GOPATH
	mkdir -p "${GOPATH}"/src/${GOLANG_PKG_IMPORTPATH_ALIAS} || die
	ebegin "Moving ${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}"
		mv "${GOLANG_PKG_NAME}-${GOLANG_PKG_VERSION}" "${GOPATH}"/src/${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME} || die
	eend
}

# @FUNCTION: golang-single_src_configure
# @DESCRIPTION:
# Configure the package.
golang-single_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No Golang implementation set (pkg_setup not called?)."

	# Golang doesn't have a configure phase,
	# so instead we print the output of 'go env'
	oldifs="$IFS"
	IFS=$'\n'
	local -a GOLANG_ENV=( $( ${GO} env ) )
	IFS="$oldifs"
	if [[ ${#GOLANG_ENV[@]} -eq 1 ]]; then
		eerror "Your golang environment should be more verbose"
	fi

	# Prints build environment summary
	for env in "${GOLANG_ENV[@]}"; do
		einfo " - ${env}"
	done
}


# @FUNCTION: golang-single_src_compile
# @DESCRIPTION:
# Compiles the package.
golang-single_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No Golang implementation set (pkg_setup not called?)."

	${EGO} build \
		-v -a -p $(makeopts_jobs) \
		-o "${GOBIN}"/${GOLANG_PKG_OUTPUT_NAME} \
		${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${GOLANG_PKG_BUILDPATH} \
		|| die
}


# @FUNCTION: golang-single_src_install
# @DESCRIPTION:
# Installs binaries and documents from DOCS or HTML_DOCS arrays.
golang-single_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	# install binaries
	dobin "${GOBIN}"/${GOLANG_PKG_OUTPUT_NAME}

	base_src_install_docs
}


# @FUNCTION: golang-single_src_test
# @DESCRIPTION:
# Runs the unit test for the main package.
golang-single_src_test() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No Golang implementation set (pkg_setup not called?)."

	${EGO} test \
		-v -a -p $(makeopts_jobs) \
		-o "${GOBIN}"/${GOLANG_PKG_OUTPUT_NAME} \
		${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${GOLANG_PKG_BUILDPATH} \
		|| die
}