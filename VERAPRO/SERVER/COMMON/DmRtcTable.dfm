inherited RtcTableDm: TRtcTableDm
  object RtcFunctionGroupTable: TRtcFunctionGroup
    Left = 328
    Top = 240
  end
  object RtcServerModuleCommon: TRtcServerModule
    DataFormats = [fmt_RTC, fmt_JSONrpc2]
    AutoSessions = True
    AutoSessionCheck = True
    ModuleFileName = '/table'
    FunctionGroup = RtcFunctionGroupTable
    Left = 240
    Top = 136
  end
  object RtcDataServerLinkCommon: TRtcDataServerLink
    Left = 80
    Top = 184
  end
end
