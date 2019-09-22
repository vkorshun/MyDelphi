object FmViewHistory: TFmViewHistory
  Left = 0
  Top = 0
  Caption = 'FmViewHistory'
  ClientHeight = 562
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 292
    Width = 784
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 357
  end
  object DBGridEhVk1: TDBGridEhVk
    Left = 0
    Top = 0
    Width = 784
    Height = 292
    Align = alClient
    AllowedOperations = []
    DataGrouping.GroupLevels = <>
    DataSource = DataSource1
    DrawMemoText = True
    Flat = True
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    IndicatorOptions = [gioShowRowIndicatorEh]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghRowHighlight, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    RowDetailPanel.Color = clBtnFace
    SortLocal = True
    STFilter.Local = True
    STFilter.Location = stflInTitleFilterEh
    STFilter.Visible = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    UseMultiTitle = True
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 543
    Width = 784
    Height = 19
    Panels = <>
  end
  object VkSynEdit1: TVkSynEdit
    Left = 0
    Top = 296
    Width = 784
    Height = 247
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 2
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Lines.Strings = (
      'VkSynEdit1')
  end
  object AdsQuery1: TAdsQuery
    StoreActive = True
    Left = 272
    Top = 152
    ParamData = <>
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = DataSetDriverEh1
    AfterOpen = MemTableEh1AfterOpen
    Left = 376
    Top = 152
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = AdsQuery1
    Left = 272
    Top = 72
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    OnDataChange = DataSource1DataChange
    Left = 160
    Top = 56
  end
end
