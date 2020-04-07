
<a name="0.0.1"></a>
## 0.0.1 (2020-04-08)

### Bug Fixes

* Fix git-chglog config (again)
* Fix release script
* Fix shellcheck errors with udhcpc default script
* Fix reboot/poweroff -- path to telinit
* Fix build_make() and drop into a shelll if we're on a terminal and the build fails
* Fix truly silent boot

### Documentation

* Document prebuilt Hybrid ISO, Kernel and RootFS along with how to install to disk

### Features

* Add tools to create Github Releases
* Add power management (ACPI) to the kernel
* Add sinit as the init process (suckless init) [REFACTOR] ([#12](https://github.com/prologic/ulinux/issues/12))
* Add cloudinit support ([#7](https://github.com/prologic/ulinux/issues/7))
* Add getty support ([#11](https://github.com/prologic/ulinux/issues/11))
* Add support for syslog
* Add support for crond ([#9](https://github.com/prologic/ulinux/issues/9))
* Add support for persisting the default Kernel Config (KConfig) in the rop-level repo
* Add /etc/hosts to rootfs Fixes [#1](https://github.com/prologic/ulinux/issues/1)
* Add symlink for /usr/bin/env Fixes [#4](https://github.com/prologic/ulinux/issues/4)
* Add GNU Make to the toolchain to make building existing software a bit easier (potentially being able to bootstrap gcc/glibc if necessary)
* Add VIRTIO_IDE and VIRTIO_SCSI to Kernel config
* Add default dropbear config to rootfs
* Add pre-built Hybrid ISO, Kernel and RootFS to Git LFS

### Updates

* Update git-chglog config
* Update README.md
* Update README.md
* Update .dockerignore

