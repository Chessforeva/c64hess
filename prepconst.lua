-- =================================================================================
--
-- Prepares arrays of bytes from ASCII string datas
--
-- Writes header file "strconst.h" to use data files in c project
--
-- =================================================================================

const_file = "strconst.h";

ou_file = assert(io.open(const_file, "wb"));

CR = string.char(13) .. string.char(10);

--------------
-- this sub. prints out datas as array of codes
--
function str2file( varName, sc, isChess )


ou_file:write( " // char* " .. '"' .. sc .. '"' .. CR );

local St;

if(isChess==1) then
  u = string.find(sc," b3 ");
  if(u==nil) then
    u = string.find(sc," b6 ");
  end
  if (u~=nil) then
    St = repl_chess_pieces(string.sub(sc,1,u-1)) .. string.sub(sc,u);
  else
    St = repl_chess_pieces(sc);
  end
else
  St = sc;
end

ou_file:write( "static const BYTE ".. varName .. "[" ..
   string.format("%d", string.len(St)+1) .. "] = {" .. CR );

local s = "";
local i=1;

while( i<=string.len(St) ) do

   q = string.byte(St,i);

   if(i==1) then
     s = "  "
   end

   s = s .. string.format("%d",q) .. ", "

   if( string.len(s)>60) then
     ou_file:write(s .. CR);
     s = "  "     
   end

   i = i+1;
end

ou_file:write(s);

if( string.len(s)>2) then
   ou_file:write(CR);
end

ou_file:write( " 0 };" .. CR .. CR);

end
--------------


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

--
-- Prepare our datas
--

ou_file:write(CR .. CR);

chessFEN0 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

--chessFEN0 = "2Q5/4kpQP/4p3/p2PN3/7p/BP5B/4K2P/7R b KQkq - 0 1";

str2file( "chess_sFEN", chessFEN0, 1 );
str2file( "chess_cs", "KQkq", 1 );
str2file( "chess_pc", " PNBRQK    pnbrqk", 0 );

str2file( "s_0", "by Chessforeva", 0 );
str2file( "s_1", "year 2015", 0 );
str2file( "s_2", "Thanks to 8-bit CPU C-compiler CC65,", 0 );
str2file( "s_3", "Project One for Koala picture editor", 0 );
str2file( "s_4", "and Commodore community for support!", 0 );

str2file( "s_5", "Press key [/] to disable twice-press", 0 );
str2file( "s_6", "or any other key...", 0 );

str2file( "m_1", "Polgar puzzles published in 1994 ", 0);
str2file( "m_2", "306 M1, 3391 M2, 743 M3 cases", 0 );
str2file( "m_3", "ESC - back, Z - cursor mode", 0 );

str2file( "c_puzzles", " puzzles", 0 );
str2file( "c_pts", " PTS", 0 );
str2file( "c_1p_", ".", 0 );
str2file( "c_3p_", "...", 0 );

str2file( "o000", "0-0-0".. string.char(0), 0 );

str2file( "loading_txt", "LOADING...", 0 );

str2file( "err_ld_t1", "ERROR!", 0);
str2file( "err_ld_t2", "CBM not working for disk device.", 0 );
str2file( "err_ld_t3", "Press a key to see chess", 0 );
str2file( "err_ld_t4", "board in cursor mode...", 0 );

str2file( "c_seq", ".seq", 0 );

ou_file:close()

print("Ok");

