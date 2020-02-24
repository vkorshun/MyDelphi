object MainRtcDm: TMainRtcDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 323
  Width = 492
  object RtcHttpClient1: TRtcHttpClient
    MultiThreaded = True
    ServerAddr = 'localhost'
    ServerPort = '6476'
    OnConnectLost = RtcHttpClient1ConnectLost
    AutoConnect = True
    Left = 112
    Top = 136
  end
  object RtcClientModule1: TRtcClientModule
    Client = RtcHttpClient1
    AutoSessions = True
    AutoSessionsPing = 10
    ModuleFileName = '/common'
    OnConnectLost = RtcClientModule1ConnectLost
    Left = 280
    Top = 128
  end
  object RtcResult1: TRtcResult
    Left = 256
    Top = 216
  end
end
