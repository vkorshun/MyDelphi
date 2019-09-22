object FmKursLoader: TFmKursLoader
  Left = 0
  Top = 0
  Caption = 'FmKursLoader'
  ClientHeight = 267
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 184
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
  end
  object TrayIcon1: TTrayIcon
    Hint = #1047#1072#1082#1072#1095#1082#1072' '#1082#1091#1088#1089#1086#1074' '#1074#1072#1083#1102#1090' (2.0)'
    PopupMenu = PopupMenu1
    Visible = True
    Left = 80
    Top = 160
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 3600000
    OnTimer = Timer1Timer
    Left = 256
    Top = 56
  end
  object PopupMenu1: TPopupMenu
    Left = 312
    Top = 32
    object LoadUKR1: TMenuItem
      Caption = 'Load UKR'
      OnClick = LoadUKR1Click
    end
    object LoadRUS1: TMenuItem
      Caption = 'Load RUS'
      OnClick = LoadRUS1Click
    end
    object Lo1: TMenuItem
      Caption = 'Load MgBank'
      OnClick = Lo1Click
    end
    object LoadMegbankSale: TMenuItem
      Caption = 'Load MegbankSale'
      OnClick = LoadMegbankSaleClick
    end
    object LoadEvroBegonofmonth1: TMenuItem
      Caption = 'Load Evro Begon of month'
      OnClick = LoadEvroBegonofmonth1Click
    end
    object LoadKZ1: TMenuItem
      Caption = 'Load KZ'
      OnClick = LoadKZ1Click
    end
    object Re1: TMenuItem
      Caption = 'Test Timer1Timer'
      OnClick = Re1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object FDPhysADSDriverLink1: TFDPhysADSDriverLink
    VendorLib = 'ace32.dll'
    DateFormat = 'DD.MM.YYYY'
    Left = 208
    Top = 144
  end
  object FDAdsConnection1: TFDConnection
    Params.Strings = (
      'DriverID=ADS'
      'TableType=CDX'
      'ServerTypes=Remote'
      'Protocol=TCPIP'
      'CharacterSet=OEM')
    Left = 296
    Top = 120
  end
  object FDAdsQuery1: TFDQuery
    Connection = FDAdsConnection1
    Left = 240
    Top = 216
  end
  object FDAdsQuery2: TFDQuery
    Connection = FDAdsConnection1
    Left = 312
    Top = 200
  end
  object FDTbKurs: TFDTable
    Connection = FDAdsConnection1
    UpdateOptions.UpdateTableName = 'kurs'
    TableName = 'kurs'
    Left = 176
    Top = 200
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 160
    Top = 72
  end
end
