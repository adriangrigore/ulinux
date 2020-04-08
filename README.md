# ulinux

![Build](https://github.com/prologic/ulinux/workflows/Build/badge.svg)

> µLinux (uLinux) is a micro (µ)Linux Cloud Native OS designed for high
> performance, minimal overheads and decreased security footprint attack surface.
> µLinux is container-ready and is small enough with a lot of fat removed and
> stripped down you could _almost_ consider it a "Unikernel" of sorts.
> If you care about performance, footprint, security and minimalism like I do
> you'll want to use µLinux for your workloads.

> __NOTE:__: µLinux is _NOT_ a full blown Desktop OS nor will it ever likely be.
>            It is also not ever likely to build your favourite GCC/GLIBC/Clang
>            software as it only ships with a very small C compiler and libc (musl).
>            Consider using [Alpine](https://alpinelinux.org/) for a more feature
>            rich system or any other "heavier" / "full featured" distro.

## Supported Platforms

- [X] VirtualBox
- [X] QEMU/KVM
- [X] [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
- [X] [Vultr](https://vultr.com)
- [X] [DigitalOcean](https://digitalocean.com)
- _need more? file an issue or submit a PR!_

## Features

- Recent Linux Kernel
- Busybox userland
- Dropbear SSH
- Hybrid Live ISO
- Installer
- CloudInit
- Crude (_to be replaced_) package  manager

### Toolchain

uLinux currently supports building C and Assembly and ships with the following compilers and tools:

- Tiny C Compiler
- Flat Assembler
- Musl LibC
- Make

There is no support for GCC/GLIBC.

### Screenshots

![screenshot-1](screenshot-1.png?raw=true "Botting from the Hybrid Live ISO")
![screenshot-2](screenshot-2.png?raw=true "After running `setup /dev/sda` to install to disk and booting from disk")
![screenshot-3](screenshot-3.png?raw=true "Fully booted showing process list and resources used after boot")

## Getting Started

First make sure you have [Docker](https://www.docker.com) installed on your
system as the build uses this extensively to build the OS reliably across
all platforms consistently.

Also make sure you have [QEMU](https://www.qemu.org/) installed as this is
used for testing and booting the OS into a Guest VM.

## Prebuilt

This repo contains prebuilt assets to get you started quickly without having
to build anything yourself.

Please see the [Release](https://github.com/prologic/ulinux/releases) for the
latest published versions of:

- `ulinux.iso` -- Hybrid Live ISO with Installer.
- `kernel.gz`  -- The Kernel Image (Linux)
- `rootfs.gz`  -- The RootFS Image (INITRD)

## Installing

Once booted with either the Hybrid Live ISO or Kernel + RootFS you can install
uLinux to disk by typing in a shell:

```sh
# setup /dev/sda
```

Assuming `/dev/sda` is the device path to the disk you want to install to.

**WARNING:** This will _automatically_ partition, format and install uLinux
             with no questions asked without hestigation. Please be sure you
             understand what you are doing.

## Building

Just run:

```sh
$ make
```

## Testing

Just run:

```sh
$ make test
```

The OS comes pre-shipped with Dropbear (_SSH Daemon_) as well as a Busybox
Userland. The test script (`test.sh`) also uses QEMU and sets up a User mode
network which forwards port `10022` to teh geust VM for SSh access.

You can access the guest with:

```sh
$ ssh -p 2222 root@localhost
```
