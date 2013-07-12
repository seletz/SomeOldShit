Unit rt_textures;
Interface
Uses rt_types, rt_lists, rt_math;
Const
  Black: RT_color = (r: 0; g: 0; b: 0);
  GRAU10: RT_color = (r: 0.1; g: 0.1; b: 0.1);
  GRAU30: RT_color = (r: 0.3; g: 0.3; b: 0.3);
  GRAU60: RT_color = (r: 0.6; g: 0.6; b: 0.6);
  GRAU50: RT_color = (r: 0.5; g: 0.5; b: 0.5);
  GRAU90: RT_color = (r: 0.9; g: 0.9; b: 0.9);
  White: RT_color = (r: 1; g: 1; b: 1);
  Red: RT_color = (r: 1; g: 0; b: 0);
  Red30: RT_color = (r: 1; g: 0.3; b: 0.3);
  Red60: RT_color = (r: 1; g: 0.6; b: 0.6);
  Green30: RT_color = (r: 0.3; g: 1; b: 0.3);
  Green60: RT_color = (r: 0.6; g: 1; b: 0.6);
  Green: RT_color = (r: 0; g: 1; b: 0);
  Blue30: RT_color = (r: 0.3; g: 0.3; b: 1);
  Blue60: RT_color = (r: 0.6; g: 0.6; b: 1);
  Blue: RT_color = (r: 0; g: 0; b: 1);
  Yellow: RT_color = (r: 1; g: 1; b: 0);
  Cyan: RT_color = (r: 0; g: 1; b: 1);
  MANGENTA: RT_color = (r: 1; g: 0; b: 1);
  
  NO_TEXTURE = 0;
  MARBLE_TEXTURE = 1;
  HELL_TEXTURE = 2;
  CLOUD_TEXTURE = 3;
  
  
Type
  rt_mat_p = ^rt_mat;
  rt_mat = Object (rt_obase)
             mat_name: String;
             ka, kd, ks: Double;
             Color: RT_color;
             specular_color: RT_color;
             phong_value: Double;
             ior: Double;
             reflection_value, refraction_value: Double;
             texture: Integer;
             Constructor init (c1, c2: RT_color; k1, k2, k3, p, refl, refr, iior: Double; itext: Integer; imatname: String);
           End;
  rt_mlist = Object (rt_list)
               Function get_mat: rt_mat_p;
               Function getbyname (Name: String): rt_mat_p;
               Procedure Insert (insnode: rt_mat_p);
             End;

Procedure init_std_text (Var mlist: rt_mlist);
Implementation
Uses rt_noisef;
{



        material_OBJEKT



}
Constructor rt_mat. init;
Begin
  Color := c1;
  specular_color := c2;
  ka := k1; kd := k2; ks := k3; phong_value := p;
  refraction_value := refr;
  reflection_value := refl;
  ior := iior;
  texture := itext;
  MAT_name := imatname;
End;
Function rt_mlist. get_mat: rt_mat_p;
Begin
  get_mat := rt_mat_p (rt_list. get);
End;
Function rt_mlist. getbyname (Name: String): rt_mat_p;
Var i: LongInt;
  found: Boolean;
Begin
  setfirst;
  Write ('Suche: ' + Name + '...');
  i := 0;
  found := False;
  While (get_mat^. mat_name <> Name) And (i <= Length) Do
  Begin
    Inc (i);
    rt_list. next;
    found := True
  End;
  found := get_mat^. mat_name = Name;
  If found Then WriteLn ('Gefunden:' + get_mat^. mat_name);
  If found Then getbyname := get_mat Else getbyname := Nil;
  If Not found Then doerror ('Material nicht gefunden:' + Name);
  setfirst;
End;
Procedure rt_mlist. Insert;
Begin
  rt_list. Insert (insnode);
End;

Procedure init_std_text;
Begin
  { materialien }
  
  
  mlist. Insert (New (rt_mat_p, init (            Red30, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.45,       { kd}
  0.5,     { ks    }
  1000,     { phong    }
  0.9,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , HELL_TEXTURE,
  'rot2') )
  );
  mlist. Insert (New (rt_mat_p, init (            Red30, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.45,       { kd}
  0.5,     { ks    }
  6,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , no_TEXTURE,
  'rot matt') )
  );
  mlist. Insert (New (rt_mat_p, init (            green30, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.45,       { kd}
  0.5,     { ks    }
  6,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , no_TEXTURE,
  'grn matt') )
  );
  mlist. Insert (New (rt_mat_p, init (            blue30, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.45,       { kd}
  0.5,     { ks    }
  6,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , no_TEXTURE,
  'blau matt') )
  );
  mlist. Insert (New (rt_mat_p, init (            Blue60, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.75,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'blau sp') )
  );
  mlist. Insert (New (rt_mat_p, init (            Green60, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.75,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'grn sp') )
  );
  mlist. Insert (New (rt_mat_p, init (            grau90, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  1.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'sp') )
  );
  mlist. Insert (New (rt_mat_p, init (            grau90, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.0,     { sp    }
  1.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'tr') )
  );
  mlist. Insert (New (rt_mat_p, init (            grau90, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.5,     { sp    }
  0.5,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'sp+tr') )
  );
  mlist. Insert (New (rt_mat_p, init (            Cyan, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'cyan matt') )
  );
  mlist. Insert (New (rt_mat_p, init (            mangenta, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  1.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , NO_TEXTURE,
  'mangenta matt') )
  );
  mlist. Insert (New (rt_mat_p, init (            Blue60, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.2,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , cloud_TEXTURE,
  'wolken') )
  );
  mlist. Insert (New (rt_mat_p, init (            Blue60, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.3,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , hell_TEXTURE,
  'hell') )
  );
  mlist. Insert (New (rt_mat_p, init (            Blue60, { color }
  GRAU30,   { specc }
  0.1,       { ka}
  0.4,       { kd}
  0.9,     { ks    }
  100,     { phong    }
  0.0,     { sp    }
  0.0,    { tr }
  1.5        { ior   }
  , marble_TEXTURE,
  'marble') )
  );
  
  
End;

Begin
End.