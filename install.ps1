# install.ps1
# One-click install Boshiamy for RIME (PowerShell version)

# Set RIME_HOME for Windows
$PLATFORM = "windows"
$HOME_DIR = $env:USERPROFILE
$RIME_HOME = Join-Path $env:APPDATA "Rime"

# Check if RIME is installed (user config exists)
$RimeConfigPath = Join-Path $env:APPDATA "Rime\default.custom.yaml"
if (-not (Test-Path $RimeConfigPath)) {
    Write-Host "RIME installation or user config file not detected ($RimeConfigPath)." -ForegroundColor Yellow
    Write-Host "Please install RIME input method and launch it once before running this installer."
    exit 1
}

function Install-Boshiamy($name) {
    $table_file = "$name.db"
    $dict_file = "$name.dict.yaml" 
    $schema_file = "$name.schema.yaml" 
  
    if (Test-Path $table_file) {
        .\ibus2rime.ps1 $table_file

        Copy-Item $dict_file -Destination $RIME_HOME -Force
        Copy-Item $schema_file -Destination $RIME_HOME -Force

        Write-Host "$name -- " -NoNewline
        Write-Host "Done" -ForegroundColor Green
        Write-Host ""
        return 0
    } else {
        Write-Host "File $table_file not found, skipping."
        return 1
    }
}

Install-Boshiamy "boshiamy_t"
Install-Boshiamy "boshiamy_j"

Write-Host "After conversion, please edit $RIME_HOME/default.custom.yaml and add Boshiamy input method, for example:"
Write-Host ""
Write-Host "    patch:"
Write-Host "      schema_list:  # For list types, you need to replace the whole list in the custom file!"
Write-Host "        - schema: luna_pinyin"
Write-Host "        - schema: cangjie5"
Write-Host "        - schema: luna_pinyin_fluency"
Write-Host "        - schema: luna_pinyin_simp"
Write-Host "        - schema: luna_pinyin_tw"
Write-Host "        - schema: boshiamy_t  # Boshiamy Chinese mode" -ForegroundColor Green
Write-Host "        - schema: boshiamy_j  # Boshiamy Japanese mode" -ForegroundColor Green
Write-Host ""