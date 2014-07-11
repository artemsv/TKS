object FrmError: TFrmError
  Left = 109
  Top = 100
  BorderStyle = bsDialog
  Caption = 'Ошибка'
  ClientHeight = 113
  ClientWidth = 427
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 104
    Top = 24
    Width = 223
    Height = 24
    Caption = 'Нет доступа к A:\db2.exe'
    Color = clMenu
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Button1: TButton
    Left = 112
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Повторить'
    ModalResult = 1
    TabOrder = 0
  end
  object Button3: TButton
    Left = 232
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Отменить'
    ModalResult = 2
    TabOrder = 1
  end
end
