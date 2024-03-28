-include config.mk

ifndef C
$(error C must be defined)
endif

include $C/config.mk

BUILDDIR := $(shell mktemp --dry-run --directory -t imgbldr-XXXXX)
BASEDIR := $(dir $(realpath $(firstword ${MAKEFILE_LIST})))

FILES = ${BUILDDIR}/files
files = files

CACHE = cache/${RELEASE}
DOWNLOADS_BASE = https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}
INSTRUCTION_SET = $(shell curl --silent ${DOWNLOADS_BASE}/profiles.json | jq --raw-output .arch_packages)

CONFIGS = config.mk $C/config.mk
DEPS += $(shell find ${files} -type f,l)
DEPS += $(shell [ -d $C/files ] && find $C/files -type f,l)
DEPS += ${CONFIGS}

HOSTS ?= $C
SCPOPTS = -O

IMAGE ?= squashfs-sysupgrade.bin

imagebuilder ?= openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64

image ?= openwrt-${RELEASE}-${TARGET}-${SUBTARGET}-${PLATFORM}-${IMAGE}

comment = \#%
parts = $(filter-out ${comment}, $(foreach f,$1,$(file < ${BASEDIR}/lists/$f)))
PACKAGES = \
	$(addprefix -,$(call parts,${REMOVE_LISTS})) \
	$(addprefix -,$(foreach p,${REMOVE_PKGS},$p)) \
	$(call parts,${INSTALL_LISTS}) \
	$(filter-out ${comment}, $(foreach p,${INSTALL_PKGS},$p))
#	$(foreach p,${INSTALL_PKGS},$p)

all: image

listpks:
	@echo ${PACKAGES}

${CACHE}:
	mkdir --parents $@

${BUILDDIR}:
	mkdir --parents $@

imagebuilder: ${BUILDDIR}/${imagebuilder}

${BUILDDIR}/${imagebuilder}: ${CACHE}/${imagebuilder}.tar.xz ${BUILDDIR}
	tar --touch -C ${BUILDDIR} -xf $<

${CACHE}/${imagebuilder}.tar.xz: | ${CACHE}
	curl --remote-name --continue-at - --output-dir $| ${DOWNLOADS_BASE}/${@F}

image: $C/${image}

install = rsync --mkpath ${1} ${FILES}${2}

${FILES}:
	mkdir ${FILES}
	${FILES_INSTALL}
	[ ! -d $C/files ] || cp -r -T -f $C/files ${FILES}

files: ${FILES}


$C/${image}: ${BUILDDIR}/${imagebuilder} ${FILES} ${DEPS}
	umask 022; $(MAKE) -C $< image \
		PROFILE=${PLATFORM} \
		PACKAGES="${PACKAGES}" \
		FILES=${FILES} \
		CONFIG_DOWNLOAD_FOLDER=$(realpath ${CACHE})/${INSTRUCTION_SET}
	cp ${BUILDDIR}/${imagebuilder}/bin/targets/${TARGET}/${SUBTARGET}/${image} $@
ifndef LEAVE_BUILD
	rm -rf ${BUILDDIR}
else
	@echo ${BUILDDIR}
endif

copy: $C/${image}
	$(foreach h,${HOSTS}, \
		scp ${SCPOPTS} $< $h:/tmp & \
	)

install: $C/${image}
	$(foreach h,${HOSTS}, ( \
		scp ${SCPOPTS} $< $h:/tmp && \
		ssh $h sysupgrade -v /tmp/${image} \
	)& )

.PHONY: copy listpks image
.SECONDARY: ${BUILDDIR} ${BUILDDIR}/${imagebuilder} ${FILES}
