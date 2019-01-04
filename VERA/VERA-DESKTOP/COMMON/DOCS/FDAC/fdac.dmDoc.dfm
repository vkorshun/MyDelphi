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
    ProviderDataSet = FDQueryDoc
    OnUpdateRecord = DataSetDriverEhDocUpdateRecord
    Left = 72
    Top = 56
  end
  object FDCommandLock: TFDCommand
    Left = 72
    Top = 120
  end
  object FDCommandUpdate: TFDCommand
    Left = 224
    Top = 120
  end
  object FDQueryDoc: TFDQuery
    FetchOptions.AssignedValues = [evMode, evRecordCountMode, evUnidirectional, evCursorKind, evLiveWindowFastFirst]
    FetchOptions.Unidirectional = True
    FetchOptions.RecordCountMode = cmFetched
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvGeneratorName, uvCheckUpdatable]
    Left = 152
    Top = 184
  end
  object FDMetaInfoQueryDoc: TFDMetaInfoQuery
    FetchOptions.AssignedValues = [evUnidirectional]
    FetchOptions.Unidirectional = True
    MetaInfoKind = mkTableFields
    Left = 64
    Top = 184
  end
end
