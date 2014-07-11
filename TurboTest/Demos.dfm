object MainForm: TMainForm
  Left = 52
  Top = 97
  Width = 534
  Height = 333
  Caption = 'Delphi 5  Developer'#39's Guide Columnar Report Example'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = mmMain
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lblLastName: TLabel
    Left = 312
    Top = 40
    Width = 51
    Height = 13
    Caption = 'Last Name'
  end
  object lblColumns: TLabel
    Left = 312
    Top = 8
    Width = 165
    Height = 13
    Caption = 'Column Widths in Tenths of Inches'
  end
  object lblFirstName: TLabel
    Left = 312
    Top = 72
    Width = 50
    Height = 13
    Caption = 'First Name'
  end
  object lblAddress: TLabel
    Left = 312
    Top = 104
    Width = 38
    Height = 13
    Caption = 'Address'
  end
  object lblCity: TLabel
    Left = 432
    Top = 40
    Width = 17
    Height = 13
    Caption = 'City'
  end
  object lblState: TLabel
    Left = 432
    Top = 72
    Width = 25
    Height = 13
    Caption = 'State'
  end
  object lblZip: TLabel
    Left = 432
    Top = 104
    Width = 15
    Height = 13
    Caption = 'Zip'
  end
  object lblHeader: TLabel
    Left = 8
    Top = 24
    Width = 35
    Height = 13
    Caption = 'Header'
  end
  object dbgColumns: TDBGrid
    Left = 0
    Top = 132
    Width = 526
    Height = 155
    Align = alBottom
    DataSource = dsClients
    TabOrder = 0
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clBlack
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object edtHeaderFont: TEdit
    Left = 8
    Top = 48
    Width = 273
    Height = 21
    TabOrder = 1
    Text = 'edtHeaderFont'
  end
  object btnHeaderFont: TButton
    Left = 64
    Top = 20
    Width = 113
    Height = 25
    Caption = 'Header Font'
    TabOrder = 2
    OnClick = btnHeaderFontClick
  end
  object edtLastName: TEdit
    Left = 380
    Top = 36
    Width = 26
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object edtFirstName: TEdit
    Left = 380
    Top = 68
    Width = 26
    Height = 21
    TabOrder = 4
    Text = '0'
  end
  object edtAddress: TEdit
    Left = 380
    Top = 100
    Width = 26
    Height = 21
    TabOrder = 5
    Text = '0'
  end
  object edtCity: TEdit
    Left = 468
    Top = 36
    Width = 26
    Height = 21
    TabOrder = 6
    Text = '0'
  end
  object edtState: TEdit
    Left = 468
    Top = 68
    Width = 26
    Height = 21
    TabOrder = 7
    Text = '0'
  end
  object edtZip: TEdit
    Left = 468
    Top = 100
    Width = 26
    Height = 21
    TabOrder = 8
    Text = '0'
  end
  object udLastName: TUpDown
    Left = 406
    Top = 36
    Width = 15
    Height = 21
    Associate = edtLastName
    Min = 0
    Position = 0
    TabOrder = 9
    Wrap = False
  end
  object udFirstName: TUpDown
    Left = 406
    Top = 68
    Width = 15
    Height = 21
    Associate = edtFirstName
    Min = 0
    Position = 0
    TabOrder = 10
    Wrap = False
  end
  object udAddress: TUpDown
    Left = 406
    Top = 100
    Width = 15
    Height = 21
    Associate = edtAddress
    Min = 0
    Position = 0
    TabOrder = 11
    Wrap = False
  end
  object udCity: TUpDown
    Left = 494
    Top = 36
    Width = 15
    Height = 21
    Associate = edtCity
    Min = 0
    Position = 0
    TabOrder = 12
    Wrap = False
  end
  object udState: TUpDown
    Left = 494
    Top = 68
    Width = 15
    Height = 21
    Associate = edtState
    Min = 0
    Position = 0
    TabOrder = 13
    Wrap = False
  end
  object udZip: TUpDown
    Left = 494
    Top = 100
    Width = 15
    Height = 21
    Associate = edtZip
    Min = 0
    Position = 0
    TabOrder = 14
    Wrap = False
  end
  object tblClients: TTable
    Active = True
    DatabaseName = 'C:\Program Files\Common Files\Borland Shared\Data'
    FieldDefs = <
      item
        Name = 'LAST_NAME'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'FIRST_NAME'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'ACCT_NBR'
        DataType = ftFloat
      end
      item
        Name = 'ADDRESS_1'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'CITY'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'STATE'
        DataType = ftString
        Size = 2
      end
      item
        Name = 'ZIP'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'TELEPHONE'
        DataType = ftString
        Size = 12
      end
      item
        Name = 'DATE_OPEN'
        DataType = ftDate
      end
      item
        Name = 'SS_NUMBER'
        DataType = ftFloat
      end
      item
        Name = 'PICTURE'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'BIRTH_DATE'
        DataType = ftDate
      end
      item
        Name = 'RISK_LEVEL'
        DataType = ftString
        Size = 8
      end
      item
        Name = 'OCCUPATION'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'OBJECTIVES'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'INTERESTS'
        DataType = ftString
        Size = 120
      end
      item
        Name = 'IMAGE'
        DataType = ftTypedBinary
        Size = 1
      end>
    StoreDefs = True
    TableName = 'CLIENTS.DBF'
    Left = 64
    Top = 88
  end
  object dsClients: TDataSource
    DataSet = tblClients
    Left = 92
    Top = 88
  end
  object mmMain: TMainMenu
    Left = 40
    Top = 88
    object mmiFile: TMenuItem
      Caption = 'File'
      object mmiPrint: TMenuItem
        Caption = 'Print'
        OnClick = mmiPrintClick
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 12
    Top = 88
  end
end
