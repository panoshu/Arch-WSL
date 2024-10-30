OUT_TGZ=rootfs.tar.gz

DLR=curl
DLR_FLAGS=-L
BOOTSTRAP_URL=https://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst
PACMAN_CONF_URL=https://gitlab.archlinux.org/archlinux/archiso/-/raw/master/configs/releng/pacman.conf
MIRRORLIST_URL=https://archlinux.org/mirrorlist/all/
PKGS=archlinux-keyring wget curl vim less sudo base base-devel zip unzip man inetutils openbsd-netcat openssh tk zsh

all: $(OUT_TGZ)

tgz: $(OUT_TGZ)
$(OUT_TGZ): cache_clean
	@echo -e '\e[1;32mBuilding $(OUT_TGZ)\e[m'
	cd root.x86_64; sudo bsdtar -zcpf ../$(OUT_TGZ) *
	sudo chown `id -un` $(OUT_TGZ)
	sha256sum rootfs.tar.gz > rootfs.tar.gz.sha256sum
	sudo chown `id -un` rootfs.tar.gz.sha256sum

	rm -rf Arch
	mkdir -p Arch
	wget -O wsldl_icons.zip https://github.com/yuk7/wsldl/releases/latest/download/icons.zip
	unzip -o wsldl_icons.zip Arch.exe -d Arch/
	cp $(OUT_TGZ) Arch/$(OUT_TGZ)
	zip Arch.zip -r Arch/
	sudo chown `id -un` Arch.zip
	sha256sum Arch.zip > Arch.zip.sha256sum
	sudo chown `id -un` Arch.zip.sha256sum

cache_clean: final_setting pacman_setting
	@echo -e '\e[1;32mclean cache...\e[0m'
	sudo mv -f root.x86_64/etc/mtab.bak root.x86_64/etc/mtab
	yes | sudo chroot root.x86_64 /usr/bin/pacman -Scc
	-sudo umount root.x86_64/sys
	-sudo umount root.x86_64/proc
	sudo rm -rf root.x86_64/etc/pacman.d/gnupg
	sudo rm -rf root.x86_64/etc/pacman.conf~
	sudo rm -rf `sudo find root.x86_64/root/ -type f`
	sudo rm -rf `sudo find root.x86_64/tmp/ -type f`

final_setting: packages
	@echo -e '\e[1;32mfinale setting...\e[0m'
	echo "%wheel ALL=(ALL:ALL) ALL\n%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee root.x86_64/etc/sudoers.d/wheel
	echo "[boot]\nsystemd = true\n\n[automount]\nenabled = true\noptions = \"metadata\"\nmountFsTab = true" | sudo tee root.x86_64/etc/wsl.conf

pacman_setting: packages
	@echo -e '\e[1;32mDownloading pacman.conf mirrorlist...\e[0m'
	$(DLR) $(DLR_FLAGS) $(PACMAN_CONF_URL) -o pacman.conf.tmp
	sudo cp -bf pacman.conf.tmp root.x86_64/etc/pacman.conf

	@echo -e '\e[1;32mDownloading mirrorlist...\e[0m'
	$(DLR) $(DLR_FLAGS) $(MIRRORLIST_URL) -o mirrorlist.tmp
	sudo cp -rf mirrorlist.tmp root.x86_64/etc/pacman.d/mirrorlist

packages: locale
	@echo -e '\e[1;32minstall packages: $(PKGS)\e[0m'
	sudo mv -f root.x86_64/etc/resolv.conf root.x86_64/etc/resolv.conf.bak
	sudo cp -f /etc/resolv.conf root.x86_64/etc/resolv.conf
	echo "Server = https://geo.mirror.pkgbuild.com/\$$repo/os/\$$arch" | sudo tee root.x86_64/etc/pacman.d/mirrorlist
	sudo chroot root.x86_64 bash -c 'pacman-key --init'
	sudo chroot root.x86_64 bash -c 'pacman-key --populate'
	sudo chroot root.x86_64 bash -c 'pacman -Syu --noconfirm --needed $(PKGS)'
	sudo mv -f root.x86_64/etc/resolv.conf.bak root.x86_64/etc/resolv.conf

locale: mount_temp
	@echo -e '\e[1;32mlocale setting...\e[0m'
	sudo sed -i -e "s/#en_US.UTF-8/en_US.UTF-8/" root.x86_64/etc/locale.gen
	sudo chroot root.x86_64 bash -c 'locale-gen'
	echo "LANG=en_US.UTF-8\nLC_TIME=C.UTF-8" | sudo tee root.x86_64/etc/locale.conf
	sudo chroot root.x86_64 bash -c 'unset LANG'
	sudo chroot root.x86_64 bash -c 'source /etc/profile.d/locale.sh'
	touch locale.tmp

mount_temp: bootstrap
	@echo -e '\e[1;32msetting mtab...\e[0m'
	sudo mv -f root.x86_64/etc/mtab root.x86_64/etc/mtab.bak
	echo "rootfs / rootfs rw 0 0" | sudo tee root.x86_64/etc/mtab
	sudo mount -t proc proc root.x86_64/proc/
	sudo mount --bind /sys root.x86_64/sys

bootstrap:
	@echo -e '\e[1;32mDownloading archlinux-bootstrap-x86_64.tar.zst...\e[m'

	-sudo rm -rf Arch.zip*
	-sudo rm -rf rootfs.tar.gz*

	$(DLR) $(DLR_FLAGS) $(BOOTSTRAP_URL) -o archlinux-bootstrap-x86_64.tar.zst

	@echo -e '\e[1;32mExtracting archlinux-bootstrap...\e[0m'
	sudo tar -I zstd -xvf archlinux-bootstrap-x86_64.tar.zst
	sudo chmod +x root.x86_64

clean: cleanall

cleanall: cleanarchicon cleanroot cleantmp

cleanarchicon:
	-sudo rm -rf wsldl_icons.zip
	-sudo rm -rf Arch/

cleanroot:
	-sudo umount root.x86_64/sys
	-sudo umount root.x86_64/proc
	-sudo rm archlinux-bootstrap-x86_64.tar.gz
	-sudo rm -rf root.x86_64

cleantmp:
	-sudo rm -rf *.tmp
	-sudo rm -rf Arch.zip*
	-sudo rm -rf rootfs.tar.gz*
