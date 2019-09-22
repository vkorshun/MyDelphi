object FmLogin: TFmLogin
  Left = 0
  Top = 0
  Caption = 'Login'
  ClientHeight = 122
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 22
    Top = 24
    Width = 48
    Height = 13
    Caption = 'Username'
  end
  object Label2: TLabel
    Left = 22
    Top = 51
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object EdUserName: TEdit
    Left = 112
    Top = 21
    Width = 193
    Height = 21
    TabOrder = 0
    Text = 'EdUserName'
  end
  object EdPassword: TEdit
    Left = 112
    Top = 48
    Width = 193
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    Text = 'EdPassword'
  end
  object Button1: TButton
    Left = 136
    Top = 89
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object Button2: TButton
    Left = 230
    Top = 89
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
