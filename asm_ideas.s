;====================================================
;
;    cc65 8-bit ca65 asm code - ideas for chess processing
;
;====================================================

; connection to C

;  parameters:
	.importzp ptr1, ptr2, ptr3

;  functions available in C
	.export _get_pieces_on_game_start
	.export _makemove_e2e4
	.export _see_string_from_C

;====================================================
; How we represent chess board in 8 bits
; It is not int64, anyway all bitwise tricks possible :)
; 
chessboard_8x8_bits:

WhitePawns:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %11111111
    .byte %00000000
  
WhiteKnights:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %01000010

WhiteBishops:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00100100

WhiteRooks:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %10000001

WhiteQueens:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00010000

WhiteKings:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00001000

BlackPawns:
    .byte %00000000
    .byte %11111111
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
  
BlackKnights:
    .byte %01000010
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

BlackBishops:
    .byte %00100100
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

BlackRooks:
    .byte %10000001
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

BlackQueens:
    .byte %00010000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

BlackKings:
    .byte %00001000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000



;==============================
; So, this asm gives placement of chess pieces when starting new game
;
_get_pieces_on_game_start:

		LDA #<chessboard_8x8_bits
        LDX #>chessboard_8x8_bits
				; A register = unsigned char returned value also
		RTS
    
_makemove_e2e4:

		LDA WhitePawns+6	;2nd row
		AND #%00000000
		STA WhitePawns+6
		LDA WhitePawns+4	;4th row
		ORA #%00001000
		STA WhitePawns+4
		RTS				; A returns 4th row

_see_string_from_C:
		
		sta     ptr1
        stx     ptr1+1    ; save given pointer from A,X regs 
		
		LDY #0
		LDA (ptr1),Y
		
		RTS				; A returns 1st char of   char* that was provided as parameter

