inherited RtcUseMonthDm: TRtcUseMonthDm
  OldCreateOrder = True
  object RtcDataServerLinkUseMonth: TRtcDataServerLink
    Left = 80
    Top = 184
  end
  object RtcServerModuleUseMonth: TRtcServerModule
    Link = RtcDataServerLinkUseMonth
    ModuleFileName = '/usemonth'
    FunctionGroup = RtcFunctionGroupUseMonth
    Left = 240
    Top = 136
  end
  object RtcFunctionGroupUseMonth: TRtcFunctionGroup
    Left = 328
    Top = 240
  end
end
