unit Demos;
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DBGrids, DB, DBTables, Menus, StdCtrls, Spin,
  Gauges, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    tblClients: TTable;
    dsClients: TDataSource;
    dbgColumns: TDBGrid;
    mmMain: TMainMenu;
    mmiFile: TMenuItem;
    mmiPrint: TMenuItem;
    lblLastName: TLabel;
    lblColumns: TLabel;
    lblFirstName: TLabel;
    lblAddress: TLabel;
    lblCity: TLabel;
    lblState: TLabel;
    lblZip: TLabel;
    edtHeaderFont: TEdit;
    lblHeader: TLabel;
    btnHeaderFont: TButton;
    FontDialog: TFontDialog;
    edtLastName: TEdit;
    edtFirstName: TEdit;
    edtAddress: TEdit;
    edtCity: TEdit;
    edtState: TEdit;
    edtZip: TEdit;
    udLastName: TUpDown;
    udFirstName: TUpDown;
    udAddress: TUpDown;
    udCity: TUpDown;
    udState: TUpDown;
    udZip: TUpDown;
    procedure mmiPrintClick(Sender: TObject);
    procedure btnHeaderFontClick(Sender: TObject);
  private
    PixelsInInchx: integer;
    LineHeight: Integer;
   { Keeps track of vertical space in pixels, printed on a page }
    AmountPrinted: integer;
   { Number of pixels in 1/10 of an inch. This is used for line spacing }
    TenthsOfInchPixelsY: integer;
    procedure PrintLine(Items: TStringList);
    procedure PrintHeader;
    procedure PrintColumnNames;
  end;

var
  MainForm: TMainForm;

implementation
uses printers, AbortFrm;

{$R *.DFM}

procedure TMainForm.PrintLine(Items: TStringList);
var
  OutRect: TRect;
  Inches: double;
  i: integer;
begin
  // First position the print rect on the print canvas
  OutRect.Left := 0;
  OutRect.Top := AmountPrinted;
  OutRect.Bottom := OutRect.Top + LineHeight;
  With Printer.Canvas do
    for i := 0 to Items.Count - 1 do
    begin
      Inches := longint(Items.Objects[i]) * 0.1;
      // Determine Right edge
      OutRect.Right := OutRect.Left + round(PixelsInInchx*Inches);
      if not Printer.Aborted then
       // Print the line
        TextRect(OutRect, OutRect.Left, OutRect.Top, Items[i]);
      // Adjust right edge
      OutRect.Left := OutRect.Right;
    end;
 { As each line prints, AmountPrinted must increase to reflect how
   much of a page has been printed on based on the line height. }
  AmountPrinted := AmountPrinted + TenthsOfInchPixelsY*2;
end;

procedure TMainForm.PrintHeader;
var
  SaveFont: TFont;
begin
 { Save the current printer's font, then set a new print font based
  on the selection for Edit1 }
  SaveFont := TFont.Create;
  try
    Savefont.Assign(Printer.Canvas.Font);
    // First print out the Header
    with Printer do
    begin
      if not Printer.Aborted then
        Canvas.TextOut((PageWidth div 2)-(Canvas.TextWidth('edtHeaderFont.Text')
                         div 2),0,'edtHeaderFont.Text');
     // Increment AmountPrinted by the LineHeight
      AmountPrinted := AmountPrinted + LineHeight+TenthsOfInchPixelsY;
    end;
    // Restore the old font to the Printer's Canvas property
    Printer.Canvas.Font.Assign(SaveFont);
  finally
    SaveFont.Free;
  end;
end;

procedure TMainForm.PrintColumnNames;
var
  ColNames: TStringList;
begin
  { Create a TStringList to hold the column names and the
    positions where the width of each column is based on values
    in the TEdit controls. }
  ColNames := TStringList.Create;
  try
    // Print the column headers using a bold/underline style
    Printer.Canvas.Font.Style := [fsBold, fsUnderline];

    with ColNames do
    begin
      // Store the column headers and widths in the TStringList object
      AddObject('LAST NAME',  pointer(StrToInt(edtLastName.Text)));
      AddObject('FIRST NAME', pointer(StrToInt(edtFirstName.Text)));
      AddObject('ADDRESS',    pointer(StrToInt(edtAddress.Text)));
      AddObject('CITY',       pointer(StrToInt(edtCity.Text)));
      AddObject('STATE',      pointer(StrToInt(edtState.Text)));
      AddObject('ZIP',        pointer(StrToInt(edtZip.Text)));
    end;

    PrintLine(ColNames);
    Printer.Canvas.Font.Style := [];  
  finally
    ColNames.Free;   // Free the column name TStringList instance
  end;
end;

procedure TMainForm.mmiPrintClick(Sender: TObject);
var
  Items: TStringList;
begin
  { Create a TStringList instance to hold the fields and the widths
    of the columns in which they'll be drawn based on the entries in
    the edit controls }
  Items := TStringList.Create;
  try
    // Determine pixels per inch horizontally
    PixelsInInchx := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
    TenthsOfInchPixelsY := GetDeviceCaps(Printer.Handle,
                            LOGPIXELSY) div 10;
    AmountPrinted := 0;
    MainForm.Enabled := false; // Disable the parent form
    try
      Printer.BeginDoc;
      AbortForm.Show;
      Application.ProcessMessages;
      { Calculate the line height based on text height using the
        currently rendered font }
      LineHeight := Printer.Canvas.TextHeight('X')+TenthsOfInchPixelsY;
      if edtHeaderFont.Text <> '' then
        PrintHeader;
      PrintColumnNames;
      tblClients.First;
      { Store each field value in the TStringList as well as its
        column width }
      while (not tblClients.Eof) or Printer.Aborted do
      begin

        Application.ProcessMessages;
        with Items do
        begin
          AddObject(tblClients.FieldByName('LAST_NAME').AsString,
                        pointer(StrToInt(edtLastName.Text)));
          AddObject(tblClients.FieldByName('FIRST_NAME').AsString,
                        pointer(StrToInt(edtFirstName.Text)));
          AddObject(tblClients.FieldByName('ADDRESS_1').AsString,
                        pointer(StrToInt(edtAddress.Text)));
          AddObject(tblClients.FieldByName('CITY').AsString,
                        pointer(StrToInt(edtCity.Text)));
          AddObject(tblClients.FieldByName('STATE').AsString,
                        pointer(StrToInt(edtState.Text)));
          AddObject(tblClients.FieldByName('ZIP').AsString,
                        pointer(StrToInt(edtZip.Text)));
        end;
        PrintLine(Items);
        { Force print job to begin a new page if printed output has
          exceeded page height }
        if AmountPrinted + LineHeight > Printer.PageHeight then
        begin
          AmountPrinted := 0;
          if not Printer.Aborted then
            Printer.NewPage;
          PrintHeader;
          PrintColumnNames;
        end;
        Items.Clear;
        tblClients.Next;
      end;
      AbortForm.Hide;
      if not Printer.Aborted then
        Printer.EndDoc;
    finally
      MainForm.Enabled := true;
    end;
  finally
    Items.Free;
  end;
end;

procedure TMainForm.btnHeaderFontClick(Sender: TObject);
begin
 { Assign the font selected with FontDialog1 to Edit1. }
  FontDialog.Font.Assign(edtHeaderFont.Font);
  if FontDialog.Execute then
    edtHeaderFont.Font.Assign(FontDialog.Font);
end;

end.
