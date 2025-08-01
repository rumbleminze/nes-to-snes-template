package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
)

// This utility will take an NES rom as input, and split it up into 4k banks
// It currently assumes a lot about the game, and is set up to parse the game
// Super Dodge Ball, a MMC1 game, where banks 8+ are CHR ROM banks and within those banks
// banks at memory 1A000 - 1FFFF are data and 8000 - 19FFF are tiles.  It will automatically
// convert the 2bpp tiles into 4bpp SNES format, but leave the data parts as is.
//
// For all banks it'll break up and label every 0x100 bytes, as well as setting a segment directive
//
// This script also assumes that the file will have a 16 byte header that we skip.
//
// It very naively will just print out the code as:
//
// .byte $HL, $HL, ......
//
// with 16 bytes per line
func main() {
	inputFile := flag.String("in", "../resources/Castlevania (U) (PRG1).nes", "input file to split out")

	inputBytes, _ := ioutil.ReadFile(*inputFile)
	var banks [][]byte
	var bankSize = 0x4000

	// remove the header
	headerLess := inputBytes


	for i := 0; i < len(headerLess); i += bankSize {
		end := i + bankSize

		if end > len(headerLess) {
			end = len(headerLess)
		}

		banks = append(banks, headerLess[i:end])
	}

	tileBanks := []int{0, 1, 2, 3, 6}
	offsets := []int{0x3501, 8, 8, 8, 0, 0, 0x3117}
	// write out banks of tile data that we may use
	for _, tileBank := range tileBanks {
		var bankFile, _ = os.Create(fmt.Sprintf("tile_bank%d.asm", tileBank))
		defer bankFile.Close()
		bankFile.WriteString(fmt.Sprintf("; Tile Bank %d\n", tileBank))
		bankFile.WriteString(fmt.Sprintf(".segment \"PRGA%X\"\n", tileBank+8))

		// skip the first 8 bytes
		for byteIndex := offsets[tileBank]; byteIndex + 16 < len(banks[tileBank]); byteIndex += 16 {
			bankFile.WriteString(
				fmt.Sprintf(
					".byte $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X,"+
						" $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X\n",
					banks[tileBank][byteIndex],
					banks[tileBank][byteIndex+8],
					banks[tileBank][byteIndex+1],
					banks[tileBank][byteIndex+1+8],
					banks[tileBank][byteIndex+2],
					banks[tileBank][byteIndex+2+8],
					banks[tileBank][byteIndex+3],
					banks[tileBank][byteIndex+3+8],
					banks[tileBank][byteIndex+4],
					banks[tileBank][byteIndex+4+8],
					banks[tileBank][byteIndex+5],
					banks[tileBank][byteIndex+5+8],
					banks[tileBank][byteIndex+6],
					banks[tileBank][byteIndex+6+8],
					banks[tileBank][byteIndex+7],
					banks[tileBank][byteIndex+7+8],
				),
			)		
			bankFile.WriteString(".byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00\n")
		}
		bankFile.WriteString(".byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF\n")
		bankFile.WriteString(".byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00\n")
	}

	var byteOffset = 0x8000
	for i := 0; i < 8; i++ {
		if i == 7 {
			byteOffset = 0xC000
		}

		var bankFile, _ = os.Create(fmt.Sprintf("bank%d.asm", i))
		defer bankFile.Close()
		if i != 7 {
			bankFile.WriteString(fmt.Sprintf(".segment \"PRGA%d\"", i+1))
		}
		bankFile.WriteString(fmt.Sprintf("; Bank %d\n", i))
		for byteIndex := 0; byteIndex < len(banks[i]); byteIndex++ {
			if byteIndex <= 0x1FFFF {
				if byteIndex%0x100 == 0 {
					bankFile.WriteString(fmt.Sprintf("\n\n; %04X - bank %d\n", byteIndex+byteOffset, i))
				}
				if byteIndex%0x10 == 0 {
					bankFile.WriteString(".byte ")
				}

				bankFile.WriteString(fmt.Sprintf("$%02X", banks[i][byteIndex]))

				if byteIndex%0x10 == 0x0F {
					bankFile.WriteString("\n")
				} else {
					bankFile.WriteString(", ")
				}
			}
		}
		if i != 7 {
			bankFile.WriteString(fmt.Sprintf(
				".segment \"PRGA%dC\"\nfixeda%d:\n.include \"bank7.asm\"\nfixeda%d_end:",
				i+1, i+1, i+1,
			))
		}
	}
	// CHR banks
	// tileset := 0
	// for i := 8; i < 16; i++ {
	// 	var bankFile, _ = os.Create(fmt.Sprintf("chrom-tiles-%d.asm", i-8))
	// 	defer bankFile.Close()
	// 	bankFile.WriteString(fmt.Sprintf(".segment \"PRGA%X\"\n", i))
	// 	for byteIndex := 0; byteIndex < len(banks[i]); byteIndex += 0x10 {
	// 		if byteIndex%0x1000 == 0 {
	// 			bankFile.WriteString(fmt.Sprintf("chrom_bank_%d_tileset_%d:\n", i-8, tileset))
	// 			tileset++
	// 		}

	// 		// if i < 14 || (byteIndex < 0x2000 && i == 14) {
	// 		// converts these to SNES expected format
	// 		bankFile.WriteString(
	// 			fmt.Sprintf(
	// 				".byte $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X,"+
	// 					" $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X\n",
	// 				banks[i][byteIndex],
	// 				banks[i][byteIndex+8],
	// 				banks[i][byteIndex+1],
	// 				banks[i][byteIndex+1+8],
	// 				banks[i][byteIndex+2],
	// 				banks[i][byteIndex+2+8],
	// 				banks[i][byteIndex+3],
	// 				banks[i][byteIndex+3+8],
	// 				banks[i][byteIndex+4],
	// 				banks[i][byteIndex+4+8],
	// 				banks[i][byteIndex+5],
	// 				banks[i][byteIndex+5+8],
	// 				banks[i][byteIndex+6],
	// 				banks[i][byteIndex+6+8],
	// 				banks[i][byteIndex+7],
	// 				banks[i][byteIndex+7+8],
	// 			),
	// 		)
	// 		bankFile.WriteString(".byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00\n")
	// 		// If some of the banks in the PRG rom are actually data banks, then we need to _not_ format them at 4bpp.
	// 		// for Double Dragon all of the banks are just tile data.
	// 		// } else {
	// 		// 	// these are data banks that need to be formatted differently
	// 		// 	bankFile.WriteString(
	// 		// 		fmt.Sprintf(
	// 		// 			".byte $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00\n"+
	// 		// 				".byte $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00, $%02X, $00\n",
	// 		// 			banks[i][byteIndex],
	// 		// 			banks[i][byteIndex+1],
	// 		// 			banks[i][byteIndex+2],
	// 		// 			banks[i][byteIndex+3],
	// 		// 			banks[i][byteIndex+4],
	// 		// 			banks[i][byteIndex+5],
	// 		// 			banks[i][byteIndex+6],
	// 		// 			banks[i][byteIndex+7],
	// 		// 			banks[i][byteIndex+8],
	// 		// 			banks[i][byteIndex+9],
	// 		// 			banks[i][byteIndex+10],
	// 		// 			banks[i][byteIndex+11],
	// 		// 			banks[i][byteIndex+12],
	// 		// 			banks[i][byteIndex+13],
	// 		// 			banks[i][byteIndex+14],
	// 		// 			banks[i][byteIndex+15],
	// 		// 		),
	// 		// 	)
	// 		// }
	// 	}
	// }

}
