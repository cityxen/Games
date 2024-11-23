///////////////////////////////////////
// Kickassembler plugin for
// using Meatloaf HiScore API
// By Deadline / CityXen
// % Idolpx 2024
// CONFIG FILE
// You will want to add your
// security token here from your
// Meatloaf HiScore API
// Information Panel

MLHS_API_TOKEN: // 16 byte token from meatloaf.cc
.text "WAD_GAME_HISCORE"
.byte 0

MLHS_API_SCORE: // 4 Bytes
.byte 0
.byte 0
.byte whack_score_lo
.byte whack_score_hi

MLHS_API_DRIVE_NUMBER:
.byte 8
