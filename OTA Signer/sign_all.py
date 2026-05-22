#!/usr/bin/env python3
"""
KaiOS OTA ZIP Batch Signer
Tu dong ki tat ca file ZIP trong 8 thu muc Gapps/Kapps
Dat file nay cung thu muc voi: signapk.jar, conscrypt-openjdk-uber.jar,
bcprov-jdk15on-1.64.jar, bcpkix-jdk15on-1.64.jar, testkey.x509.pem, testkey.pk8
"""

import os
import subprocess
import sys
from pathlib import Path

# ── CAU HINH ──────────────────────────────────────────────────────────────────

JAVA = r"D:\desktop\Tools\Java\bin\java.exe"

# Thu muc chua tools - cung cho voi script nay
TOOL_DIR = Path(__file__).parent

# Danh sach cap (thu muc input, thu muc output)
JOBS = [
    (
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip but unsign\Method 1 - on System",
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip and sign\Method 1 - on System",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip but unsign\Method 2 - slideload",
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip and sign\Method 2 - slideload",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip but unsign\Method 3 - Slideload and System",
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip and sign\Method 3 - Slideload and System",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip but unsign\Method 4 - System App - Both Json",
        r"C:\Users\hoang\Downloads\desktop\Gapps\OTA Update\Zip and sign\Method 4 - System App - Both Json",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip but unsign\Method 1 - on System",
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip and sign\Method 1 - on System",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip but unsign\Method 2 - slideload",
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip and sign\Method 2 - slideload",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip but unsign\Method 3 - Slideload and System",
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip and sign\Method 3 - Slideload and System",
    ),
    (
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip but unsign\Method 4 - System App - Both Json",
        r"C:\Users\hoang\Downloads\desktop\Kapps\OTA Update\Zip and sign\Method 4 - System App - Both Json",
    ),
]

# ── KIEM TRA TOOLS ────────────────────────────────────────────────────────────

def check_tools():
    ok = True
    required = [
        "signapk.jar",
        "conscrypt-openjdk-uber.jar",
        "bcprov-jdk15on-1.64.jar",
        "bcpkix-jdk15on-1.64.jar",
        "testkey.x509.pem",
        "testkey.pk8",
    ]
    print("Kiem tra tools...")
    if not Path(JAVA).exists():
        print(f"  [LOI] Khong tim thay Java: {JAVA}")
        ok = False
    else:
        print(f"  [OK ] Java: {JAVA}")

    for f in required:
        path = TOOL_DIR / f
        if not path.exists():
            print(f"  [LOI] Khong tim thay: {path}")
            ok = False
        else:
            print(f"  [OK ] {f}")
    return ok

# ── KY MOT FILE ZIP ───────────────────────────────────────────────────────────

def sign_zip(input_zip: Path, output_zip: Path) -> bool:
    classpath = ";".join([
        str(TOOL_DIR / "signapk.jar"),
        str(TOOL_DIR / "conscrypt-openjdk-uber.jar"),
        str(TOOL_DIR / "bcprov-jdk15on-1.64.jar"),
        str(TOOL_DIR / "bcpkix-jdk15on-1.64.jar"),
    ])

    cmd = [
        JAVA,
        "-cp", classpath,
        "SignApk",
        "-w",
        str(TOOL_DIR / "testkey.x509.pem"),
        str(TOOL_DIR / "testkey.pk8"),
        str(input_zip),
        str(output_zip),
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"    [LOI] {result.stderr.strip()}")
        return False
    return True

# ── XU LY TUNG THU MUC ───────────────────────────────────────────────────────

def process_folder(input_dir: str, output_dir: str) -> tuple:
    input_path  = Path(input_dir)
    output_path = Path(output_dir)

    if not input_path.exists():
        print(f"  [BQ ] Thu muc khong ton tai: {input_path}")
        return 0, 0

    zip_files = sorted(input_path.glob("*.zip"))
    if not zip_files:
        print(f"  [BQ ] Khong co file ZIP nao trong: {input_path.name}")
        return 0, 0

    output_path.mkdir(parents=True, exist_ok=True)

    success = 0
    failed  = 0

    for zip_file in zip_files:
        out_name = zip_file.stem.replace("-unsigned", "").replace("_unsigned", "")
        out_name = out_name + "-signed.zip"
        out_file = output_path / out_name

        size_mb = zip_file.stat().st_size / 1024 / 1024
        print(f"    Signing: {zip_file.name} ({size_mb:.1f} MB) ...", end=" ", flush=True)

        if sign_zip(zip_file, out_file):
            out_mb = out_file.stat().st_size / 1024 / 1024
            print(f"OK -> {out_name} ({out_mb:.1f} MB)")
            success += 1
        else:
            print("THAT BAI")
            failed += 1

    return success, failed

# ── MAIN ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("  KaiOS OTA ZIP Batch Signer")
    print("=" * 60)
    print()

    if not check_tools():
        print()
        print("Vui long dat day du cac file tools cung thu muc voi script nay.")
        input("Nhan Enter de thoat...")
        sys.exit(1)

    print()
    total_ok  = 0
    total_err = 0

    for i, (input_dir, output_dir) in enumerate(JOBS, 1):
        parts = Path(input_dir).parts
        label = f"{parts[-3]}\\...\\{parts[-1]}" if len(parts) >= 3 else input_dir
        print(f"[{i:02d}/08] {label}")

        ok, err = process_folder(input_dir, output_dir)
        total_ok  += ok
        total_err += err

        if ok > 0:
            print(f"         -> {ok} file thanh cong")
        if err > 0:
            print(f"         -> {err} file that bai")
        print()

    print("=" * 60)
    print(f"  Ket qua: {total_ok} thanh cong  |  {total_err} that bai")
    print("=" * 60)
    input("Nhan Enter de thoat...")

if __name__ == "__main__":
    main()
