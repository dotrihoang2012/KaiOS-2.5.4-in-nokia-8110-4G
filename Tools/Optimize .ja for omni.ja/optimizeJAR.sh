#!/usr/bin/env python3
import sys, os, struct, zlib
from datetime import datetime

def dos_time(dt):
    return (dt.hour << 11) | (dt.minute << 5) | (dt.second >> 1)

def dos_date(dt):
    return ((dt.year - 1980) << 9) | (dt.month << 5) | dt.day

def deflate_raw(data):
    crc32 = zlib.crc32(data) & 0xFFFFFFFF
    c = zlib.compressobj(9, zlib.DEFLATED, -15)
    return crc32, c.compress(data) + c.flush()

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <source_dir> <output_path>")
        sys.exit(1)

    source_dir = os.path.realpath(sys.argv[1])
    output_path = sys.argv[2]

    # Collect all items sorted by full path (matches PowerShell Sort-Object FullName)
    all_items = []
    for root, dirs, files in os.walk(source_dir):
        for d in dirs:
            all_items.append((os.path.join(root, d), True))
        for f in files:
            all_items.append((os.path.join(root, f), False))
    all_items.sort(key=lambda x: x[0])

    print(f"Scanning {len(all_items)} items...")

    entries = []
    for item_path, is_dir in all_items:
        rel = os.path.relpath(item_path, source_dir).replace('\\', '/')

        try:
            mtime = datetime.fromtimestamp(os.path.getmtime(item_path))
            if mtime.year < 1980:
                mtime = datetime(1980, 1, 1)
        except Exception:
            mtime = datetime(1980, 1, 1)

        dt = dos_time(mtime)
        dd = dos_date(mtime)

        if is_dir:
            name_b = (rel + '/').encode('utf-8')
            entries.append({'name': name_b, 'compress_type': 0,
                            'compressed': b'', 'uncompressed_size': 0,
                            'crc32': 0, 'dos_time': dt, 'dos_date': dd})
        else:
            raw = open(item_path, 'rb').read()
            name_b = rel.encode('utf-8')
            if len(raw) == 0:
                entries.append({'name': name_b, 'compress_type': 0,
                                'compressed': b'', 'uncompressed_size': 0,
                                'crc32': 0, 'dos_time': dt, 'dos_date': dd})
            else:
                crc32, deflated = deflate_raw(raw)
                if len(deflated) < len(raw):
                    entries.append({'name': name_b, 'compress_type': 8,
                                    'compressed': deflated, 'uncompressed_size': len(raw),
                                    'crc32': crc32, 'dos_time': dt, 'dos_date': dd})
                else:
                    entries.append({'name': name_b, 'compress_type': 0,
                                    'compressed': raw, 'uncompressed_size': len(raw),
                                    'crc32': crc32, 'dos_time': dt, 'dos_date': dd})

    print(f"Building CDR and local entries for {len(entries)} entries...")

    # CDR size: 46 bytes fixed + filename bytes per entry
    cdr_size = sum(46 + len(e['name']) for e in entries)

    # Build local entries (offsets start at: 4 + cdr_size + 22)
    local_parts = []
    local_offsets = []
    current_pos = 0

    for e in entries:
        local_offsets.append(4 + cdr_size + 22 + current_pos)
        name = e['name']
        # Local file header: PK\x03\x04 + 26 bytes + name + data
        header = b'PK\x03\x04' + struct.pack('<HHHHHIIIHH',
            20, 0, e['compress_type'], e['dos_time'], e['dos_date'],
            e['crc32'], len(e['compressed']), e['uncompressed_size'],
            len(name), 0)
        entry_bytes = header + name + e['compressed']
        local_parts.append(entry_bytes)
        current_pos += len(entry_bytes)

    # Build CDR (Central Directory Records)
    cdr_parts = []
    for i, e in enumerate(entries):
        name = e['name']
        # CDR header: PK\x01\x02 + 42 bytes + name
        record = b'PK\x01\x02' + struct.pack('<HHHHHHIIIHHHHHII',
            20, 20, 0, e['compress_type'], e['dos_time'], e['dos_date'],
            e['crc32'], len(e['compressed']), e['uncompressed_size'],
            len(name), 0, 0, 0, 0, 0, local_offsets[i])
        cdr_parts.append(record + name)

    cdr_bytes = b''.join(cdr_parts)

    # EOCD: CDR starts at offset 4 (after magic prefix)
    eocd_bytes = b'PK\x05\x06' + struct.pack('<HHHHIIH',
        0, 0, len(entries), len(entries), cdr_size, 4, 0)

    local_bytes = b''.join(local_parts)

    # Write output: [4 null bytes][CDR][EOCD][local entries][EOCD]
    print("Writing output file...")
    with open(output_path, 'wb') as f:
        f.write(b'\x00\x00\x00\x00')
        f.write(cdr_bytes)
        f.write(eocd_bytes)
        f.write(local_bytes)
        f.write(eocd_bytes)

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"Done: {output_path} ({size_mb:.2f} MB, {len(entries)} entries)")

if __name__ == '__main__':
    main()
