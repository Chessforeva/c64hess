/*
	Board user interface, keyboard control for c64 key codes
*/
#define PGN_txt_addr (BYTE *)0xA600	// address to save pgn text for displaying

WORD points = 0;		// let's count solved M1 = 2pt, M2 = 6pt, M3=10pt
						// wrong move or drag gives -2pt
BYTE n_next = 0;		// is displayed N-next advice
				//Displays chess statuses
BYTE gmResult;	// 0-active,1- "1-0", 2- "0-1" 3-"1/2-1/2"

BYTE cursorMode;		// 0-pgn puzzles, 1-user can only move pieces

BYTE f_movemade = 0;		// flag that there was a move

BYTE p_cnt = 0;		// count of moves in text buffer

//---- PGN text preparation on screen
void PGN_text( BYTE u, BYTE ck )
{
	BYTE *p = PGN_txt_addr, *h, *L;
	BYTE f,t,k,e,pr,b,cp;
	switch(u)
	{
	case 0:
		{ p_cnt=0; *p=250; *(++p)=0; *(++p)=251; break; }	/* prepare memory */
	case 1:	/* add move */
		{
		p=memchr(p,251,0xfff); L=p;
		h = Chess.mh-8;
		f=h[0]; t=h[1]; k=h[3]; e=h[4];	pr = h[2];
		if(k!=0)
		{
		b=(k==1 ? 3 : 5);
		memcpy( p, o000, b);
		p+=b; 
		}
		else
		{
		b = ( pr ? (Chess.w?11:1) : Chess.B[t] );
		cp=((e!=0xFF || h[5]!=0) ? 42 : 45 );	//'x' or '-'
		if(b>10) b-=10;
		if(b==1)
			{
			if(cp==42) { *(p++)=97+(f&7); *(p++)=cp; }
			}
		else
			{
			*(p++)=chess_pc[b];
			if(cp==42) *(p++)=cp;
			}
		*(p++)=97+(t&7);
		*(p++)=49+(t/8);
		if(pr!=0) { *(p++)=61; *(p++)=chess_pc[10+pr]; }	//=QRBN
		}
		if(ck!=0) *(p++)=ck;	// check or checkmate
		*(p++)=0;
		*(p++)=251;
		p_cnt++;
		break;
		}
	case 2:	/* remove last move */
		{
		p=memchr(p,251,0xfff);
		p-=2;
		if(*p!=250)
			{
			for(; *(--p)!=0; );
			*(++p)=251;
			p_cnt--;
			}
		break;
		}	
	}
}

//------------
// Returns: 1 if new position

BYTE InfoStatus()
{
	WORD w;
	BYTE r, loop=1, ck=0;
	for( r=0 ; loop; r++)
	{
	loop=0;

	dspBlank(26,20,15,2);	// clear check signs
	dspBlank(28,24,13,2);	// clear undo,new signs
	
	if(isCheck())	/* if check+ */
		{
		if(!Chess.gc)	/* if can not move then checkmate */
			{
			dspCkMate();
			gmResult = (Chess.w ? 2 : 1 );
			ck = 35;	// '#'
			}
		else { dspCk(); ck= 43; } // '+'
		}
	else
		{
		if(!Chess.gc)	/* if can not move then stalemate */
			{
			dspStMate();
			gmResult = 3;
			}
		}
	switch(gmResult)
		{
		case 1: { dsp10(); break; }
		case 2: { dsp01(); break; }
		case 3: { dspRemis(); break; }
		}
	dspToMove();
	if(f_movemade)
		{
		PGN_text(1, ck);
		f_movemade = 0;
		}
	dspPGNtxtOfGame(PGN_txt_addr+1, p_cnt);
	if(!cursorMode)
		{
		if(gmResult>0)
			{
			for( w=clock(); clock()<w+100; );		// pause wait
			RandomGamePointer();
			gmResult = 0;
			PGN_text(0,0);
			dspChessBoard();
			loop=1;
			}
		}
	}
	return (--r);
}

/*
 Enter cursor mode, loop till ESC pressed
 returns 0 if ESC has been pressed
*/
BYTE MenuSelection()
{
	BYTE r=0, mn = menu, mn2 = 0xFF, pt2 = 0xFF;
	ClrAllScreen();
	dspMenuButtons();
	dspMenuAddedTxt();
	/* LOOP MENU ITEM SELECTION */
	for( kcode=0; kcode!=3 /*ESC*/ && kcode!=13 && r!=2; )
		{
		if(mn2!=0xFF)
			{
			dspCursMenuItem(mn2,0);		// clear previous
			mn2 = 0xFF;
			}
		if(mn!=0xFF)
			{
			dspCursMenuItem(mn, 1 );	// activate cursor
			mn = 0xFF;
			}
		
		if(kbhit())
		{
		kcode = Keyb_GetKey();
		if(kcode==157) kcode=145;		// the same as UP
		else if(kcode==29) kcode=17;	// the same as DOWN

		switch(kcode)
		{
		case 0: break;
		case 90:/* Z- Start in cursor mode */
			{
			r=2; break;
			}
		case 17:/*DOWN*/
			{
			if(menu!=2) { mn2 = menu; menu++; mn = menu; }
			break;
			}
		case 145:/*UP*/
			{
			if(menu!=0) { mn2 = menu; menu--; mn = menu; }
			break;
			}
		case 32: /*Space*/ kcode=13; 
		case 13: /*Enter*/ break;
		default: break;
		}
		}
		}
	ClrAllScreen();
	if(r!=2) r=((kcode==3) ? 0 : 1);
	return r;
}

void PointCnt( BYTE u, BYTE n )
{
	if(!cursorMode)
		{
		if(!u) points+=n;	// add points
		else	// wrong moves cost some
			{ if(n>points) points=0; else points-=n; }
		}
}

BYTE sqStarting() {	return( cursorMode ? 12 /*e2*/ : 36 /*e5*/ ); }

/*
 Enter cursor mode, loop till ESC pressed
*/
void BoardGUI( no_pgn )
{
 BYTE cc_, cc_2=0xFF, i,f,t=0xFF,e,k,b, *h;
 BYTE curs_sq, drag_sq=0xFF, SQ=0xFF;

 cursorMode=0;
 if(no_pgn==1)
	{
	cursorMode=1;
	OnloadInitChessGame();
	dspCursorMode();
	}
 curs_sq=sqStarting(); /*e2*/
	
 gmResult = 0;
 PGN_text(0,0);
 
 dspC64Logo();
 dspBoardLabels();
 dspChessBoard();
 InfoStatus();
 if(!n_next) { n_next=1; dspN_Next(); }

// THE MAIN LOOP
 for( kcode=0, cc_=curs_sq; kcode!=3 /*ESC*/; SQ=0xFF )
 {
	if(cc_!=0xff)
		{
		dspSquare(cc_);
		if(drag_sq!=0xFF) dspCursor( dspC(drag_sq), dspV(drag_sq), 1 );
		if(curs_sq!=0xFF) dspCursor( dspC(curs_sq), dspV(curs_sq), 0 );
		cc_=0xff;
		if(cc_2!=0xFF) { cc_=cc_2; cc_2 = 0xFF; }
		dspPoints(points);
		}
	
	if(!cursorMode) SQ = pgn_AnswerDrag();
		
	if(kbhit() || (SQ!=0xFF))
	{
	
	if(SQ!=0xFF)
		{
		if(curs_sq!=0xFF) dspSquare(curs_sq);
		curs_sq = SQ; kcode=13;
		}
	else kcode = Keyb_GetKey();
		
	if(kcode>=193 && kcode<=218) kcode-=128;
	switch(kcode)
	 {
	 case 0: break;
	 case 157:/*LEFT*/
		{
		if((curs_sq&7)!=0) cc_=curs_sq--;
		break;
		}
	 case 29:/*RIGHT*/
		{
		if(((curs_sq&7)-7)!=0) cc_=curs_sq++;
		break;
		}
	 case 17:/*DOWN*/
		{
		if((curs_sq>>3)!=0) { cc_=curs_sq; curs_sq-=8; }
		break;
		}
	 case 145:/*UP*/
		{
		if(((curs_sq>>3)-7)!=0) { cc_=curs_sq; curs_sq+=8; }
		break;
		}
	 case 32: /*Space*/ kcode=13; 
	 case 13: /*Enter*/
		{
		mg_L = Chess.gList;
		for(t=0xFF, i=0; i<Chess.gc; i++, t=0xFF, mg_L+=5)
			{
			f = mg_L[0]; t = mg_L[1]; k = mg_L[3]; e=mg_L[4];
				/* drag my piece, or chose other */
			if( (f==curs_sq) &&
				(drag_sq==0xFF || ((Chess.B[curs_sq]<10)==Chess.w))	)
				{
				if(cursorMode || pgn_ValidateDrag(curs_sq))
					{
					t = 0xFF;
					cc_2 = drag_sq;
					cc_=curs_sq; drag_sq = curs_sq;
					PointCnt(0,(SQ==0xFF ? 1:0) );	//+1pt
					}
				else PointCnt(1,2);	//-2pt
				break;
				}
				/* move piece to square */
			if( (t==curs_sq) && (drag_sq==f) )
				{		
				b = (cursorMode ? 1 : pgn_ValidateAndMove(curs_sq));
				if(b)
					{
					cc_2 = drag_sq;
					cc_=curs_sq; drag_sq = 0xFF;
					MkMove(i+(--b));
					f_movemade = 1;
					PointCnt(0,(SQ==0xFF ? 1:0));
					}
				else { t = 0xFF; PointCnt(1,2); }	//-2pt
				break;
				}
			}
		break;
		}
	 case 85:/*U- Undo move*/
		{
		if(cursorMode && ((Chess.mn>1) || (!Chess.w)))
			{
			h = Chess.mh-8;
			f=h[0]; t=h[1]; k=h[3]; e=h[4];
			cc_=drag_sq; drag_sq = 0xFF;
			if(cc_==0xFF) cc_=curs_sq;
			UnMkMove();
			gmResult = 0;
			PGN_text(2,0);
			}
		break;
		}
	 case 90:/* Z- Start or stop cursor mode */
		{
		if(!no_pgn)
			{
			cursorMode = cursorMode^1;
			kcode = 78;	// new game, next
			}
		}
	 case 78:/* N - New game, Next puzzle*/
		{
		drag_sq = 0xFF; cc_ = curs_sq; curs_sq=sqStarting();
		if(cursorMode) OnloadInitChessGame();
		else RandomGamePointer();
		gmResult = 0;
		PGN_text(0,0);
		dspChessBoard();
		InfoStatus();
		if(cursorMode) { dspCursorMode(); dspNEW(); }
		}
	 default:
		{
		if(kcode>=65 && kcode<=72)
			{ cc_=curs_sq; curs_sq&=56; curs_sq|=kcode-65; }
		if(kcode>=49 && kcode<=56)
			{ cc_=curs_sq; curs_sq&=7; curs_sq|=(kcode-49)<<3; }
		break;
		}
	 }
	
	/* if moved or unmoved */
	if(t!=0xFF)
		{
		dspPoints(points);
		MoveGen();
		dspSquare(f); dspSquare(t);
		if(e!=0xFF) dspSquare(e);
		if(k!=0)
			{
			if(k==1) { dspSquare(f+3); dspSquare(f+1); }
			else { dspSquare(f-4); dspSquare(f-1); }
			}
		t=0xFF;
		// gives M1 +0pt, M2 +2pt, M3 +4pt
		if(pgn_Solved()) PointCnt(0, (menu<<1));		
		if( InfoStatus() ) curs_sq = sqStarting();
		if(kcode==85) dspUNDO();
		}
	}
 }
 
}
