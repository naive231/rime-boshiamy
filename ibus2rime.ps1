# ibus2rime.ps1
# Usage: .\ibus2rime.ps1 boshiamy_t.db

param (
    [Parameter(Mandatory=$true)]
    [string]$DbFile
)

$Sqlite3 = ".\sqlite3.exe"

# Check if sqlite3.exe exists, if not, try to download it
if (-not (Test-Path ".\sqlite3.exe")) {
    Write-Host "sqlite3.exe not found. Attempting to download..."
    $sqlite_url = "https://www.sqlite.org/2024/sqlite-tools-win-x64-3450200.zip"
    $zip_file = "sqlite3_download.zip"
    try {
        Invoke-WebRequest -Uri $sqlite_url -OutFile $zip_file
        Write-Host "Download complete. Extracting sqlite3.exe..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zip_file, ".")
        # Move sqlite3.exe from extracted folder if needed
        $extracted = Get-ChildItem -Recurse -Filter sqlite3.exe | Select-Object -First 1
        if ($extracted) {
            Move-Item $extracted.FullName ".\sqlite3.exe" -Force
        }
        Remove-Item $zip_file
    } catch {
        Write-Error "Failed to download or extract sqlite3.exe. Please download it manually from https://www.sqlite.org/download.html and place it in this folder."
        exit 1
    }
}

$FileName = [System.IO.Path]::GetFileNameWithoutExtension($DbFile)
$RimeDict = "$FileName.dict.yaml"

Write-Host "Converting $FileName to $RimeDict ..."

# Get description and version
$Description = & $Sqlite3 $DbFile "SELECT val FROM ime where attr = 'description';" | ForEach-Object { $_ -replace "IBus", "Rime" }
$Version = & $Sqlite3 $DbFile "SELECT val FROM ime where attr = 'serial_number';"

# Create Rime dict file
@"
# $Description
#
# This dictionary file is converted from the ibus table file.
# The copyright of the dictionary table (below the "..." line) belongs to E-Typist Co., Ltd.
#
# For use only by individuals with a valid license. Redistribution is not permitted.

---
name: $FileName
version: "$Version"
sort: original
use_preset_vocabulary: false

...
"@ | Set-Content -Encoding UTF8 $RimeDict

# Count total entries
$total_entries = & $Sqlite3 $DbFile 'SELECT COUNT(*) FROM phrases;'
Write-Host "Total entries: $total_entries"

# Export phrases
& $Sqlite3 -list $DbFile '.separator "\t"' 'SELECT phrase, tabkeys FROM phrases ORDER BY tabkeys, freq DESC;' | Add-Content -Encoding UTF8 $RimeDict