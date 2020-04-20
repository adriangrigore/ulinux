
<a name="1.2.3"></a>
## [1.2.3](https://github.com/prologic/ulinux/compare/1.2.2...1.2.3) (2020-04-20)

### Bug Fixes

* Fix missing -t option to mktemp leaking temporayr directories during test runs
* Fix setup tool to use absolute paths to some /sbin or /usr/sbin tools so setup works over ssh
* Fix build to fail early on failure instead of silently continuting :/
* Fix missing /etc/profile in filesystem port
* Fix broken extlinux package

### Features

* Add test for setup to ensure we can install to disk


<a name="1.2.2"></a>
## [1.2.2](https://github.com/prologic/ulinux/compare/1.2.1...1.2.2) (2020-04-20)

### Bug Fixes

* Fix missing setup port that got missed in the 1.2 refactor
* Fix test.sh to optionally include the clouddrive iso


<a name="1.2.1"></a>
## [1.2.1](https://github.com/prologic/ulinux/compare/1.2...1.2.1) (2020-04-20)

### Bug Fixes

* Fix generating next release tag
* Fix release script to show progress properly and skip shippping a useless clouddrive iso

### Updates

* Update release tool to print TAG being released


<a name="1.2"></a>
## [1.2](https://github.com/prologic/ulinux/compare/1.0.2...1.2) (2020-04-20)

### Bug Fixes

* Fix typo
* Fix filesystem port to pickup uLinux TAG and REV from the enviornment
* Fix size of logo to fit theme
* Fix Jeykl theme layout
* Fix test_pkg
* Fix bug with creating temp dirs for run in buidls
* Fix missing cloudinit manifest
* Fix missing ca-certifactes manifest
* Fix filesystem port with missing default mdev.conf
* Fix ports/pkgs links on topnav
* Fix pkg to remove old build directory if exists
* Fix pkg to output verbose outputs of tar to stderr
* Fix a bug in pkg add causing non-zero exit for no good reason
* Fix some more bugs from the refactor and add more tests
* Fix missing box package
* Fix missing /etc/dropbear directory for core services
* Fix missing telinit in rc port

### Features

* Add kernel as a core package
* Add iptables as a core package
* Add rng-tools as a core package
* Add extlinux as a core package
* Add dropbear as a core package
* Add busybox as a core package
* Add make as a core package
* Add sinit as a core package
* Add musl as a core package
* Add uLinux logo
* Add a shell Make target for debugging builds
* Add support for building core packages and user ports with optional features such as WITH_SSL
* Add more error handling around the main script
* Add pkg to the Docker image buidler as part of the build bootstrap process
* Add tests cycle to CI
* Add a basic integration test suite
* Add customization to the jekyl hacker layout

### Updates

* Update and refactor release process
* Update docker build to be quiet
* Update Makefile to be clear about what we're building
* Update Jeykl config to show downloads
* Update README and remove logo
* Update Jekyl minimal theme and add logo config
* Update tcc manifest
* Update .gitignore
* Update order of build steps
* Update Docker Image build to identify when we're using a local rootfs.gz or downloading the altest released one
* Update the pkg_build test to be more quiet
* Update default ports tree in pkg.conf
* Update more of the build and refactor servifes
* Update build with a MAJOR refactor
* Update site nav and disable download links


<a name="1.0.2"></a>
## [1.0.2](https://github.com/prologic/ulinux/compare/1.0.1...1.0.2) (2020-04-17)

### Bug Fixes

* Fix release workflow (Fixes [#23](https://github.com/prologic/ulinux/issues/23))
* Fix ncurses ports to add symlinks for -lcurses and -lncurses
* Fix sacc port linking against ncursesw
* Fix bug in bare service that fails to find pids of some binaries
* Fix useless warning about zip sources in pkg
* Fix checksum of ncurses port

### Features

* Add tmux and its dependency libevent ports
* Add a sane default mdev config
* Add var/cache to rootfs
* Add support for adding and publishing packages to/from a central PKG_PKGSDIR path
* Add search, depends sub-commands to pkg
* Add nasm port
* Add fasm port and move out of the base system build
* Add sic port
* Add gdbserver port
* Add tzdata port

### Updates

* Update release/upload Make targets to perform SHA/GPG after the build but before the upload
* Update tcc to 20200416
* Update rootfs with default config for builtin httpd and empty /var/www and default directory listing
* Update geomyidae with default config and service script
* Update README and remove toc also disable/remove gh-pages as we're going to self-host with uLinux itself
* Update ports tree
* Update setup to reuse rc.common and fail fast if a step fails
* Update setup tool to have some options including a reboot option (-r/--reboot)
* Update tcc port to 20200415 and use gitver (SHA) to track source
* Update ports tree index
* Update manifest of zlib port
* Update ports tree idnex
* Update irc port to depend on tzdata


<a name="1.0.1"></a>
## [1.0.1](https://github.com/prologic/ulinux/compare/1.0...1.0.1) (2020-04-15)

### Bug Fixes

* Fix ncurses port to enable widec
* Fix bug with pkg build logic to preserve build directory if the build fails

### Features

* Add irc prot
* Add the linux C headers to the system
* Add ulinux script like crux in CRUX (crux.nu) to display version/build informaiton more quickly/easily
* Add mailx and its dep getconf ports

### Updates

* Update README.md
* Update repo with license, code_of_conduct and contributing
* Update pkg to leave the build direcotyr on failed builds for inspection
* Update pkg to preserve the build directory if the build fails


<a name="1.0"></a>
## [1.0](https://github.com/prologic/ulinux/compare/0.0.11...1.0) (2020-04-14)

### Bug Fixes

* Fix release tool to take TAG as an env var
* Fix tcc port's build
* Fix checksum(s) of pkg and tcc ports
* Fix the pkg build environment and tcc ar so more things  compile
* Fix bug where we were toggling the active boot partition on and off causing [#20](https://github.com/prologic/ulinux/issues/20) (Fixes [#20](https://github.com/prologic/ulinux/issues/20))
* Fix bug with pkg sourcing in configuration
* Fix source for strace-static port
* Fix pkg header

### Features

* Add ports zlib, ncurses, git and geomyidae. Also fix sacc to use the ncurses UI
* Add sacc port
* Add LD export to pkg build environment
* Add msmtp port
* Add duktape port (a small embedded Javascript interpreter)
* Add ability to use . in pkg add
* Add support for explicitly downlading a busybox snapshot
* Add clean sub-command to pkg
* Add feature section on lightweight(ness)

### Updates

* Update build_syslinux() and remove the syslinix binary (we only need exxtlinux)
* Update build_syslinux() to trim down the size of what we install (we don't need many of the COM32 modules)
* Update .dockerignore to be a symlink of .gitignore
* Update tcc checksum
* Update musl build and disable static libc
* Update build_ports() to refactor port building and also include the core ports tree as part of the base rootfs
* Update build system and refactor NUM_JOBS for nproc
* Update pkg tool to source in /etc/pkg.conf so we can export sensible build environment to pkg build
* Update Kernel to 5.6.3
* Update test script to add -accel options for Linux and Darwin dev machines
* Update pkg's prtcreate to just create an empty Pkgfile in the current directory
* Update toc


<a name="0.0.11"></a>
## [0.0.11](https://github.com/prologic/ulinux/compare/0.0.10...0.0.11) (2020-04-12)

### Bug Fixes

* Fix bug with pkg add with computing package naems
* Fix Kernel config for Docker Swarm Mode with Overlay IPVS/VXLAN networking

### Features

* Add tool to publish prebuitl packages to bintray

### Updates

* Update Kernel build to only run make menuconfig if on a terminal
* Update docker port to depend on cgroupfs-mount and remove obsolte *-docker tools and mount-cgroups


<a name="0.0.10"></a>
## [0.0.10](https://github.com/prologic/ulinux/compare/0.0.9...0.0.10) (2020-04-12)

### Bug Fixes

* Fix entrypoint/cmd of the Docker image

### Features

* Add docker port
* Add basic support for network-config (tested with Proxmox VE 6.1)
* Add documentation for uLinux ([#21](https://github.com/prologic/ulinux/issues/21))
* Add set of core ports ([#19](https://github.com/prologic/ulinux/issues/19))
* Add pkg a set of package management tools ([#17](https://github.com/prologic/ulinux/issues/17))
* Add support for env, workdir and volumes to box

### Updates

* Update default ports url
* Update busybox to latest snapshot


<a name="0.0.9"></a>
## [0.0.9](https://github.com/prologic/ulinux/compare/0.0.8...0.0.9) (2020-04-10)

### Bug Fixes

* Fix /dev/ptmx symlink and /tmp mount

### Features

* Add SYSCALL and SYSCTL to Kernel conig

### Updates

* Update cached copy of Kernel Config for refernece
* Update the build and trim some unneeded Kernel options and remove --enable-static and -static flags
* Update Kernel config and remove unused RD compression options


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

