unit DmMainRtc;

interface

uses
  System.SysUtils, System.Classes, rtcInfo, rtcConn, rtcDataCli, rtcHttpCli,
  RtcSqlQuery, rtcCliModule, commoninterface, Dialogs, Forms, Variants, SettingsStorage,
  DCPsha256, Rtti, rtcFunction, RtcResult, RtcQueryDataSet, u_xmlinit, vkvariable, Rtcservice,
  rtcDataSrv;

type

  TMainRtcDm = class(TDataModule)
    RtcHttpClient1: TRtcHttpClient;
    RtcClientModule1: TRtcClientModule;
    RtcDataRequest1: TRtcDataRequest;
    procedure DataModuleCreate(Sender: TObject);
    procedure RtcHttpClient1ConnectLost(Sender: TRtcConnection);
    procedure RtcClientModule1ConnectLost(Sender: TRtcConnection);
    procedure DataModuleDestroy(Sender: TObject);
    procedure RtcDataRequest1BeginRequest(Sender: TRtcConnection);
    procedure RtcDataRequest1ResponseDone(Sender: TRtcConnection);
  private
    { Private declarations }
    DCP_sha2561: TDCP_sha256;
    FUserInfo: PUserInfo;
    query: TRtcQuery;
    FXmlIni: TXmlIni;
    FUserAccessTypes: TVkVariableCollection;
    FUserAccessValues: TVkVariableCollection;
    FStorage: TSettingsStorage;
    FRtcService: TRtcService;
    FRtcUser: PRtcServiceUser;
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
    function GetRtcUser(): PRtcServiceUser;

    function RtcQueryValue(const SQL:String; params: array of Variant):IRtcResult;
    function RtcQueryValues(const SQL:String; params: array of Variant):IRtcResult;
    function QueryValue(const SQL:String; params: array of Variant):Variant;
    procedure QueryValues(const AVarList:TVkVariableCollection; const SQL:String; params: array of Variant);
    procedure DoRequest(const ASql:String;const AParams: TVariants; AOnRequest: TOnRequest = nil);
    procedure SetUser(Param: TRtcFunctionInfo);
//    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): variant; overload;
    class procedure CloneComponent(const aSource, aDestination: TComponent);
    class function rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): IRtcResult; overload;
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
//  RtcHttpClient1.ServerAddr := fStorage.GetVariable('SEREVR','host','localhost').AsString;
//  RtcHttpClient1.ServerPort := fStorage.GetVariable('SEREVR','port','6476').AsString;
  RtcHttpClient1.Connect();
  FXmlIni := TXmlIni.Create(self,ChangeFileExt(Application.ExeName,'.xml'));
  FUserAccessTypes := TVkVariableCollection.Create(self);
  FUserAccessValues := TVkVariableCollection.Create(self);
  FRtcService := TRtcService.Create(self);
  FRtcService.httpClient := RtcHttpClient1;
  FRtcUser := new( PRtcServiceUser);
//  FRtcService.DataRequest.OnBeginRequest := RtcDataRequest1.OnBeginRequest;
end;

procedure TMainRtcDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FXmlIni);
  FreeAndNil(FStorage);
  Dispose(FRtcUser);
end;

procedure TMainRtcDm.DoRequest(const ASql: String; const AParams: TVariants; AOnRequest: TOnRequest);
var qr: TRtcQuery;
    i: Integer;
begin
  qr := TRtcQuery.Create(self, GetRtcUser());
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
      Result := rtcExecute(RtcClientModule1, RtcClientModule1.Data.asFunction).Result.asLargeInt;
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
   Result := TRtcQueryDataSet.Create(self,GetRtcUser);
   Result.RtcQuery.httpClient := RtcHttpClient1;
   Result.RtcQuery.path := '/verapro/query';
end;

function TMainRtcDm.QueryValue(const SQL: String; params: array of Variant): Variant;
var i: Integer;
    retval: IRtcResult;
begin
  retval := RtcQueryValue(SQL, params);
  if Assigned(retval) then
  begin
    if (retval.Result.isType = rtc_Array) then
    begin
      Result := VarArrayCreate([0,retval.Result.asArray.Count], varVariant);
      for I := 0 to retval.Result.asArray.Count-1 do
        Result[i] := retval.Result.asArray.asValue[i];
    end
    else
      Result := retval.Result.asValue;
  end
  else
    Result := null;
end;

procedure TMainRtcDm.QueryValues(const AVarList: TVkVariableCollection; const SQL: String; params: array of Variant);
var i: Integer;
    retval: IRtcResult;
    _v: TVkVariable;
begin
  retval := RtcQueryValue(SQL, params);
  if Assigned(retval)  then
  begin
    if (retval.Result.isType = rtc_Record) then
    begin
      for i := 0 to retval.Result.asRecord.Count - 1 do
      begin
        _v := TVkVariable.Create(AVarList);
        _v.Name := retval.Result.asRecord.FieldName[i];
        _v.Value := retval.Result.asRecord.asValue[_v.Name];
      end;
    end
    else if (retval.Result.isType = rtc_Array) then
    begin
      for i := 0 to retval.Result.asArray.Count - 1 do
      begin
        _v := TVkVariable.Create(AVarList);
        _v.Name := retval.Result.asArray.asRecord[i].asString['name'];
        _v.Value := retval.Result.asArray.asRecord[i].asValue['value'];
      end;
    end;
  end;
end;

procedure TMainRtcDm.RtcClientModule1ConnectLost(Sender: TRtcConnection);
begin
  // RtcHTTPClient1.Disconnect;
  // RtcHTTPClient1.Connect();
  RtcClientModule1.Release;
end;

procedure TMainRtcDm.RtcDataRequest1BeginRequest(Sender: TRtcConnection);
begin
  with TRtcDataClient(Sender) do
  begin
    Request.AutoLength := true;
    Request.HeaderText := Request.HeaderText +
      'Accept: application/json; charset=UTF-8' + #13#10;
    Request.HeaderText := Request.HeaderText +
      'Content-Type: application/json' + #13#10;

    {*req := FRequestQueue.Extract;
    if req.isNeedAuth then
    begin
      sAuth := StringReplace
        (Mime_Encode(Utf8Encode(FUsername + ':' + getPasswordHash(FPassword))),
        #13#10, '', []);
      Request.HeaderText := Request.HeaderText + 'Authorization: Basic ' +
        sAuth + #13#10;
    end;
    // Request.Cookie.Value['request_id'] := IntToStr(req.id);
     }
    try
      Request.AutoLength := true;

      // Request.FileName:='/adsweb/'+FLocation+req.url;
      {if req.isRoot then
        Request.FileName := '/universal/' + req.url
      else
        Request.FileName := '/universal/' + FLocation + req.url;}
      Request.FileName := '/verapro/users/auth';
      if (Request.Method = 'GET') then
      begin
        {if Assigned(req.params) then
        begin
          for item in req.params.AsObject do
          begin
            Request.Query.Value[item.Name] := item.Value.AsString
          end;
        end;
        Write();}
      end
      else
      begin
        Request.AutoLength := true;
        {if Assigned(req.params) then
          Write(Utf8Encode(req.params.AsJSon))
        else
          if length(req.JSON)>0 then
          Write(Utf8Encode(req.JSon));}
        Write(Utf8Encode(FRtcservice.params.toJSon));


      end;
    finally
      //FreeAndNil(req);
    end;
  end;

end;

procedure TMainRtcDm.RtcDataRequest1ResponseDone(Sender: TRtcConnection);
var s: String;
begin

end;

class function TMainRtcDm.rtcExecute(clientModule:TRtcClientModule;func: TRtcFunctionInfo): IRtcResult;
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
      Result := nil ;//TRtcFuncResult.Create(retval);

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
  //ShowMessage('LOST');
end;

function TMainRtcDm.rtcLogin: Boolean;
var
  Retval: IRtcResult;
  func: TRtcFunctionInfo;
begin
//  with RtcClientModule1 do
  begin
    try
//    with Prepare('RtcConnect') do
//    begin
      FRtcservice.Params.asWideString['username'] := FUserInfo.user_name;
      FRtcservice.Params.asWideString['password'] := FUserInfo.user_password;
      RtcDataRequest1.Request.Method := 'POST';
//      RtcDataRequest1.Post();
      Retval := FRtcservice.execute('/verapro/users/auth','POST');
      Result := (Retval.Result.asRecord.asString['Result'] = 'OK') and Retval.Result.asRecord.asRecord['content'].asBoolean['result']=true;
      if not Result  then
        ShowMessage('Incorrect password');
//      TUtils.RtcToVkVariableColections(Retval.asRecord.asRecord['USERACCESSTYPES'], FUserAccessTypes);
//      TUtils.RtcToVkVariableColections(Retval.asRecord.asRecord['USERACCESSVALUES'], FUserAccessValues);
//      TUtils.RtcValueToRecord(Retval.asRecord.asRecord['USERINFO'],FUserInfo, TypeInfo(RUserInfo));
//    end;
    finally
//      FreeAndNil(Retval);
    end;
  end;
end;

function TMainRtcDm.RtcQueryValue(const SQL: String; params: array of Variant): IRtcResult;
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


function TMainRtcDm.RtcQueryValues(const SQL: String; params: array of Variant): IRtcResult;
var i: Integer;
begin
//  Result := null;
  with RtcClientModule1 do
  begin
    with Prepare('RtcQueryValues') do
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

function TMainRtcDm.GetRtcUser: PRtcServiceUser;
begin
  FRtcUser.userName := FUserInfo.user_name;
  FRtcUser.password := FUserInfo.user_password;
  Result := FRtcUser;
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
