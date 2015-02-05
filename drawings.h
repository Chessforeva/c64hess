/*
	Here is code that draws everything on C64 screen
*/

// Screen things are placed here at the bottom of all memory
#define Bitmap_RAM (BYTE *)0xE000
#define Screen_RAM (BYTE *)0xC800
#define Colour_RAM (BYTE *)0xD800

#define menu_itmC 12

void OnLoadSetDisplay()
{
  saveDisplayBytes();	// in common.h

  poke(0xd011, peek(0xd011) | 0x20); /* Bitmap mode */
  poke(0xd016, 0x18); /* enable multicolour VIC Control Register */;

  poke(0xd018, 0x28); /* Bitmap at $E000, screen at $C800 */
  poke(0xdd02, 0x03);
  poke(0xdd00, 0x00);

  poke(0xd020, 0x00); /* black border */
  poke(0xd021, 0x00); /* black background */
}

void OnUnloadRestoreDisplay()
{
  restoreDisplayBytes();	// in common.h
}

/* Displays prepared images
	Parameters: column C=[1..40], row V=[1..25]
		from top left to bottom right
		data - prepared binary data of images
 */
void PutBitmapImage( BYTE C, BYTE V, BYTE* data )
{
  BYTE w = data[0], h = data[1], y, w8 = w<<3;
  BYTE *p = data+2, *t = Bitmap_RAM;
  WORD dy = (40 * (V-1)) + (C-1);
  t += (dy<<3);
  for(y=0; y<h; y++, t+=320, p+=w8) memcpy ((void*)t, (void*)p, w8);

  t = Screen_RAM + dy;
  for(y=0; y<h; y++, t+=40, p+=w) memcpy ((void*)t, (void*)p, w);
   
  t = Colour_RAM + dy;
  for(y=0; y<h; y++, t+=40, p+=w) memcpy ((void*)t, (void*)p, w);
  
}

/* clear all screen */
void ClrAllScreen()
{
memset ( Bitmap_RAM, 0, 8000);
memset ( Screen_RAM, 0, 1000);
memset ( Colour_RAM, 0, 1000);
}

static const BYTE *ChessPcImgTable [] =
 { bgW , bgB, wPw, wPb, wNw, wNb, wBw, wBb, wRw, wRb, wQw, wQb, wKw, wKb,
			bPw,bPb, bNw, bNb, bBw, bBb, bRw, bRb, bQw, bQb, bKw, bKb };

/* Prepares image data according to square
	Parameter: square [0..63]
	Returns pointer to data 
*/		
BYTE* GetChesspieceImg( BYTE sq )
{
  BYTE c = Chess.B[sq], b = ((sq>>3)+(sq&7))&1;
  if(c>10) c-=4;
  return (BYTE *)ChessPcImgTable[(c<<1)+(b^1)];
}

BYTE dspC ( BYTE sq ) { return 2+((sq&7)*3); }
BYTE dspV ( BYTE sq ) { return 1+( (7-(sq>>3))*3); }

void dspSquare( BYTE sq )
{
 PutBitmapImage( dspC(sq), dspV(sq), (BYTE *)GetChesspieceImg(sq) );
}

void dspChessBoard()
{
 BYTE v,h;
 for(v=8; v>0;)
	for(v--,h=0; h<8; h++) dspSquare( (v<<3)+h );
}

static const BYTE *BoeardLbH [] =
 { BL_a, BL_b, BL_c, BL_d, BL_e, BL_f, BL_g, BL_h };
static const BYTE *BoeardLbV [] =
 { BL_1, BL_2, BL_3, BL_4, BL_5, BL_6, BL_7, BL_8 };
 		
void dspBoardLabels()
{
	BYTE i, H, V;
	for(H=3, V=25, i=0; i<8; i++, H+=3)
		PutBitmapImage(  H, V, (BYTE *)BoeardLbH[i] );
	for(H=1, V=2, i=8; i!=0; V+=3)
		PutBitmapImage(  H, V, (BYTE *)BoeardLbV[--i] );
}

void dspC64Logo() { PutBitmapImage( 28,1,  (BYTE *)C64_logo ); }
void dspCk() { PutBitmapImage(27,20,  (BYTE *)I_check ); }
void dspStMate() { PutBitmapImage( 27,20,  (BYTE *)I_stmate ); }
void dspCkMate() { PutBitmapImage( 26,20,  (BYTE *)I_ckmate ); }
void dspUNDO() { PutBitmapImage( 28,24,  (BYTE *)I_undo ); }
void dspNEW() { PutBitmapImage( 28,24,  (BYTE *)I_new ); }
void dspCursorMode() { PutBitmapImage( 27,20,  (BYTE *)I_cursor_mode ); }
void dspN_Next() { PutBitmapImage( 27,20,  (BYTE *)I_N_next ); }
void dsp10() { PutBitmapImage( 28,24,  (BYTE *)I_res10 ); }
void dsp01() { PutBitmapImage( 28,24,  (BYTE *)I_res01 ); }
void dspRemis() { PutBitmapImage( 28,24,  (BYTE *)I_resDraw ); }

void dspGameOver()
	{
	ClrAllScreen();
	PutBitmapImage( 11,12,  (BYTE *)I_gameover );
	Keyb_WaitForKeyPress();
	ClrAllScreen();
	}
  
// Clears area on screen in 
void dspBlank( BYTE C, BYTE V, BYTE w, BYTE h )
 {
  BYTE y,w8 = w<<3;
  BYTE *t = Bitmap_RAM;
  int dy = (40 * (V-1)) + (C-1);
  t += (dy<<3);
  for(y=0; y<h; y++, t+=320) memset ((void*)t, 0, w8);

  t = Screen_RAM + dy;
  for(y=0; y<h; y++, t+=40) memset ((void*)t, 0, w);
   
  t = Colour_RAM + dy;
  for(y=0; y<h; y++, t+=40) memset ((void*)t, 0, w);
 }

void dspToMove()
 {
	if(Chess.w) { dspBlank( 26,1, 2, 2 ); PutBitmapImage( 26,23,  (BYTE *)BL_snW ); }
	else { dspBlank( 26,23, 2, 2 ); PutBitmapImage( 26,1,  (BYTE *)BL_snB ); }
 }

// Sorry, can not manage proper coloured cursor displaying
// Solution could be creation of images for all pieces with cursor around.
//static const BYTE *CursImgs[] = { curs_B, curs_R, curs_G };

/*
 Now there are 2 types of cursors:
	col=0 - blank lines, 1 - no 2nd line, 2 - dotted lines
*/
void dspCursor( BYTE C, BYTE V, BYTE col ) {

  BYTE *p;	// =(BYTE *)(CursImgs[col]+2)
  BYTE *t = Bitmap_RAM;
  BYTE y, h=2;
  int dy = (40 * (V-1)) + (C-1);
  t += (dy<<3);
/* 
  BYTE q,c, *sp, *st;
  sp = p, st = t;
*/
  // horizontal lines above and under square
  for(y=0; y<6; y++, t+=8, p+=8)
	{
	if((col!=1) || ((y!=1) && (y!=4))) memset ((void*)t, (col!=0 ? 129 : 0), h);
	if(y==2) { t+=624-h; p+=3; }
	}
/* 	
  p = sp; t = st;
  // vertical lines on both sides of square
  for(y=0; y<6; y++)
	{
	for(q=0; q<8; q++,t++)
		{
		// doesn't work. Gives a bunch of pixels
		c = *(t); *(t) = ((y<3) ? c & 127 : c & 254);
		}
	t-=8;
	if(y==2) { p = sp+2; t = st+16; }
	else { t+=320, p+=3; }
	}
*/
};

static const BYTE *MyAscii_33_96[] =
 { c_33, c_34, c_35, c_36, c_37, c_38, c_39,
	c_40, c_41, c_42, c_43, c_44, c_45, c_46, c_47,
	c_0, c_1, c_2, c_3, c_4, c_5, c_6, c_7, c_8, c_9,
	c_58, c_59, c_60, c_61, c_62, c_63, c_32 /* no "@" */, 
	c_A, c_B, c_C, c_D, c_E, c_F, c_G, c_H, c_I, c_J, c_K, c_L, c_M,
	c_N, c_O, c_P, c_Q, c_R, c_S, c_T, c_U, c_V, c_W, c_X, c_Y, c_Z,
	c_91, c_92, c_93, c_94, c_95, c_96
 };
static const BYTE *MyAscii_123_126[] = { c_123, c_124, c_125, c_126 };

/* Displays prepared ASCII chars from table or empty space */
void dspChr( BYTE C, BYTE V, BYTE c )
{
	BYTE *p = (BYTE *)c_32;
	if(c>=97 && c<=122) c-=32;	// to upper-case
	if(c>=33 && c<=96) p = (BYTE *)MyAscii_33_96[c-33];
	if(c>=123 && c<=126) p = (BYTE *)MyAscii_123_126[c-123];
	PutBitmapImage( C,V,  (BYTE *)p);
}

/* Displays prepared ASCII string ending with 0 */
void dspString( BYTE C, BYTE V, BYTE *s )
{
	BYTE x = C, y = V, i, c;
	for(i=0; ; x++,i++)
	 {
	 c=s[i]; if(c==0) break;
	 dspChr(x,y,c);
	 if(x==40) { x=0; y++; }
	 }
}

void dspLoading( BYTE *txt1, BYTE *txt2 )
{
 dspString( 16,11,  (BYTE *)loading_txt );
 dspString( 16,13,  (BYTE *)txt1 );
 dspString( 16,15,  (BYTE *)txt2 );
 }

 void dspErrorOfLoading()
{
 ClrAllScreen();
 dspString( 16,8, (BYTE *)err_ld_t1 );
 dspString( 4,12,  (BYTE *)err_ld_t2 );
 dspString( 6,18,  (BYTE *)err_ld_t3 );
 dspString( 8,20,  (BYTE *)err_ld_t4 );
 Keyb_WaitForKeyPress();
 ClrAllScreen();
 }
 
BYTE c_buff[10];
void dspPoints( WORD n )
{
 dspString( 35,1,  (BYTE *)c_pts );
 dspBlank( 35,2,6,1 );
 itoa( n, c_buff, 10);
 dspString( 37,2,  (BYTE *)c_buff );
}

static const BYTE welc_XY [] = { 15,1, 14,5,
	11,10, 13,12, 1,16, 1,18, 1,20, 1,23, 10,25 };
static const BYTE *welc_S [] = { C64_logo, C64_chessproj,
	s_0, s_1, s_2, s_3, s_4, s_5, s_6 };

/* Displays my Welcome title */
void dspWelcome()
{
	BYTE i,i2, H,V,*p;
	for(i=0,i2=0; i<9; i++,i2+=2)
		{
		H = welc_XY[i2]; V = welc_XY[i2+1];
		p = (BYTE *)welc_S[i];
		if(i<2) PutBitmapImage( H, V, p );
		else dspString( H, V, p );
		}
	Keyb_WaitForKeyPress();
	ClrAllScreen();
}

static const BYTE menu_XY [] = { 3,21, 4,23, 5,25 };
static const BYTE *menu_S [] = { m_1, m_2, m_3 };

/* Displays text under menu */
void dspMenuAddedTxt()
{
	BYTE i,i2, H,V,*p;
	for(i=0,i2=0; i<3; i++,i2+=2)
		{
		H = menu_XY[i2]; V = menu_XY[i2+1];
		p = (BYTE *)menu_S[i];
		dspString( H, V, p );
		}
}

static const BYTE *S_mv123 [] = { S_1mv, S_2mv, S_3mv };

void dspMenuButtons()
{
	BYTE i,v;
	PutBitmapImage( menu_itmC-2, 2, (BYTE *)S_chess_puzzles );	
	for(i=0; i<3; i++)
		{
		v = 8+(i<<2);
		PutBitmapImage( menu_itmC, v, (BYTE *)S_mv123[i] );	
		PutBitmapImage( menu_itmC+1, v, (BYTE *)S_moves2mate );
		}
}

// redraws cursor around current menu item, or clears if not active
void dspCursMenuItem( BYTE i, BYTE act )
{
 BYTE *p, x, y, v = 7+(i<<2);
 if(!act)		// clear previous cursor 
	{
	dspBlank( menu_itmC-1,v, 16, 1 );
	dspBlank( menu_itmC-1,v+1, 1, 2 );
	dspBlank( menu_itmC+14,v+1, 1, 2 );
	dspBlank( menu_itmC-1,v+3, 16, 1 );
	}
  else			// put cursor
	{
	for(y=0; y<4; y++)
	 for(x=0; x<16; x++)
		{
		switch(y) {
			case 0: { switch(x) {
					case  0: {p = (BYTE *)B_curs_00; break; }
					case 15: {p = (BYTE *)B_curs_02; break; }
					default: {p = (BYTE *)B_curs_01; break; } }
					break; }
			case 3: { switch(x) {
					case  0: {p = (BYTE *)B_curs_20; break; }
					case 15: {p = (BYTE *)B_curs_22; break; }
					default: {p = (BYTE *)B_curs_21; break; } }
					break; }
			default: { switch(x) {
					case  0: {p = (BYTE *)B_curs_10; break; }
					case 15: {p = (BYTE *)B_curs_12; break; }
					default: {p =NULL; break; } }
					break; }	
			}
		if(p!=NULL) PutBitmapImage( menu_itmC-1+x, v+y, p );
		}
	}
};

// For debugging purposes only,
// Displays chess moves possible now...
void dspPossibleMoves()
	{
	BYTE i,p,f,t,V=0,H;
	mg_L = Chess.gList;
	ClrAllScreen();
	for(i=0; i<Chess.gc; i++, mg_L+=5)
		{
		if((i&3)==0) { V++; H=1; }
		f = mg_L[0]; t = mg_L[1]; p = Chess.B[f];
		if(p>10) p-=10;
		if(p>1) dspChr( H++, V, chess_pc[p] );
		dspChr( H++, V, 97+(f&7) );
		dspChr( H++, V, 49+(f/8) );
		dspChr( H++, V,
			(Chess.B[t]!=0 || Chess.ep==t) ? 42 : 45 );	//'x' or '-'
		dspChr( H++, V, 97+(t&7) );
		dspChr( H++, V, 49+(t/8) );
		dspChr( H++, V, 59 );	// ';' separate moves
		}
	Keyb_WaitForKeyPress();
	}

void dspPGNtxtOfGame( BYTE *p, BYTE p_cnt )
{
	BYTE i, x, y;
	BYTE w=Chess.w, mn=Chess.mn, m=0;
	dspBlank( 26, 5, 15, 5 );
	
	p=memchr(p,251,0xfff);
	
	for( ; m<p_cnt && m<5; )		// find first move to display
		{
		p-=2;
		if(*p!=250) for(; *(--p)!=0; );
		++p; ++m;
		w^=1;
		if(!w) mn--;
		}
	for( i=0; i<m; i++ )
		{
		y = 5+i;
		itoa( mn, c_buff, 10);
		strcat(c_buff, c_1p_ );
		dspString( 27, y, c_buff );	
		if(w) x=32;
		else { dspString( 32, y, (BYTE *)c_3p_ ); x=35; }	
		dspString( x, y, p );
		p+=strlen(p)+1;
		w^=1;
		if(w) mn++;
		}	
}

// for debug purposes
void dspDbgw( WORD i )
{
	itoa( i, c_buff, 10);
	dspString( 1, 1, c_buff );
	Keyb_WaitForKeyPress();
}