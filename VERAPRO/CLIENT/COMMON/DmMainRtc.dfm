object MainRtcDm: TMainRtcDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 323
  Width = 492
  object RtcHttpClient1: TRtcHttpClient
    MultiThreaded = True
    ServerAddr = 'localhost'
    ServerPort = '6273'
    OnConnectLost = RtcHttpClient1ConnectLost
    AutoConnect = True
    UseWinHTTP = True
    TimeoutsOfAPI.ConnectTimeout = 10000
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
  object RtcDataRequest1: TRtcDataRequest
    Client = RtcHttpClient1
    OnBeginRequest = RtcDataRequest1BeginRequest
    OnResponseDone = RtcDataRequest1ResponseDone
    Left = 376
    Top = 200
  end
end
