procedure TEdit1.ShiftChars(a1,a2:byte);    {сдвигает строку в chars на один}
var                                         {символ : при а2>a1 - вправо    }
  k:byte;                                   {         при a2<a1 - влево     }
                                            {при сдвиге позиция chars[y,a1] }
                                            {становится пустой              }
begin
  if a1<a2 then for k:=a2 downto a1 do      {сдвиг вправо  }
     chars[y,k]:=chars[y,k-1]
     else
  for k:=a2 to a1 do                        {сдвиг влево}
      chars[y,k]:=chars[y,k+1];
   chars[y,a1]:=sym32;                      {уничтожение начальной позиции}
end;
