object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 587
  ClientWidth = 1087
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 449
    Top = 292
    Width = 62
    Height = 13
    Caption = 'Players ships'
  end
  object Label2: TLabel
    Left = 824
    Top = 292
    Width = 64
    Height = 13
    Caption = 'Enemys ships'
  end
  object Label3: TLabel
    Left = 449
    Top = 8
    Width = 52
    Height = 13
    Caption = 'Attack grid'
  end
  object Label4: TLabel
    Left = 826
    Top = 10
    Width = 52
    Height = 13
    Caption = 'Attack grid'
  end
  object StringGrid1: TStringGrid
    Left = 449
    Top = 29
    Width = 257
    Height = 257
    ColCount = 10
    DefaultColWidth = 24
    FixedCols = 0
    RowCount = 10
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 0
  end
  object Button1: TButton
    Left = 712
    Top = 29
    Width = 75
    Height = 25
    Caption = 'start'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 712
    Top = 85
    Width = 75
    Height = 25
    Caption = 'attack'
    TabOrder = 3
    OnClick = Button3Click
  end
  object StringGrid2: TStringGrid
    Left = 449
    Top = 311
    Width = 257
    Height = 257
    ColCount = 10
    DefaultColWidth = 24
    FixedCols = 0
    RowCount = 10
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 4
  end
  object StringGrid3: TStringGrid
    Left = 824
    Top = 29
    Width = 257
    Height = 257
    ColCount = 10
    DefaultColWidth = 24
    FixedCols = 0
    RowCount = 10
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 5
  end
  object StringGrid4: TStringGrid
    Left = 824
    Top = 311
    Width = 257
    Height = 257
    ColCount = 10
    DefaultColWidth = 24
    FixedCols = 0
    RowCount = 10
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 6
  end
end
