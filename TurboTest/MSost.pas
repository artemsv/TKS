{$O-}
unit MSost;                              //  Дата создания : 06.11.02.

interface

uses Windows,WinApp,MRed,Main,UOleRTF;

type
  TSost=class(TRed)
  private
    FCount:integer;                      //  номер текущего блока
    Frame:TFrame;                        //  текущий составляемый кадр
    procedure WriteInvite(Invite:PCHar); //  приглашение в строке статуса
    procedure Block;                     //  реакция на нажатие kbBlock
    procedure NewFrame;                  //  создает новый кадр
  protected
    function CloseQuery:boolean;override;
    procedure DoSetFocus(WParam:DWORD);override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
    function Init:boolean;override;
  public
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient;FileName:PChar);override;
  end;

implementation

uses MConst,SysUtils,RichEDit,Messages,CommCtrl;

{ TSost }

procedure TSost.Block;
var
  m:integer;
  oldCF,CF:TCharFormat;
begin
  if FCount=Header.d+1 then NewFrame           //  если введен правильный ответ
  else begin
    RTF.SetSel(RTF.GetTextLen,RTF.GetTextLen); //курсор-в конец текста
    if FCount=0 then                           //  если был введен сам вопрос
    begin
      if RTF.Text='' then Exit;                //  если в вопросе нет символов
      RTF.AddSplitter
    end else                                   //  добавляем раздел.линию
      RTF.Perform(WM_CHAR,13,0);               //  имитация нажатия Enter
    m:=RTF.GetCurCaretX;
    RTF.Perform(WM_CHAR,49+FCount,0);          //  номер ответа
    RTF.Perform(WM_CHAR,46,0);                 //  точка
    RTF.GetCharFormat(true,oldCF);
    CF:=oldCF;
    CF.szFaceName:='System';
    CF.dwEffects:=CF.dwEffects and not CFE_AUTOCOLOR;
    CF.crTextColor:=COLOR_NUM_PASSIVE;
    CF.dwMask:=CF.dwMask or CFM_COLOR or CFM_FACE;
    RTF.SetSel(m,m+2);                       //  выделяем номер с точкой
    RTF.SetCharFormat(SCF_SELECTION,CF);     //  формат номеров ответов
    RTF.SetSel(m+2,m+2);
    RTF.SetCharFormat(SCF_SELECTION,oldCF);  //  восст. старый формат
    Inc(Fcount);                             //  инкремент счетчика блоков
    Frame.Nums[FCount]:=RTF.GetCount-1;      //  количество линий в блоке
    if FCount=Header.d+1 then WriteInvite('Введите правильный ответ')else
    WriteInvite(PChar(('Введите '+IntToStr(FCount)+'-й неправильный ответ')));
  end;
end;

constructor TSost.Create(AParent:TMDIWindow;AClient:TMDIClient;FileName: PChar);
var
  CF:TCharFormat;
begin
  inherited;
  if Header.nn=Header.ckolko then
    raise Exception.Create('       Введены все вопросы!       ');
  FCount:=0;
  WriteInvite('Введите вопрос');
  NumFrame:=Header.nn+1;          // текущий кадр - сследующий после посл.
  TMyMDI(Parent).StatusBar.SetText(3,PChar('Вопрос '+IntToStr(NumFrame)));
  Frame:=TFrame.Create;           //  создаем новый(пустой) кадр
  RTF.SetFrame(Frame);            //  устанавливаем его в редактор
  RTF.SetSel(0,0);
  FillChar(CF,SizeOf(TCharFormat),0);
  CF.cbSize:=SizeOf(TCharFormat);
  CF.dwMask:=CFM_FACE or CFM_COLOR or CFM_SIZE;
  CF.yHeight:=200;
  CF.szFaceName:='System';
  CF.crTextColor:=$000000;
  RTF.SetCharFormat(SCF_SELECTION,CF);            //  шрифт нового вопроса
end;

function TSost.CloseQuery: boolean;
begin
  Result:=false;
  case MessageBox(Handle,'В тему были внесены изменения.Сохранить?','Turbo Test',
      MB_ICONWARNING or MB_YESNOCANCEL) of
    ID_CANCEL:Exit;
    ID_YES:SaveTema;
  end;
  Result:=true;
end;

function TSost.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
  case WParam of
    CM_DOWN,CM_UP:Exit;           //  нет реакции на PgUp-PgDown
    DOM_BLOCK:Block;              //  окончание составления блока
    DOM_CANSELECTALL:Result:=1;   //  нельзя выделить все
  else
    Result:=inherited DoCommand(WParam,LParam);
  end;
end;

procedure TSost.DoSetFocus(WParam:DWORD);
begin
  inherited;
  if FCount=0 then WriteInvite('Введите вопрос') else
    if FCount<Header.d then
      WriteInvite(PChar('Введите '+IntToStr(FCount)+' неправильный ответ'))
    else
      WriteInvite('Введите правильный ответ');
end;

function TSost.Init: boolean;
begin
  Result:=false;
  if not LoadTema then Exit;;
  Result:=true;
end;

procedure TSost.NewFrame;
var
  KL:HKL;
begin
  KL:=GetKeyBoardLayout(0);       //  запоминаем текущую ракладку
  FModified:=true;
  RTF.UpdateFrame;                //  утверждаем изменения в текущем кадре
  Frames.Add(Frame);              //  доб. в список измененный кадр
  Frame:=TFrame.Create;           //  создаем новый(пустой) кадр
  RTF.SetFrame(Frame);            //  устанавливаем его
  Inc(NumFrame);                  //  номер текущего кадра
  Header.nn:=Header.nn+1;         //  считаем кол-во введенных кадров
  TMyMDI(Parent).StatusBar.SetText(3,PChar('Вопрос '+IntToStr(NumFrame)));
  WriteInvite('Введите вопрос');
  FCount:=0;                      //  Ткущий блок-вопрос
  if NumFrame>Header.ckolko then  //  если введены все кадры
  begin
    MessageBox(Handle,'          Ввод окончен!          ','Turbo Test ',0);
    SaveTema;
    Free
  end;
  ActivateKeyBoardLayout(KL,0);       //  восстанавливаем раскладку пред.
end;

procedure TSost.WriteInvite(Invite:PChar);
begin
  TMyMDI(Parent).StatusBar.SetText(2,PChar(invite));
end;

end.
