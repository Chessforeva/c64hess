/*
	Loads PGN data and operates them
*/

#define fPgnHadler 1
#define DEVICE_8 8 		//1541 @ device #8, good for .d64
#define CHESS_LOAD_PGN_RAM (BYTE *)0x8600	// Load ~8Kb of chess file

#define CH_TABLE_FROM 7
#define CH_TABLE_TILL 249

WORD pgn_file_len, pgn_games_cnt, pgn_read_cnt;
BYTE *pgn_fname, *pgn_p, pgn_q, pgn_W;
BYTE pgn_gm_FEN[100], tmpbuf[100];

static const BYTE *pgn_fgroups[] = { files_m1p, files_m2p, files_m3p };

void PrepareDecodedFEN()
{
	BYTE l, a, L;
	BYTE *f,*t,*d= (BYTE *)CH_FEN_decode;
	
	for(pgn_q=0; pgn_p[pgn_q]!=254; pgn_q++);	
	L = pgn_q;
	
	memcpy(pgn_gm_FEN, pgn_p, L);
	pgn_gm_FEN[L] = 0;
	pgn_p+=(L+1);
		
	for(l=0, a=CH_TABLE_TILL; a>=CH_TABLE_FROM; a--, d++)
		{
		if(*(d)!=0)
			{
			for(;d[l]!=0;l++);
			if(memchr( pgn_gm_FEN, a, L )!=NULL)
				{
				t = tmpbuf; f = pgn_gm_FEN;
				for( L=0; *(f)!=0; f++)
					{
					if(*(f)==a) { memcpy(t,d,l); t+=l; L+=l; }
					else { *(t++) = *(f); L++; }
					}
				memcpy(pgn_gm_FEN,tmpbuf,L);
				pgn_gm_FEN[L]=0;
				}
			d+=l;
			}
		}
	pgn_W = (memchr( pgn_gm_FEN, 119 /*w*/, L )!=NULL);	// white to move puzzle
}

void RandomGamePointer()
{
	BYTE c, stop;
	WORD r;
	
	for(c=252, stop=0; !stop; )
		{
		switch(c)
			{
			case 252:	// file end byte
				{
				r = random(pgn_file_len-200);
				pgn_p = CHESS_LOAD_PGN_RAM+2;		// 2 bytes is loading address (info only)
				pgn_p+=r;
				break;
				}
			case 253:	// end of game byte
				{
				c=*(++pgn_p);
				if(c!=252) stop=1;	// if next is a game then found,ok
				break;
				}
			case 254:	// FEN end byte
				{
				for( ; (c!= 250) && (c!=253); ) c=*(--pgn_p);
				pgn_p++; stop=1;
				break;
				}
			case 250:	// beginning of file
				{
				pgn_p++; stop=1;
				break;
				}
			default:
				{
				pgn_p++;
				break;
				}
			}		
		c = *pgn_p;
		}
	PrepareDecodedFEN();
	setFEN( (BYTE*) pgn_gm_FEN );
};

BYTE LoadPgnFile()
{
	WORD r;
	BYTE ok = 0, *po, *p, q, tm;

	po = (BYTE *)(pgn_fgroups[menu]);	// menu defined in keybcontrol.h
		
	// find total count of parts
	for(q=0, p=po; ; q++, p++)
		{
		if( p[0]==0 && p[1]==0 && p[2]==0 ) break;
		}
	
	r = random(q-2);	// take random

		// find beginning of part, ignore 0s in file size, count of puzzles
	for(po+=r, p=po-5; r>0 ; r--, po--,p--)
		{
		if( po[4]==77 && (p[4]==0) && (r<5 || memchr( p, 0, 4 )==NULL) ) break;
		}
	
	pgn_file_len = lo2hi((BYTE)po[0]) + (BYTE)po[1];
	pgn_games_cnt = lo2hi((BYTE)po[2]) + (BYTE)po[3];
	pgn_read_cnt = 0;
	pgn_fname = po+4;		// skip file size and count of records
	
	ClrAllScreen();
	itoa( pgn_games_cnt, tmpbuf, 10); strcat(tmpbuf, c_puzzles);
	
	for(tm = 0; tm<2; tm++)
		{
		
		dspLoading(pgn_fname, tmpbuf);
		for( r=clock(); clock()<r+100; );		// pause wait
		ClrAllScreen();
	
		// load file to memory address, declared in common.h
		pgn_read_cnt = LoadModuleToAddress( pgn_fname, CHESS_LOAD_PGN_RAM );

		if(pgn_read_cnt!=0)		// =file length -2 bytes loading address
			{
			RandomGamePointer();
			ok = 1;
			break;
			}
		// make "FILENAME,s,r" to "FILENAME.seq" for modern OSes and try again
		strcpy(  memchr( pgn_fname, 44 /* ',' */, 0xff ), c_seq );
		}
	return ok;			
}
// returns 1 if this piece should move
BYTE pgn_ValidateDrag( BYTE f )
{	
	BYTE r = 0;
	if((*pgn_p!=253) && (*pgn_p & 127)==f) { ++pgn_p; r=1; }
	return r;
}
// returns 1 if piece moves to this square, (2..5)-promoted Q,R,B,N
BYTE pgn_ValidateAndMove( BYTE t )
{
	BYTE r = 0;
	if((*pgn_p & 127)==t) { ++pgn_p; r=1; }
	if(*pgn_p==255) { r+= *(++pgn_p); --r; ++pgn_p; }
	return r;
}

BYTE pgn_AnswerDrag()
{
	BYTE sq = 0xFF;
	if((*pgn_p!=253) && (pgn_W!=Chess.w)) sq = (*pgn_p & 127);
	return sq;
}
BYTE pgn_Solved() { return (*pgn_p==253); }
