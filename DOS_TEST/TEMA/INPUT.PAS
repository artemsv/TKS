program Input;          {дата создания окончательной версии 4.67: XX.03.02}

uses
  {MOpros,}App{,MyLib};
{
type
  aap=object(TApplication)
    procedure Run;virtual;
  end;

var
  info:RInfo;

procedure aap.run;
begin
  Inp(info);
end;
 }
var
  A:Appliocation{aap};
begin
  a.init;
  a.run;
  a.done;
end.