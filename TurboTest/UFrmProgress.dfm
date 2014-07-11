object FrmProgress: TFrmProgress
  Left = 159
  Top = 152
  Width = 308
  Height = 133
  Caption = 'Копирование файлов'
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 120
    Height = 13
    Caption = 'Копирование файлов в '
  end
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 91
    Height = 13
    Caption = 'Осталось: 10 сек.'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 40
    Width = 249
    Height = 13
    Min = 0
    Max = 1000
    Smooth = True
    Step = 1
    TabOrder = 0
  end
end
