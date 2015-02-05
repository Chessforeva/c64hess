-- =================================================================================
--
-- 1) Prepares .SEQ files of pgn-data of chess positions and moves
-- 2) Writes "create_d64.bat" file to generate .d64 disk image.
-- 3) Writes header file "chesspgns.h" to use data files in c project
-- 
-- 
-- =================================================================================



-- this loads and executes other .lua file
function dofile (filename)
  local f = assert(loadfile(filename))
  return f()
end
dofile( "c0_chess_subroutine.lua" );	-- chess logic

-- file names are in PETSCII format
petToAscTable = {
0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x14,0x09,0x0d,0x11,0x93,0x0a,0x0e,0x0f,
0x10,0x0b,0x12,0x13,0x08,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,
0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,
0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f,
0x40,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x5b,0x5c,0x5d,0x5e,0x5f,
0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf,
0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf,
0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,
0x90,0x91,0x92,0x0c,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f,
0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf,
0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf,
0x60,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x7b,0x7c,0x7d,0x7e,0x7f,
0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf,
0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf
};

ascToPetTable = {
0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x14,0x20,0x0d,0x11,0x93,0x0a,0x0e,0x0f,
0x10,0x0b,0x12,0x13,0x08,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,
0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,
0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f,
0x40,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf,
0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0x5b,0x5c,0x5d,0x5e,0x5f,
0xc0,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0xdb,0xdc,0xdd,0xde,0xdf,
0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,
0x90,0x91,0x92,0x0c,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f,
0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf,
0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf,
0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f,
0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef,
0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff
};

function PETSCII_2_ASCII(s)
	local o="";
	local i=1;
	local c;
	while i<=string.len(s) do
		c = petToAscTable[ string.byte(s,i)+1 ]
		o=o..string.char(c);
		i=i+1;
	end
	return o;
end

function ASCII_2_PETSCII(s)
	local o="";
	local i=1;
	local c;
	while i<=string.len(s) do
		c = ascToPetTable[ string.byte(s,i)+1 ]
		o=o..string.char(c);
		i=i+1;
	end
	return o;
end

--
-- This LUA program prepares pgn-data to binaries ready for c64
--

MAXFSIZE = 1.6 * 1024;		-- Kb for each chess file for faster loading
D64_size = 170 * 1024;		-- size of d64 file FDD for the C64,
	--the 1541 is a single-sided 170-kilobyte drive for 5¼s
ALLOWED = D64_size - (30*1024);	-- allowed space - reserved for PRG file
	
TOTAL_SIZE = 0;	-- counter

Exits = 0;		-- flag to stop processing

CR = string.char(13) .. string.char(10);

----------------------------


CH_TABLE_FROM = 7;
CH_TABLE_TILL = 249;

-- arrays of encoding FEN string to get it shorter

function c(a)
return string.char(a);
end

ch = {};
ch[7]=c(32)..c(119)..c(32)..c(45)..c(32)..c(45)..c(32)..c(48)..c(32)..c(49);
ch[8]=c(32)..c(13)..c(32)..c(45)..c(32)..c(45)..c(32)..c(48)..c(32)..c(49);
ch[9]=c(56)..c(56)..c(56)..c(56);
ch[10]=c(56)..c(56)..c(56)..c(7);
ch[17]=c(45)..c(32)..c(48)..c(32);
ch[18]=c(11)..c(49)..c(11);
ch[19]=c(1)..c(1)..c(1);
ch[20]=c(49)..c(1)..c(49);
ch[21]=c(6)..c(49)..c(7);
ch[22]=c(56)..c(56)..c(7);
ch[23]=c(11)..c(11)..c(11);
ch[24]=c(56)..c(56)..c(56);
ch[25]=c(11)..c(50)..c(11);
ch[26]=c(50)..c(1)..c(49);
ch[27]=c(49)..c(11);
ch[28]=c(49)..c(1);
ch[29]=c(11)..c(49);
ch[30]=c(1)..c(49);
ch[31]=c(50)..c(1);
ch[33]=c(50)..c(11);
ch[34]=c(16)..c(49);
ch[35]=c(56)..c(56);
ch[36]=c(51)..c(1);
ch[37]=c(6)..c(49);
ch[38]=c(51)..c(11);
ch[39]=c(56)..c(7);
ch[40]=c(4)..c(49);
ch[41]=c(14)..c(49);
ch[42]=c(2)..c(49);
ch[43]=c(11)..c(50);
ch[44]=c(6)..c(50);
ch[46]=c(3)..c(49);
ch[47]=c(52)..c(1);
ch[57]=c(50)..c(5);
ch[58]=c(11)..c(51);
ch[59]=c(13)..c(49);
ch[60]=c(50)..c(6);
ch[61]=c(16)..c(51);
ch[62]=c(12)..c(49);
ch[63]=c(1)..c(50);
ch[64]=c(51)..c(5);
ch[65]=c(4)..c(50);
ch[66]=c(4)..c(51);
ch[67]=c(2)..c(50);
ch[68]=c(14)..c(50);
ch[69]=c(16)..c(50);
ch[70]=c(5)..c(49);
ch[71]=c(16)..c(52);
ch[72]=c(56)..c(52);
ch[73]=c(2)..c(51);
ch[74]=c(5)..c(50);
ch[75]=c(56)..c(53);
ch[76]=c(56)..c(49);
ch[77]=c(4)..c(52);
ch[78]=c(3)..c(50);
ch[79]=c(3)..c(51);
ch[80]=c(6)..c(51);
ch[81]=c(14)..c(51);
ch[82]=c(12)..c(50);
ch[83]=c(15)..c(49);
ch[84]=c(56)..c(51);
ch[85]=c(6)..c(52);
ch[86]=c(5)..c(51);
ch[87]=c(2)..c(52);
ch[88]=c(13)..c(50);
ch[89]=c(16)..c(53);
ch[90]=c(56)..c(54);
ch[91]=c(3)..c(52);
ch[92]=c(1)..c(1);
ch[93]=c(27)..c(49);
ch[94]=c(16)..c(11);
ch[95]=c(4)..c(53);
ch[96]=c(14)..c(52);
ch[97]=c(50)..c(3);
ch[99]=c(50)..c(2);
ch[100]=c(4)..c(54);
ch[101]=c(38)..c(52);
ch[102]=c(56)..c(55);
ch[104]=c(1)..c(51);
ch[105]=c(60)..c(53);
ch[106]=c(6)..c(7);
ch[107]=c(16)..c(54);
ch[108]=c(6)..c(54);
ch[109]=c(15)..c(50);
ch[110]=c(11)..c(52);
ch[111]=c(13)..c(51);
ch[112]=c(16)..c(27);
ch[113]=c(12)..c(51);
ch[114]=c(49)..c(5);
ch[115]=c(16)..c(55);
ch[116]=c(31)..c(53);
ch[117]=c(32)..c(17);
ch[118]=c(53)..c(11);
ch[120]=c(52)..c(61);
ch[121]=c(64)..c(52);
ch[122]=c(28)..c(50);
ch[123]=c(28)..c(54);
ch[124]=c(36)..c(52);
ch[125]=c(33)..c(53);
ch[126]=c(49)..c(2);
ch[127]=c(27)..c(54);
ch[128]=c(57)..c(53);
ch[129]=c(49)..c(3);
ch[130]=c(1)..c(52);
ch[131]=c(6)..c(55);
ch[132]=c(117)..c(49);
ch[133]=c(52)..c(58);
ch[134]=c(11)..c(11);
ch[135]=c(47)..c(51);
ch[136]=c(13)..c(52);
ch[137]=c(53)..c(1);
ch[138]=c(5)..c(55);
ch[139]=c(53)..c(43);
ch[140]=c(12)..c(52);
ch[141]=c(9)..c(7);
ch[142]=c(119)..c(32);
ch[143]=c(32)..c(142);
ch[144]=c(53)..c(74);
ch[145]=c(4)..c(7);
ch[146]=c(4)..c(55);
ch[147]=c(11)..c(55);
ch[148]=c(27)..c(50);
ch[149]=c(53)..c(44);
ch[150]=c(15)..c(51);
ch[151]=c(54)..c(34);
ch[152]=c(53)..c(63);
ch[153]=c(51)..c(85);
ch[154]=c(52)..c(80);
ch[155]=c(54)..c(30);
ch[156]=c(6)..c(53);
ch[157]=c(56)..c(50);
ch[158]=c(51)..c(71);
ch[159]=c(1)..c(53);
ch[160]=c(12)..c(53);
ch[161]=c(52)..c(73);
ch[162]=c(54)..c(29);
ch[163]=c(52)..c(11);
ch[164]=c(54)..c(37);
ch[165]=c(33)..c(50);
ch[166]=c(54)..c(21);
ch[167]=c(3)..c(55);
ch[168]=c(52)..c(86);
ch[169]=c(28)..c(51);
ch[170]=c(14)..c(53);
ch[171]=c(49)..c(13);
ch[172]=c(31)..c(50);
ch[173]=c(5)..c(52);
ch[174]=c(14)..c(54);
ch[175]=c(38)..c(50);
ch[176]=c(27)..c(51);
ch[177]=c(50)..c(13);
ch[178]=c(97)..c(53);
ch[179]=c(49)..c(100);
ch[180]=c(114)..c(54);
ch[181]=c(11)..c(53);
ch[182]=c(49)..c(108);
ch[183]=c(99)..c(53);
ch[184]=c(28)..c(1);
ch[185]=c(54)..c(40);
ch[186]=c(53)..c(67);
ch[187]=c(49)..c(12);
ch[188]=c(51)..c(87);
ch[189]=c(51)..c(91);
ch[190]=c(15)..c(52);
ch[191]=c(28)..c(52);
ch[192]=c(55)..c(5);
ch[193]=c(6)..c(8);
ch[194]=c(28)..c(53);
ch[195]=c(54)..c(70);
ch[196]=c(33)..c(51);
ch[197]=c(18)..c(49);
ch[198]=c(5)..c(53);
ch[199]=c(14)..c(11);
ch[200]=c(31)..c(51);
ch[201]=c(3)..c(53);
ch[202]=c(50)..c(89);
ch[203]=c(4)..c(8);
ch[204]=c(50)..c(29);
ch[205]=c(53)..c(65);
ch[206]=c(54)..c(46);
ch[207]=c(14)..c(27);
ch[208]=c(49)..c(15);
ch[209]=c(49)..c(107);
ch[210]=c(52)..c(66);
ch[211]=c(31)..c(1);
ch[212]=c(126)..c(54);
ch[213]=c(14)..c(34);
ch[214]=c(36)..c(1);
ch[215]=c(54)..c(1);
ch[216]=c(52)..c(2);
ch[217]=c(9)..c(39);
ch[218]=c(4)..c(21);
ch[219]=c(51)..c(2);
ch[220]=c(4)..c(143);
ch[221]=c(50)..c(95);
ch[222]=c(51)..c(16);
ch[223]=c(52)..c(79);
ch[224]=c(3)..c(1);
ch[225]=c(40)..c(21);
ch[226]=c(54)..c(42);
ch[227]=c(36)..c(50);
ch[228]=c(51)..c(4);
ch[229]=c(55)..c(106);
ch[230]=c(54)..c(11);
ch[231]=c(37)..c(8);
ch[232]=c(53)..c(69);
ch[233]=c(13)..c(11);
ch[234]=c(2)..c(55);
ch[235]=c(6)..c(5);
ch[236]=c(51)..c(77);
ch[237]=c(53)..c(78);
ch[238]=c(6)..c(1);
ch[239]=c(27)..c(52);
ch[240]=c(27)..c(53);
ch[241]=c(50)..c(16);
ch[242]=c(51)..c(30);
ch[243]=c(2)..c(53);
ch[244]=c(41)..c(13);
ch[245]=c(15)..c(53);
ch[246]=c(52)..c(16);
ch[247]=c(51)..c(29);
ch[248]=c(19)..c(50);
ch[249]=c(14)..c(23);

CHcnt = 0;

function CHtodecode()
	local i,c4;
	local s = "";
	CHcnt = 0;
	i = CH_TABLE_TILL;
	while(i>=CH_TABLE_FROM) do
		c4 = ch[i];
		if(c4==nil) then
			s = s .. "0, ";
			CHcnt = CHcnt+1;
		else
			s = s .. data2c(c4) .. " 0, ";
			CHcnt = CHcnt+string.len(c4)+1;
		end
		i = i-1;
		if (i % 20)==0 then
			s = s .. CR .. "   ";
		end
	end
	CHcnt = CHcnt+1;
	return (s .. "0");
end
----------------------------

function Alltrim(s)
  local i1,i2 = string.find(s,'^%s*');
  if i2 >= i1 then s = string.sub(s,i2+1) end;
  local i1,i2 = string.find(s,'%s*$');
  if i2 >= i1 then s = string.sub(s,1,i1-1) end;
  return s;
end

function GetFData(s)
  local i1 = string.find(s,'"');
  s = string.sub(s,i1+1);
  local i2 = string.find(s,'"');
  s = string.sub(s,1,i2-1);
  return s;
end

function numb2binInt(n)
  local n2 = n % 256;
  local n1 = (n-n2) / 256;
  return string.char(n1)..string.char(n2);
end

function Str2hexStr(s)
  local o="";
  local c;
  local i=1;
  while i<=string.len(s) do
	c = string.format( "%x", string.byte(s,i) );
	if(string.len(c)==1) then
		c = "0"..c;
	end
	o = o .. c;
	i = i+1;
  end
  return "0x" .. string.upper(o);
end

--------------
-- this sub. prepares text of data
--
function data2c( sc )

local q,s = "";
local i=1;
while( i<=string.len(sc) ) do
   q = string.byte(sc,i);
   if(i==1) then
     s = "  "
   end
   s = s .. string.format("%d",q) .. ", "
   i = i+1;
end
return s;

end
--------------


-- WRITE to data file
function Write2file(fn,Bin,ln,rc,cn)

	local fns = fn..".seq";
	local seq = ",s,r";
	local fn_petscii_filename = ASCII_2_PETSCII(fn..seq);
	
	local c_s = "c1541.exe -attach c64hess.d64 ";
	c_s = c_s .. "-write " .. fns .. " " .. (fn..",seq") .. CR;
	bat_file:write(c_s);

	ou_filb = assert(io.open(fns, "wt"));
	ou_filb:write(Bin);
	ou_filb:close();
	
	TOTAL_SIZE = TOTAL_SIZE + ln;
	local s = fns.." "..string.format("%d",ln);
	s = s .. " bytes ( " .. string.format("%d",rc);
	s = s .. " chess games here, total " .. string.format("%d",cn).." )";
	print(s);
	
	F_comm = F_comm .. "      //  " .. string.format("%d",ln)
			.. ", " .. string.format("%d",rc) ..
			', "' .. fn_petscii_filename .. '"'.. CR;
	
	fn_petscii_filename = fn_petscii_filename .. string.char(0);
	
	F_txt = F_txt .. data2c(numb2binInt(ln)..numb2binInt(rc) ..
			fn_petscii_filename) .. CR .. "   ";
	F_cnt = F_cnt + 4+string.len(fn_petscii_filename);
	
end

-- codes to my board
function toMyChess16( sc )
	local St;
	local u = string.find(sc," b3 ");
	if(u==nil) then
		u = string.find(sc," b6 ");
	end
	if (u~=nil) then
		St = repl_chess_pieces(string.sub(sc,1,u-1)) .. string.sub(sc,u);
	else
		St = repl_chess_pieces(sc);
	end
	return St;
 end
--------------
-- this sub. replaces chess pieces to codes
--
function repl_chess_pieces( s )

local q,c;
local i=1,l;
local o = "";
while( i<=string.len(s) ) do

   q = string.sub(s,i,i);
   c = string.find("PNBRQK",q);
   if(c==nil) then
     c = string.find("pnbrqk",q);
     if(c~=nil) then
       c = c+10;
     end
   end 

   if(c~=nil) then
     o = o .. string.char(c);
   else
     o = o .. q;
   end  

   i = i+1;
end

   return o;
end

-- file name+001
function plusFnumb(p)
	local q,o;
	
	if string.len(p)==0 then
		q = 1;
	else
		q = tonumber(p)+1;
	end
	o = string.format("%d",q);
	while string.len(o)<3 do
		o = "0" .. o;
	end
	return o;
end

-- PROCESSING .PGN FILES


function prepFile(filename, fname2)

if(Exits==1) then
	return;
end

F_txt = "";
F_cnt = 0; 
F_comm = "";

fname = string.sub( filename, 1, string.len(filename)-4 );

in_file = assert(io.open(filename, "rt"));

Bin_file = "";
gcnt = 0;

ppp = "";
s = 0;
P = "";
I = "";
H = "";
reccnt = 0;

while (Exits==0) do
 t = in_file:read();
 if not t then break end;
 t = Alltrim(t);
 if(string.len(t)>0) then
   if(s==0) then
     if(string.sub(t,1,1)=='[') then
        H = H .. (t..CR);
		P = "";
        if( string.sub(t,1,7)=='[Event ') then
          Event = GetFData(t);
        end
        if( string.sub(t,1,5)=='[FEN ') then
          Fen = GetFData(t);
        end
        if( string.sub(t,1,8)=='[Result ') then
          Result = GetFData(t);
          if( string.find(Result,"0")==nil ) then
            Result="1/2"	-- ignore unfinished games
          end
        end
     else
        s=1;
		P = P .. t .. " ";
     end
   else
     if(s==1) then
       P = P .. t .. " ";
     end
   end

 else

   if(s==1) then
    s=0;

	c0_LuaChess.c0_start_FEN = Fen;
	c0_LuaChess.c0_set_FEN(Fen);
	uci = c0_LuaChess.c0_get_moves_from_PGN(P);
	if(c0_LuaChess.c0_errflag) then
		print("Error for FEN "..Fen.." ,moves "..P);
	else
	
	-- save current game in binary format
	Bin = "";
	
	-- encode FEN
	fenEnc = string.gsub(Fen,'/','');

	isFenGood = 1;
	fp1 = string.find(fenEnc," ");
	fpa = 1;
	fpN = 0;
	fpV = 0;
	while fpa<fp1 do
		fpc = string.sub(fenEnc,fpa,fpa);
		fp2 = string.find("12345678",fpc);
		if(fp2~=nil) then
			fpN=fpN+tonumber(fpc);
		else
			fpN=fpN+1;
		end
		if fpN>8 then
			break;
		end
		if(fpN==8) then
			fpN=0;
			fpV=fpV+1;
		end
		fpa = fpa+1;
	end
	if (fpN~=0 or fpV~=8) then
		print("Bad FEN:" ..Fen .. " Ev: "..Event);	
		break
	end
	
	fenEnc = toMyChess16(fenEnc);
	
	
	-- encoding is too slow
	if true then
	
	if string.len(Bin_file)==0 then
		Bin_file = Bin_file .. PRG_load_addr;
		Bin_file = Bin_file .. string.char(250);	-- to know where is beginning byte
	end
	
	ec = CH_TABLE_FROM;
	while ec<=CH_TABLE_TILL do		-- till 249 
		ecCh = ch[ec];

		if(ecCh~=nil) then
			e2 = 1;
			f2 = "";
			LL = string.len(ecCh);
			L2 = string.len(fenEnc);
			while (e2<=L2 ) do
				e3 = 1;
				ok = 1;
				while ((ok==1) and (e2+(e3-1)<=L2) and (e3<=LL )) do
					f1c = string.byte(fenEnc,e2+(e3-1));
					f2c = string.byte(ecCh,e3);
					if(f1c~=f2c) then
						ok = 0;
					end
					e3 = e3 + 1;
				end
				if(ok==1) then
					f2 = f2 .. string.char(ec);
					e2 = e2 + LL;
				else
					f2 = f2 .. string.sub(fenEnc,e2,e2);
					e2 = e2 + 1;
				end
			end
			fenEnc = f2;
			
		end
		ec = ec+1;
	end
	
	end
	
	
	-- byte to know where FEN ends
	Bin = Bin .. fenEnc .. string.char(254);

    cnt = 0;

     -- analyse list of moves and prepare datas
     i = 1;
     while i<string.len(uci) do

       fH = string.byte(uci,i+0)-string.byte("a",1);
       fV = string.byte(uci,i+1)-string.byte("1",1);
       tH = string.byte(uci,i+2)-string.byte("a",1);
       tV = string.byte(uci,i+3)-string.byte("1",1);
       i = i + 4;
       d = 0;
       if( i<string.len(uci) ) then
         if( string.sub(uci,i,i)=='[') then
           g = string.sub(uci,i+1,i+1);
           i = i + 3;
		   d=string.find( "QRBN", g );
           if( d==nil ) then
             d=0;
           end
         end
       end
       Cf = 128 + (fV*8) + fH;
       Ct = 128 + (tV*8) + tH;

       Bin = Bin ..string.char(Cf) ..string.char(Ct);

       if(d>0) then
		Bin = Bin ..string.char(255) .. string.char(d);
       end

       cnt = cnt + 1;

     end
	 
	 -- byte "next chess game"
     Bin = Bin .. string.char(253);
	
     if(cnt>0) then
	 	reccnt = reccnt +1;
		Bin_file = Bin_file .. Bin;
		
		LN = string.len(Bin_file);
		
		if( LN>MAXFSIZE-100 ) then
				-- also avoid mall tail files
		 if( string.len(ppp)==0 or
		 		string.find(" m1p002 , m2p046 , m3p014 ", fname2..ppp )==nil) then
			Bin_file = Bin_file .. string.char(252);	-- the last byte
			LN = LN+1;
			ppp = plusFnumb( ppp );
			gcnt = gcnt + reccnt;
			Write2file(fname2..ppp,Bin_file,LN,reccnt,gcnt);
			Bin_file = "";
			reccnt = 0;
		  end
		end
		if( TOTAL_SIZE>ALLOWED ) then
			Exits=1;
			print("Consumed all d64 space, exiting");
		end
		
	 end
	 
	end
   end
	
 end

end

LN = string.len(Bin_file);
if(reccnt>0) then
	Bin_file = Bin_file .. string.char(252);	-- the last byte
	LN = LN+1;	
	ppp = plusFnumb( ppp );
	gcnt = gcnt + reccnt;
	Write2file(fname2..ppp,Bin_file,LN,reccnt,gcnt);
	Bin_file = "";
	reccnt = 0;
end

 -- prepare data for c-header file
 F_txt =  F_txt .. '0,0';
 F_cnt = F_cnt + 2;
 h_file:write(F_comm);
 h_file:write( "static const BYTE files_" ..fname2.." [" ..
   string.format("%d", F_cnt) .. "] = {" .. F_txt .. "};" .. CR ..CR );

   
end

-- Call samples...
--c0_LuaChess.a_SAMPLES ()

h_file = assert(io.open("chesspgns.h", "wt"));
h_file:write(CR..CR);
h_file:write ('   // bytes to decode compressed FEN string ' .. CR );

ch_decds = CHtodecode();

h_file:write( "static const BYTE CH_FEN_decode [" ..
   string.format("%d", CHcnt) .. "] = {" .. ch_decds .. " };" .. CR ..CR );
h_file:write(CR..CR);


bat_file = assert(io.open("create_d64.bat", "wt"));
c_s = "c1541.exe -format chesspuzzles,id d64 c64hess.d64" .. CR;
c_s = c_s .. "c1541.exe -attach c64hess.d64 -write c64hess.prg c64hess,prg" .. CR;
bat_file:write(c_s);


-- loading address for seq files is A600, just to know it
PRG_load_addr = string.char( 0xA6 ) .. string.char( 0x00 );

h_file:write ('   // Data for pgn-file loading ' .. CR );
h_file:write ('   //   size 2 bytes, record count 2 bytes,' .. CR );
h_file:write ('   //   filename for OPEN 1, 8, 0, "FILENAME,s,r" ...' .. CR );
h_file:write ('   //   (file starts with loading address ' ..
						Str2hexStr(PRG_load_addr) .. ')'.. CR );
h_file:write ('   //   ...' .. CR );

-- process chess pgn files
prepFile("M1verified.pgn","m1p");
prepFile("M2verified.pgn","m2p");
prepFile("M3verified.pgn","m3p");

h_file:close();
   
bat_file:write("pause"..CR);
bat_file:close();

print("Data prepared, Ok");


