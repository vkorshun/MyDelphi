object FmSelectFromQuery: TFmSelectFromQuery
  Left = 0
  Top = 0
  Caption = 'FmSelectFromQuery'
  ClientHeight = 360
  ClientWidth = 711
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
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 0
    Width = 711
    Height = 29
    Caption = 'ActionToolBar1'
    Color = clMenuBar
    ColorMap.HighlightColor = clWhite
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    Spacing = 0
  end
  object DBGridEhVkDoc: TDBGridEhVk
    Left = 0
    Top = 29
    Width = 711
    Height = 312
    Align = alClient
    AllowedOperations = []
    DataGrouping.GroupLevels = <>
    DataSource = DataSource1
    Flat = True
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    IndicatorOptions = [gioShowRowIndicatorEh]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghRowHighlight, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    PopupMenu = PopupMenu1
    RowDetailPanel.Color = clBtnFace
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    UseMultiTitle = True
    OnDrawColumnCell = DBGridEhVkDocDrawColumnCell
    OnKeyPress = DBGridEhVkDocKeyPress
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 341
    Width = 711
    Height = 19
    Panels = <>
  end
  object ImageList1: TImageList
    Left = 256
    Top = 112
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 360
    Top = 208
  end
  object PopupMenu1: TPopupMenu
    Images = ImageList1
    Left = 464
    Top = 120
  end
  object AdsQuery1: TAdsQuery
    StoreActive = True
    Left = 152
    Top = 72
    ParamData = <>
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = DataSetDriverEh1
    Left = 152
    Top = 160
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = AdsQuery1
    Left = 344
    Top = 96
  end
  object ActionManager1: TActionManager
    Left = 584
    Top = 128
    StyleName = 'Platform Default'
  end
end
