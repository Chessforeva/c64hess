/*
	Keyboard control
	To avoid "too fast" effect on emulators, we use "twice key press" disabled.
*/
BYTE key_lastpress, key_twice, kcode;
BYTE menu=0;	// for menu, values = 0-M1, 1-M2, 2-M3

void Keyb_Onload()
{
	key_twice = 1;		// 1-allow, 0-disable
	key_lastpress = 47;	// '/'
}

BYTE Keyb_GetKey()	// get keypress
{
	BYTE kcode = cgetc();
	if( (!key_twice) &&  (key_lastpress==kcode)) kcode = 0;
	else if(kcode==47) { kcode=key_lastpress; key_twice =0; /*disable*/ }
	else key_lastpress = kcode;
	poke(198,0); /* clear keyboard queue */
	return kcode;
}

	/* wait for key */
void Keyb_WaitForKeyPress()
{
  while (!kbhit() || Keyb_GetKey()==0);
}
