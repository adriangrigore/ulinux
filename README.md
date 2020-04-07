# ulinux

![Build](https://github.com/prologic/ulinux/workflows/Build/badge.svg)

> _so far..._ uLinux is an improved, refactored version of prior work I've done
> in the past with [Minimal Container Linux](https://github.com/prologic/minimcal-container-linux)
> in an effort to create yet another Linux OS / Distro with a different set of goals.
>
> I'm not sure what those goals are yet, this is still very early stages.
>
> Right now you can expect things to change rapidly, but in a stable way
> with the following features:

As of the 6th Apr 2020:

> µLinux (uLinux) is now a micro Linux Cloud Native OS designed for high performance, minimal overheads and decreased security footprint attack surface.

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

![screenshot-1](/screenshot-1.png?raw=true "Botting from the Hybrid Live ISO")
![screenshot-2](/screenshot-2.png?raw=true "After running `setup /dev/sda` to install to disk and booting from disk")
![screenshot-3](/screenshot-3.png?raw=true "Fully booted showing process list and resources used after boot")

## Getting Started

First make sure you have [Docker](https://www.docker.com) installed on your
system as the build uses this extensively to build the OS reliably across
all platforms consistently.

Also make sure you have [QEMU](https://www.qemu.org/) installed as this is
used for testing and booting the OS into a Guest VM.

## Prebuilt

This repo contains prebuilt assets to get you started quickly without having
to build anything yourself. The following are currently available and stored
with [Git LFS](https://help.github.com/en/github/managing-large-files) and
can by fetched with `git lfs fetch` or downloaded directly from Github:

- [ulinux.iso](https://github.com/prologic/ulinux/blob/master/ulinux.iso) -- Hybrid Live ISO
- [kernel.gz](https://github.com/prologic/ulinux/blob/master/ulinux.iso) -- Linux Kernel
- [rootfs.gz](https://github.com/prologic/ulinux/blob/master/ulinux.iso) -- RootFS (_initrd_)

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
