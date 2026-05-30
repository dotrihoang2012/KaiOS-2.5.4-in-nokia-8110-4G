# Optimize .ja for omni.ja

## Windows

```
.\optimizeJAR.ps1 -SourceDir <source_dir> -OutputPath <output_file>
```

**Examples:**

```powershell
# Pack omni/ into omni.ja
.\optimizeJAR.ps1 -SourceDir .\omni -OutputPath .\omni.ja

# Pack omnistock/ into omnistock.ja
.\optimizeJAR.ps1 -SourceDir .\omnistock -OutputPath .\omnistock.ja

# Output to a different name
.\optimizeJAR.ps1 -SourceDir .\omni -OutputPath "C:\backup\omni_backup.ja"
```

## Linux

```
./optimizeJAR.sh <source_dir> <output_file>
```

**Examples:**

```bash
# Pack omni/ into omni.ja
./optimizeJAR.sh ./omni ./omni.ja

# Pack omnistock/ into omnistock.ja
./optimizeJAR.sh ./omnistock ./omnistock.ja

# Output to a different name
./optimizeJAR.sh ./omni /backup/omni_backup.ja
```
