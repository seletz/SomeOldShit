{***************************************}
{  VGAEXTRA unit                        }
{       Thomas Design                   }
{       August 5,  1989                 }
{***************************************}

unit VGAEXTRA;
interface

type RGB = array[0..255,0..2] of byte;

procedure dacpalette(var Pal :RGB);
procedure flashmodeon;
procedure flashmodeoff;

implementation
procedure flashmodeon;
begin
  inline($ba/$c4/$03/$b0/$01/$ee/$42/$ec/$0c/$20/$ee/$ba/$da/$03);
end;

procedure flashmodeoff;
begin
  inline($ba/$c4/$03/$b0/$01/$ee/$42/$ec/$24/$df/$ee/$ba/$da/$03);
end;

procedure dacpalette(var Pal : RGB);  { load all 256 DAC registers }
begin
   inline($1E/$C5/$76/<Pal/$BA/$C8/$03/$B0/$00/$EE/$42/$FA/$FC/$52
         /$B9/$80/$01/$BA/$DA/$03/$EC/$24/$08/$75/$FB/$EC/$24/$08
         /$74/$FB/$5A/$54/$58/$3B/$C4/$75/$18/$F3/$6E/$52/$B9/$80
         /$01/$BA/$DA/$03/$EC/$24/$08/$75/$FB/$EC/$24/$08/$74/$FB
         /$5A/$F3/$6E/$EB/$0D/$33/$C9/$AD/$EE/$8A/$C4/$EE/$AC/$EE
         /$FE/$C1/$75/$F5/$FB/$1F);
end;
end.
