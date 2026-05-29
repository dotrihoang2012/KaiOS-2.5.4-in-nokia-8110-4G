# ── TOOLS ─────────────────────────────────────────────────────────────────────
ADB         := Tools/adb/Linux/adb
MKBOOTIMG   := Tools/Android\ Image\ Kitchen/Linux/bin/mkbootimg
MAKE_EXT4FS := Tools/make_ext4fs/bin/make_ext4fs
SIGN        := Tools/Sign/sign.sh
SIGNER_DIR  := Tools/OTA\ Signer
JAVA        := java
CLASSPATH   := $(SIGNER_DIR)/signapk.jar:$(SIGNER_DIR)/conscrypt-openjdk-uber.jar:$(SIGNER_DIR)/bcprov-jdk15on-1.64.jar:$(SIGNER_DIR)/bcpkix-jdk15on-1.64.jar
CERT        := Tools/Keys/testkey.x509.pem
KEY         := Tools/Keys/testkey.pk8

# ── RESOURCES ─────────────────────────────────────────────────────────────────
BOOT_RAMDISK    := Resources/Boot/ramdisk
BOOT_SPLIT      := Resources/Boot/split_img
RECOVERY_RAMDISK := Resources/Recovery/ramdisk
RECOVERY_SPLIT  := Resources/Recovery/split_img
SYSTEM_DIR      := Resources/System
SPLASH_DIR      := Resources/Splash
OTA_DIR         := Resources/Zip\ OTA

# ── BOOT IMAGE PARAMETERS ─────────────────────────────────────────────────────
BOOT_CMDLINE        := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive
BOOT_BASE           := 0x80000000
BOOT_PAGESIZE       := 2048
BOOT_KERNEL_OFFSET  := 0x00008000
BOOT_RAMDISK_OFFSET := 0x01000000
BOOT_SECOND_OFFSET  := 0x00f00000
BOOT_TAGS_OFFSET    := 0x00000100

# ── SYSTEM IMAGE ──────────────────────────────────────────────────────────────
SYSTEM_SIZE := 1073741824

# ── OUTPUT ────────────────────────────────────────────────────────────────────
VERSION     ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
RANDOMID    := $(shell cat /dev/urandom | tr -dc 'a-f0-9' | head -c 8)
BACKUP_DIR  := works/backups
INPUT       ?= input.zip
OUTPUT      ?= $(basename $(INPUT))-signed.zip

.PHONY: all build build-boot build-system build-recovery build-splash \
        backup backup-boot backup-system backup-recovery backup-splash \
        deploy deploy-boot deploy-system deploy-recovery deploy-splash \
        flash-recovery sideload sign build-installer wipe help

all: help

# ── BUILD ─────────────────────────────────────────────────────────────────────

build: build-boot build-recovery build-system build-splash
	@echo "All images built successfully."

build-boot:
	@echo "Building boot.img..."
	cd $(BOOT_RAMDISK) && find . | cpio -o -H newc | gzip > /tmp/boot-ramdisk.gz
	$(MKBOOTIMG) \
		--kernel $(BOOT_SPLIT)/boot.img-kernel \
		--ramdisk /tmp/boot-ramdisk.gz \
		--cmdline "$(BOOT_CMDLINE)" \
		--base $(BOOT_BASE) \
		--pagesize $(BOOT_PAGESIZE) \
		--kernel_offset $(BOOT_KERNEL_OFFSET) \
		--ramdisk_offset $(BOOT_RAMDISK_OFFSET) \
		--second_offset $(BOOT_SECOND_OFFSET) \
		--tags_offset $(BOOT_TAGS_OFFSET) \
		--output boot.img
	@rm -f /tmp/boot-ramdisk.gz
	@echo "-> boot.img done"

build-recovery:
	@echo "Building recovery.img..."
	cd $(RECOVERY_RAMDISK) && find . | cpio -o -H newc | gzip > /tmp/recovery-ramdisk.gz
	$(MKBOOTIMG) \
		--kernel $(RECOVERY_SPLIT)/recovery.img-kernel \
		--ramdisk /tmp/recovery-ramdisk.gz \
		--cmdline "$(BOOT_CMDLINE)" \
		--base $(BOOT_BASE) \
		--pagesize $(BOOT_PAGESIZE) \
		--kernel_offset $(BOOT_KERNEL_OFFSET) \
		--ramdisk_offset $(BOOT_RAMDISK_OFFSET) \
		--second_offset $(BOOT_SECOND_OFFSET) \
		--tags_offset $(BOOT_TAGS_OFFSET) \
		--output recovery.img
	@rm -f /tmp/recovery-ramdisk.gz
	@echo "-> recovery.img done"

build-system:
	@echo "Building system.img..."
	$(MAKE_EXT4FS) -s -l $(SYSTEM_SIZE) -a system system.img $(SYSTEM_DIR)
	@echo "-> system.img done"

build-splash:
	@echo "Building splash.img..."
	ffmpeg -vcodec png -i $(SPLASH_DIR)/logo.png \
		-vcodec rawvideo -f rawvideo -pix_fmt bgr565 -s 240x320 -y /tmp/splash-raw.bin
	cat $(SPLASH_DIR)/logohdr.bin /tmp/splash-raw.bin > splash.img
	@rm -f /tmp/splash-raw.bin
	@echo "-> splash.img done"

# ── BACKUP ────────────────────────────────────────────────────────────────────

backup: backup-boot backup-system backup-recovery backup-splash

backup-boot:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell dd if=/dev/block/bootdevice/by-name/boot of=/sdcard/boot.img
	$(ADB) pull /sdcard/boot.img $(BACKUP_DIR)/boot.$(RANDOMID).img
	$(ADB) shell rm /sdcard/boot.img
	@echo "-> Backed up to $(BACKUP_DIR)/boot.$(RANDOMID).img"

backup-system:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell dd if=/dev/block/bootdevice/by-name/system of=/sdcard/system.img
	$(ADB) pull /sdcard/system.img $(BACKUP_DIR)/system.$(RANDOMID).img
	$(ADB) shell rm /sdcard/system.img
	@echo "-> Backed up to $(BACKUP_DIR)/system.$(RANDOMID).img"

backup-recovery:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell dd if=/dev/block/bootdevice/by-name/recovery of=/sdcard/recovery.img
	$(ADB) pull /sdcard/recovery.img $(BACKUP_DIR)/recovery.$(RANDOMID).img
	$(ADB) shell rm /sdcard/recovery.img
	@echo "-> Backed up to $(BACKUP_DIR)/recovery.$(RANDOMID).img"

backup-splash:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell dd if=/dev/block/bootdevice/by-name/splash of=/sdcard/splash.img
	$(ADB) pull /sdcard/splash.img $(BACKUP_DIR)/splash.$(RANDOMID).img
	$(ADB) shell rm /sdcard/splash.img
	@echo "-> Backed up to $(BACKUP_DIR)/splash.$(RANDOMID).img"

# ── DEPLOY ────────────────────────────────────────────────────────────────────

deploy: deploy-boot deploy-recovery deploy-system deploy-splash

deploy-boot:
	$(ADB) push boot.img /sdcard/boot.img
	$(ADB) shell dd if=/sdcard/boot.img of=/dev/block/bootdevice/by-name/boot
	$(ADB) shell rm /sdcard/boot.img
	@echo "-> boot.img deployed"

deploy-recovery:
	$(ADB) push recovery.img /sdcard/recovery.img
	$(ADB) shell dd if=/sdcard/recovery.img of=/dev/block/bootdevice/by-name/recovery
	$(ADB) shell rm /sdcard/recovery.img
	@echo "-> recovery.img deployed"

deploy-system:
	$(ADB) push system.img /sdcard/system.img
	$(ADB) shell dd if=/sdcard/system.img of=/dev/block/bootdevice/by-name/system
	$(ADB) shell rm /sdcard/system.img
	@echo "-> system.img deployed"

deploy-splash:
	$(ADB) push splash.img /sdcard/splash.img
	$(ADB) shell dd if=/sdcard/splash.img of=/dev/block/bootdevice/by-name/splash
	$(ADB) shell rm /sdcard/splash.img
	@echo "-> splash.img deployed"

# ── FLASH ─────────────────────────────────────────────────────────────────────

flash-recovery:
	$(ADB) reboot recovery

sideload:
	$(ADB) sideload $(INPUT)

wipe:
	$(ADB) shell recovery --wipe_data

# ── SIGN & INSTALLER ──────────────────────────────────────────────────────────

sign:
	$(JAVA) -cp "$(CLASSPATH)" SignApk -w $(CERT) $(KEY) $(INPUT) $(OUTPUT)

build-installer:
	@echo "Building OTA installer package..."
	bash $(SIGN) $(OTA_DIR) Nokia_8110_4G_KaiOS2.5.4_$(VERSION).zip
	@echo "-> Nokia_8110_4G_KaiOS2.5.4_$(VERSION).zip done"

# ── HELP ──────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "  KaiOS 2.5.4 — Nokia 8110 4G Build System"
	@echo "  =========================================="
	@echo ""
	@echo "  BUILD"
	@echo "    make build                Build all images (boot, recovery, system, splash)"
	@echo "    make build-boot           Build boot.img"
	@echo "    make build-recovery       Build recovery.img"
	@echo "    make build-system         Build system.img"
	@echo "    make build-splash         Build splash.img"
	@echo ""
	@echo "  BACKUP  (device must be connected)"
	@echo "    make backup               Backup all partitions"
	@echo "    make backup-boot          Backup boot partition"
	@echo "    make backup-system        Backup system partition"
	@echo "    make backup-recovery      Backup recovery partition"
	@echo "    make backup-splash        Backup splash partition"
	@echo ""
	@echo "  DEPLOY  (requires Pris Recovery or Philz Touch Recovery)"
	@echo "    make deploy               Flash all images to device"
	@echo "    make deploy-boot          Flash boot.img"
	@echo "    make deploy-recovery      Flash recovery.img"
	@echo "    make deploy-system        Flash system.img"
	@echo "    make deploy-splash        Flash splash.img"
	@echo ""
	@echo "  FLASH"
	@echo "    make flash-recovery       Reboot device into recovery"
	@echo "    make sideload INPUT=f.zip Sideload a signed ZIP via ADB"
	@echo "    make wipe                 Wipe data partition"
	@echo ""
	@echo "  PACKAGE"
	@echo "    make sign INPUT=f.zip     Sign a ZIP with test-keys"
	@echo "    make build-installer      Build OTA installer package"
	@echo "    make build-installer VERSION=1.0.0"
	@echo ""
