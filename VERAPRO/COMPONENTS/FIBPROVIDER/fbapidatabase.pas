unit fbapidatabase;

interface

uses System.SysUtils, System.Variants, System.Classes, IB, FB30Attachment,
  FBClientApi, FB30ClientApi, dIALOGS, FB30Statement;

const
  TR_READ_ONLY_PARAMS: array [0 .. 1] of byte = (isc_tpb_read, isc_tpb_nowait);
  TR_READ_COMMITED_PARAMS: array [0 .. 2] of byte = (isc_tpb_read_committed,
    isc_tpb_nowait, isc_tpb_write);
  TR_READ_CONCURENCY_PARAMS: array [0 .. 2] of byte = (isc_tpb_concurrency,
    isc_tpb_nowait, isc_tpb_write);

type
  TFBApiDatabaseParams = class(TComponent)
  private
    FDbName: String;
    FUserName: String;
    FPassword: String;
    FSqlDialect: Integer;
    FLibPath: String;
    FDefaultCharSet: String;
    FRole: String;
  public
    property DbName: String read FDbName write FDbName;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property SqlDialect: Integer read FSqlDialect write FSqlDialect;
    property LibPath: String read FLibPath write FLibPath;
    property DefaultCharSet: String read FDefaultCharSet write FDefaultCharSet;
    property Role: String read FRole write FRole;
    constructor Create(AOwner: TComponent);
  end;

  TFBApiDatabase = class(TComponent)
  private
    FBLibrary: TFbLibrary;
    FFirebirdAPI: TFB30ClientAPI;
    FParams: TFBApiDatabaseParams;
    FAttachment: TFB30Attachment;
    procedure Init;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;
    procedure Connect;
    function IsConnected: Boolean;
    function startReadTransaction: ITransaction;
    function startReadCommitedTransaction: ITransaction;
    function startConcurencyTransaction: ITransaction;
    procedure Disconnect;
    property Attachment: TFB30Attachment read FAttachment;
    property FirebirdAPI: TFB30ClientAPI read FFirebirdAPI;
    property params: TFBApiDatabaseParams read FParams;
    function QueryValue(const SQL: String;
      const AParams: array of variant): variant;
  end;

implementation

type
  { TFibProviderDatabase }

  TFBLibraryImpl = class(TFbLibrary)
  protected
    function GetFirebird3API: IFirebirdAPI; override;
    function GetLegacyFirebirdAPI: IFirebirdAPI; override;
  end;

function TFBLibraryImpl.GetFirebird3API: IFirebirdAPI;
begin
  // {$IFDEF USEFIREBIRD3API}
  Result := TFB30ClientAPI.Create(self);
  // {$ELSE}
  // Result := nil;
  // {$ENDIF}
end;

function TFBLibraryImpl.GetLegacyFirebirdAPI: IFirebirdAPI;
begin
  // {$IFDEF USELEGACYFIREBIRDAPI}
  // Result := TFB25ClientAPI.Create(self);
  // {$ELSE}
  // Result := nil;
  // {$ENDIF}
end;

procedure TFBApiDatabase.Connect;
var
  DPB: IDPB;
begin
  Init;
  DPB := FFirebirdAPI.AllocateDPB;
  DPB.Add(isc_dpb_user_name).AsString := FParams.UserName;
  DPB.Add(isc_dpb_password).AsString := FParams.Password;
  DPB.Add(isc_dpb_lc_ctype).AsString := FParams.DefaultCharSet;
  DPB.Add(isc_dpb_set_db_SQL_dialect).AsInteger := FParams.SqlDialect;
  // FFirebirdAPI.OpenDatabase(FParams.DbName,DPB,True);
  // fFirebirdApi.
  FAttachment := TFB30Attachment.Create(FFirebirdAPI, FParams.DbName,
    DPB, true);
  // FAttachment.Connect;
end;

constructor TFBApiDatabase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParams := TFBApiDatabaseParams.Create(self);
end;

destructor TFBApiDatabase.Destroy;
begin
  if IsConnected then
    Disconnect;
  FreeAndNil(FParams);
end;

procedure TFBApiDatabase.Disconnect;
begin
  // raise Exception.Create('Error Message');
  if FAttachment.IsConnected then
    FAttachment.Disconnect();
  FreeAndNil(FAttachment);
  FFirebirdAPI := nil;
end;

function TFBApiDatabase.startConcurencyTransaction: ITransaction;
begin
  Result := FAttachment.StartTransaction([isc_tpb_concurrency, isc_tpb_write,
    isc_tpb_nowait], TACommit);
end;

function TFBApiDatabase.startReadCommitedTransaction: ITransaction;
begin
  Result := FAttachment.StartTransaction([isc_tpb_read_committed, isc_tpb_write,
    isc_tpb_nowait], TACommit);

end;

function TFBApiDatabase.startReadTransaction: ITransaction;
begin

  Result := FAttachment.StartTransaction(TR_READ_ONLY_PARAMS, TACommit);
end;

procedure TFBApiDatabase.Init;
begin
  if not(Assigned(FBLibrary) and
    (FBLibrary.GetLibraryFilePath.Equals(FParams.LibPath))) then
  begin
    FBLibrary := TFBLibraryImpl.Create(FParams.LibPath);
  end;
  FFirebirdAPI := TFB30ClientAPI.Create(FBLibrary);
  if not FFirebirdAPI.LoadInterface then
    raise Exception.Create('Error in loading FirebirdAPI Interface');
end;

function TFBApiDatabase.IsConnected: Boolean;
begin
  Result := Assigned(FAttachment) and Attachment.IsConnected;
end;

function TFBApiDatabase.QueryValue(const SQL: String;
  const AParams: array of variant): variant;
var
  statement: TFb30Statement;
  i: Integer;
  rs: IResultSet;
begin
  statement := TFb30Statement.CreateWithParameterNames(FAttachment,
    startReadTransaction, SQL, FParams.SqlDialect, true, false);
  try

    for i := 0 to statement.GetSQLParams.Count - 1 do
    begin
      try
        statement.GetSQLParams.params[i].Value := AParams[i];
      except
        raise Exception.CreateFmt('Error set param qr2 [%d]', [i]);
      end;
      rs := statement.OpenCursor();
      if rs.FetchNext then
        Result := rs.Data[0].AsVariant;
    end;
  finally
    FreeAndNil(statement);
  end;

end;

{ TFBDatabaseParams }

constructor TFBApiDatabaseParams.Create;
begin
  Inherited;
  FSqlDialect := 3;
  FDefaultCharSet := 'UTF8';
end;

end.
