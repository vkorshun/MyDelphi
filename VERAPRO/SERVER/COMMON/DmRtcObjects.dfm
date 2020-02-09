inherited RtcObjectsDm: TRtcObjectsDm
  OldCreateOrder = True
  object RtcDataServerLinkObjects: TRtcDataServerLink
    Left = 80
    Top = 184
  end
  object RtcServerModuleObjects: TRtcServerModule
    Link = RtcDataServerLinkObjects
    ModuleFileName = '/objects'
    FunctionGroup = RtcFunctionGroupObjects
    Left = 240
    Top = 136
  end
  object RtcFunctionGroupObjects: TRtcFunctionGroup
    Left = 328
    Top = 240
  end
end
