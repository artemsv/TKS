unit UFiltfRec;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Mask;

type
  TFrmFiltrRec = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button2: TButton;
    CBoxTema: TComboBox;
    CBoxGruppa: TComboBox;
    CBoxTeacher: TComboBox;
    GroupBox2: TGroupBox;
    CBOc: TCheckBox;
    CBDate: TCheckBox;
    CBTema: TCheckBox;
    CBGruppa: TCheckBox;
    CBname: TCheckBox;
    CBTeacher: TCheckBox;
    EDate1: TMaskEdit;
    Label7: TLabel;
    ETime1: TMaskEdit;
    CBoxName: TComboBox;
    CBTime: TCheckBox;
    Label8: TLabel;
    EDate2: TMaskEdit;
    Label10: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    ETime2: TMaskEdit;
    CBNeprav: TCheckBox;
    Label12: TLabel;
    ENeprav: TEdit;
    CBFindNOT: TCheckBox;
    EOc: TEdit;
    CBBegin: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure CBOcClick(Sender: TObject);
    procedure CBnameClick(Sender: TObject);
    procedure CBDateClick(Sender: TObject);
    procedure CBTemaClick(Sender: TObject);
    procedure CBGruppaClick(Sender: TObject);
    procedure CBTeacherClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CBTimeClick(Sender: TObject);
    procedure CBNepravClick(Sender: TObject);
    procedure CBoxNameDblClick(Sender: TObject);
    procedure CBoxNameClick(Sender: TObject);
  public
    badSet:set of byte;
  end;

var
  FrmFiltrRec: TFrmFiltrRec;
  kod:boolean;

implementation

{$R *.DFM}

procedure TFrmFiltrRec.FormCreate(Sender: TObject);
begin
  CBoxTema.Items.LoadFromFile('temas.dat');
  CBoxGruppa.Items.LoadFromFile('gruppa.dat');
  CBoxName.Items.LoadFromFile('gruppa.dat');
  CBoxTeacher.Items.LoadFromFile('teachers.dat');
  CBoxTema.Enabled:=false;
  CBoxGruppa.Enabled:=false;
  CBoxTeacher.Enabled:=false;
  CBoxName.Enabled:=false;
  CBBegin.Checked:=true;
  CBBegin.Enabled:=false;
  ENeprav.Enabled:=false;
  EDate1.Enabled:=false;
  EDate2.Enabled:=false;
  ETime1.Enabled:=false;
  ETime2.Enabled:=false;
  EOc.Enabled:=false;
end;

procedure TFrmFiltrRec.CBOcClick(Sender: TObject);
begin
  if CBOc.Checked then
  begin
    EOc.Enabled:=true;
    EOc.SetFocus;
  end else EOc.Enabled:=false;
end;

procedure TFrmFiltrRec.CBnameClick(Sender: TObject);
begin
  if CBName.Checked then
  begin
    CBoxName.Enabled:=true;
    CBoxName.SetFocus;
    CBBegin.Enabled:=true;
  end else
  begin
    CBoxName.Enabled:=false;
    CBBegin.Enabled:=false;
  end;
end;

procedure TFrmFiltrRec.CBDateClick(Sender: TObject);
begin
  if CBDate.Checked then
  begin
    EDate1.Enabled:=true;
    EDate2.Enabled:=true;
    EDate1.SetFocus;
  end else
  begin
    EDate1.Enabled:=false;
    EDate2.Enabled:=false;
  end;
end;

procedure TFrmFiltrRec.CBTemaClick(Sender: TObject);
begin
  if CBTema.Checked then
  begin
    CBoxTema.Enabled:=true;
    CBoxTema.SetFocus;
  end else CBoxTema.Enabled:=false;
end;

procedure TFrmFiltrRec.CBGruppaClick(Sender: TObject);
begin
  if CBGruppa.Checked then
  begin
    CBoxGruppa.Enabled:=true;
    CboxGruppa.SetFocus;
  end else
  begin
    CBoxGruppa.Enabled:=false;
    CBoxName.Items.Clear;
  end;
end;

procedure TFrmFiltrRec.CBTeacherClick(Sender: TObject);
begin
  if CBTeacher.Checked then
  begin
    CBoxTeacher.Enabled:=true;
    CBoxTeacher.SetFocus;
  end else CBoxTeacher.Enabled:=false;
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
    if (StrToInt(st[0])>3) or ((st[0]='0') and (st[1]='0')) then begin
      MessageBox(Wnd,'Такого дня нет','Turbo Test',$10);Exit;
    end else
    if (StrToInt(st[3])>1)or((st[3]='0')and(st[4]='0'))or(StrToInt(st[4])>2)
    then begin
      MessageBox(Wnd,'Такого дня нет','Turbo Test',$10);
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
  Result:=true;
end;

function TimeValid(Wnd:HWND;st:PChar):boolean;
begin
  Result:=false;
    if Length(st)<8 then
    begin
      MessageBox(Wnd,'Неверное время!','Turbo Test',MB_ICONERROR);
      Exit;
    end;
    if (StrToInt(st[3])>5)
    then begin
      MessageBox(Wnd,'Неправильное число минут.','Turbo Test',MB_ICONERROR);
      Exit;
    end;
    if StrToInt(st[6])>5 then
    begin
      MessageBox(Wnd,'Неправильное число секунд.','Turbo Test',MB_ICONERROR);
      Exit;
    end;
  Result:=true;
end;

procedure TFrmFiltrRec.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var k,b,n,code:integer;st1,st2,st3:string;tim1,tim2,dat1,dat2:TDateTime;
label quit;
begin
  CanClose:=false;
  if not kod then goto quit;
  if CBOc.Checked then
  begin
    Val(EOc.Text,n,code);
    if code<>0 then
    begin
      MessageBox(Handle,'Неправильное значение в поле <Оценка>','Turbo Test',MB_ICONERROR);
      EOc.SetFocus;
      Exit;
    end;
    if not (n in [2..5]) then
    begin
      MessageBox(Handle,'Такой оценки не бывает!','Turbo Test',MB_ICONERROR);
      EOc.SetFocus;
      Exit;
    end;
  end;

  if CBDate.Checked then
  begin
    if not DateValid(Handle,PChar(EDate1.Text)) then
    begin
      EDate1.SetFocus;
      Exit;
    end;
    if EDate2.Text='00.00.00' then goto quit;   // вторая дата не учитывается

    if not DateValid(Handle,PChar(EDate2.Text)) then
    begin
      EDate2.SetFocus;
      Exit;
    end;
    dat1:=StrToDate(EDate1.Text);
    dat2:=StrToDate(EDate2.Text);

    if dat1 > dat2 then
    begin
      MessageBox(Handle,'Вторая дата меньше первой.','Turbo Test',MB_ICONERROR);
      EDate1.SetFocus;
      Exit;
    end;
  end;

  if CBTime.Checked then
  begin
    if not TimeValid(Handle,PChar(ETime1.Text)) then
    begin
      ETime1.SetFocus;
      Exit;
    end;
    if ETime2.Text='00.00.00' then goto quit;// второе время не учитывается

    if not TimeValid(Handle,PChar(ETime2.Text)) then
    begin
      ETime2.SetFocus;
      Exit;
    end;

    tim1:=StrToTime(ETime1.Text);
    tim2:=StrToTime(ETime2.Text);

    if tim1>tim2 then 
    begin
      MessageBox(Handle,'Второе время меньше первого.','Turbo Test',MB_ICONERROR);
      ETime1.SetFocus;
      Exit;
    end;
  end;

  if CBNeprav.Checked then
  begin
    if ENeprav.Text='' then
    begin
      MessageBox(Handle,'Не задан список номеров вопросов с неверными ответами',
         'Монитор ДБ',0);
      Eneprav.SetFocus;
      Exit;
    end;
    for n:=1 to Length(ENeprav.Text) do
      if not (ENeprav.Text[n] in [',','0'..'9']) then
      begin
        MessageBox(Handle,'Недопустимые символы в списке номеров вопросов',
         'Монитор ДБ',0);
        Eneprav.SetFocus;
        Exit;
      end;
    if (ENeprav.Text[1]=',') or (ENeprav.Text[Length(ENeprav.Text)]=',') then
    begin
      MessageBox(Handle,'Неправильный формат списка номеров вопросов',
         'Монитор ДБ',0);
      Eneprav.SetFocus;
      Exit;
    end;

    BadSet:=[];
    // Преобразуем строку st в множество
    k:=0;
    st1:='';
    while k<Length(ENeprav.Text) do
    begin
      inc(k);
      if (k=Length(st1))or (ENeprav.Text[k]=',') then
      begin
        n:=StrToInt(st1);
        if n>255 then begin
          MessageBox(Handle,'Номер вопроса не может быть больше 255!',
                   'Монитор ДБ',0);
          Eneprav.SetFocus;
          Exit;
        end;
        b:=byte(StrToInt(st1));
        st1:='';
        include(BadSet,b);
      end else
      st1:=st1+ENeprav.Text[k];
    end;
    n:=StrToInt(st1);
    if n>255 then begin
      MessageBox(Handle,'Номер вопроса не может быть больше 255!',
               'Монитор ДБ',0);
      Eneprav.SetFocus;
      Exit;
    end;
    b:=byte(StrToInt(st1));
    include(BadSet,b);
  end;
quit:
  CanClose:=true;
end;


procedure TFrmFiltrRec.Button2Click(Sender: TObject);
begin
  kod:=false;
end;

procedure TFrmFiltrRec.Button1Click(Sender: TObject);
begin
  kod:=true;
end;

procedure TFrmFiltrRec.CBTimeClick(Sender: TObject);
begin
  if CBTime.Checked then
  begin
    ETime1.Enabled:=true;
    ETime2.Enabled:=true;
    ETime1.SetFocus;
  end else
  begin
    ETime1.Enabled:=false;
    ETime2.Enabled:=false;
  end;
end;

procedure TFrmFiltrRec.CBNepravClick(Sender: TObject);
begin
  if CBNeprav.Checked then
  begin
    ENeprav.Enabled:=true;
    ENeprav.SetFocus;
  end else ENeprav.Enabled:=false;
end;

procedure TFrmFiltrRec.CBoxNameDblClick(Sender: TObject);
begin
  CBoxName.Items.LoadFromFile('gruppa.dat');
  CBoxName.Text:='';
  SendMessage(CBoxName.Handle,CB_SHOWDROPDOWN,1,0);
  SetCursor(LoadCursor(0,IDC_ARROW));
end;

procedure TFrmFiltrRec.CBoxNameClick(Sender: TObject);
var st:string;
begin
  st:=(Sender as TComboBox).Text;
  if CboxGruppa.Items.IndexOf(st)<>-1 then
  begin
    CBoxName.Items.LoadFromFile(st+'.grp');
    SendMessage(CBoxName.Handle,CB_SHOWDROPDOWN,1,0);
  end;
end;

end.
