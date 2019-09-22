object ServerMikkoEntrance1: TServerMikkoEntrance1
  OldCreateOrder = False
  DisplayName = 'EntranceServerMikko'
  OnStart = ServiceStart
  Height = 271
  Width = 415
  object HttpServerMikko: TRtcHttpServer
    OnClientDisconnect = HttpServerMikkoClientDisconnect
    OnListenLost = HttpServerMikkoListenLost
    Left = 80
    Top = 48
  end
  object RtcDataProvider1: TRtcDataProvider
    Server = HttpServerMikko
    OnCheckRequest = RtcDataProvider1CheckRequest
    OnDataReceived = RtcDataProvider1DataReceived
    Left = 192
    Top = 72
  end
end
