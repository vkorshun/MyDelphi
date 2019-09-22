object DmPersonalEntrance: TDmPersonalEntrance
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 241
  Width = 286
  object AdsQueryDc162: TAdsQuery
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    Left = 168
    Top = 48
    ParamData = <>
  end
end
