
<a name="0.0.8"></a>
## [0.0.8](https://github.com/prologic/ulinux/compare/0.0.7...0.0.8) (2020-04-09)

### Updates

* Update location of cloudinit from bin to sbin
* Update name of container/sandbox tool from tw to box


<a name="0.0.7"></a>
## [0.0.7](https://github.com/prologic/ulinux/compare/0.0.6...0.0.7) (2020-04-09)

### Bug Fixes

* Fix hostname bug with tw for containers and properly umount dev and tmp as part of cleanup
* Fix host networking in containers using the tw tool by bind-mounting /dev into the container

### Features

* Add a very lightweight container/sandbox tool tw written in pure POSIX Shell
* Add USER_NS support to the Kernel


<a name="0.0.6"></a>
## [0.0.6](https://github.com/prologic/ulinux/compare/0.0.5...0.0.6) (2020-04-08)

### Bug Fixes

* Fix /etc/os-release version ids
* Fix screenshot links to be relative


<a name="0.0.5"></a>
## [0.0.5](https://github.com/prologic/ulinux/compare/0.0.4...0.0.5) (2020-04-08)

### Updates

* Update Makefile release target to move sha256/gpg steps to release to fix CI


<a name="0.0.4"></a>
## [0.0.4](https://github.com/prologic/ulinux/compare/0.0.3...0.0.4) (2020-04-08)

### Updates

* Update release process to include a GPG signed sha256sums.txt for authenticty of buidls
* Update release Makefile target to ensure we are clean anad up-to-date


<a name="0.0.3"></a>
## [0.0.3](https://github.com/prologic/ulinux/compare/0.0.2...0.0.3) (2020-04-08)

### Bug Fixes

* Fix telinit path
* Fix Docker Image building
* Fix boot error mounting / as read-only which is pointless

### Features

* Add some color to uLinux 😀

### Updates

* Update release to not commit a useless commit
* Update screenshots


<a name="0.0.2"></a>
## [0.0.2](https://github.com/prologic/ulinux/compare/0.0.1...0.0.2) (2020-04-08)

### Updates

* Update repo and remove old Git LFS assets
* Update README with latest information on releases and project status
* Update release script to remove final git pull


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

* Add sha255sums.txt as part of the release process
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

