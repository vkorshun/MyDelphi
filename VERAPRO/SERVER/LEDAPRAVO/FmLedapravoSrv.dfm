object LedaPravoSrvFm: TLedaPravoSrvFm
  Left = 0
  Top = 0
  Caption = 'LedaPravoSrvFm'
  ClientHeight = 336
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 448
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object RtcHttpServer1: TRtcHttpServer
    MultiThreaded = True
    ServerAddr = 'localhost'
    ServerPort = '6476'
    Left = 127
    Top = 62
  end
end
