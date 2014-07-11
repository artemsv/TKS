object FrmPassword: TFrmPassword
  Left = 159
  Top = 80
  BorderStyle = bsDialog
  Caption = 'FrmPassword'
  ClientHeight = 132
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 249
    Height = 113
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 84
      Height = 13
      Caption = 'Введите пароль:'
    end
    object Edit1: TEdit
      Left = 16
      Top = 40
      Width = 217
      Height = 21
      Hint = 'Поле ввода пароля'
      ParentShowHint = False
      PasswordChar = '*'
      ShowHint = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 40
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Ввести'
      Default = True
      ModalResult = 1
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 136
      Top = 72
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 2
      OnClick = Button2Click
    end
  end
end
