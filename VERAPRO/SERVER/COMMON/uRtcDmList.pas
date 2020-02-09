unit uRtcDmList;

interface

uses
  SysUtils, Classes, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv, Generics.Collections,
  rtcSyncObjs;

type
  PRtcDmListItem = ^RRtcDmListItem;
  RRtcDmListItem = record
    rtcCon: TRtcConnection;
    dm: TDataModule;
  end;


{  PUserInfo = ^RUserInfo;
  RUserInfo = Record
    id_group      :Integer;
    id_user       :Integer;
    id_menu       :Integer;
    user_name     :string;
    user_password :string;
    g_user_name   :string;
    g_role_name   :string;
  end;
 }

{  PUserListItem = ^TUserListItem;
  TUserListItem = record
    RtcConnect: TRtcConnection;
    UserInfo: PUserInfo;
  end;}

//  TRemoteUserList = TList<PUserListItem>;

  TRtcDmList = class
  private
    FMap: TDictionary<String, TDataModule>;
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddDm(ARtcCon:TRtcConnection;ADm:TDataModule);
    procedure Clear;
    procedure DeleteDm(ARtcCon:TRtcConnection);
    function GetDmOnRtc(ARtcCon:TRtcConnection; AClass:TClass):TDataModule;
  end;

  var rtcDmList: TRtcDmList;
implementation

{ TRtcDmList }

procedure TRtcDmList.AddDm(ARtcCon: TRtcConnection; ADm: TDataModule);
begin
  try
    MonitorEnter(FMap);
    FMap.Add(ARtcCon.Session.ID, ADm);
  finally
    MonitorExit(FMap);
  end;
end;

procedure TRtcDmList.Clear;
var key: String;
    dm: TDataModule;
begin
  MonitorEnter(FMap);
  try
    for key in FMap.Keys do
    begin
      dm := FMap[key];
      if Assigned(dm) then
        dm.Free;
    end;
    FMap.Clear
  finally
    MonitorExit(FMap);
  end;
end;

constructor TRtcDmList.Create;
begin
  inherited;
  FMap := TDictionary<String,TDataModule>.create;
end;

procedure TRtcDmList.DeleteDm(ARtcCon:TRtcConnection);
var i: Integer;
    key: String;
    dm: TDataModule;
begin
  MonitorEnter(FMap);
  try
    key := ARtcCon.Session.ID;
    dm := FMap[key];
    if Assigned(dm) then
      dm.Free;
  finally
    MonitorExit(FMap);
  end;
end;

destructor TRtcDmList.Destroy;
begin
  FreeAndNil(FMap);
  inherited;
end;

function TRtcDmList.GetDmOnRtc(ARtcCon: TRtcConnection; AClass: TClass): TDataModule;
var p: PRtcDmListItem;
    i: Integer;
    key: String;
begin
  Result := nil;
  MonitorEnter(FMap);
  key := ARtcCon.Session.ID;
  try
    if FMap.ContainsKey(key) then
      Result := FMap[key];
  finally
    MonitorExit(FMap);
  end;
end;


initialization
  rtcDmList:= TRtcDmList.Create;
finalization
  FreeAndNil(rtcDmList);
end.
