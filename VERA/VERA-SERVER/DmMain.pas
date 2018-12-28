unit DmMain;

interface

uses
  System.SysUtils, System.Classes, rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv, rtcSyncObjs,
  SettingsStorage, Forms;

type
  TMainDm = class(TDataModule)
    RtcHttpServer1: TRtcHttpServer;
    procedure DataModuleCreate(Sender: TObject);
    procedure RtcHttpServer1ClientConnect(Sender: TRtcConnection);
    procedure RtcHttpServer1ClientDisconnect(Sender: TRtcConnection);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FCs: TRtcCritSec;
    FUserCount: Integer;
    FOnServerEvent: TNotifyEvent;
    FStorage: TSettingsStorage;
  public
    { Public declarations }
    property OnServerEvent: TNotifyEvent read FOnServerEvent write FOnServerEvent;
  end;

var
  MainDm: TMainDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TMainDm.DataModuleCreate(Sender: TObject);
begin
  FCs:= TRtcCritSec.Create;
  FUserCount := 0;
//  fini := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage := TSettingsStorage.Create(ChangeFileExt(Application.ExeName,'.ini'));
  RtcHttpServer1.ServerPort := FStorage.GetVariable('SET','port',6274).AsString;
  RtcHttpServer1.OnClientConnect := RtcHttpServer1ClientConnect;
  RtcHttpServer1.OnClientDisConnect := RtcHttpServer1ClientDisconnect;
  RtcHttpServer1.Listen();

end;

procedure TMainDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FStorage);
  FreeAndNil(FCs);
end;

procedure TMainDm.RtcHttpServer1ClientConnect(Sender: TRtcConnection);
begin
  FCs.Acquire;
  try
    Inc(FUserCount);
    if Assigned(FOnServerEvent) then
      FOnserverEvent(self);
  finally
    FCs.Release;
  end;

end;

procedure TMainDm.RtcHttpServer1ClientDisconnect(Sender: TRtcConnection);
begin
  FCs.Acquire;
  try
    Dec(FUserCount);
    if Assigned(FOnServerEvent) then
      FOnserverEvent(self);
  finally
    FCs.Release;
  end;

end;

end.
