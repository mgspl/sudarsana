#!/bin/bash

set -ouex pipefail

### Cleanup from Zirconium
dnf -y remove foot \
	NetworkManager-adsl \
  	NetworkManager-bluetooth \
  	NetworkManager-config-connectivity-fedora \
  	NetworkManager-libnm \
  	NetworkManager-openconnect \
  	NetworkManager-openvpn \
  	NetworkManager-strongswan \
  	NetworkManager-vpnc \
  	NetworkManager-wifi \
  	NetworkManager-wwan \
  	audit \
  	cups \
  	cups-pk-helper \
  	dymo-cups-drivers \
  	hplip \
  	hyperv-daemons \
  	open-vm-tools \
  	open-vm-tools-desktop \
  	openconnect \
  	pam_yubico \
  	printer-driver-brlaser \
  	ptouch-driver \
  	qemu-guest-agent \
  	spice-vdagent \
  	steam-devices \
  	switcheroo-control \
  	system-config-printer-libs \
  	system-config-printer-udev \
  	uxplay \
  	vpnc \
  	whois \
  	wireguard-tools \
  	fcitx5-mozc \
  	valent-git \
  	input-remapper 
  	

  	

### Install Kernel Cachyos (Stole From Piperita)
for pkg in kernel kernel-core kernel-modules kernel-modules-core; do
  rpm --erase $pkg --nodeps
done

pushd /usr/lib/kernel/install.d
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr disable bieszczaders/kernel-cachyos-lto
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-lto install \
  kernel-cachyos-lto

dnf -y copr enable bieszczaders/kernel-cachyos-addons
dnf -y copr disable bieszczaders/kernel-cachyos-addons
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons swap zram-generator-defaults cachyos-settings
dnf -y --enablerepo copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons install \
  scx-scheds-git \
  scx-manager
  
tee /usr/lib/modules-load.d/ntsync.conf <<'EOF'
ntsync
EOF

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
depmod -a "$(ls -1 /lib/modules/ | tail -1)"
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

### Install LACT
dnf -y copr enable ilyaz/LACT
dnf -y install lact
systemctl enable lactd
dnf -y copr disable ilyaz/LACT

### Install Gpu Screen Recorder
dnf -y copr enable brycensranch/gpu-screen-recorder-git
dnf -y install gpu-screen-recorder-ui
dnf -y copr disable brycensranch/gpu-screen-recorder-git

### Install packages from repos
dnf -y install \
	kitty 	\
	neovim   \
	openrgb	  \
	openrgb-udev-rules

systemctl enable openrgb
