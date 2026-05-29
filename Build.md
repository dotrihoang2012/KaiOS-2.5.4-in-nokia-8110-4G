# Building from Source

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
