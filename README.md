# ulinux

![Build](https://github.com/prologic/ulinux/workflows/Build/badge.svg)

> _so far..._ uLinux is an improved, refactored version of prior work I've done
> in the past with [Minimal Container Linux](https://github.com/prologic/minimcal-container-linux)
> in an effort to create yet another Linux OS / Distro with a different set of goals.
>
> I'm not sure what those goals are yet, this is still very eraly stages.
>
> Right now you can expect things to change rapidly, but in a stable way
> with the following features:

## Features

- Recent Linux Kernel
- Busybox userland
- Dropbear SSH
- Tiny C Compiler
- Flat Assembler
- Hybrid Live ISO
- Installer
- Crude (_to be replaced_) package  manager

### Screenshots

![screenshot-1](/screenshot-1.png?raw=true "screenshot-1")
> Botting from the Hybrid Live ISO in QEMU

![screenshot-2](/screenshot-2.png?raw=true "screenshot-2")
> After running `setup /dev/sda` to install to disk and booting from disk in QEMU

![screenshot-3](/screenshot-3.png?raw=true "screenshot-3")
> Resources used on boot

![screenshot-4](/screenshot-4.png?raw=true "screenshot-4")
> Also works in VirtualBox

## Getting Started

First make sure you have [Docker](https://www.docker.com) installed on your
system as the build uses this extensively to build the OS reliably across
all platforms consistently.

Also make sure you have [QEMU](https://www.qemu.org/) installed as this is
used for testing and booting the OS into a Guest VM.

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
