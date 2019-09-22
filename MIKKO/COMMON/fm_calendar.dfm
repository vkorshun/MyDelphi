object FmCalendar: TFmCalendar
  Left = 394
  Top = 241
  ActiveControl = MonthCalendar
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FmCalendar'
  ClientHeight = 195
  ClientWidth = 166
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = MonthCalendarKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object BtnOk: TButton
    Left = 42
    Top = 166
    Width = 50
    Height = 25
    Caption = 'BtnOk'
    TabOrder = 0
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 103
    Top = 166
    Width = 59
    Height = 25
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object MonthCalendar: TMonthCalendar
    Left = 0
    Top = 0
    Width = 162
    Height = 160
    AutoSize = True
    Date = 38226.667862268520000000
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    OnKeyDown = MonthCalendarKeyDown
  end
end
