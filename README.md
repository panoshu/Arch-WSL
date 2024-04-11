# Arch-WSL

## rootfs.tar.gz

Build with lastest [archlinux-bootstrap-x86_64](http://mirrors.edge.kernel.org/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.gz)

### packages

`wget curl vim less sudo base base-devel zip unzip man inetutils openbsd-netcat openssh tk zsh`

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
