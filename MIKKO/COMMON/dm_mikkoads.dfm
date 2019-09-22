object DmMikkoAds: TDmMikkoAds
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 403
  Width = 627
  object AdsQueryNewNum: TAdsQuery
    DatabaseName = 'AdsConNewNum'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    RequestLive = True
    SourceTableType = ttAdsCDX
    AdsConnection = AdsConNewNum
    Left = 120
    Top = 24
    ParamData = <>
  end
  object AdsConNewNum: TAdsConnection
    IsConnected = False
    AdsServerTypes = [stADS_REMOTE]
    LoginPrompt = True
    Compression = ccAdsCompressionNotSet
    CommunicationType = ctAdsDefault
    Left = 120
    Top = 88
  end
  object AdsConnection1: TAdsConnection
    IsConnected = False
    AdsServerTypes = [stADS_REMOTE]
    LoginPrompt = True
    Compression = ccAdsCompressionNotSet
    CommunicationType = ctAdsDefault
    Left = 256
    Top = 248
  end
  object AdsTableParoll: TAdsTable
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsConnection = AdsConnection1
    AdsTableOptions.AdsCharType = OEM
    TableName = 'paroll.dbf'
    TableType = ttAdsCDX
    Left = 280
    Top = 104
  end
  object AdsQueryProtocol: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    RequestLive = True
    SourceTableType = ttAdsCDX
    AdsConnection = AdsConnection1
    Left = 352
    Top = 160
    ParamData = <>
  end
  object AdsQuery2: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    RequestLive = True
    SourceTableType = ttAdsCDX
    AdsConnection = AdsConnection1
    Left = 360
    Top = 88
    ParamData = <>
  end
  object AdsQueryDoc: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    RequestLive = True
    SourceTableType = ttAdsCDX
    AdsConnection = AdsConnection1
    Left = 368
    Top = 24
    ParamData = <>
  end
  object AdsQuery1: TAdsQuery
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    RequestLive = True
    SourceTableType = ttAdsCDX
    AdsConnection = AdsConnection1
    Left = 280
    Top = 24
    ParamData = <>
  end
  object AdsTableLockOper: TAdsTable
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsConnection = AdsConnection1
    AdsTableOptions.AdsCharType = OEM
    TableName = 'tools\lockoper'
    TableType = ttAdsCDX
    Left = 264
    Top = 176
  end
  object TbKurs: TAdsTable
    DatabaseName = 'AdsConnection1'
    StoreActive = True
    AdsConnection = AdsConnection1
    AdsTableOptions.AdsCharType = OEM
    TableName = 'kurs'
    TableType = ttAdsCDX
    Left = 408
    Top = 264
  end
end
