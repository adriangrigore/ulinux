.PHONY: build images pkgs shell clouddrive test tests toc release up-to-date clean

all: build

build:
	@echo "Building builder ..."
	@docker build -q -f Dockerfile.builder -t ulinux/builder .
	@echo "Building uLinux ..."
	@if docker ps -a | grep -q ulinux_build; then docker rm $$(docker ps -a | grep ulinux_build | cut -f 1 -d ' '); fi
	@docker run -e TAG -e REV --name ulinux_build ulinux/builder
	@echo "Copying ISO Image(s), and RootFS ..."
	@docker cp ulinux_build:/build/ulinux.iso .
	@docker cp ulinux_build:/build/rootfs.gz .
	@docker rm -f ulinux_build
	@echo "Creating Disk Image ..."
	@qemu-img create -f qcow2 ulinux.img 1G
	@echo "Building Docker Image ..."
	@docker build -q -f Dockerfile -t prologic/ulinux .

ulinux.iso:
	@docker build -q -f Dockerfile.builder -t ulinux/builder .
	@if docker ps -a | grep -q ulinux_build; then docker rm $$(docker ps -a | grep ulinux_build | cut -f 1 -d ' '); fi
	@docker run -e TAG -e REV --name ulinux_build ulinux/builder
	@docker cp ulinux_build:/build/ulinux.iso .
	@docker rm -f ulinux_build

images: ulinux.iso
	@./images.sh

pkgs:
	@echo "Building builder ..."
	@docker build -q -f Dockerfile.builder -t ulinux/builder .
	@docker run -v "$(PWD)/artifacts":/build/artifacts ulinux/builder packages
	@if [ -n "$(PKG_SSH_HOST)" ] && [ -n "$(PKG_SSH_PATH)" ]; then \
		echo "Publishing packages to $(PKG_SSH_HOST):$(PKG_SSH_PATH) ..."; \
		scp -P "$(PKG_SSH_PORT)" ./artifacts/*#*.tar.gz "$(PKG_SSH_HOST):$(PKG_SSH_PATH)"; \
	fi

shell:
	@echo "Building builder ..."
	@docker build -q -f Dockerfile.builder -t ulinux/builder .
	@docker run -i -t -v "$(PWD)":/build ulinux/builder shell

clouddrive.iso:
	@echo "Building builder ..."
	@docker build -q -f Dockerfile.builder -t ulinux/builder .
	@echo "Building uLinux ..."
	@if docker ps -a | grep -q ulinux_build; then docker rm $$(docker ps -a | grep ulinux_build | cut -f 1 -d ' '); fi
	@docker run --name ulinux_build ulinux/builder clouddrive
	@echo "Copying CloudDrive Image ..."
	@docker cp ulinux_build:/build/clouddrive.iso .
	@docker rm -f ulinux_build

test: ulinux.iso
	@./test.sh

tests: clouddrive.iso ulinux.iso
	@./tests/run.sh

toc:
	@gh-md-toc README.md

release: clean up-to-date build tests images
	@./release.sh

up-to-date:
	@git checkout master
	@git fetch --all
	@git pull

clean:
	@git clean -f -d -x
