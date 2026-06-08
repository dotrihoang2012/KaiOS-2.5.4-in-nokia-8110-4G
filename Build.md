# Building from Source

> **Warning:** Java is distributed as a ZIP archive. You must extract it to the correct location before building:
> - **Windows:** Extract to `Tools\Java\Windows\`
> - **Linux:** Extract to `Tools/Java/Linux/`

## Usage

**Linux**

Install Make if not already present:

```
sudo apt install make
```

Make the Makefile executable:

```
chmod +x Makefile
```

Then run:

```
make <target>
```

**Windows**

```
makefile <target>
```

### BUILD

| Target | Description |
|---|---|
| `build` | Build all images (boot, recovery, system, splash) |
| `build-boot` | Build boot.img via Android Image Kitchen |
| `build-recovery` | Build recovery.img |
| `build-system` | Build system.img |
| `build-splash` | Build splash.img |

### BACKUP

Device must be connected via ADB.

| Target | Description |
|---|---|
| `backup` | Backup all partitions |
| `backup-boot` | Backup boot partition |
| `backup-recovery` | Backup recovery partition |
| `backup-system` | Backup system partition |
| `backup-splash` | Backup splash partition |

### DEPLOY

Requires Gerda Recovery or Philz Touch Recovery.

| Target | Description |
|---|---|
| `deploy` | Flash all images |
| `deploy-boot` | Flash boot.img |
| `deploy-recovery` | Flash recovery.img |
| `deploy-system` | Flash system.img |
| `deploy-splash` | Flash splash.img |

### FLASH

| Target | Description |
|---|---|
| `flash-recovery` | Reboot device into recovery |
| `sideload` | Sideload a signed ZIP via ADB (`INPUT=file.zip`) |
| `wipe` | Wipe data partition |

### PACKAGE

| Target | Description |
|---|---|
| `sign` | Sign a ZIP with test-keys (`INPUT=file.zip`) |
| `build-installer` | Build OTA installer package |
| `build-installer VERSION=1.0.0` | Build installer with specific version tag |

### CLEAN

| Target | Description |
|---|---|
| `clean` | Remove all built images |

## Building

## Supported builds as of now

- `boot`
- `recovery`
- `system`
- `splash`
- `installer`

## Dependency Requirements

### Overall

- ADB
- Bash 3+
- Make
- JRE 8

### For building the boot and recovery images

- Android Image Kitchen (included in `Tools/`)

### For building the system image

- `make_ext4fs` (included in `Tools/`)

### For building the splash image

- FFmpeg

## Building the images

```
make build
```

Files called `boot.img`, `recovery.img`, `system.img` and `splash.img` will be created in the project directory.

You can also individually run `make build-boot`, `make build-recovery`, `make build-system` and `make build-splash` to build only the parts you need right now.

## Backing up existing partitions

```
make backup
```

Files called `boot.$RANDOMID.img`, `recovery.$RANDOMID.img`, `system.$RANDOMID.img` and `splash.$RANDOMID.img` will be created in the `works/backups/` directory.
The RANDOMID value will be consistent across all backup images.

You can also individually run `make backup-boot`, `make backup-recovery`, `make backup-system` and `make backup-splash` to backup only the parts you need right now.

## Deploying the images to the device

You must have Gerda Recovery or Philz Touch Recovery installed on your device for deployment to succeed.

Boot the phone into recovery and then run:

```
make deploy
```

You can also individually run `make deploy-boot`, `make deploy-recovery`, `make deploy-system` and `make deploy-splash` to flash only the parts you need right now.

## Building the update package for recovery

You can also build a ready-made update.zip installable from recovery.

```
make build-installer
```

or

```
make VERSION=1.0.0 build-installer
```

If the `VERSION` variable is omitted, the short hash of the recent commit will be used instead.

A file called `Nokia_8110_4G_KaiOS2.5.4_${VERSION}.zip` will be created in the project directory.

To install the image, reboot into recovery and sideload:

```
adb reboot recovery
adb sideload Nokia_8110_4G_KaiOS2.5.4_${VERSION}.zip
```

Wait until the process completes, then reboot the phone.

## Changing boot splash image

Note: this guide only focuses on the splash partition image ("Powered by KaiOS" by default). The system splash ("Nokia") is stored in the `system` partition.

Prerequisites: `ffmpeg` must be installed.

### Boot splash format description

- First 8 bytes (0 to 7): `SPLASH!!` (`53 50 4C 41 53 48 21 21` in hex)
- Bytes 8 to 11: 32-bit width, little-endian (for 8110: `f0 00 00 00`, equals 240)
- Bytes 12 to 15: 32-bit height, little-endian (for 8110: `40 01 00 00`, equals 320)
- Bytes 16 to 19: 32-bit image type, little-endian (for 8110: `00 00 00 00`)
- Bytes 20 to 23: 32-bit 512-block count, little-endian (for 8110: `2c 01 00 00`, equals 240×320×2/512 = 300)
- Next 488 bytes: zero-filled
- Bytes from 512: raw 16-bit image data in BGR565LE format, length must be 153600 bytes

The header suitable for 8110 is stored in `Resources/Splash/logohdr.bin`.

### Manual steps to build the splash image

1. Place your PNG logo at `Resources/Splash/logo.png` (must be 240×320).
2. Run:

```
ffmpeg -vcodec png -i Resources/Splash/logo.png -vcodec rawvideo -f rawvideo -pix_fmt bgr565 -s 240x320 -y tmp.bin
cat Resources/Splash/logohdr.bin tmp.bin > splash.img
rm tmp.bin
```

### Automatic building

The splash image is built automatically when running `make build`. To use a custom splash, place a 240×320 PNG file at `Resources/Splash/logo.png`.

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
