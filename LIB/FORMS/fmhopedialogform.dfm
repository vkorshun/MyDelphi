inherited HopeDialogFormFm: THopeDialogFormFm
  BorderStyle = bsDialog
  Caption = 'HopeDialogFormFm'
  ClientHeight = 304
  ClientWidth = 537
  Position = poOwnerFormCenter
  ExplicitHeight = 332
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 264
    Width = 537
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 344
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 425
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
    end
  end
end
