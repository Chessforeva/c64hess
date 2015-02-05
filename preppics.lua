-- =================================================================================
--
-- Prepares picture* datas from koala file "pictures.kla" to binary codes
--
--  *thanks to Project One (http://p1.untergrund.net) koala editor
--
--  Writes header file "pictures.h" to use data files in c project
-- 
-- =================================================================================
-- 
-- .kla file is a complete multicolor screen picture 320x200 pixels
--   placable on screen
-- 
-- Commodore 64 screen is 40 x 25 (w x h) = 1000 characters (kind of graphical)
-- 
-- .kla structure is splitted this way:
--   3 bytes loading address
--   8000 bytes contain sprites of these characters: 8 bytes (of 8bits) per character
--   1000 bytes contain screen data (if simple characters by code are there)
--   1000 bytes contain colour pairs (4+4bits) of character (except black, which is background)
--   1 bytes background colour code (black 0)
--
-- Commodore has 16 colour Pepto palette
--
-- So, we read large file of 10003 bytes and prepare these characters as
--   our defined images that we will place on screen later!
--

pic_filename = "pictures.kla";


CR = string.char(13) .. string.char(10);

fname = string.sub( pic_filename, 1, string.len(pic_filename)-4 );

in_file = assert(io.open(pic_filename, "rb"));
ou_file = assert(io.open(fname..".h", "wb"));

in_file:read(2);	-- skip loading address

C = 1;
V = 1;
db = {};

while V<=25 do
 C = 1;
 db[V] = {};
 while C<=40 do
   s = in_file:read(8);
   db[V][C] = s;
   C = C+1;
 end
 V = V+1;
end

C = 1;
V = 1;
scr = {};

while V<=25 do
 C = 1;
 scr[V] = {};
 while C<=40 do
   s = in_file:read(1);
   scr[V][C] = string.byte(s,1);
   C = C+1;
 end
 V = V+1;
end

C = 1;
V = 1;
col = {};

while V<=25 do
 C = 1;
 col[V] = {};
 while C<=40 do
   s = in_file:read(1);
   col[V][C] = string.byte(s,1);
   C = C+1;
 end
 V = V+1;
end


local background = in_file:read(1);	-- the last byte is background
print( "bgcolor=" .. string.format("%d", string.byte(background,1)) );

local bfeof = in_file:read(1);
if not bfeof then
  print("eof-ok");
end

--------------
-- this sub. prints out .c datas of picture
--
function img2file( varName, posC,posV, width, height)

local s="",qS;
local q,x,y, i;
local z = width * height;

ou_file:write( "static const BYTE ".. varName .. "[" ..
   string.format("%d",2 + (z * 8) + (2 * z)) .. "] = { " );

ou_file:write( string.format("%d",width) .. " /* width */ , " );
ou_file:write( string.format("%d",height) .. " /* height */ , " .. CR );

ou_file:write( "  /* bitmap data of picture */" .. CR);

y = 0;
while y<height do
 x = 0;
 while x<width do
  i = 1
  qS = db[ posV + y ][ posC + x ];

  s = " ";

  while i<=8 do

   q = string.byte(qS,i);

   s = s .. " " .. string.format("%d",q);

   s = s .. ",";

   i = i+1;
  end

  ou_file:write(s .. CR);

  x = x+1;

 end


 y = y+1;
end

ou_file:write( "  /* screen data */" .. CR);

y = 0;
while y<height do
 x = 0;
 s = " ";

 while x<width do

   q = scr[ posV + y ][ posC + x ];

   s = s .. " " .. string.format("%d",q);

   s = s .. ",";
   
   x = x+1;

 end
 ou_file:write(s .. CR);

 y = y+1;
end

ou_file:write( "  /* colour data */" .. CR);

y = 0;
while y<height do
 x = 0;
 s = " ";

 while x<width do

   q = col[ posV + y ][ posC + x ];

   s = s .. " " .. string.format("%d",q);
   
   if(y<height-1 or x<width-1) then
      s = s .. ",";
   end

   x = x+1;

 end
 ou_file:write(s .. CR);

 y = y+1;
end

ou_file:write( "  };" .. CR .. CR);

end
--------------

--
-- Prepare our pictures
--

ou_file:write(CR .. CR);

ou_file:write( "// .....board parts............." .. CR);

ou_file:write( "// chess pieces on squares" .. CR);

ou_file:write( "// white" .. CR);

img2file("wPw",  1, 1, 3, 3);
img2file("wPb",  1, 4, 3, 3);

img2file("wNw",  4, 4, 3, 3);
img2file("wNb",  4, 1, 3, 3);

img2file("wBw",  7, 1, 3, 3);
img2file("wBb",  7, 4, 3, 3);

img2file("wRw", 10, 4, 3, 3);
img2file("wRb", 10, 1, 3, 3);

img2file("wQw", 13, 1, 3, 3);
img2file("wQb", 13, 4, 3, 3);

img2file("wKw", 16, 4, 3, 3);
img2file("wKb", 16, 1, 3, 3);

ou_file:write( "// black" .. CR);

img2file("bPw", 19, 1, 3, 3);
img2file("bPb", 19, 4, 3, 3);

img2file("bNw", 22, 4, 3, 3);
img2file("bNb", 22, 1, 3, 3);

img2file("bBw", 25, 1, 3, 3);
img2file("bBb", 25, 4, 3, 3);

img2file("bRw", 28, 4, 3, 3);
img2file("bRb", 28, 1, 3, 3);

img2file("bQw", 31, 1, 3, 3);
img2file("bQb", 31, 4, 3, 3);

img2file("bKw", 34, 4, 3, 3);
img2file("bKb", 34, 1, 3, 3);

ou_file:write( "// empty squares" .. CR);

img2file("bgW", 37, 1, 3, 3);
img2file("bgB", 37, 4, 3, 3);

ou_file:write( "// board labels" .. CR);

img2file("BL_a", 1, 7, 1, 1);
img2file("BL_b", 2, 7, 1, 1);
img2file("BL_c", 3, 7, 1, 1);
img2file("BL_d", 4, 7, 1, 1);
img2file("BL_e", 5, 7, 1, 1);
img2file("BL_f", 6, 7, 1, 1);
img2file("BL_g", 7, 7, 1, 1);
img2file("BL_h", 8, 7, 1, 1);

img2file("BL_1", 1, 8, 1, 1);
img2file("BL_2", 2, 8, 1, 1);
img2file("BL_3", 3, 8, 1, 1);
img2file("BL_4", 4, 8, 1, 1);
img2file("BL_5", 5, 8, 1, 1);
img2file("BL_6", 6, 8, 1, 1);
img2file("BL_7", 7, 8, 1, 1);
img2file("BL_8", 8, 8, 1, 1);

ou_file:write( "// To move sign" .. CR);
img2file("BL_snW", 33, 11, 2, 2);
img2file("BL_snB", 35, 11, 2, 2);

--ou_file:write( "// cursors" .. CR);
--img2file("curs_B",  9, 14, 3, 3);
--img2file("curs_R",  12, 14, 3, 3);
--img2file("curs_G",  15, 14, 3, 3);

ou_file:write( "// Cursor around buttons" .. CR);
img2file("B_curs_00", 18, 14, 1, 1);
img2file("B_curs_01", 19, 14, 1, 1);
img2file("B_curs_02", 20, 14, 1, 1);
img2file("B_curs_10", 18, 15, 1, 1);
img2file("B_curs_12", 20, 15, 1, 1);
img2file("B_curs_20", 18, 16, 1, 1);
img2file("B_curs_21", 19, 16, 1, 1);
img2file("B_curs_22", 20, 16, 1, 1);

ou_file:write( "// ..... other" .. CR);

ou_file:write( "// Commodore 64 logo" .. CR);
img2file("C64_logo", 9, 7, 6, 3);

ou_file:write( "// Game Over." .. CR);
img2file("I_gameover", 15, 7, 16, 2);

ou_file:write( "// Check+" .. CR);
img2file("I_check", 31, 7, 8, 2);

ou_file:write( "// Checkmate#" .. CR);
img2file("I_ckmate", 15, 9, 15, 2);

ou_file:write( "// Stalemate!" .. CR);
img2file("I_stmate", 15, 11, 13, 2);

ou_file:write( "// UNDO" .. CR);
img2file("I_undo", 1, 9, 7, 2);

ou_file:write( "// NEW" .. CR);
img2file("I_new", 1, 11, 6, 2);

ou_file:write( "// Cursor mode" .. CR);
img2file("I_cursor_mode", 1, 23, 14, 1);

ou_file:write( "// N-next" .. CR);
img2file("I_N_next", 1, 24, 8, 1);

ou_file:write( "// Result 1-0" .. CR);
img2file("I_res10", 30, 9, 4, 2);

ou_file:write( "// Result 0-1" .. CR);
img2file("I_res01", 34, 9, 4, 2);

ou_file:write( "// Result draw" .. CR);
img2file("I_resDraw", 28, 11, 5, 2);

ou_file:write( "// Welcome Chess project" .. CR);
img2file("C64_chessproj", 1, 14, 8, 3);

ou_file:write( "// Selections of menu" .. CR);

ou_file:write( "// Chess_puzzles" .. CR);
img2file("S_chess_puzzles", 1, 17, 20, 4);

ou_file:write( "// 1mv to mate" .. CR);
img2file("S_1mv", 1, 21, 2, 2);
ou_file:write( "// 2mv to mate" .. CR);
img2file("S_2mv", 2, 21, 2, 2);
ou_file:write( "// 3mv to mate" .. CR);
img2file("S_3mv", 3, 21, 2, 2);

ou_file:write( "// -moves:mate" .. CR);
img2file("S_moves2mate", 4, 21, 13, 2);


ou_file:write( "// ..... our charset of bitmaps" .. CR);

img2file("c_A", 1, 13, 1, 1);
img2file("c_B", 2, 13, 1, 1);
img2file("c_C", 3, 13, 1, 1);
img2file("c_D", 4, 13, 1, 1);
img2file("c_E", 5, 13, 1, 1);
img2file("c_F", 6, 13, 1, 1);
img2file("c_G", 7, 13, 1, 1);
img2file("c_H", 8, 13, 1, 1);
img2file("c_I", 9, 13, 1, 1);
img2file("c_J", 10, 13, 1, 1);
img2file("c_K", 11, 13, 1, 1);
img2file("c_L", 12, 13, 1, 1);
img2file("c_M", 13, 13, 1, 1);
img2file("c_N", 14, 13, 1, 1);
img2file("c_O", 15, 13, 1, 1);
img2file("c_P", 16, 13, 1, 1);
img2file("c_Q", 17, 13, 1, 1);
img2file("c_R", 18, 13, 1, 1);
img2file("c_S", 19, 13, 1, 1);
img2file("c_T", 20, 13, 1, 1);
img2file("c_U", 21, 13, 1, 1);
img2file("c_V", 22, 13, 1, 1);
img2file("c_W", 23, 13, 1, 1);
img2file("c_X", 24, 13, 1, 1);
img2file("c_Y", 25, 13, 1, 1);
img2file("c_Z", 26, 13, 1, 1);
img2file("c_91", 27, 13, 1, 1);
img2file("c_93", 28, 13, 1, 1);
img2file("c_33", 29, 13, 1, 1);
img2file("c_34", 30, 13, 1, 1);
img2file("c_35", 31, 13, 1, 1);
img2file("c_36", 32, 13, 1, 1);
img2file("c_37", 33, 13, 1, 1);
img2file("c_38", 34, 13, 1, 1);
img2file("c_40", 35, 13, 1, 1);
img2file("c_41", 36, 13, 1, 1);
img2file("c_43", 37, 13, 1, 1);
img2file("c_45", 38, 13, 1, 1);
img2file("c_42", 39, 13, 1, 1);
img2file("c_47", 40, 13, 1, 1);


img2file("c_60", 8, 10, 1, 1);
img2file("c_62", 9, 10, 1, 1);
img2file("c_63", 10, 10, 1, 1);

img2file("c_123", 11, 10, 1, 1);
img2file("c_125", 12, 10, 1, 1);
img2file("c_124", 13, 10, 1, 1);
img2file("c_39", 14, 10, 1, 1);

img2file("c_0", 7, 11, 1, 1);
img2file("c_1", 8, 11, 1, 1);
img2file("c_2", 9, 11, 1, 1);
img2file("c_3", 10, 11, 1, 1);
img2file("c_4", 11, 11, 1, 1);
img2file("c_5", 12, 11, 1, 1);
img2file("c_6", 13, 11, 1, 1);
img2file("c_7", 14, 11, 1, 1);

img2file("c_92", 7, 12, 1, 1);
img2file("c_8", 8, 12, 1, 1);
img2file("c_9", 9, 12, 1, 1);
img2file("c_46", 10, 12, 1, 1);
img2file("c_44", 11, 12, 1, 1);
img2file("c_59", 12, 12, 1, 1);
img2file("c_58", 13, 12, 1, 1);
img2file("c_61", 14, 12, 1, 1);


img2file("c_96", 37, 12, 1, 1);
img2file("c_94", 38, 12, 1, 1);
img2file("c_95", 39, 12, 1, 1);
img2file("c_126", 40, 12, 1, 1);

img2file("c_32", 40, 1, 1, 1);

ou_file:close()
in_file:close()
print("Ok");

