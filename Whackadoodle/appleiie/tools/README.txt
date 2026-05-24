TOOLS DIRECTORY
===============

Files needed here for the full Build.bat pipeline:

  ac.jar          AppleCommander -- creates/modifies Apple II disk images

  make_binary.ps1 (included) -- PowerShell script that:
                    - Strips the 2-byte KickAss load-address header from
                      prg_files\wad_a2.prg -> prg_files\wad_a2.bin
                    - Generates prg_files\startup.bin (tokenized Applesoft
                      "10 PRINT CHR$(4)"BRUN WAD_A2"")


GETTING AC.JAR
--------------
Download the latest release from:
  https://github.com/AppleCommander/AppleCommander/releases

Look for the file named ac-X.Y.Z.jar (or AppleCommander-X.Y.Z-ac.jar).
Rename it to ac.jar and place it in this folder.

Requires Java 11+.  Test with:  java -jar tools\ac.jar --help


DISK IMAGE (ProDOS_312.po)
--------------------------
The build uses ProDOS_312.po (in the appleiie root) as the base disk image.
This is a bootable ProDOS 3.12 disk that includes BASIC.SYSTEM.

On boot, ProDOS loads BASIC.SYSTEM, which automatically runs the STARTUP
Applesoft program.  STARTUP issues:
  PRINT CHR$(4)"BRUN WAD_A2"
which tells ProDOS to load and execute the game binary at $0800.

If you need a fresh ProDOS 3.12 image:
  https://prodos8.com  or search "ProDOS 3.12 disk image"


TESTING IN APPLEWIN
-------------------
1. Build:  Build.bat
2. Open AppleWin, select prg_files\wad_a2.po as Drive 1
3. Boot (F2 or Reset)
4. Game should launch automatically


TESTING WITHOUT AC.JAR (binary only)
-------------------------------------
Build still produces prg_files\wad_a2.bin (raw binary at $0800).
In AppleWin you can load it directly:
  File > Load Binary Image > wad_a2.bin, address 0x0800, then G 800
