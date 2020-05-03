unit RtcSqlQuery;

interface

uses
  SysUtils, Classes, rtcFunction, rtcDataCli, rtcCliModule, rtcInfo, rtcConn, rtcHttpCli, rtcLog,
  rtcDB, DB, MemTableEh, variants, commoninterface;

type
  TResponseEvent = procedure (Sender:TObject; Result: TRtcValue);

{  TSQLStringList = class (TStringList)
  private
    FOnChange: TNotifyEvent;
  public
    function Add(const S:String):Integer;override;
    procedure Delete(Index:Integer);override;
    procedure Clear;override;
    property OnChange:TNotifyEvent Read FOnChange write FOnChange;
  end; }
  TRemoteTransactionType = (ttReadCommited=0,ttStability=1, ttSnapshot=2  );
  TOnRequest = reference to procedure(AQuery: TRtcDataSet );

  TRtcQuery = class (TObject)
  private
    FActive: Boolean;
    FCurrentUser: PUserInfo;
    FSql: TStringList;
    FParams: TParams;
    FClientModule: TRtcClientModule;
    FQrResult: TRtcValue;
    FOnSelectResponse: TResponseEvent;
    FOnQueryResponse: TResponseEvent;
    procedure DoSQlListOnChange(Sender:TObject);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    constructor Create(AClientModule:TRtcClientModule;ACurrentUser:PUserInfo);
    destructor Destroy;override;
    procedure Close;
    procedure ExecQuery;
    function FieldByName(const AFieldName:String):TRtcValue;
    function Bof: Boolean;
    function Eof: Boolean;
    function IsEmpty: Boolean;
    procedure First;
    procedure FullRefresh;
    procedure Next;
    procedure Open;
    procedure Prior;

    function ParamByName(const Aname: String):TParam;
    procedure Select(ADataSet:TDataSet; isRefresh: Boolean = false);
    procedure DoRequest(_proc:TOnRequest);
    function QueryValue(const ASql:String; AParams: array of variant ):Variant;

    property Active:Boolean read GetActive write SetActive;
    property ClientModule: TRtcClientModule read FClientModule write FClientModule;
    property Params:TParams read FParams;
    property SQL:TStringList read FSQL;
    property OnSelectResponse:TResponseEvent read FOnSelectResponse write FOnSelectResponse;
    property OnQueryResponse:TResponseEvent read FOnQueryResponse write FOnQueryResponse;
    property QrResult: TRtcValue read FQrResult;
    property CurrentUser:PUserInfo Read FCurrentUser write FCurrentUser;
  end;

  TRtcSqlExecute = class (TObject)
  private
    FCurrentUser: PUserInfo;
    FIdTransaction: Cardinal;
    FSql: TStringList;
    FParams: TParams;
    FClientModule: TRtcClientModule;
    FQrResult: TRtcValue;
    procedure DoSQlListOnChange(Sender:TObject);
  public
    constructor Create(AClientModule:TRtcClientModule;ACurrentUser:PUserInfo);
    procedure Close;
    destructor Destroy;override;
    procedure ExecQuery(ATransaction:TRemoteTransactionType = ttReadCommited);
    function IsTransactionActive:Boolean;
    function ParamByName(const Aname: String):TParam;
    procedure StartTransaction(AType:TRemoteTransactionType = ttStability);
    procedure Commit;
    procedure RollBack;
    class function GetRemoteTransactionTypeasInteger(AType:TRemoteTransactionType):Integer;

    property ClientModule: TRtcClientModule read FClientModule write FClientModule;
    property Params:TParams read FParams;
    property SQL:TStringList read FSQL;
    property QrResult: TRtcValue read FQrResult;
    property CurrentUser:PUserInfo Read FCurrentUser write FCurrentUser;
  end;

implementation

{ TRtcQuery }

function TRtcQuery.Bof: Boolean;
begin
  FQrResult.asDataSet.BOF;
end;

procedure TRtcQuery.Close;
begin
//  FSql.Clear;
  if Assigned(FQrResult) then
   FQrResult.Clear
end;

constructor TRtcQuery.Create;
begin
  FSql:= TStringList.Create;
  FParams:= TParams.Create;
  FOnSelectResponse := nil;
  FOnQueryResponse := nil;
  FSQL.OnChange := DoSQlListOnChange;
  FQrResult := TRtcValue.Create;
  FCurrentUser := ACurrentUser;
  FClientModule := AClientModule;
end;

destructor TRtcQuery.Destroy;
begin
  FQrResult.Clear;
  FreeAndNil(FQrResult);
  FreeAndNil(FSql);
  FreeAndNil(FParams);
  FOnSelectResponse := nil;
  FOnQueryResponse := nil;
  inherited;
end;

procedure TRtcQuery.DoRequest(_proc: TOnRequest);
var i: Integer;
    ds: TRtcDataSet;
begin
  with FClientModule do
  begin
    with Prepare('RtcSelectSql') do
    begin
      FQrResult.Clear;
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asString['SQL'] := FSql.Text;
      Param.NewRecord('SQL_PARAMS');
      for i := 0 to FParams.Count-1 do
      begin
        if (FParams[i].DataType =ftDate) or (FParams[i].DataType =ftDateTime) then
          Param.asRecord['SQL_PARAMS'].asDateTime[FParams[i].Name] := FParams[i].AsDateTime
        else
          Param.asRecord['SQL_PARAMS'].asValue[FParams[i].Name] := FParams[i].Value;
      end;
      try
        FQrResult := Execute(False,0,False);
        if FQrResult.isType=rtc_Exception then
          Raise Exception.Create(FQrResult.asException)
        else
        begin
          if (FQrResult.isType = rtc_DataSet) and Assigned(_proc) then
          begin
            _proc(FQrResult.asDataSet);
          end;
        end;
      finally
          FQrResult.Clear;
      end;
    end;
  end;

end;

procedure TRtcQuery.DoSQlListOnChange(Sender: TObject);
begin
  FParams.Clear;
  FParams.ParseSQL(FSQL.Text,True);
end;

function TRtcQuery.Eof: Boolean;
begin
  Result := FQrResult.asDataSet.EOF;
end;

procedure TRtcQuery.ExecQuery;
begin
  Select(nil);
end;

function TRtcQuery.FieldByName(const AFieldName: String): TRtcValue;
begin
  Result := FQrResult.asDataSet.FieldByName(AFieldName)
end;

procedure TRtcQuery.First;
begin
  FQrResult.asDataSet.First;
end;

procedure TRtcQuery.FullRefresh;
begin

end;

function TRtcQuery.GetActive: Boolean;
begin
  Result := Assigned(QrResult.asDataSet);
end;

function TRtcQuery.IsEmpty: Boolean;
begin
  FQrResult.asDataSet.Empty;
end;

procedure TRtcQuery.Next;
begin
  FQrResult.asDataSet.Next;
end;

procedure TRtcQuery.Open;
begin
  Select(nil);
end;

function TRtcQuery.ParamByName(const Aname: String): TParam;
begin
  Result := FParams.ParamByName(AName)
end;

procedure TRtcQuery.Prior;
begin
  FQrResult.asDataSet.Prior;
end;

function TRtcQuery.QueryValue(const ASql: String; AParams: array of variant): Variant;
var i: Integer;
begin
  Result := null;
  with FClientModule do
  begin
    with Prepare('RtcQueryValue') do
    begin
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asWideString['SQL'] := ASql;
      Param.NewArray('SQL_PARAMS'); //:= TRtcArray.Create();
//      Param.asInteger['Param_count'] := High(AParams);
      for I := 0 to High(Aparams) do
        Param.asArray['SQL_PARAMS'][i] := AParams[i];
      try
        FQrResult := Execute(False,0,False);
        if FQrResult.isType=rtc_Exception then
        begin
          Raise Exception.Create(FQrResult.asException);
        end
        else
          Result := FQrResult.asValue;
      finally
        //FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TRtcQuery.Select(ADataSet:TDataSet; isRefresh: Boolean = false);
var i: Integer;
    ds: TRtcDataSet;
begin
  with FClientModule do
  begin
    with Prepare('RtcSelectSql') do
    begin
      FQrResult.Clear;
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asString['SQL'] := FSql.Text;
      Param.NewRecord('SQL_PARAMS');
      for i := 0 to FParams.Count-1 do
      begin
        if (FParams[i].DataType =ftDate) or (FParams[i].DataType =ftDateTime) then
          Param.asRecord['SQL_PARAMS'].asDateTime[FParams[i].Name] := FParams[i].AsDateTime
        else
          Param.asRecord['SQL_PARAMS'].asValue[FParams[i].Name] := FParams[i].Value;
      end;
      try
        FQrResult := Execute(False,0,False);
        if FQrResult.isType=rtc_Exception then
          Raise Exception.Create(FQrResult.asException)
        else
        begin
          if Assigned(ADataSet) then
          begin
            ADataSet.DisableControls;
            try
              if FQrResult.isType = rtc_DataSet then
                ds := FQrResult.asDataSet
              else
              begin
                ds := TRtcDataSet.Create;
                ds.FromJSON(FQrResult.asRecord.toJSON);
              end;

              if ((ADataSet.FieldDefs.Count=0) or not isRefresh) then
              begin
                RtcDataSetFieldsToDelphi( ds, ADataSet);
                if ADataSet is TMemTableEh then
                  TMemTableEh(ADataSet).CreateDataSet;
              end
              else
                 for I := 0 to ADataSet.FieldCount-1 do
                   ADataSet.Fields[i].ReadOnly := false;
              RtcDataSetRowsToDelphi(ds, ADataSet);
              ADataSet.First;
            finally
              ADataSet.EnableControls;
            end;
          end;
          if Assigned(FOnSelectResponse) then
            FOnSelectResponse(Self,FQrResult);
        end;
      finally
        if Assigned(ADataSet) then
          FQrResult.Clear;
      end;
    end;
  end;
end;


procedure TRtcQuery.SetActive(const Value: Boolean);
begin
  if not Value then
    Close
  else
    Open;
end;

{function TSQLStringList.Add(const S: String):Integer;
begin
  inherited Add(s);
  if Assigned(FOnChange) then
    FOnChange(self)
end;

procedure TSQLStringList.Clear;
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(self)
end;

procedure TSQLStringList.Delete(Index: Integer);
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(self)
end;
 }
{ TRtcUpdate }

procedure TRtcSqlExecute.Close;
begin
  if Assigned(FQrResult) then
   FQrResult.Clear
end;

procedure TRtcSqlExecute.Commit;
var mResult: TRtcValue;
begin
  with FClientModule do
  begin
    with Prepare('RtcTransactionCommit') do
    begin
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asCardinal['trid'] := FIdTransaction;
      mResult := Execute(False,0,False);
      FIdTransaction := 0;
      if mResult.isType=rtc_Exception then
        raise Exception.Create(mResult.asException);
    end;
  end;
end;

constructor TRtcSqlExecute.Create(AClientModule: TRtcClientModule; ACurrentUser: PUserInfo);
begin
  FSql:= TStringList.Create;
  FParams:= TParams.Create;
  FSQL.OnChange := DoSQlListOnChange;
  FQrResult := TRtcValue.Create;
  FCurrentUser := ACurrentUser;
  FClientModule := AClientModule;
  FIdTransaction := 0;
end;

destructor TRtcSqlExecute.Destroy;
begin
  FQrResult.Clear;
  FreeAndNil(FQrResult);
  FreeAndNil(FSql);
  FreeAndNil(FParams);
  inherited;
end;

procedure TRtcSqlExecute.DoSQlListOnChange(Sender: TObject);
begin
  FParams.Clear;
  FParams.ParseSQL(FSQL.Text,True);
end;

procedure TRtcSqlExecute.ExecQuery(ATransaction: TRemoteTransactionType);
var i: Integer;
begin
//  if FIdTransaction=0 then
//    Param.asInteger['TypeTransaction'] := TRtcSqlExecute.GetRemoteTransactionTypeAsInteger(ATransaction);

  with FClientModule do
  begin
    with Prepare('RtcSqlExecute') do
    begin
      FQrResult.Clear;
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asString['SQL'] := FSql.Text;
//      Param.asInteger['Param_count'] := FParams.Count;
      for i := 0 to FParams.Count-1 do
      begin
        Param.asString['PARAM'+IntTostr(i)+'_NAME'] := FParams[i].Name;
        if (FParams[i].DataType =ftDate) or (FParams[i].DataType =ftDateTime) then
          Param.asDateTime['PARAM'+IntTostr(i)+'_VALUE'] := FParams[i].AsDateTime
        else
        Param.asValue['PARAM'+IntTostr(i)+'_VALUE'] := FParams[i].Value;
      end;
      if FIdTransaction>0 then
        Param.asCardinal['trid'] := FIdTransaction
      else
        Param.asInteger['TypeTransaction'] := TRtcSqlExecute.GetRemoteTransactionTypeAsInteger(ATransaction);
      //try
      FQrResult := Execute(False,0,False);
      if FQrResult.isType=rtc_Exception then
        Raise Exception.Create(FQrResult.asException);
      //end;
    end;
  end;
end;

class function TRtcSqlExecute.GetRemoteTransactionTypeasInteger(AType: TRemoteTransactionType): Integer;
begin
  case AType of
    ttReadCommited: Result := 0;
    ttStability: Result := 1;
    ttSnapshot: Result := 2;
  end;
end;

function TRtcSqlExecute.IsTransactionActive: Boolean;
begin
  Result := FIdTransaction > 0;
end;

function TRtcSqlExecute.ParamByName(const Aname: String): TParam;
begin
  Result := FParams.ParamByName(AName);
end;

procedure TRtcSqlExecute.RollBack;
var mResult: TRtcValue;
begin
  with FClientModule do
  begin
    with Prepare('RtcTransactionRollback') do
    begin
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.asCardinal['trid'] := FIdTransaction;
      mResult := Execute(False);
      FIdTransaction := 0;
      if mResult.isType=rtc_Exception then
        raise Exception.Create(mResult.asException);
    end;
  end;

end;

procedure TRtcSqlExecute.StartTransaction;
var mResult: TRtcValue;
begin
  with FClientModule do
  begin
    with Prepare('RtcStartTransaction') do
    begin
      Param.asWideString['username'] := FCurrentUser.user_name;
      Param.asWideString['password'] := FCurrentUser.user_password;
      Param.AsInteger['TypeTransaction'] := TRtcSqlExecute.GetRemoteTransactionTypeAsInteger(AType);
      mResult := Execute(False,0,False);
      if mResult.isType=rtc_Exception then
        raise Exception.Create(mResult.asException);
      FIdTransaction := mResult.asCardinal
    end;
  end;

end;

end.
