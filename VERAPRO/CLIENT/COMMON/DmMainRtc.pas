unit DmMainRtc;

interface

uses
  System.SysUtils, System.Classes, rtcInfo, rtcConn, rtcDataCli, rtcHttpCli,
  RtcSqlQuery, rtcCliModule, commoninterface, Dialogs,
  DCPsha256, Rtti, rtcFunction, RtcFuncResult, RtcQueryDataSet;

type

  TMainRtcDm = class(TDataModule)
    RtcHttpClient1: TRtcHttpClient;
    RtcClientModule1: TRtcClientModule;
    RtcResult1: TRtcResult;
    procedure DataModuleCreate(Sender: TObject);
    procedure RtcHttpClient1ConnectLost(Sender: TRtcConnection);
    procedure RtcClientModule1ConnectLost(Sender: TRtcConnection);
  private
    { Private declarations }
    DCP_sha2561: TDCP_sha256;
    FUserInfo: PUserInfo;
    query: TRtcQuery;
    procedure test;
    function rtcLogin(): Boolean;
  public
    { Public declarations }
    // procedure test();
    function getPasswordHash(const pwd: String): UTF8String;
    function Login(const userName, password: String): Boolean;
    function NewRtcQueryDataSet: TRtcQueryDataSet;
    procedure SetUser(Param: TRtcFunctionInfo);
//    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): variant; overload;
    class procedure CloneComponent(const aSource, aDestination: TComponent);
    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): IRtcFuncResult; overload;
  end;

var
  MainRtcDm: TMainRtcDm;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TMainRtcDm.DataModuleCreate(Sender: TObject);
begin
  DCP_sha2561 := TDCP_sha256.Create(self);
  RtcHttpClient1.Connect();

end;

function TMainRtcDm.getPasswordHash(const pwd: String): UTF8String;
var
  buf: UTF8String;
  digest: array [0 .. 31] of byte;
  I: Integer;
begin
  buf := UTF8String(pwd);
  DCP_sha2561.Init();
  DCP_sha2561.UpdateStr(buf);
  DCP_sha2561.Final(digest);
  Result := StringOfChar(#0, 64);
  for I := 0 to length(digest) - 1 do
  begin
    buf := Int2Hex(digest[I], 2).ToUpper;
    Result[I * 2 + 1] := buf[1];
    Result[I * 2 + 2] := buf[2];
  end;

end;

function TMainRtcDm.Login(const userName, password: String): Boolean;
begin
  FUserInfo := new(PUserInfo);
  FUserInfo.user_name := userName;
  FUserInfo.user_password := getPasswordHash(password);
  Result := rtcLogin();
  // query := TRtcQuery.Create(RtcClientModule1, FUserInfo );
  // query.QueryValue('SELECT CAST(HASH(CAST(:pas as CHAR(20))) as CHAR(20)) as pwd FROM rdb$database', [password]);
end;

function TMainRtcDm.NewRtcQueryDataSet: TRtcQueryDataSet;
begin
   Result := TRtcQueryDataSet.Create(RtcClientModule1,FUserInfo);
end;

procedure TMainRtcDm.RtcClientModule1ConnectLost(Sender: TRtcConnection);
begin
  // RtcHTTPClient1.Disconnect;
  // RtcHTTPClient1.Connect();
  RtcClientModule1.Release;
end;

class function TMainRtcDm.rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): IRtcFuncResult;
var
  retval: TRtcValue;
begin
  retval := nil;
  try
    with func do
    begin
      retval := clientModule.Execute(False, 0, False);
      if retval.isType = rtc_Exception then
      begin
        Raise Exception.Create(retval.asException);
      end;
      Result := TRtcFuncResult.Create(retval);

    end;
  finally
//    FreeAndNil(retval);
  end;
end;

{class function TMainRtcDm.rtcExecute(clientModule: TRtcClientModule; func: TRtcFunctionInfo): TRtcDataSet;overload;
var
  retval: TRtcValue;
begin
  retval := nil;
  try
    with func do
    begin
      retval := clientModule.Execute(False, 0, False);
      if retval.isType = rtc_Exception then
      begin
        Raise Exception.Create(retval.asException);
      end;
      Result:= retval.asDataSet ;
    end;
  finally
    FreeAndNil(retval);
  end;

end;}

procedure TMainRtcDm.RtcHttpClient1ConnectLost(Sender: TRtcConnection);
begin
  // RtcHTTPClient1.Disconnect;
  ShowMessage('LOST');
end;

function TMainRtcDm.rtcLogin: Boolean;
var
//  Retval: TRtcValue;
  func: TRtcFunctionInfo;
begin
  with RtcClientModule1 do
  begin
    try
    with Prepare('RtcConnect') do
    begin
      Param.asWideString['username'] := FUserInfo.user_name;
      Param.asWideString['password'] := FUserInfo.user_password;
      Result := rtcExecute(RtcClientModule1, RtcClientModule1.Data.asFunction).getRtcValue.asInteger = 0;
    end;
    finally
//      FreeAndNil(Retval);
    end;
  end;
end;

procedure TMainRtcDm.SetUser(Param: TRtcFunctionInfo);
begin
  Param.asWideString['username'] := FUserInfo.user_name;
  Param.asWideString['password'] := FUserInfo.user_password;
end;

procedure TMainRtcDm.test;
begin
  RtcHttpClient1.Connect();
  ShowMessage(query.QueryValue
    ('SELECT name FROM objects WHERE idobject=:id_object', [4]));

end;

class procedure TMainRtcDm.CloneComponent(const aSource, aDestination: TComponent);
var
  ctx: TRttiContext;
  RttiType, DestType: TRttiType;
  RttiProperty: TRttiProperty;
  Buffer: TStringlist;

begin
  if aSource.ClassType <> aDestination.ClassType then
    raise Exception.Create('Source and destiantion must be the same class');

  Buffer := TStringlist.Create;
  try
    Buffer.Sorted := True;
    Buffer.Add('Name');
    Buffer.Add('Handle');

    RttiType := ctx.GetType(aSource.ClassType);
    DestType := ctx.GetType(aDestination.ClassType);
    for RttiProperty in RttiType.GetProperties do
    begin
      if not RttiProperty.IsWritable then
        continue;

      if Buffer.IndexOf(RttiProperty.Name) >= 0 then
        continue;

      DestType.GetProperty(RttiProperty.Name).SetValue(aDestination, RttiProperty.GetValue(aSource));
    end;
  finally
    Buffer.Free;
  end;
end;

end.
