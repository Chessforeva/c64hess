/*
	Some definitions to all code of this project
*/

#define BYTE unsigned char
#define WORD unsigned int

#define poke(A,X) (*(BYTE *)A) = (X)
#define peek(A) (*(BYTE *)A)

#define DBG_dump_addr (BYTE *)0xAE00	// address to save dump

// get highest byte
#define lo2hi(x)           \
            (__AX__ = (x),      \
             asm ("tax"),       \
             asm ("lda #$00"),  \
             __AX__)
			 
#define loByte(x)           \
            (__AX__ = (x),      \
             asm ("ldx #$00"),       \
             __AX__)

WORD random ( WORD dw ) { return ((rand() + clock()) % dw); }
BYTE svb[10];

void saveDisplayBytes()
{
 svb[0]=peek(0xd011);
 svb[1]=peek(0xd016);
 svb[2]=peek(0xd018);
 svb[3]=peek(0xdd02);
 svb[4]=peek(0xdd00);
 svb[5]=peek(0xd020);
 svb[6]=peek(0xd021);
}

void restoreDisplayBytes()
{
 poke(0xd011, svb[0]);
 poke(0xd016, svb[1]);
 poke(0xd018, svb[2]);
 poke(0xdd02, svb[3]);
 poke(0xdd00, svb[4]);
 poke(0xd020, svb[5]);
 poke(0xd021, svb[6]);
}

/* for debugging only
	Turns back to text mode, prints values.
	Unfortunately, stops program.

 */
void dbg( BYTE b ) { restoreDisplayBytes();  cprintf ("%d", b); }
void dbgw( WORD w ) { restoreDisplayBytes(); cprintf ("%d", w); }

// dumps to dump memory + st_pos
//  len-bytes of buffer from ptr address
// (good way to debug arrays of values,
//		doesn't stop program)
// f.exp., dbgDump(0, (char*)myptr, 100) copies 100 bytes from array to
// memory address AE00, where it can be viewed by monitors of emulators, or
// by saving memory snapshots
// 
void dbgDump( WORD st_pos, BYTE *ptr, BYTE len )
	{
	BYTE i, *p = DBG_dump_addr + st_pos;
	for(i=0; ; i++, p++ )
		{
		*(p) = ptr[i];
		if(len==0) { if(*(p)==0) break; }
		else { if(i>=len) break; }
		}
	++p; memset(p,0,20);
	}
	
// (good way to debug 1 byte without stopping program)
void dbgByteDump( WORD st_pos, BYTE b )
	{
	BYTE *p = DBG_dump_addr + st_pos; *(p) = b;
	}

/*
	This loading module works after screen repositioning in memory
	Otherwise cbm_open does silent commodore halt on LOAD
	We restore "bank" data for hardware, display too.
*/

WORD LoadModuleToAddress( BYTE *filename, BYTE *ram_addr )
{
  WORD rd = 0;
  BYTE dev = getcurrentdevice();	// or DEVICE 8 on most emulators
  
  BYTE d011 = peek(0xd011);		// clear screen
  poke(0xd011, 0);
  poke(0xdd02, svb[3]);		// banks for loading
  poke(0xdd00, svb[4]);
  rd=cbm_load( filename, dev, ram_addr );
  poke(0xdd02, 0x03);
  poke(0xdd00, 0x00);
  poke(0xd011, d011 );		// restore screen
  return rd;
}