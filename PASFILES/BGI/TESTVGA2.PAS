program test_vga266_unit;
uses crt, graph, vga256;
var
	s:string;
begin
	setmode( mode1024x768x256 );
	grafikein;
  setcolor(15);
  line(0,0,getmaxx,getmaxy);
  line(0,getmaxy,getmaxx,0);
  str(getmaxx,s);
  s:='Max X=' + s;
  outtextxy(10,50, s);
  str(getmaxy,s);
  s:='Max Y=' + s;
  outtextxy(10,80, s);
  readln;
  grafikaus;
end.