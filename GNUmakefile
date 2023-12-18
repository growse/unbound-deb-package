DEBNAME := unbound
APP_REMOTE := https://nlnetlabs.nl/downloads/unbound/
# renovate: datasource=github-tags depName=NLnetLabs/unbound versioning=regex:^release-(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)?$
UNBOUND_VERSION := 1.17.0
APPDESCRIPTION := Unbound recursive resolver
APPURL := https://nlnetlabs.nl/projects/unbound/download/
APP_VENDOR := https://nlnetlabs.nl/
ARCH := amd64

TARBALL = ./$(DEBNAME)-$(UNBOUND_VERSION).tar.gz
SRC_REMOTE := $(APP_REMOTE)$(TARBALL)

# Setup
BUILD_NUMBER ?= 0
DEBVERSION := $(UNBOUND_VERSION:v%=%)-$(BUILD_NUMBER)
APP_SRCDIR := $(DEBNAME)-$(UNBOUND_VERSION)
APP_CONFIGURE_SCRIPT = $(APP_SRCDIR)/configure
APP_POST_CONFIGURE_FILE := $(APP_SRCDIR)/config.status
APP_BINARY = $(APP_SRCDIR)/unbound
DESTDIR := $(abspath ./install-temp)

APP_CONFIGURE_OPTIONS=--enable-systemd --enable-dnstap --with-libevent --prefix=

# Let's map from go architectures to deb architectures, because they're not the same!
DEB_amd64_ARCH := amd64

.EXPORT_ALL_VARIABLES:

.PHONY: package
package: $(addsuffix .deb, $(addprefix $(DEBNAME)_$(DEBVERSION)_, $(foreach a, $(ARCH), $(a))))

.PHONY: build
build: $(APP_BINARY)

.PHONY: extract
extract: $(APP_CONFIGURE_SCRIPT)

.PHONY: patch
patch: $(APP_SRCDIR)/patch

.PHONY: configure
configure: $(APP_POST_CONFIGURE_FILE)

.PHONY: download
download: $(TARBALL)

$(TARBALL):	
	curl --fail -O $(SRC_REMOTE)	

$(APP_CONFIGURE_SCRIPT): $(TARBALL)	
	$(info making $@)
	tar -zmxvf $(TARBALL)

$(APP_SRCDIR)/patch: $(APP_CONFIGURE_SCRIPT)
	patch -ruN -d $(APP_SRCDIR) -p0 < systemd_unit_cap_chown.patch 
	touch $(APP_SRCDIR)/patch


$(APP_POST_CONFIGURE_FILE): $(APP_CONFIGURE_SCRIPT) $(APP_SRCDIR)/patch
	cd $(APP_SRCDIR) && $(abspath $(APP_CONFIGURE_SCRIPT)) $(APP_CONFIGURE_OPTIONS)

$(APP_BINARY): $(APP_POST_CONFIGURE_FILE)
	cd $(APP_SRCDIR) && make $(MAKEFLAGS)

$(DESTDIR):
	mkdir -p $(DESTDIR)

$(DESTDIR)/sbin/unbound: $(DESTDIR) $(APP_BINARY)
	cd $(APP_SRCDIR) && make install

$(DEBNAME)_$(DEBVERSION)_%.deb: $(APP_BINARY) $(DESTDIR)/sbin/unbound
	bundle exec fpm -f \
	-s dir \
	-t deb \
	--license BSD \
	--deb-priority optional \
	--deb-systemd-enable \
	--deb-systemd-restart-after-upgrade \
	--deb-systemd-auto-start \
	--after-install=deb-scripts/postinst.sh \
	--depends adduser \
	--maintainer github@growse.com \
	--vendor $(APP_VENDOR) \
	-n $(DEBNAME) \
	--description "$(APPDESCRIPTION)" \
	--url $(APPURL) \
	--prefix / \
	-a $(DEB_$*_ARCH) \
	-v $(DEBVERSION) \
	--deb-systemd $(APP_SRCDIR)/contrib/unbound.service \
	--chdir=$(DESTDIR) \
	.

.PHONY: clean
clean:
	rm -f *.deb
	rm -rf -- unbound-*
	rm -f -- *.tar.gz
	rm -rf $(DESTDIR)
