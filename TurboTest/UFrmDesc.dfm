object FrmDesc: TFrmDesc
  Left = 99
  Top = 75
  BorderStyle = bsDialog
  Caption = 'Turbo Test'
  ClientHeight = 171
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 369
    Height = 153
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 173
      Height = 13
      Caption = 'Введите необходимый заголовок:'
    end
    object Memo1: TMemo
      Left = 16
      Top = 40
      Width = 241
      Height = 89
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object Button1: TButton
      Left = 272
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Ок'
      ModalResult = 1
      TabOrder = 1
    end
    object Button2: TButton
      Left = 272
      Top = 112
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 2
    end
  end
end
