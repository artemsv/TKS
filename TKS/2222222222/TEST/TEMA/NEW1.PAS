unit new1;

interface

uses Objects,Dos;

function OpenStream(fileName:PathStr;var S:PStream;mode:word):boolean;
procedure WriteHexWord(w: Word);

implementation

procedure WriteHexWord(w: Word);
const
  hexChars: array [0..$F] of Char =
    '0123456789ABCDEF';
begin
  Write(hexChars[Hi(w) shr 4],
        hexChars[Hi(w) and $F],
        hexChars[Lo(w) shr 4],
        hexChars[Lo(w) and $F]);
end;

function OpenStream(fileName:PathStr;var S:PStream;mode:word):boolean;
begin
  OpenStream:=false;
  S:=New(PDosStream,Init(fileName,mode));
  if S^.status<>stOk then Exit;
  OpenStream:=true
end;

end.
