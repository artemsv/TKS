unit AbortFrm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type

  TAbortForm = class(TForm)
    bbtnAbort: TBitBtn;
    procedure bbtnAbortClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AbortForm: TAbortForm;

implementation
uses Printers;

{$R *.DFM}
procedure TAbortForm.bbtnAbortClick(Sender: TObject);
begin
  Printer.Abort;  
  Close; 
end;

end.
