# ── CONFIG ────────────────────────────────────────────────────────────────────
TARGET      := 8110
PERSISTDIR  := /data/media/0
USERDATA    := /dev/block/bootdevice/by-name/userdata
SHELL       := /bin/bash

VERSION     ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILDID     := $(shell bash -c 'echo $$RANDOM')

# ── TOOLS ─────────────────────────────────────────────────────────────────────
AIK_LINUX   := Tools/Android\ Image\ Kitchen/Linux
AIK_WIN     := Tools/Android\ Image\ Kitchen/Windows
MAKE_EXT4FS := Tools/make_ext4fs/make_ext4fs
SIGN        := Tools/Sign/sign.sh
SIGN_DIR    := Tools/Sign
JAVA        := Tools/Java/Linux/bin/java
CLASSPATH   := $(SIGN_DIR)/signapk.jar:$(SIGN_DIR)/conscrypt-openjdk-uber.jar:$(SIGN_DIR)/bcprov-jdk15on-1.64.jar:$(SIGN_DIR)/bcpkix-jdk15on-1.64.jar
CERT        := Tools/Keys/testkey.x509.pem
KEY         := Tools/Keys/testkey.pk8
ADB         := Tools/adb/Linux/adb

# ── RESOURCES ─────────────────────────────────────────────────────────────────
BOOT_DIR        := Resources/Boot
RECOVERY_DIR    := Resources/Recovery
SYSTEM_DIR      := Resources/System
SPLASH_DIR      := Resources/Splash
OTA_DIR         := Resources/Zip\ OTA

BASE_SYSTEM_SIZE := 838860800

# ── OUTPUT ────────────────────────────────────────────────────────────────────
BACKUP_DIR  := works/backups
INPUT       ?= input.zip
OUTPUT      ?= $(basename $(INPUT))-signed.zip

.PHONY: all build build-boot build-system build-recovery build-splash \
        backup backup-boot backup-system backup-recovery backup-splash \
        deploy deploy-boot deploy-system deploy-recovery deploy-splash \
        flash-recovery sideload sign build-installer wipe \
        clean clean-boot clean-system clean-recovery clean-splash clean-installer help

all: build backup deploy

# ── BUILD ─────────────────────────────────────────────────────────────────────

build: build-boot build-recovery build-splash build-system

build-boot: clean-boot
	@echo "Building boot.img..."
	@cp -r $(BOOT_DIR)/split_img $(AIK_LINUX)/split_img
	@cp -r $(BOOT_DIR)/ramdisk   $(AIK_LINUX)/ramdisk
	@cd $(AIK_LINUX) && bash repackimg.sh
	@mv $(AIK_LINUX)/image-new.img boot.img
	@rm -rf $(AIK_LINUX)/split_img $(AIK_LINUX)/ramdisk $(AIK_LINUX)/ramdisk-new.cpio*
	@echo "-> boot.img done"

build-recovery: clean-recovery
	@echo "Building recovery.img..."
	@cp -r $(RECOVERY_DIR)/split_img $(AIK_LINUX)/split_img
	@cp -r $(RECOVERY_DIR)/ramdisk   $(AIK_LINUX)/ramdisk
	@cd $(AIK_LINUX) && bash repackimg.sh
	@mv $(AIK_LINUX)/image-new.img recovery.img
	@rm -rf $(AIK_LINUX)/split_img $(AIK_LINUX)/ramdisk $(AIK_LINUX)/ramdisk-new.cpio*
	@echo "-> recovery.img done"

build-system:
	@echo "Building system.img..."
	$(MAKE_EXT4FS) -a '/system' -L 'system' -j 0 -l $(BASE_SYSTEM_SIZE) system.img $(SYSTEM_DIR)/
	@echo "-> system.img done"

build-splash: clean-splash
	@echo "Building splash.img..."
	@ffmpeg -vcodec png -i $(SPLASH_DIR)/logo.png \
		-vcodec rawvideo -f rawvideo -pix_fmt bgr565 -s 240x320 -y /tmp/splash-raw.bin
	@cat $(SPLASH_DIR)/logohdr.bin /tmp/splash-raw.bin > splash.img
	@rm -f /tmp/splash-raw.bin
	@echo "-> splash.img done"

# ── BACKUP ────────────────────────────────────────────────────────────────────

backup: backup-boot backup-recovery backup-splash backup-system

backup-boot:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) shell dd of=$(PERSISTDIR)/boot.backup.img if=/dev/block/bootdevice/by-name/boot bs=2048
	$(ADB) pull $(PERSISTDIR)/boot.backup.img $(BACKUP_DIR)/boot.$(BUILDID).img
	$(ADB) shell rm -f $(PERSISTDIR)/boot.backup.img
	@echo "-> Backed up to $(BACKUP_DIR)/boot.$(BUILDID).img"

backup-recovery:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) shell dd of=$(PERSISTDIR)/recovery.backup.img if=/dev/block/bootdevice/by-name/recovery bs=2048
	$(ADB) pull $(PERSISTDIR)/recovery.backup.img $(BACKUP_DIR)/recovery.$(BUILDID).img
	$(ADB) shell rm -f $(PERSISTDIR)/recovery.backup.img
	@echo "-> Backed up to $(BACKUP_DIR)/recovery.$(BUILDID).img"

backup-system:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) shell dd of=$(PERSISTDIR)/system.backup.img if=/dev/block/bootdevice/by-name/system bs=2048
	$(ADB) pull $(PERSISTDIR)/system.backup.img $(BACKUP_DIR)/system.$(BUILDID).img
	$(ADB) shell rm -f $(PERSISTDIR)/system.backup.img
	@echo "-> Backed up to $(BACKUP_DIR)/system.$(BUILDID).img"

backup-splash:
	@mkdir -p $(BACKUP_DIR)
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) shell dd of=$(PERSISTDIR)/splash.backup.img if=/dev/block/bootdevice/by-name/splash bs=2048
	$(ADB) pull $(PERSISTDIR)/splash.backup.img $(BACKUP_DIR)/splash.$(BUILDID).img
	$(ADB) shell rm -f $(PERSISTDIR)/splash.backup.img
	@echo "-> Backed up to $(BACKUP_DIR)/splash.$(BUILDID).img"

# ── DEPLOY ────────────────────────────────────────────────────────────────────

deploy: deploy-boot deploy-recovery deploy-splash deploy-system

deploy-boot:
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) push boot.img $(PERSISTDIR)/
	$(ADB) shell dd if=$(PERSISTDIR)/boot.img of=/dev/block/bootdevice/by-name/boot bs=2048
	$(ADB) shell rm $(PERSISTDIR)/boot.img
	@echo "-> boot.img deployed"

deploy-recovery:
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) push recovery.img $(PERSISTDIR)/
	$(ADB) shell dd if=$(PERSISTDIR)/recovery.img of=/dev/block/bootdevice/by-name/recovery bs=2048
	$(ADB) shell rm $(PERSISTDIR)/recovery.img
	@echo "-> recovery.img deployed"

deploy-system:
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) push system.img $(PERSISTDIR)/
	$(ADB) shell dd if=$(PERSISTDIR)/system.img of=/dev/block/bootdevice/by-name/system bs=2048
	$(ADB) shell rm $(PERSISTDIR)/system.img
	@echo "-> system.img deployed"

deploy-splash:
	$(ADB) shell mount -o nosuid,nodev,noatime,barrier=1,noauto_da_alloc,discard $(USERDATA) /data
	$(ADB) shell mkdir -p $(PERSISTDIR)/
	$(ADB) push splash.img $(PERSISTDIR)/
	$(ADB) shell dd if=$(PERSISTDIR)/splash.img of=/dev/block/bootdevice/by-name/splash bs=2048
	$(ADB) shell rm $(PERSISTDIR)/splash.img
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
	$(JAVA) -cp $(CLASSPATH) SignApk -w $(CERT) $(KEY) $(INPUT) $(OUTPUT)

build-installer: clean build-system build-boot build-recovery build-splash
	@mkdir -p works/installer
	@cp -r $(OTA_DIR)/* works/installer/
	@mv system.img works/installer/
	@mv boot.img works/installer/
	@mv recovery.img works/installer/
	@mv splash.img works/installer/
	@bash $(SIGN) works/installer Nokia_8110_4G_KaiOS2.5.4_$(VERSION).zip
	@rm -rf works/installer
	@echo "-> Nokia_8110_4G_KaiOS2.5.4_$(VERSION).zip done"

# ── CLEAN ─────────────────────────────────────────────────────────────────────

clean: clean-boot clean-recovery clean-system clean-splash clean-installer

clean-boot:
	@rm -f boot.img
	@rm -rf $(AIK_LINUX)/split_img $(AIK_LINUX)/ramdisk $(AIK_LINUX)/ramdisk-new.cpio* $(AIK_LINUX)/image-new.img

clean-recovery:
	@rm -f recovery.img
	@rm -rf $(AIK_LINUX)/split_img $(AIK_LINUX)/ramdisk $(AIK_LINUX)/ramdisk-new.cpio* $(AIK_LINUX)/image-new.img

clean-system:
	@rm -f system.img
	@rm -rf works/system

clean-splash:
	@rm -f splash.img

clean-installer:
	@rm -rf works/installer Nokia_8110_4G_KaiOS2.5.4_*.zip

# ── HELP ──────────────────────────────────────────────────────────────────────

help:
	@echo "Usage:"
	@echo ""
	@echo "  BUILD"
	@echo "    makefile build                Build all images (boot, recovery, system, splash)"
	@echo "    makefile build-boot           Build boot.img  (via Android Image Kitchen)"
	@echo "    makefile build-recovery       Build recovery.img"
	@echo "    makefile build-system         Build system.img"
	@echo "    makefile build-splash         Build splash.img"
	@echo ""
	@echo "  BACKUP  (device must be connected)"
	@echo "    makefile backup               Backup all partitions"
	@echo "    makefile backup-boot          Backup boot"
	@echo "    makefile backup-system        Backup system"
	@echo "    makefile backup-recovery      Backup recovery"
	@echo "    makefile backup-splash        Backup splash"
	@echo ""
	@echo "  DEPLOY  (requires Pris Recovery or Philz Touch Recovery)"
	@echo "    makefile deploy               Flash all images"
	@echo "    makefile deploy-boot          Flash boot.img"
	@echo "    makefile deploy-recovery      Flash recovery.img"
	@echo "    makefile deploy-system        Flash system.img"
	@echo "    makefile deploy-splash        Flash splash.img"
	@echo ""
	@echo "  FLASH"
	@echo "    makefile flash-recovery       Reboot device into recovery"
	@echo "    makefile sideload INPUT=f.zip Sideload a signed ZIP via ADB"
	@echo "    makefile wipe                 Wipe data partition"
	@echo ""
	@echo "  PACKAGE"
	@echo "    makefile sign INPUT=f.zip     Sign a ZIP with test-keys"
	@echo "    makefile build-installer      Build OTA installer package"
	@echo "    makefile build-installer VERSION=1.0.0"
	@echo ""
	@echo "  CLEAN"
	@echo "    makefile clean                Remove all built images"
	@echo ""
