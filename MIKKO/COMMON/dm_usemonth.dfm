object DmUseMonth: TDmUseMonth
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 261
  Width = 399
  object AdsQuery1: TAdsQuery
    StoreActive = True
    AdsTableOptions.AdsCharType = OEM
    SourceTableType = ttAdsCDX
    Left = 176
    Top = 72
    ParamData = <>
  end
end
