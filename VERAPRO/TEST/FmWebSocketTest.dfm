object MainFnWSTest: TMainFnWSTest
  Left = 0
  Top = 0
  Caption = 'MainFnWSTest'
  ClientHeight = 658
  ClientWidth = 635
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
  object Memo1: TSynEdit
    Left = 8
    Top = 192
    Width = 601
    Height = 441
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    CodeFolding.GutterShapeSize = 11
    CodeFolding.CollapsedLineColor = clGrayText
    CodeFolding.FolderBarLinesColor = clGrayText
    CodeFolding.IndentGuidesColor = clGray
    CodeFolding.IndentGuides = True
    CodeFolding.ShowCollapsedLine = False
    CodeFolding.ShowHintMark = True
    UseCodeFolding = False
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Lines.Strings = (
      'Memo1')
    FontSmoothing = fsmNone
  end
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Client: TRtcHttpClient
    ServerAddr = 'LOCALHOST'
    ServerPort = '6275'
    AutoConnect = True
    Left = 64
    Top = 64
  end
  object SockReq: TRtcDataRequest
    Client = Client
    OnConnectLost = SockReqConnectLost
    OnWSConnect = SockReqWSConnect
    OnWSDataReceived = SockReqWSDataReceived
    OnWSDataOut = SockReqWSDataOut
    OnWSDataIn = SockReqWSDataIn
    OnWSDataSent = SockReqWSDataSent
    OnWSDisconnect = SockReqWSDisconnect
    Left = 232
    Top = 88
  end
end
