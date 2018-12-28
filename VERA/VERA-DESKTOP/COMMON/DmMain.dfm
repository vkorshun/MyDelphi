object MainDm: TMainDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 421
  Width = 447
  object pFIBDatabaseVera: TpFIBDatabaseVk
    DefaultTransaction = pFIBTransactionReadOnly
    DefaultUpdateTransaction = pFIBTransactionUpdate
    SQLDialect = 3
    Timeout = 0
    LibraryName = 'fibplus.dll'
    WaitForRestoreConnect = 0
    Left = 56
    Top = 88
  end
  object pFIBDataSetVk1: TpFIBDataSetVk
    Left = 216
    Top = 104
  end
  object pFIBQueryVk1: TpFIBQueryVk
    Left = 80
    Top = 232
  end
  object pFIBTransactionReadOnly: TpFIBTransaction
    DefaultDatabase = pFIBDatabaseVera
    Left = 264
    Top = 224
  end
  object pFIBTransactionUpdate: TpFIBTransaction
    DefaultDatabase = pFIBDatabaseVera
    Left = 280
    Top = 152
  end
end
