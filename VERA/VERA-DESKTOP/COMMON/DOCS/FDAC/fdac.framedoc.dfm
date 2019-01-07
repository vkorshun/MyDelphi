object DocFrame: TDocFrame
  Left = 0
  Top = 0
  Width = 614
  Height = 421
  TabOrder = 0
  TabStop = True
  object Splitter1: TSplitter
    Left = 0
    Top = 227
    Width = 614
    Height = 5
    Cursor = crVSplit
    Align = alBottom
    Visible = False
    ExplicitLeft = 1
    ExplicitTop = 37
    ExplicitWidth = 612
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 402
    Width = 614
    Height = 19
    Panels = <
      item
        Width = 500
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 614
    Height = 227
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object ActionToolBar1: TActionToolBar
      Left = 1
      Top = 1
      Width = 612
      Height = 36
      Caption = 'ActionToolBar1'
      Color = clMenuBar
      ColorMap.DisabledFontColor = 7171437
      ColorMap.HighlightColor = clWhite
      ColorMap.BtnSelectedFont = clBlack
      ColorMap.UnusedColor = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Spacing = 0
    end
    object DBGridEhVkDoc: TDBGridEhVk
      Left = 1
      Top = 37
      Width = 612
      Height = 189
      Align = alClient
      AllowedOperations = [alopUpdateEh]
      DataSource = DataSource1
      DrawMemoText = True
      DynProps = <>
      Flat = True
      FooterRowCount = 1
      FooterParams.Color = clSilver
      GridLineParams.VertEmptySpaceStyle = dessNonEh
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghRowHighlight, dghColumnResize, dghColumnMove]
      PopupMenu = PopupMenu1
      SortLocal = True
      STFilter.InstantApply = False
      STFilter.Local = True
      STFilter.Location = stflInTitleFilterEh
      STFilter.Visible = True
      TabOrder = 1
      TitleParams.MultiTitle = True
      OnApplyFilter = DbGridEhVkDocAfterApplayUserFilter
      OnDblClick = DBGridEhVkDocDblClick
      OnDrawColumnCell = DBGridEhVkDocDrawColumnCell
      OnEnter = DBGridEhVkDocEnter
      OnFillSTFilterListValues = DBGridEhVkDocFillSTFilterListValues
      OnGetCellParams = DBGridEhVkDocGetCellParams
      OnKeyDown = DBGridEhVkDocKeyDown
      OnKeyPress = DBGridEhVkDocKeyPress
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 232
    Width = 614
    Height = 170
    Align = alBottom
    Caption = 'Panel2'
    TabOrder = 2
    Visible = False
  end
  object DataSource1: TDataSource
    OnStateChange = DataSource1StateChange
    OnDataChange = DataSource1DataChange
    Left = 120
    Top = 56
  end
  object ImageList1: TImageList
    Left = 248
    Top = 64
  end
  object PopupMenu1: TPopupMenu
    Images = ImageList1
    Left = 448
    Top = 64
  end
  object DocActionList: TActionList
    Images = ImageList1
    Left = 344
    Top = 144
    object aDocInsert: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '
      ShortCut = 45
      OnExecute = aDocInsertExecute
    end
    object aDocEdit: TAction
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      ShortCut = 115
      OnExecute = aDocEditExecute
      OnUpdate = aDocEditUpdate
    end
    object aDocDelete: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100
      ShortCut = 46
      OnExecute = aDocDeleteExecute
      OnUpdate = aDocDeleteUpdate
    end
    object aDocFind: TAction
      Caption = #1055#1086#1080#1089#1082
      ShortCut = 118
      OnExecute = aDocFindExecute
    end
    object aDocContinueFind: TAction
      Caption = #1055#1088#1086#1076#1086#1083#1078#1077#1085#1080#1077' '#1087#1086#1080#1089#1082#1072
      ShortCut = 16502
      OnExecute = aDocContinueFindExecute
    end
    object aDocRefresh: TAction
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      ShortCut = 16466
      OnExecute = aDocRefreshExecute
    end
    object aDocClone: TAction
      Caption = #1050#1083#1086#1085#1080#1088#1086#1074#1072#1090#1100
      ShortCut = 116
      OnExecute = aDocCloneExecute
    end
    object aDocMark: TAction
      Caption = #1055#1086#1084#1077#1090#1080#1090#1100'/ '#1057#1085#1103#1090#1100' '#1087#1086#1084#1077#1090#1082#1091
      ShortCut = 16461
    end
    object aDocMarkAll: TAction
      Caption = #1055#1086#1084#1077#1090#1080#1090#1100' '#1074#1089#1077
      ShortCut = 16449
    end
    object aDocUnMarkAll: TAction
      Caption = #1057#1085#1103#1090#1100' '#1074#1089#1102' '#1087#1086#1084#1077#1090#1082#1091
      ShortCut = 16469
    end
    object aDocToExcel: TAction
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' Excel'
      ShortCut = 32848
    end
  end
end
