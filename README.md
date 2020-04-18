<p align="center">
  <img src="docs/img/ulinux.logo.png" alt="uLinux" title="uLinux" />
</p>

# ulinux

![Build](https://github.com/prologic/ulinux/workflows/Build/badge.svg)

> uLinux (_µLinux_) is a micro (µ)Linux Cloud Native OS designed for high
> performance, minimal overhead and a small footprint.
>
> uLinux is container-ready and small enough that it could be used as a sort of "UniKernel"
> for your applications.
> 
> If you care about performance, footprint, security and minimalism like I do
> you'll want to use µLinux for your workloads.

> __NOTE:__: µLinux is _NOT_ a full blown Desktop OS nor will it ever likely be.
>            It is also not ever likely to build your favorite GCC/GLIBC/Clang
>            software as it only ships with a very small C compiler (tcc) and libc (musl).
>            Consider using [Alpine](https://alpinelinux.org/) for a more feature
>            rich system or any other "heavier" / "full featured" distro.

## Supported Platforms

- [X] [VirtualBox](https://www.virtualbox.org/)
- [X] [QEMU/KVM](https://www.qemu.org/)
- [X] [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
- [X] [Vultr](https://vultr.com)
- [X] [DigitalOcean](https://digitalocean.com)
- _need more? file an issue or submit a PR!_

## Features

- Recent [Linux Kernel](https://www.kernel.org/)
- [Very Lightweight](#very-lightweight)
- Full Container Support
- [Busybox Userland](https://busybox.net/)
- [Dropbear SSH Daemon](http://matt.ucc.asn.au/dropbear/dropbear.html)
- Hybrid Live ISO
- Installer
- [CloudInit](https://cloudinit.readthedocs.io/en/latest/)

### Fast Boot

uLinux is designed for high performance and small footprint. uLinux is expected
to boot within ~1s on a modern system. See [Screenshots](#screenshots).

### Very Lightweight!

uLinux will boot on as little as __64MB__ of RAM! Yes that's right!

Other notable attributes:

- ~3MB Kernel
- ~6MB Root FS (_compressed_)
- ~10MB Hybrid ISO
- ~20MB On-Disk Install

The goal is to stick to these attributes as far as we can! The only way to
grow your uLinux system once installed is through ports and packages.

### Full Container Support

uLinux supports full containerization and comes shipped with a very small
lightweight container / sandbox tool called `box`. See [box](#box).

Currently supported Container Engines:

- [X] [Docker CE](https://www.docker.com)
- [X] [box](#box)
- _need more? file an issue or submit a PR! (others may work anyway)_

### Toolchain

uLinux currently supports building C and Assembly and ships with the following compilers and tools:

- [Tiny C Compiler](https://bellard.org/tcc/)
- [Flat Assembler](https://flatassembler.net/)
- [Musl libC](https://www.musl-libc.org/)
- [GNU Make](https://www.gnu.org/software/make/)

There is no support for GCC/GLIBC.

### CloudInit / CloudConfig

uLinux fully supports configuration via CloudInit/CloudConfig.
See [CloudInit](#cloudinit).

## Screenshots

![screenshot-1](screenshot-1.png?raw=true "Boating from the Hybrid Live ISO")
![screenshot-2](screenshot-2.png?raw=true "After running `setup /dev/sda` to install to disk and booting from disk")
![screenshot-3](screenshot-3.png?raw=true "Fully booted showing process list and resources used after boot")

## Getting Started

### Prebuilt Images

This repo contains prebuilt images to get you started quickly without having
to build anything yourself.

Please see the [Release](https://github.com/prologic/ulinux/releases) for the
latest published versions of:

- `ulinux.iso` -- Hybrid Live ISO with Installer.
- `kernel.gz`  -- The Kernel Image (Linux)
- `rootfs.gz`  -- The RootFS Image (INITRD)

TODO:

- [ ] Add prebuilt Cloud Disk Images.

### Installing

Once booted with either the Hybrid Live ISO or Kernel + RootFS you can install
uLinux to disk by typing in a shell:

```sh
# setup /dev/sda
```

Assuming `/dev/sda` is the device path to the disk you want to install to.

**WARNING:** This will _automatically_ partition, format and install uLinux
             with no questions asked without hesitation. Please be sure you
             understand what you are doing.

### Building

First make sure you have [Docker](https://www.docker.com) installed on your
system as the build uses this extensively to build the OS reliably across
all platforms consistently.

> __NOTE__: Docker is not strictly required in order to build uLinux.
            You may also just run the `./main.sh` build script yourself as long
            as you have installed all required build dependencies. See the
            [Dockerfile.builder](Dockerfile.builder) for details on what
            dependencies need to be available for a successful build.

Also make sure you have [QEMU](https://www.qemu.org/) installed as this is
used for testing and booting the OS into a Guest VM.

Then just run:

```sh
$ make
```

### Customization

You can customize the build by overriding the `customize_kernel()` and
`customize_rootfs()` functions in `customize.sh`:

- `customize_kernel()` -- This is passed no arguments and the current directory
                          is the location of the current kernel sources being
                          built. You can use `config <value> <config>` to
                          enable/disable Kernel options. e.g: `config m MULTIUSER`.
- `customize_rootfs()` -- This is passed the path to the rootfs as its first
                          argument. You may run any series of commands that
                          add to or remove things from the rootfs.

if any of the `customize_*` functions fail the build will fail.

## CloudInit

uLinux is fully [cloud-init](https://cloudinit.readthedocs.io/en/latest/#)
capable and supports the following cloud-init platforms:

- [X] Amazon EC2
- [X] OpenStack
- [X] Proxmox VE
- [X] CloudDrive
- _need more? file an issue or submit a PR!_

uLinux's cloud-init fully supports a subset of the cloud-config YAML spec
including:

- Disabling the root account
- Setting a user account password
- Adding ssh keys to a user account
- Managing the hosts file

In addition there is also full support for running an arbitrary shell script
as the `user-data.

There is a sample CloudDrive config in [clouddrive](clouddrive) as the top-level
of the repo which can be customized by editing the `user-data` script and
running `make clouddrive`.

## Services

uLinux comes with its own unique set of service management tools called `svc`
and `service` (_which is just a wrapper for `svc`_). Services are stored in
a directory at `/bin/svc.d` which has the following structure:

```#!sh
# cd /bin/svc.d
# find .
.
./bare.sh
./avail
./avail/syslogd
./avail/cloudinit
./avail/ntpd
./avail/mdev
./avail/dnsd
./avail/tfptd
./avail/crond
./avail/rngd
./avail/net
./avail/hwclock
./avail/ftpd
./avail/telnetd
./avail/httpd
./avail/dropbear
./avail/udhcpd
./run
./run/syslogd
./run/cloudinit
./run/mdev
./run/crond
./run/net
./run/hwclock
./run/dropbear
#
```

Each file listed in `/bin/svc.d/avail` can either be:

- a shell script or binary that responds to `-k` (_kill_) or `-s` (_start_).
- An empty file or "bare" service denoting no special requirements and will
  be managed by the `bare.sh` wrapper. Useful for daemons that need no special
  requirements and only basic configuration.

Configuration for services is expected to be stored in `/etc/default/<service>`
which contains files that are sourced and in shell format. The `bare.sh`
wrapper looks here by default for configuration for "bare" services. Other
services _may_ also store and look for their configuration here but this is
not mandatory.

### svc

This is the primary tool for managing services:

- `svc -a`           -- List available services that can be started or enabled.
- `svc -a <service>` -- Activates the given `<service>`.
- `svc -c`           -- Creates the directory structure for `/bin/svc.d` (_done by default_).
- `svc -d <service>` -- Deactivates the given `<service>`.
` `svc -l`           -- Lists all currently activated services.
- `svc -k <service>` -- Kills the given `<service>`.
- `svc -r <service>` -- Restarts the given `<service>`.
- `svc -s <service>` -- Starts the given `<service>`.

### service

This is simply a wrapper for `svc` and supports the following three commands:

- `service start <service>`
- `service stop <service>`
- `service restart <service>`

## Packaging and Ports

If you are at all familiar with [CRUX](https://crux.nu)
or [ArchLinux](https://www.archlinux.org/) then the packages and ports and
tools provided by uLinux will be somewhat familiar to you.

Packages in uLinux are basic Tarball(s) of a prebuilt piece of software
with one minor notable exception. It also includes state of the package
database which is used to update the uLinux package database on your system
(_each package stores its installed state in separate directories in `/var/db/pkg`_).

Ports in uLinux are very similar to that of the `Pkgfile` format of CRUX with
only one notable exception. They only support POSIX Shell as that is the only
type of shell that ships with uLinux. Therefore you cannot use an array for
`source=` it must be a space or newline delimited string.

Configuration of `pkg` and `ports` are stored in `/etc/pkg.conf` and here
you can customize the behavior of the packaging and ports tools. The most
notable configuration options currently are:

- `URL`          -- The Base URL of a web resource to synchronize a collection of ports.
- `PKG_PORTSDIR` -- The path to the primary ports collection on disk.

__NOTE:__ Currently `ports` does not support multiple collections_)

What following is a brief description of the tools available and their usage.

### pkg

This is the primary tool for managing packages installed on a uLinux system.

See the help for details on usage:

```#!sh
# pkg
=> pkg [a]dd pkg.tar.gz
=> pkg [b]uild
=> pkg [c]hecksum
=> pkg [d]el pkg
=> pkg [l]ist [pkg]
```

### ports

This tool updates and synchronizes the ports collection on disk depending
on the configuration of `PKG_PORTSDIR` with a remote collection specified
by `URL`. The remote collection __must__ contain a collection of ports
as well as the `index` file generated by `repogen` and each file must be
retrievable with by `wget`.

### Other Utilities

There are a number of other utilities that live outside (_currently_) of
`pkg` and `port`, these are:

- `repogen`   -- Creates the `index` for the current directory of ports suitable
                 for hosting by a basic web server. This `index` is the first
                 resource that `ports` looks for in order to synchronize ports.
- `prtcreate` -- Creates a blank basic skeleton of a port and its `Pkgfile`
                 in `/usr/ports`.

## Utilities

### box

uLinux comes shipped with a simple Container / Sandbox tool called `box.
It has a familiar user experience if you are used to Docker (_but nowhere near
as feature rich of course!_).

Simply run `box` to get a shell in an isolated environment that is fully
isolated from your system's mounts, namespace, pid, devices, etc. The only
part that is shared from the host is the host's networking.

```#!sh
# box
KhJpKC / # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh
    6 root      0:00 ps aux
```

Or run `box <command>` like so:

```#!sh
# box echo 'I am pid $$'
I am pid 1
```

### enter-chroot

Mostly useful as a way to debug and enter the environment of an installed
system where uLinux is used as a "rescue" system.

```#!sh
$ enter-chroot /path/to/rootfs
```

__NOTE__: You must have already mounted the root file system at the desired path
          before running `enter-chroot /path/to/rootfs`.

## Testing

Just run:

```sh
$ make test
```

The OS comes pre-shipped with Dropbear (_SSH Daemon_) as well as a Busybox
Userland. The test script (`test.sh`) also uses QEMU and sets up a User mode
network which forwards port `2222` to the guest VM for SSH access.

You can access the guest with:

```sh
$ ssh -p 2222 root@localhost
```

# License

uLinux is licensed under the terms of the [MIT License](LICENSE).
