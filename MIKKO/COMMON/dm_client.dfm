object DmClient: TDmClient
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 294
  Width = 439
  object AdsQuery1: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    AdsConnection = DmMikkoAds.AdsConnection1
    Left = 136
    Top = 80
    ParamData = <>
  end
  object AdsQuery2: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    AdsConnection = DmMikkoAds.AdsConnection1
    Left = 152
    Top = 144
    ParamData = <>
  end
  object AdsQueryUpdateParam: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    AdsConnection = DmMikkoAds.AdsConnection1
    Left = 312
    Top = 64
    ParamData = <>
  end
  object AdsQueryInsertParam: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    AdsConnection = DmMikkoAds.AdsConnection1
    Left = 304
    Top = 184
    ParamData = <>
  end
end
