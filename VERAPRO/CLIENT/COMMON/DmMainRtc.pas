unit DmMainRtc;

interface

uses
  System.SysUtils, System.Classes, rtcInfo, rtcConn, rtcDataCli, rtcHttpCli,
  RtcSqlQuery, rtcCliModule, commoninterface, Dialogs, Forms, Variants, SettingsStorage,
  DCPsha256, Rtti, rtcFunction, RtcFuncResult, RtcQueryDataSet, u_xmlinit, vkvariable;

type

  TMainRtcDm = class(TDataModule)
    RtcHttpClient1: TRtcHttpClient;
    RtcClientModule1: TRtcClientModule;
    RtcResult1: TRtcResult;
    procedure DataModuleCreate(Sender: TObject);
    procedure RtcHttpClient1ConnectLost(Sender: TRtcConnection);
    procedure RtcClientModule1ConnectLost(Sender: TRtcConnection);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    DCP_sha2561: TDCP_sha256;
    FUserInfo: PUserInfo;
    query: TRtcQuery;
    FXmlIni: TXmlIni;
    FUserAccessTypes: TVkVariableCollection;
    FUserAccessValues: TVkVariableCollection;
    FStorage: TSettingsStorage;

    procedure test;
    function rtcLogin(): Boolean;
  public
    { Public declarations }
    // procedure test();
    function getPasswordHash(const pwd: String): UTF8String;
    function Login(const userName, password: String): Boolean;
    function NewRtcQueryDataSet: TRtcQueryDataSet;
    function Gen_ID(const key:String):Int64;
    function GetTypeGroup( AId: LargeInt): LargeInt;

    function RtcQueryValue(const SQL:String; params: array of Variant):IRtcFuncResult;
    function QueryValue(const SQL:String; params: array of Variant):Variant;
    function QueryValues(const AVarList:TVkVariableCollection; const SQL:String; params: array of Variant):Variant;
    procedure DoRequest(const ASql:String;const AParams: TVariants; AOnRequest: TOnRequest = nil);
    procedure SetUser(Param: TRtcFunctionInfo);
//    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): variant; overload;
    class procedure CloneComponent(const aSource, aDestination: TComponent);
    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): IRtcFuncResult; overload;
    property UserAccessTypes: TVkVariableCollection read FUserAccessTypes;
    property UserAccessValues: TVkVariableCollection read FUserAccessValues;
    property XmlInit: TXmlIni read FXmlIni;
    property UserInfo:PUserInfo read FUserInfo;
  end;

var
  MainRtcDm: TMainRtcDm;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TMainRtcDm.DataModuleCreate(Sender: TObject);
begin
  DCP_sha2561 := TDCP_sha256.Create(self);
  FStorage := TSettingsStorage.Create(TSettingsStorage.GetDefaultStorageName);
  FStorage.Read;
  RtcHttpClient1.ServerAddr := fStorage.GetVariable('SEREVR','host','localhost').AsString;
  RtcHttpClient1.ServerPort := fStorage.GetVariable('SEREVR','port','6476').AsString;
  RtcHttpClient1.Connect();
  FXmlIni := TXmlIni.Create(self,ChangeFileExt(Application.ExeName,'.xml'));
  FUserAccessTypes := TVkVariableCollection.Create(self);
  FUserAccessValues := TVkVariableCollection.Create(self);
end;

procedure TMainRtcDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FXmlIni);
  FreeAndNil(FStorage);
end;

procedure TMainRtcDm.DoRequest(const ASql: String; const AParams: TVariants; AOnRequest: TOnRequest);
var qr: TRtcQuery;
    i: Integer;
begin
  qr := TRtcQuery.Create(RtcClientModule1, FUserInfo);
  try
    qr.SQL.Text := ASql;
    if Assigned(AParams) then
      for i:=Low(AParams)  to High(AParams) do
        qr.Params[i].Value := AParams[i];
    qr.DoRequest(AOnRequest);
  finally
    qr.Free;
  end;
end;

function TMainRtcDm.Gen_ID(const key: String): Int64;
begin
  with RtcClientModule1 do
  begin
    try
    with Prepare('RtcGen_ID') do
    begin
      Param.asWideString['username'] := FUserInfo.user_name;
      Param.asWideString['password'] := FUserInfo.user_password;
      Param.asWideString['ID_NAME']  := key;
      Result := rtcExecute(RtcClientModule1, RtcClientModule1.Data.asFunction).getRtcValue.asLargeInt;
    end;
    finally
//      FreeAndNil(Retval);
    end;
  end;
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

function TMainRtcDm.QueryValue(const SQL: String; params: array of Variant): Variant;
var i: Integer;
    retval: IRtcFuncResult;
begin
  retval := RtcQueryValue(SQL, params);
  if Assigned(retval) then
  begin
    if (retval.RtcValue.isType = rtc_Array) then
    begin
      Result := VarArrayCreate([0,retval.RtcValue.asArray.Count], varVariant);
      for I := 0 to retval.RtcValue.asArray.Count-1 do
        Result[i] := retval.RtcValue.asArray.asValue[i];
    end
    else
      Result := retval.RtcValue.asValue;
  end
  else
    Result := null;
end;

function TMainRtcDm.QueryValues(const AVarList: TVkVariableCollection; const SQL: String; params: array of Variant): Variant;
var i: Integer;
    retval: IRtcFuncResult;
    _v: TVkVariable;
begin
  retval := RtcQueryValue(SQL, params);
  if Assigned(retval) and (retval.RtcValue.isType = rtc_Record) then
  begin
    for i := 0 to retval.RtcValue.asRecord.Count - 1 do
    begin
      _v := TVkVariable.Create(AVarList);
      _v.Name := retval.RtcValue.asRecord.FieldName[i];
      _v.Value := retval.RtcValue.asRecord.asValue[_v.Name];
    end;
  end;
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
  Retval: TRtcValue;
  func: TRtcFunctionInfo;
begin
  with RtcClientModule1 do
  begin
    try
    with Prepare('RtcConnect') do
    begin
      Param.asWideString['username'] := FUserInfo.user_name;
      Param.asWideString['password'] := FUserInfo.user_password;
      Retval := rtcExecute(RtcClientModule1, RtcClientModule1.Data.asFunction).getRtcValue;
      Result := Retval.asRecord.asInteger['RESULT'] = 0;
      TUtils.RtcToVkVariableColections(Retval.asRecord.asRecord['USERACCESSTYPES'], FUserAccessTypes);
      TUtils.RtcToVkVariableColections(Retval.asRecord.asRecord['USERACCESSVALUES'], FUserAccessValues);
      TUtils.RtcValueToRecord(Retval.asRecord.asRecord['USERINFO'],FUserInfo, TypeInfo(RUserInfo));
    end;
    finally
//      FreeAndNil(Retval);
    end;
  end;
end;

function TMainRtcDm.RtcQueryValue(const SQL: String; params: array of Variant): IRtcFuncResult;
var i: Integer;
begin
//  Result := null;
  with RtcClientModule1 do
  begin
    with Prepare('RtcQueryValue') do
    begin
      Param.asWideString['username'] := FUserInfo.user_name;
      Param.asWideString['password'] := FUserInfo.user_password;
      Param.asWideString['SQL'] := SQL;
      Param.NewArray('SQL_PARAMS'); //:= TRtcArray.Create();
//      Param.asInteger['Param_count'] := High(AParams);
      for I := 0 to High(params) do
        Param.asArray['SQL_PARAMS'][i] := params[i];
//      Result := TRtcFuncResult.Create(retval);

      Result := rtcExecute(RtcClientModule1, RtcClientModule1.Data.asFunction);

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

function TMainRtcDm.GetTypeGroup( AId: LargeInt): LargeInt;
var id : LargeInt;
    retval:Variant;
begin
  id := -1;
  Result := -1;
  if AId=0 then
    Exit;
  retval := QueryValue('SELECT idgroup, idobject FROM objects WHERE idobject=:idobject',[AId]);
{  FDQuerySelect.Active := False;
  FDQuerySelect.SQL.Clear;
  FDQuerySelect.SQL.Add('SELECT idgroup, idobject FROM objects WHERE idobject=:idobject');
  FDQuerySelect.ParamByName('idobject').AsLargeInt := AId;}
  while id<>0 do
  begin
    if (not VarIsEmpty(retval)) and (VarIsArray(retval)) and (VarArrayHighBound(retval,1)>=1) then
    begin
      id := retval[0];
      Result := retval[1];
      if (id <> 0) then
        retval := QueryValue('SELECT idgroup, idobject FROM objects WHERE idobject=:idobject',[id]);
    end
    else
    begin
       Result := 0;
       Exit;
    end;
       //      raise Exception.Create('Error group');
  end;
end;

{procedure TMainDm.InitConstsList(var AVarList: TVkVariableCollection; const ATableName, AIdName: String);
begin
  if Assigned(AVarList) then
    AVarList.Clear
  else
    AVarList := TVkVariableCollection.Create(self);
  with VkUIBQuerySelect do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT * FROM '+ATableName);
    Open;
    try
      while not Eof  do
      begin
        AVarList.CreateVkVariable(FieldByName('CONSTNAME').AsString,FieldByName(AIdName).Value);
        Next;
      end;
    finally
      Close;
    end;
  end;
end;}


end.
