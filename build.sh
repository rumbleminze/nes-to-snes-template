#!/usr/bin/env sh
export PATH=$PATH:../cc65-snapshot-win32/bin
export GAME=GameName
set -e

# Use generate_options_asm.go to create the options screen
go run utilities/generate_options_asm.go
mv options.bin ./src/options.bin
mv options_macro_defs.asm ./src/options_macro_defs.asm

cd "$(dirname "$0")"

mkdir -p out
ca65 ./src/main.asm -o ./out/main.o -g
ld65 -C ./src/hirom.cfg -o ./out/$GAME.sfc ./out/main.o
timestamp=`date '+%Y%m%d%H%M%S'`
cp ./out/$GAME.sfc ./out/buildarchive/$GAME-$timestamp.sfc
