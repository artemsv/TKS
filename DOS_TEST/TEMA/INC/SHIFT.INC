procedure TEdit1.ShiftChars(a1,a2:byte);    {ᤢ����� ��ப� � chars �� ����}
var                                         {ᨬ��� : �� �2>a1 - ��ࠢ�    }
  k:byte;                                   {         �� a2<a1 - �����     }
                                            {�� ᤢ��� ������ chars[y,a1] }
                                            {�⠭������ ���⮩              }
begin
  if a1<a2 then for k:=a2 downto a1 do      {ᤢ�� ��ࠢ�  }
     chars[y,k]:=chars[y,k-1]
     else
  for k:=a2 to a1 do                        {ᤢ�� �����}
      chars[y,k]:=chars[y,k+1];
   chars[y,a1]:=sym32;                      {㭨�⮦���� ��砫쭮� ����樨}
end;
