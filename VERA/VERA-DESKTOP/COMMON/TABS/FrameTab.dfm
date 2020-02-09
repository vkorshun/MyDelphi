object TabFrame: TTabFrame
  Left = 0
  Top = 0
  Width = 482
  Height = 283
  TabOrder = 0
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 0
    Width = 482
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
  object StatusBar1: TStatusBar
    Left = 0
    Top = 243
    Width = 482
    Height = 40
    Panels = <
      item
        Width = 500
      end>
    ExplicitTop = 488
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
end
