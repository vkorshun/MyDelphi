object DocDm: TDocDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 249
  Width = 309
  object MemTableEhDoc: TMemTableEh
    Params = <>
    AfterOpen = MemTableEhDocAfterOpen
    BeforeClose = MemTableEhDocBeforeClose
    Left = 224
    Top = 56
  end
  object DataSetDriverEhDoc: TDataSetDriverEh
    OnUpdateRecord = DataSetDriverEhDocUpdateRecord
    ResolveToDataSet = False
    Left = 72
    Top = 56
  end
end
