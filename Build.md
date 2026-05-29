# Building from Source

## Usage

**Linux**

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
