program deftest;
{$define test}
begin
     {$ifdef test}
     writeln('test');
     {$endif}
     {$ifndef test}
     writeln('nicht');
     {$endif}
end.