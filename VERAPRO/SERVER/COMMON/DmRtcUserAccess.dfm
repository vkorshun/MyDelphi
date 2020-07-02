inherited RtcUserAccessDm: TRtcUserAccessDm
  OldCreateOrder = True
  object RtcDataServerLinkUserAccess: TRtcDataServerLink
    Left = 80
    Top = 184
  end
  object RtcServerModuleUserAccess: TRtcServerModule
    Link = RtcDataServerLinkUserAccess
    DataFormats = [fmt_RTC, fmt_JSONrpc2]
    AutoSessions = True
    AutoSessionCheck = True
    ModuleFileName = '/UserAccess'
    FunctionGroup = RtcFunctionGroupUserAccess
    Left = 240
    Top = 136
  end
  object RtcFunctionGroupUserAccess: TRtcFunctionGroup
    Left = 328
    Top = 240
  end
end
