HOSTS = hostname

TARGET = mvebu
SUBTARGET = cortexa9
PLATFORM = linksys_wrt1900ac

define INSTALL_LISTS
	firewall
	hdd
	iptables
	luci
	mass-storage
	openvpn
	procps
	router
	ssh
	ssh-keygen
	tools-add
	tools-basic
	tools-huge
	usb
	vim-fuller
	wpad
endef
define REMOVE_LISTS
	ppp
	router-simple
endef
define INSTALL_PKGS
	sudo
	luci-app-samba4
	luci-app-minidlna
endef
define REMOVE_PKGS
endef

define FILES_INSTALL
	$(call install,files/authorized_keys,/root/.ssh/)
	$(call install,files/mactelnet,/etc/config/)
endef
