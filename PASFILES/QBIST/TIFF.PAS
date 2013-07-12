Program tiff_save;
Uses crt;
Const
  tag_imagewidth: Word				 = $0100;
  tag_imagelength: Word			 = $0101;
  tag_samplesperpixel: Word	 = $0115;
  tag_bitspersample: Word		 = $0102;
  tag_minsamplevalue: Word		 = $0118;
  tag_maxsamplevalue: Word		 = $0119;
  tag_photometricinterpretation: Word		 = $0106;
  tag_compression: Word			 = $0103;
  tag_stripoffsets: Word			 = 	$0111;
  
  type_byte: Byte						 = $01;
  type_ascii: Byte						 = $02;
  type_short: Byte						 = $03;
  type_long: Byte						 = $04;
  type_rational: Byte				 = $05;
  
Type
  tiff_header = Record
                  byte_order_a, byte_order_b: Char;
                  version: Word;
                  first_ifd_p: LongInt;
                End;
  
  tag = Record
          tag_type: Word;
          data_type: Byte;
          data_length: LongInt;
          data_value: LongInt;
        End;
  
  tiff_rgb = Record
               header: tiff_header;
               num_tags: Word;
               image_width,
               image_length,
               samples_per_pixel,
               bits_per_sample,
               min_sample_value,
               max_sample_value,
               photometric_interpretation,
               compression,
               strip_offset: tag;
               termination: LongInt; { ist null da kein weiterer IFD  }
             End;
Var
  tiff: tiff_rgb;
Procedure build_tiff ( breite, hoehe: Word);
Begin
  With tiff Do
  Begin
    With header Do
    Begin
      byte_order_a := 'I'; byte_order_b := 'I'; { INTEL Byte Order }
      version := $002a;
      first_ifd_p := SizeOf (header); { erstes IFD nach header }
    End;
    num_tags := 9;
    With image_width Do
    Begin
      tag_type := tag_imagewidth;
      data_type := type_short;
      data_length := 1;
      data_value := breite;
    End;
    With image_length Do
    Begin
      tag_type := tag_imagelength;
      data_type := type_short;
      data_length := 1;
      data_value := hoehe;
    End;
    With samples_per_pixel Do
    Begin
      tag_type := tag_samplesperpixel;
      data_type := type_short;
      data_length := 1;
      data_value := 3; { 3 farbteile pro pixel }
    End;
    With bits_per_sample Do
    Begin
      tag_type := tag_bitspersample;
      data_type := type_short;
      data_length := 1;
      data_value := 8; { 8 Bit pro farbteil }
    End;
    With min_sample_value Do
    Begin
      tag_type := tag_minsamplevalue;
      data_type := type_short;
      data_length := 1;
      data_value := $00; { $00 -> keine intensitaet }
    End;
    With max_sample_value Do
    Begin
      tag_type := tag_maxsamplevalue;
      data_type := type_short;
      data_length := 1;
      data_value := $ff; { $ff -> volle intensitaet }
    End;
    With photometric_interpretation Do
    Begin
      tag_type := tag_photometricinterpretation;
      data_type := type_short;
      data_length := 1;
      data_value := 2; { RGB }
    End;
    With compression Do
    Begin
      tag_type := tag_compression;
      data_type := type_short;
      data_length := 1;
      data_value := 1; { uncompressed }
    End;
    With strip_offset Do
    Begin
      tag_type := tag_imagewidth;
      data_type := type_long;
      data_length := - 1;
      data_value := SizeOf (tiff); { bilddaten nach tiff_record }
    End;
    termination := $00000000; { kein weiterer IFD }
  End
End;
Procedure write_tiff_header ( fn: String);
Var
  ft: File Of tiff_rgb;
Begin
  Assign (ft, fn);
  Rewrite (ft);
  Write (ft, tiff);
  Close (ft);
End;
Procedure write_test_tiff ( breite, hoehe: Word; fn:string);
Var
  X, Y: Word;
  r,g,b:byte;
  f: Text;
Begin
  Assign (f, fn );
  Append (f);
  For Y := 0 To hoehe - 1 Do
    For X := 0 To breite - 1 Do
    Begin
      r:=round( 255* (y/hoehe) );
      g:=round( 255* (x/breite) );
      b:=128;

      write(f, chr(r), chr(g), chr(b) );
    End;
  Close (f);
End;
Begin
  build_tiff (320, 200);
  write_tiff_header ( 'test.tif' );
  write_test_tiff (320, 200, 'test.tif');
End.