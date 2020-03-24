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
    BeforePost = MemTableEhDocBeforePost
    BeforeDelete = MemTableEhDocBeforeDelete
    Left = 224
    Top = 56
  end
  object RtcClientModule1: TRtcClientModule
    Client = MainRtcDm.RtcHttpClient1
    AutoSessions = True
    AutoSessionsPing = 10
    ModuleFileName = '/common'
    Left = 181
    Top = 152
  end
end
