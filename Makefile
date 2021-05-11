# TODO: auto version update

include config.mk
include ${C}/config.mk

MIRROR = https://downloads.openwrt.org
BUILDDIR ?= .

#CONFIGS = $(wildcard $C/install.d/* $C/remove.d/*)
CONFIGS = config.mk ${C}/config.mk
DEPS = $(shell find $C/install.d $C/remove.d $C/files -type f,l) ${CONFIGS}

imagebuilder ?= openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64

image ?= openwrt-${RELEASE}-${TARGET}-${SUBTARGET}-${PLATFORM}-${IMAGE}
#image = ${imagebuilder}/bin/targets/${TARGET}/${SUBTARGET}/openwrt-${RELEASE}-${TARGET}-${SUBTARGET}-${PLATFORM}-${IMAGE}

comment = \#%
parts = $(filter-out ${comment}, $(foreach f,$(wildcard $C/$1.d/*),$(file < $f)))
PACKAGES = $(addprefix -,$(call parts,remove)) $(call parts,install)


all: copy

listpks:
	@echo ${PACKAGES}

imagebuilder: ${BUILDDIR}/${imagebuilder}

${BUILDDIR}/${imagebuilder}: ${imagebuilder}.tar.xz
	tar --touch -C ${BUILDDIR} -xf $<

${imagebuilder}.tar.xz:
	wget -c https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}/$@

image: ${C}/${image}

${C}/${image}: ${BUILDDIR}/${imagebuilder} ${DEPS}
	umask 022; $(MAKE) -C $< image PROFILE=${PLATFORM} PACKAGES="${PACKAGES}" FILES=${CURDIR}/${C}/files/
	cp ${BUILDDIR}/${imagebuilder}/bin/targets/${TARGET}/${SUBTARGET}/${image} $@

copy: ${C}/${image}
	$(foreach h,${HOSTS},scp $< $h:/tmp&)

install: copy
	$(foreach h,${HOSTS},ssh $h sysupgrade -v /tmp/${image}&)

clean:
	$(RM) -r ${BUILDDIR}/${imagebuilder}

distclean: clean
	$(RM) ${imagebuilder}.tar.xz ${image}

.PHONY: clean distclean copy listpks image
