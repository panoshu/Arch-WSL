# Arch-WSL

## rootfs.tar.gz

Build with lastest [archlinux-bootstrap-x86_64](http://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst)

### packages

`git wget curl vim less sudo zip unzip`

### wsl.conf

``` conf
[boot]
systemd=true

[automount]
enabled = true
options = "metadata"
mountFsTab = true
```

### locale

``` conf
LANG=en_US.UTF-8
LC_TIME=C.UTF-8
```

### pacman setting

- latest [pacman.conf](https://gitlab.archlinux.org/archlinux/archiso/-/raw/master/configs/releng/pacman.conf) file, add archlinuxcn mirror: `https://mirrors.cernet.edu.cn/archlinuxcn/$arch`
- latest [mirrorlist](https://archlinux.org/mirrorlist/all/) file, use tsinghua mirror: `https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch`

## rootfs.tar.gz with wsldl

Add [yuk7/wsldl](https://github.com/yuk7/wsldl/releases/latest/download/icons.zip)


## add packages

### add yay AUR

`sudo pacman -S yay`

### base packages

- network tools: `inetutils openbsd-netcat openssh`
- make tools: `aarch64-linux-gnu-gcc base base-devel bc cpio bison flex pahole`
- others: `man zsh tk`

## sudo systemctl start hangs on supported WSL version

### solution a

- modify ExecStart in `/usr/lib/systemd/system/systemd-networkd-wait-online.service`.
- The new ExecStart should be:
  `ExecStart=/usr/lib/systemd/systemd-networkd-wait-online -i eth0 --any --timeout=10`
- restart WSL: `wsl --shutdown`
- check again: `systemctl status`

### solution b

- `sudo systemctl list-jobs | grep running`
- `sudo systemctl cancel <job-number>`
- `sudo systemctl disable systemd-networkd-wait-online`
