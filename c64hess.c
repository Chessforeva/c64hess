/*

Chess program for Commodore 64
(cc65 compiler -  an awesome tool to create 8-bit software)



RAM PLACEMENT:
0810 - ... this PRG program (code + data of piece pixel images, other)
...
...
...7500

         ...actually lots of free space for program..........

8600 - pgn-data of chess games (loadpgns.h)
			about 3Kb (max.possible 8Kb, too slow)
...	   
A600 - pgn-text for displaying (boarGUI.h)
AE00 - short place for dbg dump (common.h)

B000 - chess logic, move generation (chesslogic.h)
B500 - chess logic, history of moves of game
C800 - display, screen	(drawings.h)
..
CFFF - C stack
D800 - display,colour
E000 - display, bitmap

*/

// system includes
#include <cbm.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include <stdio.h>
#include <device.h> 
#include <time.h>

// current folder c-code
#include "common.h"			// definitions for all code
#include "strconst.h"		// ASCII strings as arrays prepared by "prepconst.lua"
#include "pictures.h"		// data of images prepared by "preppics.lua"
#include "chesspgns.h"		// data of chess pgn-files, file names
#include "asm_ideas.h"		// 8-bit asm ideas for faster chess processing (nothing there)

/*
 Koala picture .kla , .koa
 edited by using tool "Project One" (http://p1.untergrund.net)

 #include "loadkoala_to_see.c"
 LoadKoalaPictureAndDisplay("pictures.kla");
*/

#include "keybcontrol.h"	// keyboard control
#include "chesslogic.h"		// chess things
#include "drawings.h"		// all display things
#include "loadpgns.h"		// load chess pgn-files into memory and get data
#include "boardGUI.h"		// board user interface, keyboard control

// The program starts here
 
int main(void) {
  
  BYTE exit=0;
  
/*
	assembler implementation in this project
	just some ideas and working test code
*/
  BYTE *asm_chess_board = get_pieces_on_game_start();
  BYTE asm_a = loByte( asm_chess_board[15] );
  BYTE asm_b = loByte( makemove_e2e4() );
  BYTE asm_c = loByte( see_string_from_C("aha"));
  
  //cprintf ("%d\n", asm_a );	// 66 = %01000010	white kings b1,g1
  //cprintf ("%d\n", asm_b) ;	// 8 = %00001000	4th row pawn
  //cprintf ("%d\n", asm_c ); 	// 65 = petscii code = chr$(65) = "a" 
  //cgetc();
  
  Keyb_Onload();
  _randomize();		// for chess games in pgn
  ClrAllScreen();		// clear memory where we will put images 
  OnLoadSetDisplay();	// prepare C64 video
  dspWelcome();		// project title
  OnloadInitChessGame();	// this sets up starting position

  for(;!exit;)
  {
	switch( MenuSelection() )
	{
	case 1:
		{
		if( LoadPgnFile() ) BoardGUI(0); // activate board for puzzles
		else { dspErrorOfLoading(); BoardGUI(1); }	// show cursor mode
		break;
		}	
	case 2: { BoardGUI(1); break; }		// cursor mode
	case 0: { exit=1; break; }	// ESC
	} 
  }	
  dspGameOver();
  OnUnloadRestoreDisplay();		// set back text mode and colours
  return(0); 
}
