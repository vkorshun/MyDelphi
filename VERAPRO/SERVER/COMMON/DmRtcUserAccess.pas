unit DmRtcUserAccess;

interface

uses
  System.SysUtils, System.Classes, DmRtcCustom, rtcFunction, rtcSrvModule,
  rtcInfo, rtcConn, rtcDataSrv;

type
  TRtcUserAccessDm = class(TRtcCustomDm)
    RtcDataServerLinkUserAccess: TRtcDataServerLink;
    RtcServerModuleUserAccess: TRtcServerModule;
    RtcFunctionGroupUserAccess: TRtcFunctionGroup;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure RtcGetSqltableProperties(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
  end;

var
  RtcUserAccessDm: TRtcUserAccessDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
