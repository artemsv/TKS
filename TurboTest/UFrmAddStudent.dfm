object FrmAddStudent: TFrmAddStudent
  Left = 130
  Top = 136
  BorderStyle = bsDialog
  Caption = '���������� ������ ���������'
  ClientHeight = 140
  ClientWidth = 305
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
    Width = 289
    Height = 121
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 253
      Height = 13
      Caption = '������� ������� � �������� ������ ���������:'
    end
    object Edit1: TEdit
      Left = 16
      Top = 40
      Width = 209
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 16
      Top = 80
      Width = 75
      Height = 25
      Hint = '���������� ���� ��������'
      Caption = '������ ���'
      Default = True
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 104
      Top = 80
      Width = 75
      Height = 25
      Hint = '��������� ��������� � �������'
      Caption = '���������'
      ModalResult = 1
      TabOrder = 2
    end
    object Button3: TButton
      Left = 192
      Top = 80
      Width = 75
      Height = 25
      Hint = '�� ��������� ��������� � �������'
      Cancel = True
      Caption = '������'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
  end
end
