unit Opros;

interface

uses
  Windows, ActiveX, Classes, ComObj, TurboOpros_TLB, StdVcl;

type
  TOpros = class(TTypedComObject, IOpros)
  protected
    function Show: HResult; stdcall;
    {Declare IOpros methods here}
  end;

implementation

uses ComServ;

function TOpros.Show: HResult;
begin

end;

initialization
  TTypedComObjectFactory.Create(ComServer, TOpros, Class_Opros,
    ciMultiInstance, tmApartment);
end.
