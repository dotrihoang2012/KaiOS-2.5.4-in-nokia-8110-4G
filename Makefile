JAVA        := java
SIGNER_DIR  := Tools/OTA\ Signer
CLASSPATH   := $(SIGNER_DIR)/signapk.jar:$(SIGNER_DIR)/conscrypt-openjdk-uber.jar:$(SIGNER_DIR)/bcprov-jdk15on-1.64.jar:$(SIGNER_DIR)/bcpkix-jdk15on-1.64.jar
CERT        := $(SIGNER_DIR)/testkey.x509.pem
KEY         := $(SIGNER_DIR)/testkey.pk8

EDL         := python3 Tools/EDL/EDL/edl.py
LOADER      := Tools/EDL/EDL/Loaders/8110.mbn
SYSTEM_IMG  := Resources/System.img
BOOT_IMG    := Resources/Boot.img

INPUT  ?= input.zip
OUTPUT ?= $(basename $(INPUT))-signed.zip

.PHONY: all sign sideload flash-recovery flash-edl wipe help

all: help

## Sign a ZIP file with test-keys
## Usage: make sign INPUT=path/to/file.zip
sign:
	$(JAVA) -cp "$(CLASSPATH)" SignApk -w $(CERT) $(KEY) $(INPUT) $(OUTPUT)

## Boot into recovery
flash-recovery:
	adb reboot recovery

## Sideload a signed ZIP via ADB
## Usage: make sideload INPUT=path/to/file-signed.zip
sideload:
	adb sideload $(INPUT)

## Flash system + boot via EDL
flash-edl:
	adb reboot edl
	sleep 5
	$(EDL) w system $(SYSTEM_IMG) --loader=$(LOADER)
	$(EDL) w boot $(BOOT_IMG) --loader=$(LOADER)
	$(EDL) reset

## Wipe data via ADB (recovery must be open)
wipe:
	adb shell recovery --wipe_data

help:
	@echo ""
	@echo "  KaiOS 2.5.4 - Nokia 8110 4G"
	@echo "  =============================="
	@echo ""
	@echo "  make sign INPUT=file.zip       Sign a ZIP with test-keys"
	@echo "  make flash-recovery            Reboot into recovery"
	@echo "  make sideload INPUT=file.zip   Sideload a signed ZIP via ADB"
	@echo "  make flash-edl                 Flash system + boot via EDL"
	@echo "  make wipe                      Wipe data (recovery must be open)"
	@echo ""
