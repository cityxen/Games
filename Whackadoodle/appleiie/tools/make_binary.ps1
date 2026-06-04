# Strip the 2-byte KickAssembler load-address header and generate the
# Applesoft STARTUP program that tells ProDOS to BRUN the game binary.
#
# Inputs:  prg_files\wad_a2.prg   (KickAss output, first 2 bytes = $00 $60)
# Outputs: prg_files\wad_a2.bin   (raw binary at $6000, no header)
#          prg_files\startup.bin  (tokenized Applesoft BASIC, loads at $0801)

Set-Location $PSScriptRoot\..

# --- strip header ---
$prg = [System.IO.File]::ReadAllBytes("prg_files\wad_a2.prg")
if ($prg[0] -ne 0x00 -or $prg[1] -ne 0x60) {
    Write-Warning "Unexpected header bytes $($prg[0].ToString('X2')) $($prg[1].ToString('X2')) -- stripping anyway"
}
$bin = $prg[2..($prg.Length - 1)]
[System.IO.File]::WriteAllBytes("prg_files\wad_a2.bin", $bin)
Write-Host "wad_a2.bin: $($bin.Length) bytes at 0x6000"

# --- generate STARTUP Applesoft tokenized binary ---
#
# Program:  10 PRINT CHR$(4)"BRUN WAD_A2"
#
# Applesoft tokenized format (program loads at $0801 in memory):
#   [next_ptr lo/hi] [line_num lo/hi] [tokens...] [00=EOL]
#   [00 00] = end of program
#
# Tokens:
#   $BA = PRINT   $C7 = CHR$   $28 = (   $34 = 4   $29 = )
#   $22 = "       literal "BRUN WAD_A2"   $22 = "   $00 = EOL
#
# Record = 2+2+19 = 23 bytes.  Starts at $0801, so next ptr = $0818.
$startup = [byte[]](
    0x18, 0x08,                                                   # next line ptr ($0818)
    0x0A, 0x00,                                                   # line number 10
    0xBA,                                                         # PRINT
    0xC7, 0x28, 0x34, 0x29,                                       # CHR$(4)
    0x22,                                                         # "
    0x42, 0x52, 0x55, 0x4E, 0x20,                                 # BRUN (space)
    0x57, 0x41, 0x44, 0x5F, 0x41, 0x32,                          # WAD_A2
    0x22,                                                         # "
    0x00,                                                         # EOL
    0x00, 0x00                                                    # end of program
)
[System.IO.File]::WriteAllBytes("prg_files\startup.bin", $startup)
Write-Host "startup.bin: $($startup.Length) bytes (Applesoft line 10)"
