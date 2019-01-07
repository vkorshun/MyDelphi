object MainDm: TMainDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 386
  Width = 465
  object FDConnectionMain: TFDConnection
    Params.Strings = (
      'DriverID=FB3_VK'
      'User_Name=sysdba'
      'Password=masterkey'
      'PageSize=16384'
      'Protocol=TCPIP'
      'CharacterSet=UTF8'
      'Port=3050'
      'RoleName=RHOPE')
    ConnectedStoredUsage = []
    LoginPrompt = False
    Transaction = FDTransactionRead
    UpdateTransaction = FDTransactionSerializ
    Left = 88
    Top = 72
  end
  object FDTransactionRead: TFDTransaction
    Options.ReadOnly = True
    Connection = FDConnectionMain
    Left = 328
    Top = 32
  end
  object FDQuerySelect: TFDQuery
    Connection = FDConnectionMain
    Left = 248
    Top = 160
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 288
    Top = 248
  end
  object FDTransactionRC: TFDTransaction
    Connection = FDConnectionMain
    Left = 328
    Top = 96
  end
  object FDQueryEx: TFDQuery
    Connection = FDConnectionMain
    Left = 120
    Top = 176
  end
  object FDTransactionSS: TFDTransaction
    Options.Isolation = xiSnapshot
    Connection = FDConnectionMain
    Left = 352
    Top = 160
  end
  object FDTransactionSerializ: TFDTransaction
    Options.Isolation = xiSerializible
    Connection = FDConnectionMain
    Left = 368
    Top = 208
  end
  object FDQueryUpdate: TFDQuery
    Connection = FDConnectionMain
    Left = 152
    Top = 248
  end
  object FDTransactionUpdate: TFDTransaction
    Connection = FDConnectionMain
    Left = 376
    Top = 296
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    DriverID = 'FB3_VK'
    Left = 184
    Top = 64
  end
  object FDCommandSelect: TFDCommand
    Connection = FDConnectionMain
    Left = 88
    Top = 304
  end
end
