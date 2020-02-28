unit DmRtcCommonFunctions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DmRtcCustom, rtcFunction, rtcSrvModule, rtcInfo, rtcConn, rtcDataSrv,
  rtcDb, DmMain, uRtcDmList, DmRtcUseMonth, rtclog, SQLTableProperties,
  DmRtcObjects, CommonInterface, FbApiQuery, IB, rtcHttpSrv, FbApiDatabase;

type

  TRtcCommonFunctionsDm = class(TRtcCustomDm)
    RtcServerModuleCommon: TRtcServerModule;
    RtcFunctionGroupCommon: TRtcFunctionGroup;
    RtcDataServerLinkCommon: TRtcDataServerLink;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FDmRtcUseMonth: TRtcUseMonthDm;
    FDmRtcObjects: TRtcObjectsDm;
  protected
    function GetDefaultGroup: TRtcFunctionGroup; override;
  public
    { Public declarations }
    procedure RtcConnect(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    procedure RtcDocEdit(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    function RtcInternalConnect(Sender: TRtcConnection;
      const AUsername, APassword: String): TMainDm;
    procedure RtcGetCurrentUserInfo(Sender: TRtcConnection;
      FnParams: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcSelectSql(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    procedure RtcQueryValue(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    procedure RtcSqlExecute(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    procedure RtcStartTransaction(Sender: TRtcConnection;
      FnParams: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcTransactionCommit(Sender: TRtcConnection;
      FnParams: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcTransactionRollback(Sender: TRtcConnection;
      FnParams: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetSqltableProperties(Sender: TRtcConnection; FnParams: TRtcFunctionInfo;
      Result: TRtcValue);
    procedure RtcGen_ID(Sender: TRtcConnection;
      FnParams: TRtcFunctionInfo; Result: TRtcValue);
    function GetDmMainUib(AConnection: TRtcConnection;
      const AUsername, APassword: string): TMainDm;
    procedure ConnectUser(Sender: TRtcConnection);
    procedure DisconnectUser(Sender: TRtcConnection);
    procedure SetRtcServer(const Value: TRtcDataServer);override;
  end;

var
  RtcCommonFunctionsDm: TRtcCommonFunctionsDm;

implementation

{$R *.dfm}

uses DmSrvDoc;
{ TDmRtcCustom1 }

procedure TRtcCommonFunctionsDm.ConnectUser(Sender: TRtcConnection);
begin
end;

procedure TRtcCommonFunctionsDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  FDmRtcUseMonth := TRtcUseMonthDm.Create(Self);
  FDmRtcObjects := TRtcObjectsDm.Create(Self);

  RegisterRtcFunction('RtcConnect', RtcConnect);
  RegisterRtcFunction('RtcSelectSql', RtcSelectSql);
  RegisterRtcFunction('RtcQueryValue', RtcQueryValue);
  RegisterRtcFunction('RtcGetCurrentUserInfo', RtcGetCurrentUserInfo);
  RegisterRtcFunction('RtcSqlExecute', RtcSqlExecute);
  RegisterRtcFunction('RtcStartTransaction', RtcStartTransaction);
  RegisterRtcFunction('RtcTransactionCommit', RtcTransactionCommit);
  RegisterRtcFunction('RtcTransactionRollback', RtcTransactionRollback);
  RegisterRtcFunction('RtcGetSqlTableProperties', RtcGetSqlTableProperties);
  RegisterRtcFunction('RtcDocEdit', RtcDocEdit);
  RegisterRtcFunction('RtcGen_ID', RtcGen_ID);
end;

procedure TRtcCommonFunctionsDm.DisconnectUser(Sender: TRtcConnection);
begin
  RtcDmList.DeleteDm(Sender);
end;

function TRtcCommonFunctionsDm.GetDefaultGroup: TRtcFunctionGroup;
begin
  Result := RtcFunctionGroupCommon;
end;

function TRtcCommonFunctionsDm.GetDmMainUib(AConnection: TRtcConnection;
  const AUsername, APassword: String): TMainDm;
begin
  Result := TMainDm(RtcDmList.GetDmOnRtc(AConnection, TMainDm));

  if not Assigned(Result) then
    Result := RtcInternalConnect(AConnection, AUsername, APassword)
  else if not Result.Connected then
    Result.Login(AUsername, APassword);
end;

procedure TRtcCommonFunctionsDm.RtcConnect(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
begin
  Result.asInteger := -1;
  mUserName := FnParams.AsWideString['username'];
  mPassword := FnParams.AsWideString['password'];
  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  if Assigned(mDmMain) then
    if mDmMain.Connected then
      Result.asInteger := 0;
end;

procedure TRtcCommonFunctionsDm.RtcGen_ID(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
begin
  Result.asInteger := -1;
  mUserName := FnParams.AsWideString['username'];
  mPassword := FnParams.AsWideString['password'];
  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  if Assigned(mDmMain) then
      Result.asLargeInt := mDmMain.Gen_ID(FnParams.AsWideString['ID_NAME']);
end;


procedure TRtcCommonFunctionsDm.RtcDocEdit(Sender: TRtcConnection; FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mMainDm: TMainDm;
//  query: TFbApiQuery;
//  tableName: String;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
//  tableName := FnParams.AsString['TABLENAME'];
  mMainDm := GetDmMainUib(Sender, mUserName, mPassword);
  SrvDocDm.rtcDocEdit(mMainDm,FnParams,Result);
end;

procedure TRtcCommonFunctionsDm.RtcGetCurrentUserInfo(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  Result.NewRecord;
  Result.asRecord.Value['id_user'] := mDmMain.CurrentUser.id_user;
  Result.asRecord.Value['id_group'] := mDmMain.CurrentUser.id_group;
  Result.asRecord.Value['id_menu'] := mDmMain.CurrentUser.id_menu;
  // Result.asRecord.Value['id_user'] :=  mDmMainUib.CurrentUser.id_user;
end;

procedure TRtcCommonFunctionsDm.RtcGetSqlTableProperties(Sender: TRtcConnection; FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMainUib: TMainDm;
//  i: Integer;
//  mSQL: String;
//  nField: Integer;
//  _params: TRtcArray;
//  query: TFbApiQuery;
  tableName: String;
  vSQLTableProperties: TSQLTableProperties;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
  tableName := FnParams.AsString['TABLENAME'];
  mDmMainUib := GetDmMainUib(Sender, mUserName, mPassword);
  vSQLTableProperties := TSQLTableProperties.Create;
  try
    mDmMainUib.GetSQLTableProperties(tableName, vSQLTableProperties);
    TUtils.ObjectToRtcValue(vSQLTableProperties, Result.NewRecord);
  finally
    vSQLTableProperties.Free;
  end;

end;

function TRtcCommonFunctionsDm.RtcInternalConnect(Sender: TRtcConnection;
  const AUsername, APassword: String): TMainDm;
begin
  Result := TMainDm.Create(Self);
  try
    Result.Login(AUsername, APassword);
    RtcDmList.AddDm(Sender, Result);
  except
    Result.Free;
    Raise;
  end;
end;

procedure TRtcCommonFunctionsDm.RtcQueryValue(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMainUib: TMainDm;
  i: Integer;
//  mSQL: String;
  nField: Integer;
  _params: TRtcArray;
  query: TFbApiQuery;
  v: TVariants;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
  mDmMainUib := GetDmMainUib(Sender, mUserName, mPassword);
  _params := FnParams.asArray['SQL_PARAMS'];
  v := TUtils.RtcArrayToVarArray(_params);
  Result.asValue := mDmMainUIB.FbDatabase.QueryValue(FnParams.AsString['SQL'], v);
end;

procedure TRtcCommonFunctionsDm.RtcSelectSql(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
  i: Integer;
  query: TFbApiQuery;
  sqlParams: TRtcRecord;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);

  try
    query := mDmMain.GetNewQuery;
    with query do
    begin
      Active := False;
      SQL.Clear;
      SQL.Text := FnParams.AsString['SQL'];
      sqlParams := FnParams.asRecord['SQL_PARAMS'];
      for i := 0 to Params.Count - 1 do
        if (Params[i].SQLType = SQL_DATE) or (Params[i].SQLType = SQL_TIMESTAMP)
        then
          Params[i].AsDateTime := sqlParams.AsDateTime[String(Params[i].Name)]
        else
          ParamByName(String(Params[i].Name)).AsVariant := sqlParams.asValue[String(Params[i].Name)];
      ExecQuery;
    end;
    QueryToRtc(query, Result.NewDataSet);
    //Result.asVarName := 'OK';
  finally
    query.Close;
    FreeAndNil(query);
  end;

end;

procedure TRtcCommonFunctionsDm.RtcSqlExecute(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
  mDmMain: TMainDm;
  i: Integer;
  sqlParams: TRtcRecord;
  CommandQuery: TFbApiQuery;
//  CommandTransaction: TFbApiTransaction;
  // nTrOption, k: Integer;
  // IdTr: Cardinal;
  // old_tr: TFbApiTransaction;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  CommandQuery := mDmMain.GetNewQuery
    (mDmMain.getNewTransaction(mDmMain.SnapshotTransactionOptions));
  // nTrOption := FnParams.AsInteger['TypeTransaction'];
  // IdTr := FnParams.asCardinal['trid'];
  try
    with CommandQuery do
    begin
      //Close; // := Faaalse;
      { if IdTr>0 then
        begin
        old_tr := Transaction;
        Transaction := mDmmain.GetShortTransaction(IdTr,k);
        end
        else
        begin
        if nTrOption=1 then
        Transaction.Options := TRWriteTableStability
        else
        if nTrOption=2 then
        Transaction.Options := TRSnapShot
        else
        Transaction.Options := TRReadCommitted;
        end; }

      // try
      SQL.Clear;
      SQL.Text := FnParams.AsString['SQL'];
      // Prepare(True);
      { for I := 0 to Params.ParamCount-1 do
        begin

        if Param.isType['PARAM'+IntToStr(i)+'_VALUE'] = rtc_DateTime then
        begin
        Params.ByNameAsDateTime[Param.asString['PARAM'+IntToStr(i)+'_NAME']] :=
        Param.asDateTime['PARAM'+IntToStr(i)+'_VALUE'];
        end;
        if (Params.FieldType[i]=uftDate) or (Params.FieldType[i]=uftTimestamp) then
        Params.ByNameAsDateTime[Param.asString['PARAM'+IntToStr(i)+'_NAME']] :=
        Param.asDateTime['PARAM'+IntToStr(i)+'_VALUE']
        else

        if Params.IsNumeric[i] then
        Params.ByNameAsDateTime[Param.asString['PARAM'+IntToStr(i)+'_NAME']] :=
        Param.asDateTime['PARAM'+IntToStr(i)+'_VALUE'];

        Params.ByNameAsVariant[Param.asString['PARAM'+IntToStr(i)+'_NAME']] :=
        Param.asValue['PARAM'+IntToStr(i)+'_VALUE'];

        end; }
      // SQL.Text := FnParams.asString['SQL'];
      sqlParams := FnParams.asRecord['SQL_PARAMS'];
      for i := 0 to ParamCount - 1 do
        if (Params[i].SQLType = SQL_DATE) or (Params[i].SQLType = SQL_TIMESTAMP)
        then
          Params[i].AsDateTime := sqlParams.AsDateTime[String(Params[i].Name)]
        else
          ParamByName(String(Params[i].Name)).AsVariant := sqlParams[String(Params[i].Name)];
      ExecQuery;
      if SQLStatementType = SQLSelect then
      begin
        Result.NewArray;
        for i := 0 to FieldCount - 1 do
        begin
          Result.asArray.NewRecord(i);
          Result.asArray.asRecord[i].AsString['NAME'] := String(Fields[i].Name);
          Result.asArray.asRecord[i].asValue['VALUE'] := Fields[i].AsVariant;
        end;
      end
      else
        Result.asInteger := RowsAffected;
      // if (IdTr=0) and mDmMain.CommandQuery.Transaction.InTransaction then
      CloseWithTransaction(True);
      CommandQuery.Transaction.Commit;
      // Result.asInteger := 0;
      { finally
        if IdTr>0 then
        Transaction := old_tr;
        end; }
    end;
//    CommandQuery.Transaction.Free;
    CommandQuery.Free;
  except
    on E: Exception do
    begin
      Result.asException := E.Message;
      //CommandQuery.Transaction.Free;
      CommandQuery.CloseWithTransaction(False);
      CommandQuery.Free;
    end;
  end;

end;

procedure TRtcCommonFunctionsDm.RtcStartTransaction(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
//  mDmMain: TMainDm;
//  i: Integer;
//  nTrOption: Integer;
  // _Option: TTransParams;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
//  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
//  nTrOption := FnParams.asInteger['TypeTransaction'];

  { *  with mDmMainUib do
    begin
    if nTrOption=1 then
    _Option := TRWriteTableStability
    else
    if nTrOption=2 then
    _Option := TRSnapShot
    else
    _Option := TRReadCommitted;

    Result.asCardinal :=  StartShortTransaction(_Option);
    end;
  }
end;

procedure TRtcCommonFunctionsDm.RtcTransactionCommit(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
//  mDmMain: TMainDm;
//  _Id: cardinal;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
//  _Id := FnParams.asCardinal['trid'];
//  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  // mDmMainUib.EndShortTransaction(0,_Id);
end;

procedure TRtcCommonFunctionsDm.RtcTransactionRollback(Sender: TRtcConnection;
  FnParams: TRtcFunctionInfo; Result: TRtcValue);
var
  mUserName, mPassword: string;
//  mDmMain: TMainDm;
//  _Id: cardinal;
begin
  mUserName := FnParams.AsString['username'];
  mPassword := FnParams.AsString['password'];
//  _Id := FnParams.asCardinal['trid'];
//  mDmMain := GetDmMainUib(Sender, mUserName, mPassword);
  // mDmMainUib.EndShortTransaction(1,_Id);
end;

procedure TRtcCommonFunctionsDm.SetRtcServer(const Value: TRtcDataServer);
var dm: TComponent;
    i: Integer;
begin
  Inherited;
  for i := 0 to Application.ComponentCount-1 do
  begin
    //dm := Application.Components[i];
    if (dm is TRtcCustomDm) and (dm <> self) then
      TRtcCustomDm(dm).SetRtcServer(Value);
  end;
end;


// function GetIDmRtcCommon(AOwner: TComponent): IDmRtcCommon;
// begin
// Result := TDmRtcCommonFunctions.Create(AOwner);
// end;

// exports
// GetIDmRtcCommon;
end.
