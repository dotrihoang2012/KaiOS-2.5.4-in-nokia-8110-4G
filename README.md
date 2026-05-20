# KaiOS 2.5.4 for Nokia 8110 4G

<p align="center">
  <img src="images/black.png" width="49%" />
  <img src="images/yellow.png" width="49%" />
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

**Step 2 — Sideload the package**

In the recovery menu, select **"Apply update" → "Apply from ADB"**, then run:
```bash
adb sideload kaios-2.5.4-nokia8110-signed.zip
```

**Step 3 — Reboot**

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

Unplug and reboot the device manually.

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

If you encounter any issues, email: dotrihoang2012@gmail.com
