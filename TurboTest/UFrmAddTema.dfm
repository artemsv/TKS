object FrmAddTema: TFrmAddTema
  Left = 139
  Top = 110
  Width = 273
  Height = 243
  Caption = 'Добавление темы'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 249
    Height = 201
    Caption = 'Список тем'
    TabOrder = 0
    object ListBox1: TListBox
      Left = 16
      Top = 24
      Width = 121
      Height = 161
      ItemHeight = 13
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 152
      Top = 112
      Width = 75
      Height = 25
      Caption = 'ОK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 152
      Top = 160
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 2
    end
  end
end
