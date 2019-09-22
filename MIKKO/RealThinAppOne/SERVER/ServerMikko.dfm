object ServerMikkoEntrance1: TServerMikkoEntrance1
  OldCreateOrder = False
  DisplayName = 'EntranceServerMikko'
  OnStart = ServiceStart
  Height = 271
  Width = 415
  object HttpServerMikko: TRtcHttpServer
    Left = 80
    Top = 48
  end
end
