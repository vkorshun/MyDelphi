object DmEntrance: TDmEntrance
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 251
  Width = 338
  object AdsQueryDc162: TAdsQuery
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    Left = 168
    Top = 48
    ParamData = <>
  end
end
