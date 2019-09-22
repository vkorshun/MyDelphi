unit dm_personalentrance;

interface

uses
  SysUtils, Classes, dm_MikkoAds, SuperObject,superdate, DB, adsdata, adsfunc, adstable, dm_entrance;

type
  TDmPersonalEntrance = class(TDataModule)
    AdsQueryDc162: TAdsQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    FDmMikkoAds: TDmMikkoAds;
    FHandle_connection: Integer;
    procedure SetDmMikkoads(const Value: TDmMikkoAds);
    { Private declarations }
  public
    { Public declarations }
    property DmMikkoAds: TDmMikkoAds read FDmMikkoAds write SetDmMikkoads;
//    property handle_connection: Integer read FHandle_connection write FHandle_connection;
    function GetCurrentStatus(const AUserName,APassword: String):ISuperObject;
    function SetCurrentStatus(const AUserName,APassword: String; bEnter: Boolean):ISuperObject;
    function GetCurrentState(const AUserName,APassword: String):ISuperObject;
  end;

var
  DmPersonalEntrance: TDmPersonalEntrance;

implementation

{$R *.dfm}

{ TDataModule1 }

procedure TDmPersonalEntrance.DataModuleCreate(Sender: TObject);
begin
  FDmMikkoAds := TDmMikkoAds.Create(self);
  with AdsQueryDc162 do
  begin
    DataBaseName := 'FDmMikkoAds.AdsConnection1';
    if Assigned(FDmMikkoAds.AdsConnection1) then
      AdsConnection := FDmMikkoAds.AdsConnection1;
  end;
end;

function TDmPersonalEntrance.GetCurrentState(const AUserName, APassword: String): ISuperObject;
var sError: String;
    mDmEntrance : TDmEntrance;
    dt: TDateTime;
begin
  Result := SO('{}');
  dt := now - 30;
  if FDmMikkoAds.JavaLogin(AuserName, APassword, sError) then
  try
    mDmEntrance := TDmEntrance.Create(self);
    mDmEntrance.DmMikkoAds := FDmMikkoAds;
    mDmEntrance.kodEntrance := KOD_ENTRANCE_MIKKO;
    Result := mDmEntrance.GetLastEvent(FDmMikkoAds.pUserInfo.nUserAliasKodkli,dt);
{*    if mDmEntrance.CheckIsOut(FDmMikkoAds.pUserInfo.nUserAliasKodkli,dt)=True then
    begin
      Result.B['input'] := true;
      Result.I['time']  :=  DelphiToJavaDateTime(dt);
      Result.S['error'] := '';
    end
    else
    begin
      Result.S['error'] := 'Нет отметки о приходе';
      Result.I['time']  :=  DelphiToJavaDateTime(now);
      Result.B['input'] := false;
    end;*}
  except
    on E: Exception do
      Result.S['error'] := E.message;
  end
  else
    Result.S['error'] := sError;
end;

function TDmPersonalEntrance.GetCurrentStatus(const AUserName, APassword: String): ISuperObject;
var sError: String;
    mDmEntrance : TDmEntrance;
    dt: TDateTime;
begin
  Result := SO('{}');
  dt := now;
  if FDmMikkoAds.JavaLogin(AuserName, APassword, sError) then
  try
    mDmEntrance := TDmEntrance.Create(self);
    mDmEntrance.DmMikkoAds := FDmMikkoAds;
    mDmEntrance.kodEntrance := KOD_ENTRANCE_MIKKO;
    if mDmEntrance.CheckIsOut(FDmMikkoAds.pUserInfo.nUserAliasKodkli,dt)=True then
    begin
      Result.B['input'] := true;
      Result.I['time']  :=  DelphiToJavaDateTime(dt);
      Result.S['error'] := '';
    end
    else
    begin
      Result.S['error'] := 'Нет отметки о приходе';
      Result.I['time']  :=  DelphiToJavaDateTime(now);
      Result.B['input'] := false;
    end;
  except
    on E: Exception do
      Result.S['error'] := E.message;
  end
  else
    Result.S['error'] := sError;
end;

procedure TDmPersonalEntrance.SetDmMikkoads(const Value: TDmMikkoAds);
begin
  FDmMikkoAds := Value;
  with AdsQueryDc162 do
  begin
    DataBaseName := 'FDmMikkoAds.AdsConnection1';
    if Assigned(FDmMikkoAds.AdsConnection1) then
      AdsConnection := FDmMikkoAds.AdsConnection1;
  end;
end;

function TDmPersonalEntrance.SetCurrentStatus(const AUserName, APassword: String; bEnter: Boolean): ISuperObject;
var sError: String;
    mDmEntrance : TDmEntrance;
    dt: TDateTime;
    b: Boolean;
begin
  Result := SO('{}');
  dt := 0;
  if FDmMikkoAds.JavaLogin(AuserName, APassword, sError) then
  try
    mDmEntrance := TDmEntrance.Create(self);
    mDmEntrance.DmMikkoAds := FDmMikkoAds;
    mDmEntrance.kodEntrance := KOD_ENTRANCE_MIKKO;
    if mDmEntrance.CheckIsOut(FDmMikkoAds.pUserInfo.nUserAliasKodkli,dt)=True then
    begin
      b := false;
    end
    else
    begin
      b := true;
    end;
    Result := GetCurrentState(AUserName, APassword);
    Result.I['time']  :=  DelphiToJavaDateTime(Now);
    Result.S['error'] := '';
    Result.B['input'] := true;
  except
    on E: Exception do
      Result.S['error'] := E.message;
  end
  else
    Result.S['error'] := sError;

end;

end.
