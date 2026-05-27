# make_xex.ps1 — Wrap KickAssembler .prg output as Atari XEX
#
# KickAssembler emits a 2-byte load-address prefix (lo, hi) followed
# by the raw binary.  This script strips the prefix, then builds a
# standard Atari Executable (XEX) with:
#   - Segment 1: the program data at its load address
#   - Run-address segment at $02E0-$02E1 pointing to load address
#

$inFile  = "prg_files\wadatari.xex"
$outFile = "prg_files\wadatari.xex"

if (-not (Test-Path $inFile)) {
    Write-Error "ERROR: $inFile not found. Did the assembler step succeed?"
    exit 1
}

$raw = [IO.File]::ReadAllBytes($inFile)

if ($raw.Length -lt 3) {
    Write-Error "ERROR: $inFile is too small to be a valid PRG."
    exit 1
}

# Extract 2-byte load address (little-endian KickAss prefix)
$loadLo  = $raw[0]
$loadHi  = $raw[1]
$loadAddr = [int]$loadHi * 256 + [int]$loadLo

# Program data (strip 2-byte header)
$data    = $raw[2..($raw.Length - 1)]
$dataLen = $data.Length
$endAddr = $loadAddr + $dataLen - 1

$endLo = [byte]($endAddr -band 0xFF)
$endHi = [byte](($endAddr -shr 8) -band 0xFF)

Write-Host "  Load  : `$$('{0:X4}' -f $loadAddr)"
Write-Host "  End   : `$$('{0:X4}' -f $endAddr)"
Write-Host "  Size  : $dataLen bytes"

# Build XEX byte array
$xex = [System.Collections.Generic.List[byte]]::new()

# Segment 1 header: $FFFF magic + start + end
$xex.Add(0xFF); $xex.Add(0xFF)
$xex.Add($loadLo); $xex.Add($loadHi)
$xex.Add($endLo); $xex.Add($endHi)

# Segment 1 data
foreach ($b in $data) { $xex.Add($b) }

# Run-address segment: $02E0-$02E1 = load address
$xex.Add(0xE0); $xex.Add(0x02)   # start = $02E0
$xex.Add(0xE1); $xex.Add(0x02)   # end   = $02E1
$xex.Add($loadLo); $xex.Add($loadHi)

[IO.File]::WriteAllBytes($outFile, $xex.ToArray())
Write-Host "  XEX   : $outFile ($($xex.Count) bytes)"
