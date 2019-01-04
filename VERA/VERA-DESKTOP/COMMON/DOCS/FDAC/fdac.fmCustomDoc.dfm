inherited CustomDocFm: TCustomDocFm
  Caption = 'CustomDocFm'
  ClientHeight = 405
  Position = poDefault
  OnActivate = FormActivate
  OnClose = FormClose
  OnShow = FormShow
  ExplicitHeight = 444
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 371
    Width = 527
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    OnResize = pnBottomResize
    object btnOk: TButton
      Left = 338
      Top = 7
      Width = 61
      Height = 24
      Action = aOk
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
    object BtnCansel: TButton
      Left = 419
      Top = 7
      Width = 74
      Height = 24
      Action = aCancel
      Cancel = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 24
    object aOk: TAction
      Caption = #1054#1082
      Visible = False
      OnExecute = aOkExecute
    end
    object aCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      Visible = False
      OnExecute = aCancelExecute
    end
  end
end
