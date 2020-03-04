unit fbapidatabase;

interface

uses System.SysUtils, System.Variants, System.Classes, IB,
  FBClientApi, Dialogs, FBMessages, DB;

const
  DPBPrefix = 'isc_dpb_';
  DPBConstantNames: array[1..isc_dpb_last_dpb_constant] of string = (
    'cdd_pathname',
    'allocation',
    'journal',
    'page_size',
    'num_buffers',
    'buffer_length',
    'debug',
    'garbage_collect',
    'verify',
    'sweep',
    'enable_journal',
    'disable_journal',
    'dbkey_scope',
    'number_of_users',
    'trace',
    'no_garbage_collect',
    'damaged',
    'license',
    'sys_user_name',
    'encrypt_key',
    'activate_shadow',
    'sweep_interval',
    'delete_shadow',
    'force_write',
    'begin_log',
    'quit_log',
    'no_reserve',
    'user_name',
    'password',
    'password_enc',
    'sys_user_name_enc',
    'interp',
    'online_dump',
    'old_file_size',
    'old_num_files',
    'old_file',
    'old_start_page',
    'old_start_seqno',
    'old_start_file',
    'drop_walfile',
    'old_dump_id',
    'wal_backup_dir',
    'wal_chkptlen',
    'wal_numbufs',
    'wal_bufsize',
    'wal_grp_cmt_wait',
    'lc_messages',
    'lc_ctype',
    'cache_manager',
    'shutdown',
    'online',
    'shutdown_delay',
    'reserved',
    'overwrite',
    'sec_attach',
    'disable_wal',
    'connect_timeout',
    'dummy_packet_interval',
    'gbak_attach',
    'sql_role_name',
    'set_page_buffers',
    'working_directory',
    'sql_dialect',
    'set_db_readonly',
    'set_db_sql_dialect',
    'gfix_attach',
    'gstat_attach',
    'set_db_charset',
    'gsec_attach',
    'address_path' ,
    'process_id',
    'no_db_triggers',
    'trusted_auth',
    'process_name',
    'trusted_role',
    'org_filename',
    'utf8_ilename',
    'ext_call_depth',
    'auth_block',
    'client_version',
    'remote_protocol',
    'host_name',
    'os_user',
    'specific_auth_data',
    'auth_plugin_list',
    'auth_plugin_name',
    'config',
    'nolinger',
    'reset_icu',
    'map_attach'
    );

  TPBPrefix = 'isc_tpb_';
  TPBConstantNames: array[1..isc_tpb_last_tpb_constant] of string = (
    'consistency',
    'concurrency',
    'shared',
    'protected',
    'exclusive',
    'wait',
    'nowait',
    'read',
    'write',
    'lock_read',
    'lock_write',
    'verb_time',
    'commit_time',
    'ignore_limbo',
    'read_committed',
    'autocommit',
    'rec_version',
    'no_rec_version',
    'restart_requests',
    'no_auto_undo',
    'lock_timeout'
  );




  TR_READ_ONLY_PARAMS: array [0 .. 1] of byte = (isc_tpb_read, isc_tpb_nowait);
  TR_READ_COMMITED_PARAMS: array [0 .. 2] of byte = (isc_tpb_read_committed,
    isc_tpb_nowait, isc_tpb_write);
  TR_READ_CONCURENCY_PARAMS: array [0 .. 2] of byte = (isc_tpb_concurrency,
    isc_tpb_nowait, isc_tpb_write);

type
  TFbApiTransaction = class;
  TIBTransaction = TFbApiTransaction;
  TIBBase = class;
  TFBApiDatabase = class;

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

  TFBApiDatabase = class(TCustomConnection)
  private
    FBLibrary: IFirebirdLibrary;
    FFirebirdAPI: IFirebirdAPI;
    FParams: TFBApiDatabaseParams;
    FAttachment: IAttachment;
    FDefaultTransaction: TFbApiTransaction;
    FInternalTransaction: TIBTransaction;
    FSQLObjects: TList;
    FTransactions: TList;
    FAllowStreamedConnected: boolean;
    procedure Init;
    function AddSQLObject(ds: TIBBase): Integer;
    procedure RemoveSQLObject(Idx: Integer);
    procedure RemoveSQLObjects;
    procedure SetDefaultTransaction(const Value: TFbApiTransaction);
    function GetTransaction(Index: Integer): TIBTransaction;
    function GetConnected: Boolean;override;
    procedure SetConnected( Value: Boolean);override;
    function GetSQLObject(Index: Integer): TIBBase;
    function GetSQLObjectCount: Integer;
    function GetSQLObjectsCount: Integer;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;
    property Connected:Boolean read GetConnected write SetConnected;
    procedure Connect;
    procedure CheckActive;
    procedure CheckInactive;
    function IsConnected: Boolean;
    function startReadTransaction: ITransaction;
    function startReadCommitedTransaction: ITransaction;
    function startConcurencyTransaction: ITransaction;
    procedure Disconnect;
    property Attachment: IAttachment read FAttachment;
    property FirebirdAPI: IFirebirdAPI read FFirebirdAPI;
    property params: TFBApiDatabaseParams read FParams;
    property SQLObjectCount: Integer read GetSQLObjectCount; {ignores nil objects}
    property SQLObjectsCount: Integer read GetSQLObjectsCount;
    property SQLObjects[Index: Integer]: TIBBase read GetSQLObject;
    property DefaultTransaction: TFbApiTransaction read FDefaultTransaction
                                                 write SetDefaultTransaction;
    property Transactions[Index: Integer]: TIBTransaction read GetTransaction;
    property InternalTransaction: TIBTransaction read FInternalTransaction;
    property AllowStreamedConnected: boolean read FAllowStreamedConnected
             write FAllowStreamedConnected;

    function QueryValue(const SQL: String;
      const AParams: array of variant): Variant;

    function AddTransaction(TR: TIBTransaction): Integer;
    function FindDefaultTransaction(): TIBTransaction;
    function FindTransaction(TR: TIBTransaction): Integer;
    procedure RemoveTransaction(Idx: Integer);
    procedure RemoveTransactions;

  end;

  TFbTransactionParams = array of byte;
  TDefaultEndAction = TARollback..TACommit;
  TIBDatabase = TFbApiDatabase;

  TFbApiTransaction = class(TComponent)
  private
    FTransaction: ITransaction;
    FParams: IB.TByteArray;
    FDefaultDatabase: TFbApiDatabase;
    FDatabases: TList;
    FSQLObjects         : TList;
    FTPB                : ITPB;
//    FTimer              : TFPTimer;
    FDefaultAction      : TDefaultEndAction;
    FTRParams           : TStrings;
    FTRParamsChanged    : Boolean;
    FInEndTransaction   : boolean;
    FEndAction          : TTransactionAction;
    FStreamedActive: Boolean;
//    FDefaultCompletion: TTransactionCompletion;
    IsParamsChanged: Boolean;
    FDefaultCompletion: TTransactionCompletion;
    FTransactionIntf: ITransaction;
    procedure EnsureNotInTransaction;
    procedure EndTransaction(Action: TTransactionAction; Force: Boolean);
    procedure SetDatabase(const Value: TFbApiDatabase);
    procedure SetParams(const Value: TByteArray);
    function GetInTransaction: Boolean;
    procedure SetDefaultCompletion(const Value: TTransactionCompletion);
    function CheckTransaction:Boolean;
    procedure CreateNewTransaction;
    procedure RemoveSQLObject(Idx: Integer);
    procedure RemoveSQLObjects;
    procedure TRParamsChange(Sender: TObject);
    procedure TRParamsChanging(Sender: TObject);
    function GetDatabase(Index: Integer): TFbApiDatabase;
    function GetDatabaseCount: Integer;
    //function GetInTransaction: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure SetDefaultDatabase(const Value: TFbApiDatabase);
    procedure SetTRParams(const Value: TStrings);
//    procedure Start;
    function GenerateTPB(FirebirdAPI: IFirebirdAPI; sl: TStrings): ITPB;
    function AddSQLObject(ds: TIBBase): Integer;

  protected
    procedure Loaded; override;
    procedure Notification( AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    procedure Close;
    procedure Commit;
    procedure CommitRetaining;
    procedure Rollback;
    procedure RollbackRetaining;
    procedure StartTransaction;
    procedure CheckInTransaction;
    procedure CheckNotInTransaction;

    function AddDatabase(db: TFbApiDatabase): Integer;
    function FindDatabase(db: TFbApiDatabase): Integer;
    function FindDefaultDatabase: TFbApiDatabase;
    function GetEndAction: TTransactionAction;
    procedure RemoveDatabase(Idx: Integer);
    procedure RemoveDatabases;
    procedure CheckDatabasesInList;

    property DatabaseCount: Integer read GetDatabaseCount;
    property Databases[Index: Integer]: TFbApiDatabase read GetDatabase;
//    property SQLObjectCount: Integer read GetSQLObjectCount;
//    property SQLObjects[Index: Integer]: TIBBase read GetSQLObject;
    property InTransaction: Boolean read GetInTransaction;
    property TransactionIntf: ITransaction read FTransactionIntf;
    property TPB: ITPB read FTPB;
  published
    property Active: Boolean read GetInTransaction write SetActive;
    property DefaultDatabase: TFbApiDatabase read FDefaultDatabase
                                           write SetDefaultDatabase;
//    property IdleTimer: Integer read GetIdleTimer write SetIdleTimer default 0;
    property DefaultAction: TDefaultEndAction read FDefaultAction write FDefaultAction default taCommit;
    property Params: TStrings read FTRParams write SetTRParams;
//    property OnIdleTimer: TNotifyEvent read FOnIdleTimer write FOnIdleTimer;
//    property BeforeTransactionEnd: TNotifyEvent read FBeforeTransactionEnd
//                                             write FBeforeTransactionEnd;
//    property AfterTransactionEnd: TNotifyEvent read FAfterTransactionEnd
//                                            write FAfterTransactionEnd;
//    property OnStartTransaction: TNotifyEvent read FOnStartTransaction
//                                              write FOnStartTransaction;
//    property AfterExecQuery: TNotifyEvent read FAfterExecQuery
//                                              write FAfterExecQuery;
//    property AfterEdit: TNotifyEvent read FAfterEdit write FAfterEdit;
//    property AfterDelete: TNotifyEvent read FAfterDelete write FAfterDelete;
//    property AfterInsert: TNotifyEvent read FAfterInsert write FAfterInsert;
//    property AfterPost: TNotifyEvent read FAfterPost write FAfterPost;




  {  procedure Start;
    procedure Commit;
    procedure Rollback;
    property Params:TByteArray read FParams write SetParams;
    property Database:TFbApiDatabase read FDefaultDatabase write SetDatabase;
    property InTransaction: Boolean read GretInTransaction;
    property TransactionIntf:ITransaction read FTransaction ;
    property DefaultCompletion: TTransactionCompletion read FDefaultCompletion write SetDefaultCompletion;}
  end;

  TTransactionEndEvent = procedure(Sender:TObject; Action: TTransactionAction) of object;
  TBeforeDatabaseConnectEvent = procedure (Sender: TObject; DBParams: TStrings;
                              var DBName: string; var CreateIfNotExists: boolean) of object;
  { TIBBase }

  { Virtually all components in IB are "descendents" of TIBBase.
    It is to more easily manage the database and transaction
    connections. }
  TIBBase = class(TObject)
  private
    FOnCreateDatabase: TNotifyEvent;
  protected
    FBeforeDatabaseConnect: TBeforeDatabaseConnectEvent;
    FDatabase: TIBDatabase;
    FIndexInDatabase: Integer;
    FTransaction: TIBTransaction;
    FIndexInTransaction: Integer;
    FOwner: TObject;
    FBeforeDatabaseDisconnect: TNotifyEvent;
    FAfterDatabaseDisconnect: TNotifyEvent;
    FAfterDatabaseConnect: TNotifyEvent;
    FOnDatabaseFree: TNotifyEvent;
    FBeforeTransactionEnd: TTransactionEndEvent;
    FAfterTransactionEnd: TNotifyEvent;
    FOnTransactionFree: TNotifyEvent;
    FIsTransactionOwner: Boolean;

    procedure DoBeforeDatabaseConnect(DBParams: TStrings;
                              var DBName: string; var CreateIfNotExists: boolean); virtual;
    procedure DoAfterDatabaseConnect; virtual;
    procedure DoBeforeDatabaseDisconnect; virtual;
    procedure DoAfterDatabaseDisconnect; virtual;
    procedure DoOnCreateDatabase; virtual;
    procedure DoDatabaseFree; virtual;
    procedure DoBeforeTransactionEnd(Action: TTransactionAction); virtual;
    procedure DoAfterTransactionEnd; virtual;
    procedure DoTransactionFree; virtual;
    procedure SetDatabase(Value: TIBDatabase); virtual;
    procedure SetTransaction(Value: TIBTransaction); virtual;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    procedure CheckDatabase; virtual;
    procedure CheckTransaction; virtual;
    procedure DoAfterExecQuery(Sender: TObject); virtual;
    procedure DoAfterEdit(Sender: TObject); virtual;
    procedure DoAfterDelete(Sender: TObject); virtual;
    procedure DoAfterInsert(Sender: TObject); virtual;
    procedure DoAfterPost(Sender: TObject); virtual;
    procedure HandleException(Sender: TObject);
    procedure SetCursor;
    procedure RestoreCursor;
  public
    property BeforeDatabaseConnect: TBeforeDatabaseConnectEvent read FBeforeDatabaseConnect
                                                 write FBeforeDatabaseConnect;
    property AfterDatabaseConnect: TNotifyEvent read FAfterDatabaseConnect
                                                write FAfterDatabaseConnect;
    property BeforeDatabaseDisconnect: TNotifyEvent read FBeforeDatabaseDisconnect
                                                   write FBeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect: TNotifyEvent read FAfterDatabaseDisconnect
                                                  write FAfterDatabaseDisconnect;
    property OnCreateDatabase: TNotifyEvent read FOnCreateDatabase
                                            write FOnCreateDatabase;
    property OnDatabaseFree: TNotifyEvent read FOnDatabaseFree write FOnDatabaseFree;
    property BeforeTransactionEnd: TTransactionEndEvent read FBeforeTransactionEnd write FBeforeTransactionEnd;
    property AfterTransactionEnd: TNotifyEvent read FAfterTransactionEnd write FAfterTransactionEnd;
    property OnTransactionFree: TNotifyEvent read FOnTransactionFree write FOnTransactionFree;
    property Database: TIBDatabase read FDatabase
                                    write SetDatabase;
    property Owner: TObject read FOwner;
    property Transaction: TIBTransaction read FTransaction
                                          write SetTransaction;
    property IsTransactionOwner:Boolean read FIsTransactionOwner;
  end;


implementation


function TFBApiDatabase.AddSQLObject(ds: TIBBase): Integer;
begin
  result := 0;
//  if (ds.Owner is TIBCustomDataSet) then
//    FDataSets.Add(ds.Owner);
  while (result < FSQLObjects.Count) and (FSQLObjects[result] <> nil) do
    Inc(result);
  if (result = FSQLObjects.Count) then
    FSQLObjects.Add(ds)
  else
    FSQLObjects[result] := ds;
end;

function TFBApiDatabase.AddTransaction(TR: TIBTransaction): Integer;
begin
  result := FindTransaction(TR);
  if result <> -1 then
  begin
    result := -1;
    exit;
  end;
  result := 0;
  while (result < FTransactions.Count) and (FTransactions[result] <> nil) do
    Inc(result);
  if (result = FTransactions.Count) then
    FTransactions.Add(TR)
  else
    FTransactions[result] := TR;
end;

procedure TFBApiDatabase.CheckActive;
begin
  if StreamedConnected and (not Connected) then
    Loaded;
  if FAttachment = nil then
    IBError(ibxeDatabaseClosed, [nil]);
end;

procedure TFBApiDatabase.CheckInactive;
begin
  if FAttachment <> nil then
    IBError(ibxeDatabaseOpen, [nil]);
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

  FAttachment := FFirebirdAPI.OpenDatabase(FParams.DbName, DPB, True);

  // FAttachment.Connect;
end;

constructor TFBApiDatabase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParams := TFBApiDatabaseParams.Create(self);
  FTransactions := TList.Create;
  FSQLObjects := TList.Create;

end;

destructor TFBApiDatabase.Destroy;
begin
  if IsConnected then
    Disconnect;
  FreeAndNil(FParams);
  FreeAndNil(FTransactions);
  FreeAndNil(FSQLObjects);
  Inherited;
end;

procedure TFBApiDatabase.Disconnect;
begin
  // raise Exception.Create('Error Message');
  if FAttachment.IsConnected then
    FAttachment.Disconnect();
  FreeAndNil(FAttachment);
  FFirebirdAPI := nil;
end;

function TFBApiDatabase.FindDefaultTransaction: TIBTransaction;
var
  i: Integer;
begin
  result := FDefaultTransaction;
  if result = nil then
  begin
    for i := 0 to FTransactions.Count - 1 do
      if (Transactions[i] <> nil) and
        (TIBTransaction(Transactions[i]).DefaultDatabase = self) and
        (TIBTransaction(Transactions[i]) <> FInternalTransaction) then
       begin
         result := TIBTransaction(Transactions[i]);
         break;
       end;
  end;

end;

function TFBApiDatabase.FindTransaction(TR: TIBTransaction): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to FTransactions.Count - 1 do
    if TR = Transactions[i] then
    begin
      result := i;
      break;
    end;
end;

function TFBApiDatabase.GetConnected: Boolean;
begin
  result := (FAttachment <> nil) and FAttachment.IsConnected;
end;

function TFBApiDatabase.GetSQLObject(Index: Integer): TIBBase;
begin
  result := FSQLObjects[Index];
end;

function TFBApiDatabase.GetSQLObjectCount: Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to FSQLObjects.Count - 1 do if FSQLObjects[i] <> nil then
    Inc(result);
end;

function TFBApiDatabase.GetSQLObjectsCount: Integer;
begin
  Result := FSQLObjects.Count;
end;

function TFBApiDatabase.GetTransaction(Index: Integer): TIBTransaction;
begin
  result := FTransactions[Index];
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
  FBLibrary := LoadFBLibrary(FParams.libPath);
  FFirebirdAPI := IB.FirebirdAPI;
//  if not FFirebirdAPI.LoadInterface then
//    raise Exception.Create('Error in loading FirebirdAPI Interface');
end;

function TFBApiDatabase.IsConnected: Boolean;
begin
  Result := Assigned(FAttachment) and Attachment.IsConnected;
end;

function TFBApiDatabase.QueryValue(const SQL: String;
  const AParams: array of variant): variant;
var
  statement: IStatement;
  tr: ITransaction;
  i: Integer;
  rs: IResultSet;
begin
  tr := startReadTransaction;
  statement := FAttachment.PrepareWithNamedParameters(tr, SQL, FParams.SqlDialect, true, false);
  try
    if Assigned(statement.GetSQLParams) then
    for i := 0 to statement.GetSQLParams.Count - 1 do
    begin
      try
        statement.GetSQLParams.params[i].Value := AParams[i];
      except
        raise Exception.CreateFmt('Error set param qr2 [%d]', [i]);
      end;
    end;
      rs := statement.OpenCursor();
      if rs.FetchNext then
      begin
        if (rs.Count>1) then
        begin
          Result := VarArrayCreate([0,rs.Count-1],varVariant);
          for i:=0 to rs.Count-1 do
             Result[i] := rs.Data[i].AsVariant;
        end
        else
          Result := rs.Data[0].AsVariant;

      end;
  finally
    tr.commit;
    statement := nil;
    tr := nil;
  end;

end;

procedure TFBApiDatabase.RemoveSQLObject(Idx: Integer);
var
  ds: TIBBase;
begin
  if (Idx >= 0) and (FSQLObjects[Idx] <> nil) then
  begin
    ds := SQLObjects[Idx];
    FSQLObjects[Idx] := nil;
    ds.Database := nil;
//    if (ds.owner is TDataSet) then
//      FDataSets.Remove(TDataSet(ds.Owner));
  end;

end;

procedure TFBApiDatabase.RemoveSQLObjects;
begin

end;

procedure TFBApiDatabase.RemoveTransaction(Idx: Integer);
var
  TR: TIBTransaction;
begin
  if ((Idx >= 0) and (FTransactions[Idx] <> nil)) then
  begin
    TR := Transactions[Idx];
    FTransactions[Idx] := nil;
    TR.RemoveDatabase(TR.FindDatabase(Self));
    if TR = FDefaultTransaction then
      FDefaultTransaction := nil;
  end;
end;

procedure TFBApiDatabase.RemoveTransactions;
var
  i: Integer;
begin
  for i := 0 to FTransactions.Count - 1 do if FTransactions[i] <> nil then
    RemoveTransaction(i);
end;

procedure TFBApiDatabase.SetConnected( Value: Boolean);
begin
  if StreamedConnected and not AllowStreamedConnected then
  begin
    StreamedConnected := false;
    Value := false
  end;
  inherited SetConnected(Value);

end;

procedure TFBApiDatabase.SetDefaultTransaction(const Value: TIBTransaction);
begin
  FDefaultTransaction := Value;
end;

{ TFBDatabaseParams }

constructor TFBApiDatabaseParams.Create;
begin
  Inherited;
  FSqlDialect := 3;
  FDefaultCharSet := 'UTF8';
end;

{ TFbTransaction }

function TFbApiTransaction.AddDatabase(db: TFbApiDatabase): Integer;
var
  i: Integer;
  NilFound: Boolean;
begin
  EnsureNotInTransaction;
  CheckNotInTransaction;
  FTransactionIntf := nil;

  i := FindDatabase(db);
  if i <> -1 then
  begin
    result := i;
    exit;
  end;
  NilFound := False;
  i := 0;
  while (not NilFound) and (i < FDatabases.Count) do
  begin
    NilFound := (FDatabases[i] = nil);
    if (not NilFound) then
      Inc(i);
  end;
  if (NilFound) then
  begin
    FDatabases[i] := db;
    result := i;
  end
  else
  begin
    result := FDatabases.Count;
    FDatabases.Add(db);
  end;
end;

function TFbApiTransaction.AddSQLObject(ds: TIBBase): Integer;
begin
  result := 0;
  while (result < FSQLObjects.Count) and (FSQLObjects[result] <> nil) do
    Inc(result);
  if (result = FSQLObjects.Count) then
    FSQLObjects.Add(ds)
  else
    FSQLObjects[result] := ds;
end;

procedure TFbApiTransaction.CheckDatabasesInList;
begin
  if GetDatabaseCount = 0 then
    IBError(ibxeNoDatabasesInTransaction, [nil]);
end;

procedure TFbApiTransaction.CheckInTransaction;
begin
  if FStreamedActive and (not InTransaction) then
    Loaded;
  if (TransactionIntf = nil) then
    IBError(ibxeNotInTransaction, [nil]);
end;

procedure TFbApiTransaction.CheckNotInTransaction;
begin
  if (TransactionIntf <> nil) and  TransactionIntf.InTransaction then
    IBError(ibxeInTransaction, [nil]);
end;

function TFbApiTransaction.CheckTransaction: Boolean;
begin
  if not Assigned(FTransaction) then
    raise Exception.Create('Transaction not started');
  Result := true;
end;

procedure TFbApiTransaction.Close;
begin
  if InTransaction then
    EndTransaction(FDefaultAction, True);
end;

procedure TFbApiTransaction.Commit;
begin
  EndTransaction(TACommit, False);
end;

procedure TFbApiTransaction.CommitRetaining;
begin
  EndTransaction(TACommitRetaining, False);
end;

constructor TFbApiTransaction.Create;
var I: Integer;
begin
  inherited Create(AOwner);
  FDatabases := TList.Create;
  FSQLObjects := TList.Create;
  FTPB := nil;
  FTRParams := TStringList.Create;
  FTRParamsChanged := True;
  TStringList(FTRParams).OnChange := TRParamsChange;
  TStringList(FTRParams).OnChanging := TRParamsChanging;
  FDefaultAction := taCommit;


  IsParamsChanged := True;
  SetLength(FParams,3);
  for I := 0 to 2 do
  FParams[i] := TR_READ_CONCURENCY_PARAMS[i];
  FDefaultCompletion := TACommit;
  FTransaction := nil;
end;

procedure TFbApiTransaction.CreateNewTransaction;
begin
  FTransaction := nil;
  FTransaction := FDefaultDatabase.Attachment.StartTransaction(FParams,FDefaultCompletion);
end;

destructor TFbApiTransaction.Destroy;
var
  i: Integer;
begin
  if InTransaction then
    EndTransaction(FDefaultAction, True);
{  for i := 0 to FSQLObjects.Count - 1 do
    if FSQLObjects[i] <> nil then
      SQLObjects[i].DoTransactionFree;
  RemoveSQLObjects;}
  RemoveDatabases;
  FTPB := nil;
  FTRParams.Free;
  FSQLObjects.Free;
  FDatabases.Free;
  inherited Destroy;
end;


procedure TFbApiTransaction.EndTransaction(Action: TTransactionAction; Force: Boolean);
var
  i: Integer;
begin
  CheckInTransaction;
  if FInEndTransaction then Exit;
  FInEndTransaction := true;
  FEndAction := Action;
  try
  case Action of
    TARollback, TACommit:
    begin
      try
        //DoBeforeTransactionEnd;
      except on E: EIBInterBaseError do
        begin
          if not Force then
            raise;
        end;
      end;

      for i := 0 to FSQLObjects.Count - 1 do if FSQLObjects[i] <> nil then
      try
        //SQLObjects[i].DoBeforeTransactionEnd(Action);
      except on E: EIBInterBaseError do
        begin
          if not Force then
              raise;
          end;
      end;

      if InTransaction then
      begin
        if (Action = TARollback) then
            FTransactionIntf.Rollback(Force)
        else
        try
          FTransactionIntf.Commit;
        except on E: EIBInterBaseError do
          begin
            if Force then
              FTransactionIntf.Rollback(Force)
            else
              raise;
          end;
        end;

          for i := 0 to FSQLObjects.Count - 1 do if FSQLObjects[i] <> nil then
          try
            //SQLObjects[i].DoAfterTransactionEnd;
          except on E: EIBInterBaseError do
            begin
              if not Force then
                raise;
            end;
          end;
        try
          //DoAfterTransactionEnd;
        except on E: EIBInterBaseError do
          begin
            if not Force then
              raise;
          end;
        end;
      end;
    end;
    TACommitRetaining:
      FTransactionIntf.CommitRetaining;

    TARollbackRetaining:
      FTransactionIntf.RollbackRetaining;
  end;
{  if not (csDesigning in ComponentState) then
  begin
    case Action of
      TACommit:
        MonitorHook.TRCommit(Self);
      TARollback:
        MonitorHook.TRRollback(Self);
      TACommitRetaining:
        MonitorHook.TRCommitRetaining(Self);
      TARollbackRetaining:
        MonitorHook.TRRollbackRetaining(Self);
    end;
  end;}
  finally
    FInEndTransaction := false
  end;

end;

procedure TFbApiTransaction.EnsureNotInTransaction;
begin
  if csDesigning in ComponentState then
  begin
    if TransactionIntf <> nil then
      Rollback;
  end;
end;

function TFbApiTransaction.FindDatabase(db: TFbApiDatabase): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to FDatabases.Count - 1 do
    if db = TIBDatabase(FDatabases[i]) then
    begin
      result := i;
      break;
    end;
end;

function TFbApiTransaction.FindDefaultDatabase: TFbApiDatabase;
var
  i: Integer;
begin
  result := FDefaultDatabase;
  if result = nil then
  begin
    for i := 0 to FDatabases.Count - 1 do
      if (TIBDatabase(FDatabases[i]) <> nil) and
        (TIBDatabase(FDatabases[i]).DefaultTransaction = self) then
      begin
        result := TIBDatabase(FDatabases[i]);
        break;
      end;
  end;
end;

function TFbApiTransaction.GenerateTPB(FirebirdAPI: IFirebirdAPI; sl: TStrings): ITPB;
var
  i, j, TPBVal: Integer;
  ParamName, ParamValue: string;
begin
  Result := FirebirdAPI.AllocateTPB;
  for i := 0 to sl.Count - 1 do
  begin
    if (Trim(sl[i]) =  '') then
      Continue;

    if (Pos('=', sl[i]) = 0) then {mbcs ok}
      ParamName := LowerCase(sl[i]) {mbcs ok}
    else
    begin
      ParamName := LowerCase(sl.Names[i]); {mbcs ok}
      ParamValue := Copy(sl[i], Pos('=', sl[i]) + 1, Length(sl[i])); {mbcs ok}
    end;
    if (Pos(TPBPrefix, ParamName) = 1) then {mbcs ok}
      Delete(ParamName, 1, Length(TPBPrefix));
    TPBVal := 0;
    { Find the parameter }
    for j := 1 to isc_tpb_last_tpb_constant do
      if (ParamName = TPBConstantNames[j]) then
      begin
        TPBVal := j;
        break;
      end;
    { Now act on it }
    case TPBVal of
      isc_tpb_consistency, isc_tpb_exclusive, isc_tpb_protected,
      isc_tpb_concurrency, isc_tpb_shared, isc_tpb_wait, isc_tpb_nowait,
      isc_tpb_read, isc_tpb_write, isc_tpb_ignore_limbo,
      isc_tpb_read_committed, isc_tpb_rec_version, isc_tpb_no_rec_version:
        Result.Add(TPBVal);

      isc_tpb_lock_read, isc_tpb_lock_write:
        Result.Add(TPBVal).SetAsString(ParamValue);

      else
      begin
        if (TPBVal > 0) and
           (TPBVal <= isc_tpb_last_tpb_constant) then
          IBError(ibxeTPBConstantNotSupported, [TPBConstantNames[TPBVal]])
        else
          IBError(ibxeTPBConstantUnknownEx, [sl.Names[i]]);
      end;
    end;
  end;

end;

function TFbApiTransaction.GetDatabase(Index: Integer): TFbApiDatabase;
begin
  result := FDatabases[Index];
end;

function TFbApiTransaction.GetDatabaseCount: Integer;
var
  i, Cnt: Integer;
begin
  result := 0;
  Cnt := FDatabases.Count - 1;
  for i := 0 to Cnt do if FDatabases[i] <> nil then
    Inc(result);
end;

function TFbApiTransaction.GetEndAction: TTransactionAction;
begin
  if FInEndTransaction then
     Result := FEndAction
  else
     IBError(ibxeIB60feature, [nil])
end;

function TFbApiTransaction.GetInTransaction: Boolean;
begin
  result := (TransactionIntf <> nil) and TransactionIntf.InTransaction;
end;

{function TFbApiTransaction.GretInTransaction: Boolean;
begin
  Result := Assigned(FTransaction) and FTransaction.InTransaction;
end;}

procedure TFbApiTransaction.Loaded;
begin
  inherited Loaded;
end;

procedure TFbApiTransaction.Notification(AComponent: TComponent; Operation: TOperation);
var
  i: Integer;
begin
  inherited Notification( AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDefaultDatabase) then
  begin
    i := FindDatabase(FDefaultDatabase);
    if (i <> -1) then
      RemoveDatabase(i);
    FDefaultDatabase := nil;
  end;
end;

procedure TFbApiTransaction.RemoveDatabase(Idx: Integer);
var
  DB: TIBDatabase;
begin
  if ((Idx >= 0) and (FDatabases[Idx] <> nil)) then
  begin
    EnsureNotInTransaction;
    CheckNotInTransaction;
    FTransactionIntf := nil;

    DB := Databases[Idx];
    FDatabases[Idx] := nil;
    DB.RemoveTransaction(DB.FindTransaction(Self));
    if DB = FDefaultDatabase then
      FDefaultDatabase := nil;
  end;
end;

procedure TFbApiTransaction.RemoveDatabases;
var
  i: Integer;
begin
  EnsureNotInTransaction;
  CheckNotInTransaction;
  FTransactionIntf := nil;

  for i := 0 to FDatabases.Count - 1 do if FDatabases[i] <> nil then
    RemoveDatabase(i);
end;

procedure TFbApiTransaction.RemoveSQLObject(Idx: Integer);
begin

end;

procedure TFbApiTransaction.RemoveSQLObjects;
begin

end;

procedure TFbApiTransaction.Rollback;
begin
  EndTransaction(TARollback, False);
end;

procedure TFbApiTransaction.RollbackRetaining;
begin
  EndTransaction(TARollbackRetaining, False);
end;

procedure TFbApiTransaction.SetActive(const Value: Boolean);
begin
  if csReading in ComponentState then
    FStreamedActive := Value
  else
    if Value and not InTransaction then
      StartTransaction
    else
      if not Value and InTransaction then
        Rollback;
end;

procedure TFbApiTransaction.SetDatabase(const Value: TFbApiDatabase);
var
  i: integer;
begin
  if (FDefaultDatabase <> nil) and (FDefaultDatabase <> Value) then
  begin
    i := FDefaultDatabase.FindTransaction(self);
    if (i <> -1) then
      FDefaultDatabase.RemoveTransaction(i);
  end;
  if (Value <> nil) and (FDefaultDatabase <> Value) then
  begin
    Value.AddTransaction(Self);
    AddDatabase(Value);
    {*for i := 0 to FSQLObjects.Count - 1 do
      if (FSQLObjects[i] <> nil) and
         (TIBBase(FSQLObjects[i]).Database = nil) then
         SetObjectProp(TIBBase(FSQLObjects[i]).Owner, 'Database', Value);*}
  end;
  FDefaultDatabase := Value;
end;

procedure TFbApiTransaction.SetDefaultCompletion(const Value: TTransactionCompletion);
begin
  FDefaultCompletion := Value;
end;

procedure TFbApiTransaction.SetDefaultDatabase(const Value: TFbApiDatabase);
var
  i: integer;
begin
  if (FDefaultDatabase <> nil) and (FDefaultDatabase <> Value) then
  begin
    i := FDefaultDatabase.FindTransaction(self);
    if (i <> -1) then
      FDefaultDatabase.RemoveTransaction(i);
  end;
  if (Value <> nil) and (FDefaultDatabase <> Value) then
  begin
    Value.AddTransaction(Self);
    AddDatabase(Value);
    for i := 0 to FSQLObjects.Count - 1 do
      if (FSQLObjects[i] <> nil) and
         (TIBBase(FSQLObjects[i]).Database = nil) then
         TIBBase(TIBBase(FSQLObjects[i]).Owner).Database :=  Value;
  end;
  FDefaultDatabase := Value;
end;

procedure TFbApiTransaction.SetParams(const Value: TByteArray);
begin
  if FParams <> Value then
  begin
    FParams := Value;
    IsParamsChanged := True;
  end;
end;

procedure TFbApiTransaction.SetTRParams(const Value: TStrings);
begin
  FTRParams.Assign(Value);
end;

{procedure TFbApiTransaction.Start;
begin
//  if not Assigned(FTransaction) then
//    FTransaction := TFB30Transaction.Create(FDatabase.FirebirdApi,[FDatabase.Attachment],FParams,FDefaultCompletion);

//  if Assigned(FTransaction) and not FTransaction.InTransaction then
//    FTransaction.Start(FDefaultCompletion)
//  else
//    fTransaction := FDatabase.Attachment.
   if Assigned(FTransaction) then
   begin
     if not FTransaction.InTransaction then
       if IsParamsChanged  then
         createNewTransaction
       else
         FTransaction.Start(FDefaultCompletion)
     else
       raise Exception.Create('Transaction is active');
   end
   else
         createNewTransaction
//     FTransaction := FDatabase.Attachment.StartTransaction(FParams,FDefaultCompletion);
end;}

procedure TFbApiTransaction.StartTransaction;
var
  i: Integer;
  Attachments: array of IAttachment;
  ValidDatabaseCount: integer;
begin
  CheckNotInTransaction;
  CheckDatabasesInList;
  if TransactionIntf <> nil then
    TransactionIntf.Start(DefaultAction)
  else
  begin
    for i := 0 to FDatabases.Count - 1 do
     if  FDatabases[i] <> nil then
     begin
       with TIBDatabase(FDatabases[i]) do
       if not Connected then
         if StreamedConnected then
         begin
           Open;
           StreamedConnected := False;
         end
         else
           IBError(ibxeDatabaseClosed, [nil]);
     end;
    if FTRParamsChanged then
    begin
      FTRParamsChanged := False;
      FTPB :=  GenerateTPB(Databases[0].FirebirdAPI,FTRParams);
    end;

    ValidDatabaseCount := 0;
    for i := 0 to DatabaseCount - 1 do
      if Databases[i] <> nil then Inc(ValidDatabaseCount);

    if ValidDatabaseCount = 1 then
      FTransactionIntf := Databases[0].Attachment.StartTransaction(FTPB,DefaultAction)
    else
    begin
      SetLength(Attachments,ValidDatabaseCount);
      for i := 0 to DatabaseCount - 1 do
        if Databases[i] <> nil then
          Attachments[i] := Databases[i].Attachment;

      FTransactionIntf := Databases[0].FirebirdAPI.StartTransaction(Attachments,FTPB,DefaultAction);
    end;
  end;

//  if not (csDesigning in ComponentState) then
//      MonitorHook.TRStart(Self);
//  DoOnStartTransaction;
end;

procedure TFbApiTransaction.TRParamsChange(Sender: TObject);
begin
  FTRParamsChanged := True;
end;

procedure TFbApiTransaction.TRParamsChanging(Sender: TObject);
begin
  EnsureNotInTransaction;
  CheckNotInTransaction;
  FTransactionIntf := nil;
end;


{ TIBBase }

procedure TIBBase.CheckDatabase;
begin
  if (FDatabase = nil) then
    IBError(ibxeDatabaseNotAssigned, [nil]);
  FDatabase.CheckActive;
end;

procedure TIBBase.CheckTransaction;
begin
  if FTransaction = nil then
    IBError(ibxeTransactionNotAssigned, [nil]);
  if (not FTransaction.Active) then
  begin
     FTransaction.StartTransaction;
     FIsTransactionOwner := True;
  end;
  FTransaction.CheckInTransaction;
end;

constructor TIBBase.Create(AOwner: TObject);
begin
  FOwner := AOwner;
  FIsTransactionOwner := False;
end;

destructor TIBBase.Destroy;
begin
  SetDatabase(nil);
  SetTransaction(nil);
  inherited;
end;

procedure TIBBase.DoAfterDatabaseConnect;
begin
  if assigned(FAfterDatabaseConnect) then
    AfterDatabaseConnect(self);
end;

procedure TIBBase.DoAfterDatabaseDisconnect;
begin
  if Assigned(AfterDatabaseDisconnect) then
    AfterDatabaseDisconnect(Self);
end;

procedure TIBBase.DoAfterDelete(Sender: TObject);
begin
//  if FTransaction <> nil then
//    FTransaction.DoAfterDelete(Sender);
end;

procedure TIBBase.DoAfterEdit(Sender: TObject);
begin
//  if FTransaction <> nil then
//    FTransaction.DoAfterEdit(Sender);
end;

procedure TIBBase.DoAfterExecQuery(Sender: TObject);
begin
//  if FTransaction <> nil then
//    FTransaction.DoAfterExecQuery(Sender);
end;

procedure TIBBase.DoAfterInsert(Sender: TObject);
begin
//  if FTransaction <> nil then
//    FTransaction.DoAfterInsert(Sender);
end;

procedure TIBBase.DoAfterPost(Sender: TObject);
begin
//  if FTransaction <> nil then
//    FTransaction.DoAfterPost(Sender);
end;

procedure TIBBase.DoAfterTransactionEnd;
begin
  if Assigned(AfterTransactionEnd) then
    AfterTransactionEnd(Self);
end;

procedure TIBBase.DoBeforeDatabaseConnect(DBParams: TStrings; var DBName: string; var CreateIfNotExists: boolean);
begin
  if assigned(FBeforeDatabaseConnect) then
    BeforeDatabaseConnect(self,DBParams,DBName,CreateIfNotExists);
end;

procedure TIBBase.DoBeforeDatabaseDisconnect;
begin
  if Assigned(BeforeDatabaseDisconnect) then
    BeforeDatabaseDisconnect(Self);
end;

procedure TIBBase.DoBeforeTransactionEnd(Action: TTransactionAction);
begin
  if Assigned(BeforeTransactionEnd) then
    BeforeTransactionEnd(Self,Action);
end;

procedure TIBBase.DoDatabaseFree;
begin
  if Assigned(OnDatabaseFree) then
    OnDatabaseFree(Self);
  SetDatabase(nil);
  SetTransaction(nil);
end;

procedure TIBBase.DoOnCreateDatabase;
begin
  if assigned(FOnCreateDatabase) then
    OnCreateDatabase(self);
end;

procedure TIBBase.DoTransactionFree;
begin
  if Assigned(OnTransactionFree) then
    OnTransactionFree(Self);
  FTransaction := nil;
end;

procedure TIBBase.HandleException(Sender: TObject);
begin

end;

procedure TIBBase.RestoreCursor;
begin

end;

procedure TIBBase.SetCursor;
begin

end;

procedure TIBBase.SetDatabase(Value: TIBDatabase);
begin
  if (FDatabase <> nil) then
    FDatabase.RemoveSQLObject(FIndexInDatabase);
  FDatabase := Value;
  if (FDatabase <> nil) then
  begin
    FIndexInDatabase := FDatabase.AddSQLObject(Self);
    if (FTransaction = nil) then
      Transaction := FDatabase.FindDefaultTransaction;
  end;
end;

procedure TIBBase.SetTransaction(Value: TIBTransaction);
begin
  if (FTransaction <> nil) then
    FTransaction.RemoveSQLObject(FIndexInTransaction);
  FTransaction := Value;
  if (FTransaction <> nil) then
  begin
    FIndexInTransaction := FTransaction.AddSQLObject(Self);
    if (FDatabase = nil) then
      Database := FTransaction.FindDefaultDatabase;
  end;
end;

end.
