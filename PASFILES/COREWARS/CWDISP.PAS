Unit cwdisp;
Interface
Uses
  crt, util, vesa, cwtypes;
Const
  cw_display_graphmode = mode_800X600X64k;

  cw_display_offx = 25;
  cw_display_offy = 25;
  cw_display_rows = 100;
  cw_display_cols = 100;
Type
	display_p = ^display_o;
  display_o = Object (cw_base_o)
                Constructor init;
                Destructor done;

                Procedure disp_read (adr: adress_t; b: Byte);
                Procedure disp_write (adr: adress_t; b: Byte);
                private procedure atoxy(a:adress_t; var x,y:word);
                private function btocol(b:byte):longint;
                private procedure blink(x,y:word);
                private procedure draw(x,y:word; c:longint);
              End;
Implementation
(*
 *  Public proceduren u. functions
 *)
Constructor display_o. init;
Begin
  If setmode ( cw_display_graphmode) Then
  Begin
    wrrect (cw_display_offx - 1, cw_display_offy - 1,
    cw_display_offx + cw_display_rows * 4 + 1,
		cw_display_offx + cw_display_rows * 4 + 1,
    RGB ( $ff, $ff, $ff) );
  End;
End;
Destructor display_o. done;
Begin
  TextMode (co80 + Font8X8);
End;
Procedure display_o. disp_read;
var
	xp,yp:word;
begin
	atoxy(adr, xp, yp);
  blink(xp,yp);
  draw(xp,yp,btocol(b));
end;
Procedure display_o. disp_write;
var
	xp,yp:word;
begin
	atoxy(adr, xp, yp);
  draw(xp,yp,btocol(b));
end;
(*
 *  Private proceduren u. functions
 *)
procedure display_o. atoxy(a:adress_t; var x,y:word);
Begin
  X := (a Mod (cw_display_rows) ) * 4 + cw_display_offx;
  Y := (a Div (cw_display_cols) ) * 4 + cw_display_offy;
End;
function display_o. btocol(b:byte):longint;
var
	red, blue:byte;
begin
	red:=$00;
  blue:=$00;
	if (b and $40) >0 then
  	red:=$ff;
	if (b and $80) >0 then
  	blue:=$ff;
  if (red=$ff) and (blue=$ff) then
  begin
	 btocol:=RGB($00,$ff,$00);
  end
  else
  	btocol:=RGB(red, green, blue);
end;
procedure display_o. blink;
var
	c:byte;
begin
	for c:=$00 to $ff do
  	draw(x,y,RGB(c,c,c));
end;
procedure display_o. draw;
begin
	setpix(x,y,c);
	setpix(x+1,y,c);
	setpix(x,y+1,c);
	setpix(x+1,y+1,c);
end;
Begin
End.