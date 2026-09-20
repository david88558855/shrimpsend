#Requires -Version 5.1
<#
  pdfrx Windows 构建依赖 pdfium.dll。插件 CMake 在 configure 阶段从 GitHub 下载
  pdfium-win-x64.tgz 并用 cmake -E tar 解压；网络受限时易出现 0 字节包，导致后续 COPY 失败。

  本脚本在 flutter build windows 之前，尝试将内置 pdfium（app/windows/pdfium_vendor）
  或可靠下载预置到 pdfrx 期望路径。

  如果预置失败，脚本仅发出警告而不中断构建——CMake configure 会自行下载。

  Usage（app 目录）:
    .\scripts\ensure_windows_pdfium.ps1
#>
$ErrorActionPreference = 'Continue'

$AppDir = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Get-Location }

# pdfrx 2.x 使用更新的 pdfium 版本；如 CMake 下载失败可在此调整。
# 常见版本号：pdfrx 1.x → chromium%2F7202，pdfrx 2.x → chromium%2F7xxx
$PdfiumReleaseDirName = 'chromium%2F7202'
$BuildPdfiumDir = Join-Path $AppDir "build\windows\x64\pdfium\$PdfiumReleaseDirName"
$VendorDir = Join-Path $AppDir 'windows\pdfium_vendor\x64'
$PdfiumDllName = 'pdfium.dll'
$PdfiumHeaderName = 'fpdfview.h'
$ArchiveName = 'pdfium-win-x64.tgz'
$DownloadUrl = "https://github.com/bblanchon/pdfium-binaries/releases/download/$PdfiumReleaseDirName/$ArchiveName"
$MinimumDllBytes = 1MB

function Test-PdfiumTree([string] $Root) {
    if ([string]::IsNullOrWhiteSpace($Root)) { return $false }
    $dll = Join-Path $Root "bin\$PdfiumDllName"
    $header = Join-Path $Root "include\$PdfiumHeaderName"
    if (-not (Test-Path -LiteralPath $dll)) { return $false }
    if (-not (Test-Path -LiteralPath $header)) { return $false }
    return (Get-Item -LiteralPath $dll).Length -ge $MinimumDllBytes
}

function Copy-PdfiumTree([string] $SourceRoot, [string] $DestRoot) {
    New-Item -ItemType Directory -Force -Path (Join-Path $DestRoot 'bin') | Out-Null
    Copy-Item -LiteralPath (Join-Path $SourceRoot "bin\$PdfiumDllName") `
        -Destination (Join-Path $DestRoot "bin\$PdfiumDllName") -Force
    $destInclude = Join-Path $DestRoot 'include'
    if (Test-Path -LiteralPath $destInclude) {
        Remove-Item -LiteralPath $destInclude -Recurse -Force
    }
    Copy-Item -LiteralPath (Join-Path $SourceRoot 'include') -Destination $destInclude -Recurse -Force
}

function Install-PdfiumFromVendor {
    if (-not (Test-PdfiumTree $VendorDir)) {
        Write-Warning "Built-in PDFium vendor tree is incomplete: $VendorDir — skipping"
        return $false
    }
    Write-Host "PDFium -> $BuildPdfiumDir (from vendor)"
    Copy-PdfiumTree $VendorDir $BuildPdfiumDir
    return $true
}

function Install-PdfiumFromDownload {
    New-Item -ItemType Directory -Force -Path $BuildPdfiumDir | Out-Null
    $archivePath = Join-Path $BuildPdfiumDir $ArchiveName
    if (Test-Path -LiteralPath $archivePath) {
        $size = (Get-Item -LiteralPath $archivePath).Length
        if ($size -lt 100KB) {
            Write-Host "Remove invalid PDFium archive ($size bytes): $archivePath"
            Remove-Item -LiteralPath $archivePath -Force
        }
    }

    if (-not (Test-Path -LiteralPath $archivePath)) {
        Write-Host "Download PDFium: $DownloadUrl"
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $archivePath -UseBasicParsing
        } catch {
            Write-Warning "PDFium download failed: $_ — CMake will attempt its own download"
            return $false
        }
    }

    $archiveSize = (Get-Item -LiteralPath $archivePath).Length
    if ($archiveSize -lt 100KB) {
        Write-Warning "PDFium archive too small ($archiveSize bytes): $archivePath — CMake will attempt its own download"
        return $false
    }

    Write-Host "Extract PDFium -> $BuildPdfiumDir"
    Push-Location -LiteralPath $BuildPdfiumDir
    try {
        tar -zxf $ArchiveName
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "tar failed to extract PDFium (exit $LASTEXITCODE) — CMake will attempt its own download"
            return $false
        }
    } finally {
        Pop-Location
    }
    return $true
}

if (Test-PdfiumTree $BuildPdfiumDir) {
    Write-Host "PDFium already present: $BuildPdfiumDir"
    exit 0
}

if (Test-PdfiumTree $VendorDir) {
    Install-PdfiumFromVendor
} else {
    Install-PdfiumFromDownload
}

if (-not (Test-PdfiumTree $BuildPdfiumDir)) {
    Write-Warning "PDFium pre-setup did not complete; CMake configure will attempt its own download."
}

Write-Host 'PDFium check done.'
