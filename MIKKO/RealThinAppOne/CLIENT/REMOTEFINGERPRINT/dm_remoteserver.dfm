object DmRemoteServer: TDmRemoteServer
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 341
  Width = 451
  object RtcClientModule1: TRtcClientModule
    AutoSyncEvents = True
    Client = RtcHttpClient1
    Compression = cDefault
    AutoRepost = 2
    ModuleFileName = '/Entrance'
    Left = 64
    Top = 72
  end
  object RtcDataSetMonitor1: TRtcDataSetMonitor
    Left = 96
    Top = 144
  end
  object RtcHttpClient1: TRtcHttpClient
    MultiThreaded = True
    ReconnectOn.ConnectError = True
    ReconnectOn.ConnectLost = True
    ReconnectOn.ConnectFail = True
    AutoConnect = True
    Left = 168
    Top = 64
  end
  object RtcResult1: TRtcResult
    Left = 224
    Top = 160
  end
end
