# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

GOLANG_PKG_IMPORTPATH="github.com/hashicorp"
GOLANG_PKG_ARCHIVEPREFIX="v"
GOLANG_PKG_USE_GENERATE=1
GOLANG_PKG_HAVE_TEST=1

# Declares dependencies
GOLANG_PKG_DEPENDENCIES=(
	"github.com/aws/aws-sdk-go:4944a94 -> github.com/awslabs"
	"github.com/coreos/etcd:75f8282" #v2.2.1
	"github.com/hashicorp/atlas-go:6c9afe8"
	"github.com/hashicorp/consul:0886039"
	"github.com/hashicorp/errwrap:7554cd9344"
	"github.com/hashicorp/go-checkpoint:e4b2dc3"
	"github.com/hashicorp/go-multierror:d30f099"
	"github.com/hashicorp/go-version:2b9865f"
	"github.com/hashicorp/go-cleanhttp:5df5ddc"
	"github.com/hashicorp/go-getter:3005084"
	"github.com/hashicorp/logutils:0dc08b1"
	"github.com/hashicorp/serf:892b373"
	"github.com/hashicorp/hcl:4de5195"
	"github.com/hashicorp/yamux:ddcd0a6"
	"github.com/mitchellh/cli:8102d0e"
	"github.com/mitchellh/colorstring:8631ce9"
	"github.com/mitchellh/copystructure:6fc66267e9"
	"github.com/mitchellh/go-homedir:d682a8f"
	"github.com/mitchellh/mapstructure:281073eb9e"
	"github.com/mitchellh/panicwrap:1655d88"
	"github.com/mitchellh/prefixedio:89d9b53599"
	"github.com/mitchellh/reflectwalk:eecf4c70c6"
	"github.com/kardianos/osext:6e7f843 -> github.com/mitchellh"
	"github.com/rackspace/gophercloud:63ee53d"
	"github.com/vaughan0/go-ini:a98ad7ee00"
	"github.com/golang/crypto:c8b9e63 -> golang.org/x"
	"github.com/golang/net:4a71d18255 -> golang.org/x"
	"github.com/apparentlymart/go-cidr:a3ebdb9"

	# Unit Testing
	"github.com/armon/circbuf:bbbad09"
	"github.com/Azure/azure-sdk-for-go:3dcabb6"
	"github.com/apparentlymart/go-rundeck-api:cddcfba" #v0.0.1
	"github.com/cyberdelia/heroku-go:8344c6a"
	"github.com/digitalocean/godo:2a0d64a" #v0.9.0
	"github.com/dylanmei/iso8601:2075bf119b"
	"github.com/dylanmei/winrmtest:3e9661c52c"
	"github.com/fsouza/go-dockerclient:5c1d07d4af"
	"github.com/golang/oauth2:8914e5017c -> golang.org/x"
	"github.com/google/google-api-go-client:0a735f7ec8"
	"github.com/google/go-querystring:547ef5a"
	"github.com/GoogleCloudPlatform/gcloud-golang:e34a32f9b0"
	"github.com/imdario/mergo:61a5285227"
	"github.com/mitchellh/go-linereader:07bab5fdd9"
	"github.com/mitchellh/packer:60bbe850ef"
	"github.com/masterzen/simplexml:95ba30457e"
	"github.com/masterzen/winrm:23128e7b3d"
	"github.com/masterzen/xmlpath:13f4951698"
	"github.com/nu7hatch/gouuid:179d4d0c4d"
	"github.com/packer-community/winrmcp:743b1afe5e"
	"github.com/packethost/packngo:f03d7dc"
	"github.com/pborman/uuid:cccd189"
	"github.com/pearkes/cloudflare:19e280b056"
	"github.com/pearkes/dnsimple:2a807d118c"
	"github.com/pearkes/mailgun:5b02e7e9ff"
	"github.com/satori/go.uuid:6b8e5b55d2"
	"github.com/soniah/dnsmadeeasy:5578a8c15e"
	"github.com/tent/http-link-go:ac974c6"
	"github.com/xanzy/go-cloudstack:00319560ee"
	"github.com/vmware/govmomi:b331507" #v0.2.0
)

inherit golang-single

DESCRIPTION="Terraform is a tool for building, changing, and combining infrastructure safely and efficiently"
HOMEPAGE="http://www.terraform.io"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="amd64 x86 arm"

# go-tools is required by "go:generate stringer" directive
DEPEND="dev-util/go-tools"

src_prepare() {
	golang-single_src_prepare

	use test && golang_fix_importpath_alias \
		"github.com/pborman/uuid" \
		"code.google.com/p/go-uuid"

	use test && golang_fix_importpath_alias \
		"github.com/google/google-api-go-client" \
		"google.golang.org/api"

	use test && golang_fix_importpath_alias \
		"github.com/GoogleCloudPlatform/gcloud-golang" \
		"google.golang.org/cloud"

	# FIX: github.com/mitchellh/osext has been deprecated
	#      in favour of github.com/kardianos/osext
	sed -i \
		-e "s:github.com\/mitchellh\/osext:github.com\/kardianos\/osext:" \
		"${GOPATH}"/src/github.com/mitchellh/panicwrap/panicwrap.go \
		"${GOPATH}"/src/github.com/mitchellh/packer/config.go \
		|| die
}