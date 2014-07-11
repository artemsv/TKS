uses Stream,Objects,new1;
const
  z=0;
var
  k:byte;
  S:PStream;
  st:string;
  w:PChar;
  TT:TTestFile;
  BL:PBlock;
  col:PCollection;
  Hd:PHdr;
begin
{  if z=0 then  begin if not OpenStream('vrt.tem',S,stOpen) then Halt end
   else if not OpenStream('www.pas',S,stCreate) then Halt;
 }
 RegisterStreams;
 Hd:=New(Phdr,Init(0,3,0,0,'Тема номер 1','fileXXXX.tem','qwerty'));
 TT.Init('in2.tem',stOpen,nil);

 if z=1 then
   for k:=1 to 3 do begin
     BL:=TT.InvalidBlock;
     BL^.num:=k;
     TT.PutBlock(BL);
   end
 else
   begin
     col:=TT.GetAllBlocks;
     BL:=PBlock(col^.At(7));

   end;
 TT.Done;

end.