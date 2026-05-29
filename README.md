# KaiOS 2.5.4 for Nokia 8110 4G

<p align="center">
  <img src="img/black.png" width="49%" />
  <img src="img/yellow.png" width="49%" />
</p>

A custom KaiOS 2.5.4 build for the Nokia 8110 4G (TA-1048 / TA-1059),
featuring numerous bug fixes, patches, and improvements over the stock firmware.

---

> **WARNING: FLASHING CUSTOM FIRMWARE MAY VOID YOUR WARRANTY AND CARRY THE RISK
> OF BRICKING YOUR DEVICE. I AM NOT RESPONSIBLE FOR ANY DAMAGE, DATA LOSS, OR
> BRICKED DEVICES UNDER ANY CIRCUMSTANCE. PROCEED AT YOUR OWN RISK.**

---

## What's New

**Bug Fixes & Improvements:**
- Fixed lockscreen bypass vulnerability via memory cleaner
- Added task manager
- New API for better experience
- Added SELinux Status in Settings
- Added Phone Status in Settings

---

## Before Install

You must root or jailbreak your device before flashing.

Tutorial: https://sites.google.com/view/bananahackers/home

---

## Requirements

- Nokia 8110 4G (TA-1048 or TA-1059)
- ADB & Fastboot installed on your computer
- At least **50%** battery charge
- A USB cable (avoid hubs)
- Recovery mode with **test-keys** support

---

## How to Enable ADB

**Method 1 — Dial code**

From the home screen, dial:
```
*#*#33284#*#*
```
If it doesn't work, try:
```
*#*#0574#*#*
```

**Method 2 — W2D (browser)**

1. Open the browser on your device
2. Go to: `http://w2d.js.org/`
3. Navigate to **W2D KaiOS Jailbreak**
4. Press **"Open Developer menu"**
5. Set **Debugger → ADB and DevTools**

After enabling ADB, connect to your PC and verify:
```bash
adb devices
```

---

## Flash Instructions

### Method 1 — ADB Sideload (Recovery)

**Step 1 — Boot into Recovery**
```bash
adb reboot recovery
```

**Step 2 — Wipe Data**

In the recovery menu, select **"Wipe data/factory reset"** and confirm.

**Step 3 — Sideload the package**

Select **"Apply update" → "Apply from ADB"**, then run:
```bash
adb sideload kaios-2.5.4-nokia8110-signed.zip
```

**Step 4 — Reboot**

Once complete, select **"Reboot system now"** from the recovery menu.

---

### Method 2 — EDL (Emergency Download Mode)

**Step 1 — Boot into EDL**
```bash
adb reboot edl
```

**Step 2 — Flash the partitions**

Once the device is in EDL mode, run:
```bash
python edl.py w system system.img --loader=8110.mbn
python edl.py w boot boot.img --loader=8110.mbn
```

**Step 3 — Reboot**
```bash
python edl.py reset
```

**Step 4 — Wipe Data**

After the device boots into recovery, select **"Wipe data/factory reset"** and confirm.

**Step 5 — Boot into EDL again**

Connect the device to your PC, then run:
```bash
adb reboot edl
```

---

## Common Errors

| Error | Fix |
|-------|-----|
| `signature verification failed` | Flash a test-keys recovery first |
| `Installation aborted` | Charge battery to 50%+ |
| ADB not detected | Try a different USB cable |

---

## Notes

- Package must be signed with **test-keys**
- Always back up your data before flashing
- Do not unplug or power off during the flash process

---

## Building from Source

### Dependency Requirements

**Overall:**
- ADB
- Bash 3+
- Make
- JRE 8

**For building the boot image:**
- Make, GCC

**For building the system image:**
- `make_ext4fs` (compiled during the build process)

**For building the splash image:**
- FFmpeg

### Building the Images

```bash
make build
```

Files called `boot.img`, `system.img`, `splash.img` and `recovery.img` will be created in the project directory.

You can also individually run `make build-boot`, `make build-system` and `make build-splash` to build only the parts you need right now.

### Backing up Existing Partitions

```bash
make backup
```

Files called `boot.$RANDOMID.img`, `system.$RANDOMID.img`, `splash.$RANDOMID.img` and `recovery.$RANDOMID.img` will be created in the `works/backups/` directory.
The RANDOMID value will be consistent across all backup images.

You can also individually run `make backup-boot`, `make backup-system`, `make backup-splash` and `make backup-recovery` to backup only the parts you need right now.

### Deploying the Images to the Device

Requires **Pris Recovery (Gerda Recovery)** or **Philz Touch Recovery**. Boot into recovery then:

```bash
make deploy
```

You can also individually run `make deploy-boot`, `make deploy-system`, `make deploy-recovery` and `make deploy-splash` to flash only the parts you need right now.

### Building the Update Package for Recovery

Alternatively, you can also build a ready-made update.zip for the HMD firmware v12 or for Pris Recovery (highly recommended) over any stock system version.

```bash
make build-installer
```

or

```bash
make VERSION=${ver} build-installer
```

If the `VERSION` variable is omitted, short hash of the recent commit will be used instead. Same thing goes for GitLab CI automated build.

A file called `Nokia_8110_4G_KaiOS2.5.4_${ver}.zip` will be created in the project directory.

Note that this file will not install Gerda Recovery! And if Gerda Recovery isn't installed, the update can run only from stock v12 and lower recoveries.

To install the image, run `adb reboot recovery`, select "Wipe data/factory reset" and then "Install update from ADB", afterwards run:

```bash
adb sideload Nokia_8110_4G_KaiOS2.5.4_${ver}.zip
```

And wait until the process completes. Afterwards, reboot the phone to see your newly installed OS.

### Changing Boot Splash Image

Note: this guide only focuses on the splash partition image (which is "Powered by KaiOS" by default). The system one ("Nokia") is stored in `system` partition.

Prerequisites: `imagemagick` and/or `ffmpeg` package installed. Currently `ffmpeg` is required.

#### Boot Splash Format Description

- First 8 bytes (0 to 7): `SPLASH!!` (or `53 50 4C 41 53 48 21 21` in hex)
- Bytes 8 to 11: 32-bit width, little-endian (for 8110: `f0 00 00 00`, equals to 240)
- Bytes 12 to 15: 32-bit height, little-endian (for 8110: `40 01 00 00`, equals to 320)
- Bytes 16 to 19: 32-bit image type, little-endian (for 8110: `00 00 00 00`)
- Bytes 20 to 23: 32-bit 512-block count, little endian (for 8110: `2c 01 00 00`, equals to 240x320x2/512 = 300)
- Next 488 bytes: zero-filled
- Bytes from 512: raw 16-bit image data in BGR565LE format, length must be 153600 bytes

The header suitable for 8110 is stored in the `Resources/Splash/logohdr.bin` file.

#### Manual Steps to Build the Splash Image

1. Place your PNG with the logo to `Resources/Splash/logo.png`.
2. Run:

```bash
ffmpeg -vcodec png -i Resources/Splash/logo.png -vcodec rawvideo -f rawvideo -pix_fmt bgr565 -s 240x320 -y tmp.bin
cat Resources/Splash/logohdr.bin tmp.bin > splash.img
rm tmp.bin
```

#### Automatic Building

Run `make build` or place a 240x320 PNG at `Resources/Splash/logo.png`.

---

If you encounter any issues, email: dotrihoang2012@gmail.com
