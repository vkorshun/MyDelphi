object DmMikkoDoc: TDmMikkoDoc
  OldCreateOrder = False
  OnDestroy = DataModuleDestroy
  Height = 392
  Width = 767
  object AdsQuery1: TAdsQuery
    StoreActive = True
    SourceTableType = ttAdsCDX
    Left = 592
    Top = 80
    ParamData = <>
  end
  object AdsQueryDoc: TAdsQuery
    StoreActive = True
    SourceTableType = ttAdsCDX
    Left = 600
    Top = 208
    ParamData = <>
  end
  object MemTableEhDoc: TMemTableEh
    Params = <>
    DataDriver = DataSetDriverEh1
    Left = 448
    Top = 168
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = AdsQueryDoc
    OnUpdateRecord = DataSetDriverEh1UpdateRecord
    Left = 280
    Top = 104
  end
end
