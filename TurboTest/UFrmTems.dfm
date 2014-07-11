object FrmTems: TFrmTems
  Left = 151
  Top = 77
  BorderStyle = bsDialog
  Caption = 'Темы опросов'
  ClientHeight = 267
  ClientWidth = 290
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 249
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 74
      Height = 13
      Caption = 'Темы опросов'
    end
    object btnSave: TButton
      Left = 176
      Top = 168
      Width = 75
      Height = 25
      Hint = 'Сохранить изменения и закрыть'
      Caption = 'Сохранить'
      Default = True
      ModalResult = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object btnCancel: TButton
      Left = 176
      Top = 208
      Width = 75
      Height = 25
      Hint = 'Не сохранять изменения и закрыть'
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object ListBox1: TListBox
      Left = 16
      Top = 40
      Width = 145
      Height = 193
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBox1Click
    end
    object btnDelete: TButton
      Left = 176
      Top = 128
      Width = 75
      Height = 25
      Hint = 'Удалить из списка тем выбранную тему'
      Caption = 'Удалить'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnDeleteClick
    end
    object btnAdd: TButton
      Left = 176
      Top = 88
      Width = 75
      Height = 25
      Hint = 'Добавить в список тем новую тему'
      Caption = 'Добавить'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnAddClick
    end
    object btnRefresh: TButton
      Left = 176
      Top = 48
      Width = 75
      Height = 25
      Hint = 'Создать файл TEMAS.DAT заново'
      Caption = 'Обновить'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnRefreshClick
    end
    object ListBox2: TListBox
      Left = 104
      Top = 16
      Width = 121
      Height = 17
      ItemHeight = 13
      TabOrder = 6
      Visible = False
    end
  end
end
