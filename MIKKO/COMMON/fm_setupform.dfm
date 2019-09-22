object FmSetUpForm: TFmSetUpForm
  Left = 0
  Top = 0
  Caption = 'FmSetUpForm'
  ClientHeight = 468
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 36
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
    Spacing = 0
  end
  object DBGridEhVk1: TDBGridEhVk
    Left = 0
    Top = 36
    Width = 688
    Height = 432
    Align = alClient
    AllowedOperations = [alopUpdateEh]
    DataSource = DataSource1
    DynProps = <>
    Flat = True
    FooterParams.Color = clWindow
    GridLineParams.VertEmptySpaceStyle = dessNonEh
    IndicatorOptions = [gioShowRowIndicatorEh]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghMultiSortMarking, dghRowHighlight, dghDialogFind, dghColumnResize, dghColumnMove]
    SortLocal = True
    STFilter.Local = True
    STFilter.Location = stflInTitleFilterEh
    STFilter.Visible = True
    TabOrder = 1
    TitleParams.MultiTitle = True
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object ImageList1: TImageList
    Left = 248
    Top = 64
  end
  object PopupMenu: TPopupMenu
    Images = ImageList1
    Left = 448
    Top = 64
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterOpen = MemTableEh1AfterOpen
    AfterPost = MemTableEh1AfterPost
    Left = 152
    Top = 136
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 288
    Top = 160
  end
end
