Unit diskun;

Interface
Uses crt, matrix44, objektun, viewunit;

Procedure Str2Window (zeile: String; w: p_win);
Procedure Str2vektor (zeile: String; v: p_vektor4);
Procedure load_scene (filename: String; v: p_view; ol, ll: p_oliste);

Implementation
Const
  num_cmd = 6;
  file_id = 'SITRA SCENEFILE';
  command_s: Array [1..num_cmd] Of String = ('#View', '#Objects', '#Lights', '#Textures', '##', 'End');
Type
  commands = (view, objects, lights, textures, comment, c_end);
  t_commands = Set Of commands;
  (*=========================================*
  *                                         *
  *                                         *
  *                                         *
  *                                         *
  *                                         *
  *=========================================*)
Procedure disk_error (s: String);
Begin
  WriteLn ('DiskUN: ', s);
  Halt (1);
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure Str2vektor (zeile: String; v: p_vektor4);
Var
  code, i: Integer;
  zahl: String;
  X, Y, z: Double;
Begin
  i := Pos (' ', zeile);
  If i = 0 Then
    disk_error ('bad vector format !');
  zahl := Copy (zeile, 0, i - 1);
  Val (zahl, X, code);
  If code <> 0 Then
    disk_error ('bad vector format !');
  
  i := Length (zahl);
  zeile := Copy (Zeile, i + 2, Length (zeile) - i);
  
  i := Pos (' ', zeile);
  If i = 0 Then
    disk_error ('bad vector format !');
  zahl := Copy (zeile, 0, i - 1);
  Val (zahl, Y, code);
  If code <> 0 Then
    disk_error ('bad vector format !');
  
  i := Length (zahl);
  zeile := Copy (Zeile, i + 2, Length (zeile) - i);
  Val (zeile, z, code);
  If code <> 0 Then
    disk_error ('bad vector format !');
  
  put_vektor (X, Y, z, v);
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure Str2Window (zeile: String; w: p_win);
Var
  code, i: Integer;
  zahl: String;
  xmin, ymin, xmax, ymax: Double;
Begin
  i := Pos (' ', zeile);
  If i = 0 Then
    disk_error ('bad window format !');
  zahl := Copy (zeile, 0, i - 1);
  Val (zahl, Xmin, code);
  If code <> 0 Then
    disk_error ('bad window format !');
  
  i := Length (zahl);
  zeile := Copy (Zeile, i + 2, Length (zeile) - i);
  
  i := Pos (' ', zeile);
  If i = 0 Then
    disk_error ('bad window format !');
  zahl := Copy (zeile, 0, i - 1);
  Val (zahl, Ymin, code);
  If code <> 0 Then
    disk_error ('bad window format !');
  
  i := Length (zahl);
  zeile := Copy (Zeile, i + 2, Length (zeile) - i);
  
  i := Pos (' ', zeile);
  If i = 0 Then
    disk_error ('bad window format !');
  zahl := Copy (zeile, 0, i - 1);
  Val (zahl, xmax, code);
  If code <> 0 Then
    disk_error ('bad window format !');
  
  i := Length (zahl);
  zeile := Copy (Zeile, i + 2, Length (zeile) - i);
  
  Val (zeile, ymax, code);
  If code <> 0 Then
    disk_error ('bad window format !');
  
  put_window (xmin, ymin, xmax, ymax, w);
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure load_scene (filename: String; v: p_view; ol, ll: p_oliste);
Var
  f: Text;
  zeile: String;
  i, j, k, Line: Integer;
  check: Array [1..num_cmd] Of Boolean;
  cmd_ok, fini: Boolean;
Begin
  zeile := '';
  Line := 0;
  fini := False;
  cmd_ok := False;
  
  Assign (f, filename);
  Reset (f);
  (*
  *       File-ID Check
  *)
  
  ReadLn (f, zeile); Inc (Line);
  
  If Not (zeile = file_id) Then
    disk_error ('File not a SITRA-SCENEFILE !');
  
  While Not EoF (f) Or fini Do
  Begin
    If (zeile [1] = '#') or cmd_ok Then
      For I := 1 To num_cmd Do
      Begin
        If zeile = command_s [i] Then
        Begin
          check [i] := True;
          cmd_ok := True;
        End Else Begin
          check [i] := False;
        End;

        If Not cmd_ok Then
          disk_error ('unknown command "' + zeile + '"');

      End else
      begin
        case
      end;
  End;
  
  If Not check [Ord (c_end) ] Then
    disk_error ('unexpectet end of file !');
End;
           (*=========================================*
           *                                         *
           *                                         *
           *                                         *
           *                                         *
           *                                         *
           *=========================================*)
Begin
End.
        