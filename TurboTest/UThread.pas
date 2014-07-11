unit UThread;

interface

uses
  WIndows,
  Forms,
  Classes;

type
  TTestThread = class(TThread)
  private
    FSource,FDest:string;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor CreateIt(source,dest:string);
  end;

implementation

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TestThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TestThread }

constructor TTestThread.CreateIt(source, dest: string);
begin
  inherited Create(false);
  FSource:=Source;
  FDest:=Dest;
end;

procedure TTestThread.Execute;
begin
end;

end.
