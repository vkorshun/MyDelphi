unit dm_EntranseMethodsMikko;

interface

uses
  SysUtils, Classes, rtcDataSrv, rtcSrvModule, rtcLink, rtcInfo, rtcConn, rtcFunction, dm_mikkoads,
  dm_entrance;

type
  TDmEntranceMethodsMikko = class(TDataModule)
    RtcEntranceGroup: TRtcFunctionGroup;
    RtcServModuleEntrance: TRtcServerModule;
    RtcDataServerLink1: TRtcDataServerLink;
    RtcFunction1: TRtcFunction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FDmMikkoAds: TDmMikkoAds;
    FDmEntrance: TDmEntrance;
    procedure RegisterEntranceFunction(const aname:String; fExecute: TRtcFunctionCallEvent);
    procedure RtcFunConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

  public
    { Public declarations }
  end;

var
  DmEntranceMethodsMikko: TDmEntranceMethodsMikko;
  handle_connection: Integer;

implementation

{$R *.dfm}
uses ServerMikko;

{ TDataModule1 }

procedure TDmEntranceMethodsMikko.DataModuleCreate(Sender: TObject);
begin
  RegisterEntranceFunction('Connect',RtcFunConnect);
end;

procedure TDmEntranceMethodsMikko.RegisterEntranceFunction(const aname: String; fExecute: TRtcFunctionCallEvent);
var mRtcFunction: TRtcFunction;
begin
  mRtcFunction := TRtcFunction.Create(self);
  with mRtcFunction do
  begin
    FunctionName := aname;
    Group := RtcEntranceGroup;
    OnExecute := fExecute;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcFunConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
var aUserName, aPassword: string;
    aIdOffice: Integer;
begin
  Inc(handle_connection) ;
  aUserName := Param.AsString['username'];
  aPassword := Param.AsString['password'];
  aIdOffice := Param.AsInteger['IdOffice'];
  FDmMikkoAds := TDmMikkoAds.Create(self);
  FDmEntrance := TDmEntrance.Create(self);
  FDmEntrance.DmMikkoAds := FDmMikkoAds;
  FDmEntrance.handle_connection := handle_connection;
  if FDmMikkoAds.ServerLogin(aUserName,aPassword) then
    Result.asInteger := handle_connection
  else
    Result.asInteger := 0;
  FDmEntrance.kodEntrance := aIdOffice;
  //DataSetProviderDc162.DataSet := FDmEntrance.AdsQueryDc162;
  //DataSetProviderDc167.DataSet := FDmEntrance.AdsQueryDc167;
  FDmEntrance.OpenRegistration;
  //ClearOldData;

end;

Initialization;
  handle_connection := 0;
end.
