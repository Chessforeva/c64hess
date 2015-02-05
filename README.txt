-----------------------------------------

 Commodore 64 project by Chessforeva

   http://github.com/Chessforeva/c64hess

 Chess Puzzles published in 1994
  (1994 Konemann, Laszlo Polgar)

   306  checkmates in 1 move
   3391 checkmates in 2 move
   743  checkmates in 3 move

 User can solve them one by one.

  Points +1pt for right click, -2pt for wrong,
  additional bonuses M1 +0pt, M2 +2pt, M3 +4pt

-----------------------------------------

This is a free(!) source C project designed for
awesome cc64 compiler that is a very good C64
development platform.

Tools used:
 a) cc65 compiler (www.cc65.org)
 b) Koala picture editor Project One (http://p1.untergrund.net)
 c) Lua (LUAJIT) programming language to support data preparation
 d) c1541 tool for .d64 floppy image creation and file copying*
 e) stochfish chess engine used for verification
 f) Notepad++

Thanks to Polgar for published pgns of chess games.
Compressed data contain 4440 verified and compressed positions
of the collection.

*c64hess.PRG file uses SEQ files on .d64 disk


Keys to use:

Space and Enter key, arrow keys.

"/" - disables one keypress twice when running on fast
      emulators at max.performance speed (as on Hyper64 emulator).
      Also usable to repeat last keypress.

"Z" - cursor mode on/off (can move pieces, stops puzzle mode)
"N" - next position

"A"-"H","1"-"8" places to square position by keys

ESC - return

In cursor mode:
"N" - new game
"U" - undo mode



How to run c64hess program on Commodore 64 emulators:

----------------------------------------------------------------
 on VICE c64 emulator
----------------------------------------------------------------
Menu > File > Autostart disk/type
 and open c64hess.d64 disk or
  c64hess.prg when using files in current folder without disk emulation

Important:
 The Options>True drive emulation checkbox should be de unchecked
 when VICE should become smarter than exact floppy simulator.


----------------------------------------------------------------
 on CCS64 emulator
----------------------------------------------------------------
Menu > File > Load And Run
 and open c64hess.d64 disk


----------------------------------------------------------------
 on Hyper64 emulator
----------------------------------------------------------------
Start Hyper64 then press F9 and provide c64hess.d64 disk
  then enter:    LOAD "*",8
  and start:     RUN

Keys on qwerty keybord
  ["] get by pressing [shift][2];
  [*] get by pressing ']'

When running, press [/] key at first.
Then it runs in a BEST emulation of all emulators
 without keyboard glitches.



NOTES ON DEVELOPMENT:

cc65 is well documented and C64 community on internet is wide.
It took much time to debug file loading cbm_open, cbm_load
which made c64 to halt. The problem was graphics conflict
with internal loading, so be aware when swapping to graphics mode
and changing "bank" bytes (my loader is in common.h).
Lua prepares seq-files, bat-file for .d64 creation,
static arrays of picture images, constant datas.
Koala file is 10003 bytes large. Lua prepares used part of it.
Assembler ideas are thoughts only about interesting board representation.
I just like rook moves as data:
 .byte %00001000 ;8
 .byte %00001000 ;7
 .byte %00001000 ;6
 .byte %11111111 ;5
 .byte %00001000 ;4
 .byte %00001000 ;3
 .byte %00001000 ;2
 .byte %00001000 ;1
       ;abcdefgh

Finally,

DO WHAT YOU LIKE
 with this code!

Regards
Chessforeva
2015,feb.