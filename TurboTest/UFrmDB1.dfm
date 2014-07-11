object Form1: TForm1
  Left = 97
  Top = 65
  Width = 487
  Height = 376
  ActiveControl = Panel1
  Caption = 'Form1'
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 479
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator: TDBNavigator
      Left = 8
      Top = 4
      Width = 240
      Height = 25
      DataSource = DataSource1
      Flat = True
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 33
    Width = 479
    Height = 316
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object DBGrid1: TDBGrid
      Left = 0
      Top = 0
      Width = 479
      Height = 316
      Align = alClient
      DataSource = DataSource1
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
  end
  object DataSource1: TDataSource
    DataSet = Table1
    Left = 389
    Top = 3
  end
  object Table1: TTable
    Active = True
    DatabaseName = 'C:\Program Files\Borland\Delphi5\Projects\Test6'
    TableName = 'db01.db'
    Left = 361
    Top = 3
    object Table1StringField: TStringField
      FieldName = 'ФИО'
      Size = 25
    end
    object Table1SmallintField: TSmallintField
      FieldName = 'Оценка'
    end
    object Table1SmallintField2: TSmallintField
      FieldName = 'Прав'
    end
    object Table1SmallintField3: TSmallintField
      FieldName = 'Вопросов'
    end
    object Table1StringField2: TStringField
      FieldName = 'Тема'
    end
    object Table1DateField: TDateField
      FieldName = 'Дата'
    end
    object Table1StringField3: TStringField
      FieldName = 'Группа'
      Size = 7
    end
    object Table1StringField4: TStringField
      FieldName = 'Преподаватель'
    end
    object Table1TimeField: TTimeField
      FieldName = 'Время'
    end
    object Table1StringField5: TStringField
      FieldName = 'Неправильные ответы'
      Size = 100
    end
  end
end
