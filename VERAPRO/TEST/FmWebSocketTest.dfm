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
  object btnCheck: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = 'btnCheck'
    TabOrder = 1
    OnClick = CheckClick
  end
  object btnIncome: TButton
    Left = 136
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Income'
    TabOrder = 2
    OnClick = btnIncomeClick
  end
  object btnReconnect: TButton
    Left = 24
    Top = 39
    Width = 75
    Height = 25
    Caption = 'btnReconnect'
    TabOrder = 3
    OnClick = btnReconnectClick
  end
  object btnCloseShift: TButton
    Left = 424
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Close Shift'
    TabOrder = 4
    OnClick = btnCloseShiftClick
  end
  object btnOpen: TButton
    Left = 424
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Open Shift'
    TabOrder = 5
    OnClick = btnOpenClick
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
