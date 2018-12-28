object MainDm: TMainDm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 315
  Width = 380
  object RtcHttpServer1: TRtcHttpServer
    MultiThreaded = True
    OnClientConnect = RtcHttpServer1ClientConnect
    OnClientDisconnect = RtcHttpServer1ClientDisconnect
    Left = 72
    Top = 152
  end
end
