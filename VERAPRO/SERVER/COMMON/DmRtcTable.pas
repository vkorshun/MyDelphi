unit DmRtcTable;

interface

uses
  System.SysUtils, System.Classes, DmRtcCustom, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv, rtcDB;

type
  TRtcTableDm = class(TRtcCustomDm)
    RtcFunctionGroupTable: TRtcFunctionGroup;
    RtcServerModuleCommon: TRtcServerModule;
    RtcDataServerLinkCommon: TRtcDataServerLink;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure RtcTableAction(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);

  end;

var
  RtcTableDm: TRtcTableDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TRtcTableDm }

procedure TRtcTableDm.RtcTableAction(Sender: TRtcConnection; FnParams: TRtcFunctionInfo; Result: TRtcValue);
var action: String;
begin
   //if  then

end;

end.
