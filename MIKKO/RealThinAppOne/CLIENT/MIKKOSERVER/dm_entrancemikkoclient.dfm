object DmEntranceMikkoClient: TDmEntranceMikkoClient
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 326
  Width = 318
  object RtcHttpClient1: TRtcHttpClient
    MultiThreaded = True
    OnDisconnect = RtcHttpClient1Disconnect
    ReconnectOn.ConnectError = True
    ReconnectOn.ConnectLost = True
    ReconnectOn.ConnectFail = True
    AutoConnect = True
    Left = 168
    Top = 64
  end
  object RtcClientModule1: TRtcClientModule
    AutoSyncEvents = True
    Client = RtcHttpClient1
    Compression = cDefault
    AutoRepost = 2
    ModuleFileName = '/Entrance'
    Left = 64
    Top = 72
  end
  object RtcResult1: TRtcResult
    OnReturn = RtcResult1Return
    Left = 224
    Top = 160
  end
  object MemTableEhDc162: TMemTableEh
    Params = <>
    AfterOpen = MemTableEhDc162AfterOpen
    BeforePost = MemTableEhDc162BeforePost
    Left = 152
    Top = 232
  end
  object RtcDataSetMonitor1: TRtcDataSetMonitor
    DataSet = MemTableEhDc162
    OnDataChange = RtcDataSetMonitor1DataChange
    Left = 96
    Top = 144
  end
end
