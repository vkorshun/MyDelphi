object FmTask: TFmTask
  Left = 0
  Top = 0
  Caption = 'FmTask'
  ClientHeight = 202
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 447
    Height = 202
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
    end
  end
  object ActionManager1: TActionManager
    Left = 32
    Top = 32
    StyleName = 'Platform Default'
  end
  object ActionManager2: TActionManager
    Left = 128
    Top = 32
    StyleName = 'Platform Default'
  end
  object ActionManager3: TActionManager
    Left = 40
    Top = 88
    StyleName = 'Platform Default'
  end
  object ActionManager4: TActionManager
    Left = 152
    Top = 88
    StyleName = 'Platform Default'
  end
  object ActionManager5: TActionManager
    Left = 40
    Top = 144
    StyleName = 'Platform Default'
  end
  object ActionManager6: TActionManager
    Left = 144
    Top = 144
    StyleName = 'Platform Default'
  end
end
