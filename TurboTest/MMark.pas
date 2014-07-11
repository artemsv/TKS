unit MMark;

interface

uses Windows,WinFunc,WinDlg,WinApp,SysUtils,Messages;

//  показывает окно с оценкой

procedure ShowOC(AParent:TWindow;oc,colVopr,FPrav,Total:integer;ABadStr:string);

implementation

var
  hour,min,sec,FOc,FColVopr,Prav,FTotal:integer;BadStr:string;

type
  TOcDlg=class(TDialog)
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    procedure DoPaint;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

procedure ShowOC(AParent:TWindow;oc,colVopr,FPrav,Total:integer;ABadstr:string);
var
  TOD:TOcDlg;
begin
  Foc:=oc;
  FColVopr:=colVopr;
  Prav:=FPrav;
  FTotal:=Total;
  badstr:=ABadStr;
  hour:=Total div 3600;
  Total:=Total mod 3600;
  min:=Total div 60;
  sec:=Total mod 60;
  TOD:=TOcDlg.Create(Aparent,1092,0);
  TOD.SHowModal;
  TOD.Free
end;

{ TOcDlg }

function TOcDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_COMMAND,WM_SYSKEYDOWN,WM_SYSCHAR,WM_CHAR,WM_KEYDOWN,WM_LBUTTONDOWN:
      EndDialog(Dlg,0);
    WM_RBUTTONDOWN:
      begin
        MessageBox(Dlg,PChar('Предложено вопросов: '+IntToStr(FColVopr)+#13+
        'Правильных ответов:  '+IntToStr(Prav)+#13+
        'Номера вопросов с неверными ответами: '+#13+#13+badStr+#13+#13+
        'На обдумывание затрачено'#13+'часов: '+IntToStr(hour)+#13+
        'минут: '+IntToStr(min)+#13+'секунд:'+IntToStr(sec)),'Статистика',0);
        EndDialog(Dlg,0);
      end;
  else
    Result:=inherited DlgProc(Dlg,Msg,Wparam,LParam)
  end;

end;

procedure TOcDlg.DoPaint;
var DC:HDC;R:TRect;Brush:HBRUSH;lf:TLogFont;f:HFONT;
begin
  DC:=GetDC(Handle);
  SetBkMode(DC,TRANSPARENT);

  GetWindowRect(Handle,R);                //  заполнили окно
  Brush:=CreateSolidBrush($9490B3);
  SelectObject(DC,Brush);
  Rectangle(DC,-1,-1,R.Right,R.Bottom);
  DeleteObject(Brush);

  FillChar(lf,SizeOf(lf),0);lf.lfItalic:=0;
  lf.lfStrikeOut:=0;lf.lfUnderline:=0;
  lf.lfHeight:=22;lf.lfWidth:=10;lf.lfFaceName:='Ms Sans Serif';
  lf.lfWeight:=700;f:=CreateFontIndirect(LF);SelectObject(DC,f);
  TextOut(DC,120,10,'Ваша оценка',11);
  lf.lfHeight:=16;lf.lfWidth:=7;lf.lfWeight:=400;
  f:=CreateFontIndirect(LF);SelectObject(DC,f);

  //  TextOut(DC,30,154,'Для получения дополнительной информации ',40);
  //  TextOut(DC,34,170,'щёлкните правой кнопкой мыши в этом окне',40);

  FillChar(lf,SizeOf(lf),0);lf.lfItalic:=0;
  lf.lfStrikeOut:=0;lf.lfUnderline:=0;
  lf.lfHeight:=152;lf.lfWidth:=50;lf.lfFaceName:='Courier';
  lf.lfWeight:=700;f:=CreateFontIndirect(LF);SelectObject(DC,f);
  TextOut(DC,150,30,PChar(IntToStr(FOc)),1);
  DeleteObject(f);
  ReleaseDC(Handle,DC);
end;

function TOcDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
begin
  CenterWindow(Dlg);
  Result:=inherited InitDialog(Dlg,Param);
end;

end.
