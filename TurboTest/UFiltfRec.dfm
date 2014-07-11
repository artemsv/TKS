object FrmFiltrRec: TFrmFiltrRec
  Left = 210
  Top = 122
  BorderStyle = bsDialog
  Caption = 'Фильтр записей'
  ClientHeight = 353
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 465
    Height = 337
    TabOrder = 0
    object Label1: TLabel
      Left = 168
      Top = 24
      Width = 49
      Height = 13
      Caption = 'Дата:   от'
    end
    object Label2: TLabel
      Left = 288
      Top = 24
      Width = 12
      Height = 13
      Caption = 'до'
    end
    object Label3: TLabel
      Left = 368
      Top = 24
      Width = 78
      Height = 13
      Caption = '(включительно)'
    end
    object Label4: TLabel
      Left = 168
      Top = 56
      Width = 50
      Height = 13
      Caption = 'Время: от'
    end
    object Label5: TLabel
      Left = 288
      Top = 56
      Width = 12
      Height = 13
      Caption = 'до'
    end
    object Label6: TLabel
      Left = 368
      Top = 56
      Width = 78
      Height = 13
      Caption = '(включительно)'
    end
    object Label7: TLabel
      Left = 168
      Top = 80
      Width = 27
      Height = 13
      Caption = 'Тема'
    end
    object Label8: TLabel
      Left = 328
      Top = 80
      Width = 35
      Height = 13
      Caption = 'Группа'
    end
    object Label9: TLabel
      Left = 408
      Top = 80
      Width = 38
      Height = 13
      Caption = 'Оценка'
    end
    object Label10: TLabel
      Left = 168
      Top = 136
      Width = 115
      Height = 13
      Caption = 'Неправильные ответы'
    end
    object Label11: TLabel
      Left = 168
      Top = 192
      Width = 79
      Height = 13
      Caption = 'Имя учащегося'
    end
    object Label12: TLabel
      Left = 168
      Top = 256
      Width = 79
      Height = 13
      Caption = 'Преподаватель'
    end
    object GroupBox2: TGroupBox
      Left = 16
      Top = 16
      Width = 137
      Height = 281
      Caption = 'Учитываемые поля'
      TabOrder = 0
      object CBOc: TCheckBox
        Left = 16
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Оценка'
        TabOrder = 0
        OnClick = CBOcClick
      end
      object CBDate: TCheckBox
        Left = 16
        Top = 56
        Width = 97
        Height = 17
        Caption = 'Дата'
        TabOrder = 1
        OnClick = CBDateClick
      end
      object CBTime: TCheckBox
        Left = 16
        Top = 88
        Width = 97
        Height = 17
        Caption = 'Время'
        TabOrder = 2
        OnClick = CBTimeClick
      end
      object CBTema: TCheckBox
        Left = 16
        Top = 120
        Width = 97
        Height = 17
        Caption = 'Тема'
        TabOrder = 3
        OnClick = CBTemaClick
      end
      object CBGruppa: TCheckBox
        Left = 16
        Top = 152
        Width = 97
        Height = 17
        Caption = 'Группа'
        TabOrder = 4
        OnClick = CBGruppaClick
      end
      object CBName: TCheckBox
        Left = 16
        Top = 184
        Width = 97
        Height = 17
        Caption = 'Имя учащегося'
        TabOrder = 5
        OnClick = CBNameClick
      end
      object CBTeacher: TCheckBox
        Left = 16
        Top = 216
        Width = 97
        Height = 17
        Caption = 'Преподаватель'
        TabOrder = 6
        OnClick = CBTeacherClick
      end
      object CBNeprav: TCheckBox
        Left = 16
        Top = 248
        Width = 97
        Height = 17
        Caption = 'Неправ'
        TabOrder = 7
        OnClick = CBNepravClick
      end
    end
    object CBFindNOT: TCheckBox
      Left = 32
      Top = 312
      Width = 121
      Height = 17
      Caption = 'Обратный поиск'
      TabOrder = 1
    end
    object EDate1: TMaskEdit
      Left = 224
      Top = 16
      Width = 57
      Height = 21
      EditMask = '!90/90/00;1;_'
      MaxLength = 8
      TabOrder = 2
      Text = '00.00.00'
    end
    object EDate2: TMaskEdit
      Left = 304
      Top = 16
      Width = 57
      Height = 21
      EditMask = '!90/90/00;1;_'
      MaxLength = 8
      TabOrder = 3
      Text = '00.00.00'
    end
    object ETime1: TMaskEdit
      Left = 224
      Top = 48
      Width = 57
      Height = 21
      EditMask = '!90:00:00;1;_'
      MaxLength = 8
      TabOrder = 4
      Text = '00:00:00'
    end
    object ETime2: TMaskEdit
      Left = 304
      Top = 48
      Width = 57
      Height = 21
      EditMask = '!90:00:00;1;_'
      MaxLength = 8
      TabOrder = 5
      Text = '00:00:00'
    end
    object CBoxTema: TComboBox
      Left = 168
      Top = 104
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 6
    end
    object CBoxGruppa: TComboBox
      Left = 328
      Top = 104
      Width = 65
      Height = 21
      ItemHeight = 13
      TabOrder = 7
    end
    object EOc: TEdit
      Left = 408
      Top = 104
      Width = 33
      Height = 21
      TabOrder = 8
    end
    object ENeprav: TEdit
      Left = 168
      Top = 160
      Width = 273
      Height = 21
      TabOrder = 9
    end
    object CboxName: TComboBox
      Left = 168
      Top = 224
      Width = 177
      Height = 21
      ItemHeight = 13
      TabOrder = 10
      OnClick = CBoxNameClick
      OnDblClick = CBoxNameDblClick
    end
    object CBBegin: TCheckBox
      Left = 360
      Top = 224
      Width = 97
      Height = 17
      Caption = 'С начала слова'
      TabOrder = 11
    end
    object CBoxTeacher: TComboBox
      Left = 168
      Top = 280
      Width = 177
      Height = 21
      ItemHeight = 13
      TabOrder = 12
    end
    object Button1: TButton
      Left = 376
      Top = 256
      Width = 75
      Height = 25
      Caption = 'Применить'
      Default = True
      ModalResult = 1
      TabOrder = 13
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 376
      Top = 296
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 14
      OnClick = Button2Click
    end
  end
end
