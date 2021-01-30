dir=$(dirname 0)
genkickass-script.py -t C64 -o prg_files -m true -s true -l "RETRO_DEV_LIB" -e off
kickass floridaman.asm
x64 prg_files/floridaman.d64 > /dev/null
