object MainFm: TMainFm
  Left = 0
  Top = 0
  Caption = 'Ledapravo'
  ClientHeight = 509
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ActionMainMenuBar1: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 689
    Height = 29
    Caption = 'ActionMainMenuBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 490
    Width = 689
    Height = 19
    Panels = <>
  end
  object MainTabs: TATTabs
    Left = 0
    Top = 29
    Width = 689
    Height = 30
    Align = alTop
    Tabs = <>
    DoubleBuffered = True
    OptButtonLayout = '<>,v'
    OptVarWidth = True
    OptTabHeight = 20
    OptTabWidthNormal = 200
    OptTabWidthMaximal = 600
    OptShowAngleTangent = 2.599999904632568000
    OptShowPlusTab = False
    OptShowModifiedText = '*'
    OptMouseDoubleClickClose = False
    OptHintForX = 'Close tab'
    OptHintForPlus = 'Add tab'
    OptHintForArrowLeft = 'Scroll tabs left'
    OptHintForArrowRight = 'Scroll tabs right'
    OptHintForArrowMenu = 'Show tabs list'
    OptHintForUser0 = '0'
    OptHintForUser1 = '1'
    OptHintForUser2 = '2'
    OptHintForUser3 = '3'
    OptHintForUser4 = '4'
  end
  object ActionManager2: TActionManager
    ActionBars = <
      item
      end>
    LargeImages = ImageList1
    Images = ImageList1
    Left = 336
    Top = 176
    StyleName = 'Platform Default'
  end
  object ImageList1: TImageList
    Height = 32
    Width = 32
    Left = 544
    Top = 96
  end
  object ActionList1: TActionList
    Left = 520
    Top = 248
    object aCertStore: TAction
      Category = #1044#1086#1082#1091#1084#1077#1085#1090#1099
      Caption = #1061#1088#1072#1085#1080#1083#1080#1097#1077' '#1089#1077#1088#1090#1080#1092#1080#1082#1072#1090#1086#1074
    end
    object aExit: TAction
      Category = #1044#1086#1082#1091#1084#1077#1085#1090#1099
      Caption = #1042#1099#1093#1086#1076
      OnExecute = aExitExecute
    end
    object aViewOAU: TAction
      Category = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      Caption = #1054#1073#1098#1077#1082#1090#1099' '#1072#1085#1072#1083#1080#1090#1080#1095#1077#1089#1082#1086#1075#1086' '#1091#1095#1077#1090#1072
      OnExecute = aViewOAUExecute
    end
    object aViewOKU: TAction
      Category = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      Caption = #1054#1073#1098#1077#1082#1090#1099' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1077#1085#1085#1086#1075#1086' '#1091#1095#1077#1090#1072
    end
    object aViewAttributesOAU: TAction
      Category = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      Caption = #1040#1090#1088#1080#1073#1091#1090#1099' '#1086#1073#1098#1077#1082#1090#1086#1074' '#1072#1085#1072#1083#1080#1090#1080#1095#1077#1089#1082#1086#1075#1086' '#1091#1095#1077#1090#1072
      OnExecute = aViewAttributesOAUExecute
    end
    object aViewAttributesOKU: TAction
      Category = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      Caption = #1040#1090#1088#1080#1073#1091#1090#1099' '#1086#1073#1098#1077#1082#1090#1086#1074' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1077#1085#1085#1086#1075#1086' '#1091#1095#1077#1090#1072
    end
    object aTest: TAction
      Caption = 'Test'
      OnExecute = aTestExecute
    end
    object aSettings: TAction
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    end
    object aCertLoad: TAction
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1077#1088#1090#1080#1092#1080#1082#1072#1090#1099
    end
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
      end>
    LargeImages = ImageList1
    Images = ImageList1
    Left = 352
    Top = 272
    StyleName = 'Platform Default'
  end
end
