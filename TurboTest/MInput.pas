{$O-}
unit MInput;                       //  дата создания : октябрь 2002

interface

uses
  Windows,WinApp,OprTypes;

function Input(AParent:TWindow;var info:RInfo;b:boolean):boolean;

implementation

{$R 'RES\Input.Res'}

uses Macro,WinFunc,SysUtils,Streams,Messages,WinDlg,MConst,Classes,FNewTema;

const
  ColorDlg=$ADD2D5;
  pch1:PChar='Имеется';
  pch2:PChar='Отсутствует';

var date:array[0..20] of char;n:integer;boo:bool;col:string;
    tems:array[0..64] of string;temNum:integer;
    BB:boolean;

type
  TInputDlg=class(TDialog)
  private
    FInfo:PInfo;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

  TOptionsDlg=class(TDialog)
  private
    FParentDlg:TDialog;
    FInfo:PInfo;
    colorBack:COLORREF;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

function DateValid(Wnd:HWND;st:PChar):boolean;
begin
  Result:=false;
  try
    if Length(st)<8 then
    begin
      MessageBox(Wnd,'Неверная дата!','Turbo Test',0);
      Exit;
    end;
    if (StrToInt(st[0])>3) or ((st[0]='0') and (st[1]='0')) then
    begin
      MessageBox(Wnd,'Неправильное значение числа дней','Turbo Test',$10);
      Exit;
    end else
    if (StrToInt(st[3])>1)or((st[3]='0')and(st[4]='0'))or
        ((st[3]='1') and ( StrToInt(st[4])>2))
    then begin
      MessageBox(Wnd,'Неправильное значение числа месяцев','Turbo Test',$10);
      Exit;
    end
    else
    if StrToInt(st[6])<>0 then
    begin
      MessageBox(Wnd,'Слишком большой год','Ошибка',$10);
      Exit;
    end
  except
    MessageBox(Wnd,'Это не число!!!','Error',$10);
    Exit;
  end;
  if (st[2]<>'.') or (st[5]<>'.') then
  begin
    MessageBox(Wnd,'Неправильный формат разделителей','Ошибка',$10);
    Exit;
  end;
  Result:=true;
end;

{ TInputDlg }

function TInputDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(ColorDlg);
end;

function TInputDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(ColorDlg);
end;

function TInputDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
var
  TF:TTestFile;
  k:integer;
  pch:PChar;
  boolen:BOOL;
  st:string;
  ff:textFile;
  TH:THeader;
  TOD:TOptionsDlg;
begin
  Result:=0;
  case Msg of
    WM_COMMAND:
      if LOWORD(WParam)=107 then
      begin
        if HIWORD(WParam)=BN_CLICKED then
        begin
          DeleteFile(Path+'/'+OtchetFile);
          pch:=StrNew('Отсутствует');
          SendDlgItemMessage(Dlg,138,WM_SETTEXT,0,DWORD(pch));
          EnableWindow(GetDlgItem(Dlg,107),false);
        end;
      end else
      case Wparam of
        109:begin
              TOD:=TOptionsDlg.Create(Parent,96,DWORD(Self));
              TOD.ShowModal;
              TOD.Free;
            end;
        ID_OK:
          begin
{  Время}   n:=GetDlgItemInt(Dlg,103,boo,false);
            if (n=0) or (not boo)  then
            begin
              MessageBox(Dlg,'Время задано неправильно!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,103));
              Exit;
            end;

            if (n>=3600) then
            begin
              MessageBox(Dlg,'Слишком много времени на один вопрос!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,103));
              Exit;
            end;

            FInfo.tim:=n;

{ Кол-во}   n:=GetDlgItemInt(Dlg,102,boo,false);
            if not ((n>0) and (n<256) and boo) then
            begin
              MessageBox(Dlg,'Количество вопросов задано неверно!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,102));
              Exit;
            end;
            FInfo.colVopr:=n;

{ Data }    GetDlgItemText(Dlg,101,@date,9);
            if not DateValid(Dlg,@date) then
            begin
              Windows.SetFocus(GetDlgItem(Dlg,101));
              Exit;
            end;
            SetString(FInfo.date,date,8);
            FInfo.date:=date;

            FillChar(date,SizeOf(date),0);
            GetDlgItemText(Dlg,111,@date,7);       //группа
            SetString(st,date,StrLen(date));
            if st='' then
            begin
              MessageBox(Dlg,'Не указана группа!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,111));
              Exit;
            end;
            FInfo.gr:=st;

            GetDlgItemText(Dlg,112,@date,20);      //тема
            SetString(st,date,StrLen(date));
            if st='' then
            begin
              MessageBox(Dlg,'Не указана тема тестирования!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,112));
              Exit;
            end;
            FInfo.tema:=st;
                                        //  получим номер выбранной темы
{ файл }    n:=SendDlgItemMessage(Dlg,112,CB_GETCURSEL,0,0);
            Assign(ff,Path+'\file_tem.dat');
            try
              Reset(ff);
            except
              MessageBox(0,'Ошибка доступа к файлу FILE_TEM.DAT.','Turbo Test',0);
              Halt;
            end;
            k:=0;
            while not eof(ff) do
            begin
              Readln(ff,FInfo.fnt);
              inc(k);
              if k>n then Break
            end;
            Close(ff);
//  есть ли по этой теме столькo вoпросов?
            try
              TF:=TTestFile.Create(Path+'\'+FInfo.fnt);
            except
              On E:EXception do
              begin
                MessageBox(Dlg,PChar(E.Message),'Turbo Test',0);
                Exit;
              end;
            end;
            TH:=TF.GetHeader;
            if TH.nn<FInfo.colVopr then
            begin
              MessageBox(Dlg,PChar('По теме '+FInfo.tema+' имеется только '+
                IntToStr(TH.nn)+' вопрос'+GetAffix(TH.nn)+'.'),'Turbo Test',0);
              TF.Free;
              Exit;
            end;
            TF.Free;
            GetDlgItemText(Dlg,113,@date,25);//teacher
            SetString(st,date,StrLen(date));
            if st='' then
            begin
              MessageBox(Dlg,'Не указан преподаватель!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,113));
              Exit;
            end;
            FInfo.teacher:=st;

            n:=GetDlgItemInt(Dlg,104,boolen,false);
            if not (n in [1..100]) then
            begin
              MessageBox(Dlg,'Неправильные критерии выставления оценок!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,104));
              Exit;
            end;
            FInfo.j5:=n;

            n:=GetDlgItemInt(Dlg,105,boolen,false);
            if not (n in [1..FInfo.j5]) then
            begin
              MessageBox(Dlg,'Неправильные критерии выставления оценок!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,105));
              Exit;
            end;
            FInfo.j4:=n;

            n:=GetDlgItemInt(Dlg,106,boolen,false);
            if not (n in [1..FInfo.j4]) then
            begin
              MessageBox(Dlg,'Неправильные критерии выставления оценок!','Turbo Test',0);
              Windows.SetFocus(GetDlgItem(Dlg,106));
              Exit;
            end;
            FInfo.j3:=n;

            FInfo.eraseOtchetFile:=
              SendDlgItemMessage(Dlg,107,BM_GETCHECK,0,0)=BST_CHECKED;
            EndDialog(Dlg,ID_OK);
            // создаем временный файл с группами
            CopyFile(PChar(Path+'/'+FInfo.gr+'.grp'),PChar(Path+'/'+'temp.grp'),false);
            Exit;
          end;
        ID_CANCEL:
          begin
            EndDialog(Dlg,0);
            Exit;
          end;
      end;
  else
    Result:=inherited Dlgproc(Dlg,Msg,WParam,LParam)
  end;
end;

function Input(AParent:TWindow;var info:RInfo;b:boolean):boolean;
begin
  Result:=false;
  BB:=b;                           // true-учитывать параметр info
  with TInputDlg.Create(AParent,95,DWORD(@info)) do
  begin
    if ShowModal=ID_OK then Result:=true;
    Free;
  end;
end;

function TInputDlg.InitDialog(Dlg:HWND;Param:DWORD):boolean;
var
  pch:PChar;
  k:integer;
  st,stDate:string;
  Date:TDateTime;
  TSL:TStringList;
begin
  FInfo:=PInfo(Param);
  stDate:=DateToStr(GetCurrentDateTime);       //  получили текущую дату
  CenterWindow(Dlg);
  Result:=false;

  TSL:=TStringList.Create;
  try
    TSL.LoadFromFile(Path+'\teachers.dat');
  except
    MessageBox(0,'Ошибка доступа к файлу TEACHERS.DAT.','Turbo Test',0);
    Exit;
  end;
  for k:=0 to TSL.Count-1 do
  begin
    pch:=StrNew(PChar(TSL[k]));
    SendDlgItemMessage(Dlg,113,CB_ADDSTRING,0,DWORD(pch));
  end;

  try
    TSL.LoadFromFile(Path+'\gruppa.dat');
  except
    MessageBox(0,'Ошибка доступа к файлу GRUPPA.DAT.','Turbo Test',0);
    Exit;
  end;
  for k:=0 to TSL.Count-1 do
  begin
    pch:=StrNew(PChar(TSL[k]));
    SendDlgItemMessage(Dlg,111,CB_ADDSTRING,0,DWORD(pch));
  end;

  try
    TSL.LoadFromFile(Path+'\temas.dat');
  except
    MessageBox(Dlg,'Ошибка доступа к файлу TEMAS.DAT',nil,$10);
    Exit;
  end;
  for k:=0 to TSL.Count-1 do
  begin
    pch:=StrNew(PChar(TSL[k]));
    SendDlgItemMessage(Dlg,112,CB_ADDSTRING,0,DWORD(pch));
  end;

  SetWindowText(GetDlgItem(Dlg,101),PChar(stDate));
  SendDlgItemMessage(Dlg,101,EM_LIMITTEXT,8,0);
  Windows.SetFocus(GetDlgItem(Dlg,101)) ;

  col:=IntToStr(10);
  SetWindowText(GetDlgItem(Dlg,102),PChar(col));

  col:=IntToStr(120);                               //  время на обдумывание
  SetWindowText(GetDlgItem(Dlg,103),PChar(col));

  col:=IntToStr(85);                                //  критерий пятёрки
  SetWindowText(GetDlgItem(Dlg,104),PChar(col));

  col:=IntToStr(70);                                //  критерий четвёрки
  SetWindowText(GetDlgItem(Dlg,105),PChar(col));

  col:=IntToStr(50);                                //  критерий тройки
  SetWindowText(GetDlgItem(Dlg,106),PChar(col));

  if FileExists(Path+'\'+OtchetFile) then
    pch:=StrNew('Имеется') else
    begin
      pch:=StrNew('Отсутствует');
      EnableWindow(GetDlgItem(Dlg,107),false);
    end;
  SendDlgItemMessage(Dlg,138,WM_SETTEXT,0,DWORD(pch));

  if BB then                                    //  учитываем параметр info
  begin
    SendDlgItemMessage(Dlg,113,CB_SELECTSTRING,0,DWORD(PChar(FInfo.teacher)));
    SendDlgItemMessage(Dlg,111,CB_SELECTSTRING,0,DWORD(PChar(FInfo.gr)));
    SendDlgItemMessage(Dlg,112,CB_SELECTSTRING,0,DWORD(PChar(FInfo.tema)));
    SetDlgItemInt(Dlg,102,FInfo.colVopr,false);
    SetDlgItemInt(Dlg,104,FInfo.j5,false);
    SetDlgItemInt(Dlg,105,FInfo.j4,false);
    SetDlgItemInt(Dlg,106,FInfo.j3,false);
    SetDlgItemInt(Dlg,103,FInfo.tim,false);
  end;

  Result:=inherited InitDialog(Dlg,Param);
end;

{ TOptionsDlg }

function TOptionsDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(ColorDlg);
end;

function TOptionsDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(ColorDlg);
end;

function TOptionsDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_COMMAND:
      if LOWORD(WParam)=104 then
      begin
        if SendDlgItemMessage(Dlg,104,BM_GETCHECK,0,0)=BST_UNCHECKED then
        begin
          colorBack:=GetColor(Dlg,$FFFFFF);
          if colorBack=$FFFFFF then
            SendDlgItemMessage(Dlg,104,BM_SETCHECK,BST_CHECKED,0)
        end else colorBack:=$FFFFFF;
      end else
      case Wparam of
        ID_OK:
          begin
            FInfo.canList:=SendDlgItemMessage(Dlg,102,BM_GETCHECK,0,0)=BST_CHECKED;
            FInfo.showOC:=SendDlgItemMessage(Dlg,103,BM_GETCHECK,0,0)=BST_CHECKED;
            if SendDlgItemMessage(Dlg,104,BM_GETCHECK,0,0)=BST_CHECKED then
              FInfo.colorBack:=$FFFFFF;
            FInfo.addToOtchetFile:=
              SendDlgItemMessage(Dlg,105,BM_GETCHECK,0,0)=BST_CHECKED;
            FInfo.colorBack:=colorback;
            EndDialog(Dlg,ID_OK);
            Windows.SetFocus(FParentDlg.Handle)
          end;
        ID_CANCEL:
          begin
            EndDialog(Dlg,ID_OK);
            Windows.SetFocus(FParentDlg.Handle)
          end;
      end;
    else
      Result:=inherited DlgProc(Dlg,Msg,Wparam,LParam)
  end;
end;

function TOptionsDlg.InitDialog(Dlg: HWND; Param: DWORD): boolean;
begin
  CenterWindow(Dlg);
  FParentDlg:=TDialog(Param);
  FInfo:=TInputDlg(Param).FInfo;
  colorBack:=FInfo.colorBack;
  if BB then                       //  учитывать поле FInfo-смена задания 
  begin
    if FInfo.canList then
      SendDlgItemMessage(Dlg,102,BM_SETCHECK,BST_CHECKED,0);
    if FInfo.showOC then
      SendDlgItemMessage(Dlg,103,BM_SETCHECK,BST_CHECKED,0);
    if FInfo.colorBack=$FFFFFF then
      SendDlgItemMessage(Dlg,104,BM_SETCHECK,BST_CHECKED,0);
    if FInfo.addToOtchetFile then
      SendDlgItemMessage(Dlg,105,BM_SETCHECK,BST_CHECKED,0);
  end;
  Result:=inherited InitDialog(Dlg,Param)
end;

end.
