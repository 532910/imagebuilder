# ImageBuilder

## A simple Makefile wrapper for [OpenWrt imagebuilder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder)

It's intended to be simple and to use package templates from text files.

[Other frontends](https://openwrt.org/docs/guide-developer/imagebuilder_frontends)

## TL;DR
```
% cd example
% make C=config2 image
```

## Usage
```
% make C=cfg_name [image|copy|install]
```
Where `cfg_name` is a folder containing the configuration described in `config.mk`.

- `image`: Build image and put it into the `cfg_name` folder.
- `copy`: Make image and scp it to each host in `HOSTS`.
- `install`: All above and sysupgrade. Use with caution!


### Debug

The build will be performed in the `/tmp/imgbldr-XXXXX` folder which will be removed afterwards.
To leave it for debug set `LEAVE_BUILD`:
```
% make LEAVE_BUILD=yes C=example image
```


Use `listpks` target to check [`PACKAGES`](https://openwrt.org/docs/guide-user/additional-software/imagebuilder#packages_variable):

```
% make C=cfg_name listpks
```

## Configuration

See `example` for instance.

### `cfg_name/config.mk`

At least `TARGET`, `SUBTARGET` and `PLATFORM` must be defined.

`HOSTS` is set to `cfg_name` by default and required for `copy` and `install` targets.

`IMAGE` is the last part of the image file.
The default is `squashfs-sysupgrade.bin` which is fine for the most cases.

Not all imagebuilder archives and image files match the patterns:

`openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64`
`openwrt-${RELEASE}-${TARGET}-${SUBTARGET}-${PLATFORM}-${IMAGE}`

[Forum thread](https://forum.openwrt.org/t/image-name-format).

For example `x86/64/Generic` requires:

```
IMAGE = combined-squashfs.img.gz
image = openwrt-${RELEASE}-${TARGET}-${SUBTARGET}-${IMAGE}
```

and `octeon` requires:
```
IMAGE = squashfs-sysupgrade.tar
imagebuilder = openwrt-imagebuilder-${RELEASE}-${TARGET}.Linux-x86_64
image = openwrt-${RELEASE}-${TARGET}-${PLATFORM}-${IMAGE}
```

`INSTALL_LISTS` and `REMOVE_LISTS` contain template files from `lists`.

`INSTALL_PKGS` and `REMOVE_PKGS` contain individual package names.

In addition to `cfg/files` directory
`FILES_INSTALL` defines files copy into
[`FILES`](https://openwrt.org/docs/guide-user/additional-software/imagebuilder#files_variable)
and to be included in the image.

### `config.mk`
The upper level `config.mk` is included for all configurations.

## OpenWrt release
It looks like there is no simple and clear way to get the latest release.
[Forum thread](https://forum.openwrt.org/t/how-to-find-the-latest-release-from-script).
So `RELEASE` must be defined in `config.mk` or from commandline for now.
```
% make C=cfg_name RELEASE=19.07.7 image
```
