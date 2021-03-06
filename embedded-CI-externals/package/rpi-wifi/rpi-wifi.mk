################################################################################
#
# rpi0-wifi
#
################################################################################

RPI_WIFI_VERSION = 1.0
RPI_WIFI_SITE = $(BR2_EXTERNAL_EMBEDDEDCI_EXTERNALS_PATH)/package/rpi-wifi/src
RPI_WIFI_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_RPI_WIFI),y)
define RPI_WIFI_CONFIGURE_WPA_SUPPLICANT
	cat $(@D)/wpa_supplicant.conf > $(TARGET_DIR)/etc/wpa_supplicant.conf
        $(SED) 's/^\s*ssid=.*/ssid=$(BR2_PACKAGE_RPI_WIFI_SSID)/' $(TARGET_DIR)/etc/wpa_supplicant.conf
        $(SED) 's/^\s*psk=.*/psk=$(BR2_PACKAGE_RPI_WIFI_PWD)/' $(TARGET_DIR)/etc/wpa_supplicant.conf
endef

define RPI_WIFI_CONFIGURE_NETWORK_INTERFACES
	cat $(@D)/interfaces > $(TARGET_DIR)/etc/network/interfaces
endef

ifeq ($(BR2_PACKAGE_RPI_WIFI_MODPROBE),y)
define RPI_WIFI_CONFIGURE_INITTAB 
	if ! grep -Fq "modprobe brcmfmac" $(TARGET_DIR)/etc/inittab; \
	then \
		$(SED) '/# now run any rc scripts/i\::sysinit:\/sbin\/modprobe brcmfmac' $(TARGET_DIR)/etc/inittab; \
	fi
endef
endif

ifeq ($(BR2_PACKAGE_RPI_WIFI_SSH_WITH_ROOT_LOGIN), y)
define RPI_WIFI_CONFIGURE_SSHD_CONFIG
	$(SED) 's/^\s*#*\s*PermitRootLogin.*/PermitRootLogin yes/' $(TARGET_DIR)/etc/ssh/sshd_config
endef
endif
endif



define RPI_WIFI_CONFIGURE_CMDS
	$(RPI_WIFI_CONFIGURE_WPA_SUPPLICANT)
	$(RPI_WIFI_CONFIGURE_NETWORK_INTERFACES)
	$(RPI_WIFI_CONFIGURE_INITTAB)
	$(RPI_WIFI_CONFIGURE_SSHD_CONFIG)
endef


$(eval $(generic-package))