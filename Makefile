.PHONY: clean build test

all: build

build:
	@echo "Building builder ..."
	@docker build -t ulinux/builder .
	@echo "Building image ..."
	@if docker ps -a | grep -q ulinux_build; then docker rm $$(docker ps -a | grep ulinux_build | cut -f 1 -d ' '); fi
	@docker run --name ulinux_build ulinux/builder
	@echo "Copying Kernel config ..."
	@docker cp ulinux_build:/build/KConfig .
	@echo "Copying ISO Image(s), Kernel and RootFS ..."
	@docker cp ulinux_build:/build/clouddrive.iso .
	@docker cp ulinux_build:/build/ulinux.iso .
	@docker cp ulinux_build:/build/kernel.gz .
	@docker cp ulinux_build:/build/rootfs.gz .
	@docker rm -f ulinux_build
	@echo "Creating Disk Image ..."
	@qemu-img create -f qcow2 ulinux.img 1G

repack:
	@echo "Building builder ..."
	@docker build -t ulinux/builder .
	@echo "Building image ..."
	@if docker ps -a | grep -q ulinux_build; then docker rm $$(docker ps -a | grep ulinux_build | cut -f 1 -d ' '); fi
	@docker run --name ulinux_build ulinux/builder repack
	@echo "Copying ISO Image(s), Kernel and RootFS ..."
	@docker cp ulinux_build:/build/clouddrive.iso .
	@docker cp ulinux_build:/build/ulinux.iso .
	@docker cp ulinux_build:/build/rootfs.gz .
	@docker rm -f ulinux_build
	@echo "Re-creating Disk Image ..."
	@qemu-img create -f qcow2 ulinux.img 1G

test:
	@./test.sh

clean:
	@git clean -f -d -x
