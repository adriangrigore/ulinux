.PHONY: build repack test toc release up-to-date clean

all: build

build:
	@echo "Building builder ..."
	@docker build -f Dockerfile.builder -t ulinux/builder .
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
	@echo "Building Docker Image ..."
	@docker build -f Dockerfile -t prologic/ulinux .

repack:
	@echo "Building builder ..."
	@docker build -f Dockerfile.builder -t ulinux/builder .
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
	@echo "Re-building Docker Image ..."
	@docker build -f Dockerfile -t prologic/ulinux .

test:
	@./test.sh

toc:
	@gh-md-toc README.md

release: clean up-to-date
	@echo "Calculating SHA256SUMS ..."
	@sha256sum *.gz *.iso > sha256sums.txt
	@echo "Signing SHA256SUMS ..."
	@gpg --detach-sign sha256sums.txt
	@echo "Creating release ..."
	@./tools/release.sh

upload: clean up-to-date build
	@echo "Uploading prebuilt images..."
	@./tools/upload.sh

up-to-date:
	@git checkout master
	@git fetch --all
	@git pull

clean:
	@git clean -f -d -x
