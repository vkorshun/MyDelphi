object DocDm: TDocDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 249
  Width = 309
  object MemTableEhDoc: TMemTableEh
    Params = <>
    DataDriver = DataSetDriverEhDoc
    AfterOpen = MemTableEhDocAfterOpen
    BeforeClose = MemTableEhDocBeforeClose
    Left = 224
    Top = 56
  end
  object DataSetDriverEhDoc: TDataSetDriverEh
    ProviderDataSet = pFIBDataSetVkDoc
    OnUpdateRecord = DataSetDriverEhDocUpdateRecord
    ResolveToDataSet = False
    Left = 72
    Top = 56
  end
  object pFIBQueryVkDocInfo: TpFIBQueryVk
    Left = 192
    Top = 128
    qoStartTransaction = True
  end
  object pFIBDataSetVkDoc: TpFIBDataSetVk
    UniDirectional = True
    Left = 40
    Top = 160
  end
  object pFIBQueryVkLock: TpFIBQueryVk
    Left = 144
    Top = 192
    qoStartTransaction = True
  end
  object pFIBQueryVkUpdate: TpFIBQueryVk
    Left = 240
    Top = 192
    qoStartTransaction = True
  end
end
