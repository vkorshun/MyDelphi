inherited RtcCommonFunctionsDm: TRtcCommonFunctionsDm
  OldCreateOrder = True
  object RtcServerModuleCommon: TRtcServerModule
    Link = RtcDataServerLinkCommon
    DataFormats = [fmt_RTC, fmt_JSONrpc2]
    AutoSessions = True
    AutoSessionCheck = True
    ModuleFileName = '/common'
    FunctionGroup = RtcFunctionGroupCommon
    Left = 240
    Top = 136
  end
  object RtcFunctionGroupCommon: TRtcFunctionGroup
    Left = 328
    Top = 240
  end
  object RtcDataServerLinkCommon: TRtcDataServerLink
    Left = 80
    Top = 184
  end
end
