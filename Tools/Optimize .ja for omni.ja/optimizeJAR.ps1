param(
    [Parameter(Mandatory=$true)][string]$SourceDir,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

$SourceDir = (Resolve-Path $SourceDir).Path.TrimEnd('\')

function Get-DosTime([datetime]$dt) {
    [uint16](($dt.Hour -shl 11) -bor ($dt.Minute -shl 5) -bor ($dt.Second -shr 1))
}
function Get-DosDate([datetime]$dt) {
    [uint16]((($dt.Year - 1980) -shl 9) -bor ($dt.Month -shl 5) -bor $dt.Day)
}

function Get-GzipResult([byte[]]$raw) {
    $ms = New-Object System.IO.MemoryStream
    $gz = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionLevel]::Optimal)
    $gz.Write($raw, 0, $raw.Length)
    $gz.Close()
    $data = $ms.ToArray()
    # GZip: 10-byte header | deflate data | 4-byte CRC32 LE | 4-byte size LE
    $crc32  = [System.BitConverter]::ToUInt32($data, $data.Length - 8)
    $defLen = $data.Length - 18
    $deflate = [byte[]]::new($defLen)
    [System.Array]::Copy($data, 10, $deflate, 0, $defLen)
    return $crc32, $deflate
}

$entries = [System.Collections.Generic.List[hashtable]]::new()

$allItems = Get-ChildItem -LiteralPath $SourceDir -Recurse | Sort-Object FullName
Write-Host "Scanning $($allItems.Count) items..."

foreach ($item in $allItems) {
    $rel = $item.FullName.Substring($SourceDir.Length + 1).Replace('\', '/')

    try {
        $mtime = $item.LastWriteTime
        if ($mtime.Year -lt 1980) { $mtime = [datetime]::new(1980, 1, 1) }
    } catch {
        $mtime = [datetime]::new(1980, 1, 1)
    }
    $dostime = Get-DosTime $mtime
    $dosdate = Get-DosDate $mtime

    if ($item.PSIsContainer) {
        $nameBytes = [System.Text.Encoding]::UTF8.GetBytes($rel + '/')
        $entries.Add(@{
            Name = $nameBytes; CompressType = [uint16]0
            Compressed = [byte[]]@(); UncompressedSize = [uint32]0
            CRC32 = [uint32]0; DosTime = $dostime; DosDate = $dosdate
        })
    } else {
        $raw = [System.IO.File]::ReadAllBytes($item.FullName)
        $nameBytes = [System.Text.Encoding]::UTF8.GetBytes($rel)

        if ($raw.Length -eq 0) {
            $entries.Add(@{
                Name = $nameBytes; CompressType = [uint16]0
                Compressed = [byte[]]@(); UncompressedSize = [uint32]0
                CRC32 = [uint32]0; DosTime = $dostime; DosDate = $dosdate
            })
        } else {
            $crc32, $deflate = Get-GzipResult $raw
            if ($deflate.Length -lt $raw.Length) {
                $entries.Add(@{
                    Name = $nameBytes; CompressType = [uint16]8
                    Compressed = $deflate; UncompressedSize = [uint32]$raw.Length
                    CRC32 = $crc32; DosTime = $dostime; DosDate = $dosdate
                })
            } else {
                $entries.Add(@{
                    Name = $nameBytes; CompressType = [uint16]0
                    Compressed = $raw; UncompressedSize = [uint32]$raw.Length
                    CRC32 = $crc32; DosTime = $dostime; DosDate = $dosdate
                })
            }
        }
    }
}

Write-Host "Building CDR and local entries for $($entries.Count) entries..."

# CDR size: 46 bytes fixed + filename bytes per entry
$cdrSize = [uint32]0
foreach ($e in $entries) { $cdrSize += 46 + $e.Name.Length }

# Build local entries (offsets start at: 4 + cdrSize + 22)
$localMS = New-Object System.IO.MemoryStream
$localBW = New-Object System.IO.BinaryWriter($localMS)
$localOffsets = [uint32[]]::new($entries.Count)

for ($i = 0; $i -lt $entries.Count; $i++) {
    $e = $entries[$i]
    $localOffsets[$i] = [uint32](4 + $cdrSize + 22 + $localMS.Position)

    $localBW.Write([byte]0x50); $localBW.Write([byte]0x4B)
    $localBW.Write([byte]0x03); $localBW.Write([byte]0x04)
    $localBW.Write([uint16]20)
    $localBW.Write([uint16]0)
    $localBW.Write([uint16]$e.CompressType)
    $localBW.Write([uint16]$e.DosTime)
    $localBW.Write([uint16]$e.DosDate)
    $localBW.Write([uint32]$e.CRC32)
    $localBW.Write([uint32]$e.Compressed.Length)
    $localBW.Write([uint32]$e.UncompressedSize)
    $localBW.Write([uint16]$e.Name.Length)
    $localBW.Write([uint16]0)
    $localBW.Write($e.Name)
    if ($e.Compressed.Length -gt 0) {
        $localBW.BaseStream.Write($e.Compressed, 0, $e.Compressed.Length)
    }
}
$localBW.Flush()
$localBytes = $localMS.ToArray()

# Build CDR at offset 4
$cdrMS = New-Object System.IO.MemoryStream
$cdrBW = New-Object System.IO.BinaryWriter($cdrMS)

for ($i = 0; $i -lt $entries.Count; $i++) {
    $e = $entries[$i]
    $cdrBW.Write([byte]0x50); $cdrBW.Write([byte]0x4B)
    $cdrBW.Write([byte]0x01); $cdrBW.Write([byte]0x02)
    $cdrBW.Write([uint16]20)
    $cdrBW.Write([uint16]20)
    $cdrBW.Write([uint16]0)
    $cdrBW.Write([uint16]$e.CompressType)
    $cdrBW.Write([uint16]$e.DosTime)
    $cdrBW.Write([uint16]$e.DosDate)
    $cdrBW.Write([uint32]$e.CRC32)
    $cdrBW.Write([uint32]$e.Compressed.Length)
    $cdrBW.Write([uint32]$e.UncompressedSize)
    $cdrBW.Write([uint16]$e.Name.Length)
    $cdrBW.Write([uint16]0)
    $cdrBW.Write([uint16]0)
    $cdrBW.Write([uint16]0)
    $cdrBW.Write([uint16]0)
    $cdrBW.Write([uint32]0)
    $cdrBW.Write([uint32]$localOffsets[$i])
    $cdrBW.Write($e.Name)
}
$cdrBW.Flush()
$cdrBytes = $cdrMS.ToArray()

# EOCD (22 bytes): CDR starts at offset 4
$eocdMS = New-Object System.IO.MemoryStream
$eocdBW = New-Object System.IO.BinaryWriter($eocdMS)
$eocdBW.Write([byte]0x50); $eocdBW.Write([byte]0x4B)
$eocdBW.Write([byte]0x05); $eocdBW.Write([byte]0x06)
$eocdBW.Write([uint16]0)
$eocdBW.Write([uint16]0)
$eocdBW.Write([uint16]$entries.Count)
$eocdBW.Write([uint16]$entries.Count)
$eocdBW.Write([uint32]$cdrBytes.Length)
$eocdBW.Write([uint32]4)   # CDR offset = 4 (after magic prefix)
$eocdBW.Write([uint16]0)
$eocdBW.Flush()
$eocdBytes = $eocdMS.ToArray()

# Write output: [4 null bytes][CDR][EOCD][local entries][EOCD]
Write-Host "Writing output file..."
$out = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$out.Write([byte[]]@(0,0,0,0), 0, 4)
$out.Write($cdrBytes,   0, $cdrBytes.Length)
$out.Write($eocdBytes,  0, $eocdBytes.Length)
$out.Write($localBytes, 0, $localBytes.Length)
$out.Write($eocdBytes,  0, $eocdBytes.Length)
$out.Close()

$sizeMB = (Get-Item $OutputPath).Length / 1MB
Write-Host ("Done: {0} ({1:F2} MB, {2} entries)" -f $OutputPath, $sizeMB, $entries.Count)
