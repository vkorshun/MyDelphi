object DmEntranceMethodsMikko: TDmEntranceMethodsMikko
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 396
  Width = 594
  object RtcEntranceGroup: TRtcFunctionGroup
    Left = 264
    Top = 56
  end
  object RtcServModuleEntrance: TRtcServerModule
    Link = RtcDataServerLink1
    Compression = cDefault
    ModuleFileName = '/Entrance'
    FunctionGroup = RtcEntranceGroup
    Left = 136
    Top = 176
  end
  object RtcDataServerLink1: TRtcDataServerLink
    Left = 120
    Top = 64
  end
  object RtcFunction1: TRtcFunction
    Left = 416
    Top = 144
  end
  object WebSockProvider: TRtcDataProvider
    Link = RtcDataServerLink1
    OnCheckRequest = WebSockProviderCheckRequest
    OnWSConnect = WebSockProviderWSConnect
    OnWSDataReceived = WebSockProviderWSDataReceived
    Left = 288
    Top = 232
  end
end
