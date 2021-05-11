HOSTS = hostname

TARGET = ramips
SUBTARGET = mt7620
PLATFORM = miwifi-mini

define INSTALL_LISTS
	luci
	openvpn
	procps
	router
	ssh
	ssh-keygen
	tools-add
	tools-basic
	vim-fuller
	wpad
endef
define REMOVE_LISTS
	firewall
	iptables
	ppp
	router-simple
endef
define INSTALL_PKGS
	sudo
endef
define REMOVE_PKGS
endef

define FILES_INSTALL
	$(call install,files/authorized_keys,/root/.ssh/)
	$(call install,files/mactelnet,/etc/config/)
endef
