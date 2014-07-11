object Frame2: TFrame2
  Left = 0
  Top = 0
  Width = 318
  Height = 240
  TabOrder = 0
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 284
    Height = 13
    Caption = 'Выберите нужный вариант установки и нажмите Далее'
  end
  object Label2: TLabel
    Left = 120
    Top = 40
    Width = 186
    Height = 13
    Caption = 'Программа будет установлена в ми-'
  end
  object Label3: TLabel
    Left = 120
    Top = 56
    Width = 195
    Height = 13
    Caption = 'нимально необходимой конфигурации'
  end
  object Label4: TLabel
    Left = 120
    Top = 88
    Width = 171
    Height = 13
    Caption = 'Вместе с программой будут уста-'
  end
  object Label5: TLabel
    Left = 120
    Top = 104
    Width = 93
    Height = 13
    Caption = 'новлены примеры'
  end
  object Label6: TLabel
    Left = 112
    Top = 144
    Width = 199
    Height = 13
    Caption = 'На Рабочем столе будут созданы ярлы'
  end
  object RadioButton1: TRadioButton
    Left = 16
    Top = 40
    Width = 89
    Height = 17
    Caption = 'Компактная'
    TabOrder = 0
  end
  object RadioButton2: TRadioButton
    Left = 16
    Top = 88
    Width = 97
    Height = 17
    Caption = 'Расширенная'
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 144
    Width = 97
    Height = 17
    Caption = 'Ярлыки'
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 176
    Width = 297
    Height = 49
    Caption = 'Каталог-получатель'
    TabOrder = 3
    object Label7: TLabel
      Left = 8
      Top = 24
      Width = 104
      Height = 13
      Caption = 'C:\Program Files\Test'
    end
    object Button1: TButton
      Left = 208
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Просмотр'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
