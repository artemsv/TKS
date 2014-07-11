unit MakeFont;                          {дата создания модуля: 26.10.01}
                                        {дата обновления     : 01.12.01}
interface

uses
  App,Objects,Views,Medit0,Types,Drivers,
  Menus,MsgBoxMy,MyFunc,MyLib,MHelp1;

var
  st:string;

type
  PFontWindow=^TFontWindow;
  TFontWindow=object(TWindow)
    constructor Init;
    procedure HandleEvent(var Event:TEvent);virtual;
  end;

type
  PFontDialog=^TFontDialog;
  TFontDialog=object(TEdit0)
    mTableDim:tmTableDim;
    mcharDim :tmCharDim;                  {текущий символ}
    current:byte;                         {код текущего символа ASCII}
    constructor Init(R:TRect);
    procedure Inter;                      {}
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure InitChars;
    procedure Change;
    procedure CreatefontFile;
  end;

implementation

const
  mEtalon:array[0..7] of byte=(128,64,32,16,8,4,2,1);

constructor TFontWindow.Init;
var
  FontEdit:PFontDialog;
  R:TRect;
begin
  R.Assign(10,4,70,22);
  TWindow.Init(R,'Создание шрифтов',0);
  GetClipRect(R);
  R.Grow(-1,-1);
  FontEdit:=New(PFontDialog,Init(R));
  if FontEdit=nil then
    begin
      ChDir(path+'TEMA\');
      Fail;
    end;
  Insert(FontEdit)
end;

procedure TFontWindow.HandleEvent;
begin
  if (Event.What=evCommand) and (Event.Command=cmClose) then
    EndModal(cmClose);
  ChDir(path);
  Inherited HandleEvent(Event);
end;

constructor TFontDialog.Init;
var
  st:string;
  n:integer;
  p:pointer;
  f:file of byte;
  k,j:byte;
  PW:PWindow;
begin
  inherited Init(R);
  {$I-}
  ChDir(path+'TEMA\FONT');
  {$I+}
  if IOResult<>0 then begin
    MessageBox(#3'Не обнаружен каталог FONT!',nil,mfOkButton);
    Fail;
  end;
  p:=GetFilesList(path+'TEMA\FONT\*.fnt');
  if p=nil then Fail;
  if ListDialog(p,'Выберите изменяемый шрифт',st,n,hcFont) = cmCancel then Fail;
  Assign(f,st);
  {$I-}
  Reset(f);
  {$I+}
  if (IOResult<>0) or (FileSize(f)<>4096) then
  begin
    Messagebox(#3'Ошибка чтения файла '+st+#13+#13+#3'или неверный формат.',
     nil,mfOkButton);
     Fail;
  end;
  DiskReadWriteMsg('Идет загрузка файла шрифтов!');
  for k:=0 to 255 do
    for j:=0 to 15 do
      Read(f,mTableDim[k,j]);
  Close(f);
  current:=128;
  mCharDim:=mTableDim[current];
  HideCursor;
  InitChars;
  Inter;
  Draw;
end;

procedure TFontDialog.Inter;
var
  k,j,summa:byte;
begin
  for k:=0 to 15 do
  begin
    summa:=0;
    for j:=0 to 7 do
    begin
      Inc(summa,mEtalon[j]);
      if mCharDim[k]-summa<0 then
      begin
        chars[k,j]:=sym+176;
        Dec(summa,mEtalon[j])
      end else
        chars[k,j]:=sym+219
    end;
  end;
  st:=Sstr(current);
  for k:=48 to 54 do chars[13,k]:=sym32;
  for k:=48 to 47+Length(st) do chars[13,k]:=sym+Ord(st[k-47]);
end;

procedure TFontDialog.HandleEvent;
var
  R:TPoint;
begin
  case Event.What of
    evMouseDown:
      begin
        MakeLocal(MouseWhere,R);
        if R.x<9 then
          if chars[R.y,R.x]=sym+219 then chars[R.y,R.x]:=sym+176
          else chars[R.y,R.x]:=sym+219
      end;
    evKeyDown:
      case Event.KeyCode of
        kbAltA:ShowCursor;
        kbAltS:HideCursor;
        kbAltT:InitChars;
        kbAltZ:CreateFontFile;
        kbEnter:Change;
        kbEsc  :begin Event.what:=evCommand;Event.Command:=cmClose;
                      ChDir(path+'\TEMA');PutEvent(Event);end;
        kbPgUp  :begin
                   Dec(current);
                   if current=0 then current:=255;
                   mCharDim:=mTableDim[current];
                   Inter;end;
        kbSpace :if chars[cursor.y,cursor.x]=sym+219 then
                  chars[cursor.y,cursor.x]:=sym+176 else
                  chars[cursor.y,cursor.x]:=sym+219;
        kbPgDn  :begin
                   Inc(current);
                   if current=256 then current:=1;
                   mCharDim:=mTableDim[current];
                   Inter;end;
        kbDown  :if cursor.y<15 then SetCursor(Cursor.x,cursor.y+1);
        kbLeft  :if cursor.x>0 then SetCursor(Cursor.x-1,cursor.y);
        kbUp    :if cursor.y>0 then SetCursor(Cursor.x,cursor.y-1);
        kbRight :if cursor.x<7 then SetCursor(Cursor.x+1,cursor.y);
      end;
  end;
  Draw;
  ClearEvent(Event);
end;

procedure TFontDialog.InitChars;
var
  k,j:byte;
const
  syZ=256*$1A;
begin
  for k:=0 to 15 do for j:=0 to 7 do chars[k,j]:=sym+176;
  st:='Enter-замена';for k:=35 to 46 do chars[1,k]:=syZ+Ord(st[k-34]);
  st:='AltA-показать курсор';for k:=35 to 54 do chars[3,k]:=syZ+Ord(st[k-34]);
  st:='AltS-спрятать курсор';for k:=35 to 54 do chars[5,k]:=syZ+Ord(st[k-34]);
  st:='Пробел-вкл/выкл точку';for k:=35 to 55 do chars[7,k]:=syZ+Ord(st[k-34]);
  st:='AltT-очистить все';for k:=35 to 51 do chars[9,k]:=syZ+Ord(st[k-34]);
  st:='AltZ-создать файл';for k:=35 to 51 do chars[11,k]:=syZ+Ord(st[k-34]);
  st:='ASCII-символ:';for k:=35 to 47 do chars[13,k]:=syZ+Ord(st[k-34]);
  st:='PgUp,PgDown-просмотр';for k:=35 to 54 do chars[15,k]:=syZ+Ord(st[k-34]);
end;

procedure TFontdialog.Change;
var
  k,j,summa:byte;
begin
  for k:=0 to 15 do begin
    summa:=0;
    for j:=0 to 7 do
      if chars[k,j]=sym+219 then Inc(summa,mEtalon[j]);
    mCharDim[k]:=summa;
  end;
  mTableDim[current]:=mcharDim
end;

procedure TFontDialog.CreateFontFile;
var
  fb:file of byte;
  k,j:byte;
begin
  ChDir('\TEST\TEMA\FONT');
  repeat
    if InputBox('','Введите расширение для файла шрифтов:',st,3,0)=cmCancel
      then Exit;
    if not Verify('font.'+st,GetCurDir) then Break else
    if MessageBox(#3'Такой файл уже есть.Заменить?'+GetCurDir,nil,mfNoButton)=cmYes
        then Break
  until false;
  ChDir('\TEST\TEMA\FONT');
  Assign(fb,'font.'+st);
  Rewrite(fb);
  for k:=0 to 255 do
    for j:=0 to 15 do
      Write(fb,mTableDim[k,j]);
  Close(fb);
  ChDir('\TEST\TEMA');
end;

end.
