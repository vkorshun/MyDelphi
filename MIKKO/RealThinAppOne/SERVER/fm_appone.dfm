object FmAppOne: TFmAppOne
  Left = 0
  Top = 0
  Caption = 'FmAppOne'
  ClientHeight = 243
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 392
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object HttpServerMikko: TRtcHttpServer
    OnClientDisconnect = HttpServerMikkoClientDisconnect
    OnListenStart = HttpServerMikkoListenStart
    OnListenLost = HttpServerMikkoListenLost
    Left = 80
    Top = 48
  end
  object RtcDataProvider1: TRtcDataProvider
    Server = HttpServerMikko
    OnCheckRequest = RtcDataProvider1CheckRequest
    OnDataReceived = RtcDataProvider1DataReceived
    Left = 192
    Top = 72
  end
end
