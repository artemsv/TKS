object FrmStudents: TFrmStudents
  Left = 109
  Top = 111
  BorderStyle = bsDialog
  Caption = 'Awwd'
  ClientHeight = 273
  ClientWidth = 288
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
    Width = 273
    Height = 257
    TabOrder = 0
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 127
      Height = 13
      Caption = 'Список учащихся группы'
    end
    object ListBox2: TListBox
      Left = 16
      Top = 40
      Width = 153
      Height = 201
      ItemHeight = 13
      TabOrder = 0
    end
    object Button1: TButton
      Left = 184
      Top = 216
      Width = 75
      Height = 25
      Hint = 'Несохранять изменения и закрыть'
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
    object Button2: TButton
      Left = 184
      Top = 176
      Width = 75
      Height = 25
      Hint = 'Сохранить изменения и закрыть'
      Caption = 'Сохранить'
      Default = True
      ModalResult = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 184
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Добавить'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 184
      Top = 96
      Width = 75
      Height = 25
      Hint = 'Удалить выбранного учащегося из списка группы'
      Caption = 'Удалить'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = Button4Click
    end
  end
end
