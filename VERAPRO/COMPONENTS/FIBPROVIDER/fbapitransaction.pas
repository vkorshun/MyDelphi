unit fbapitransaction;

interface

uses SysUtils, Classes, DB, IB, fbapidatabase, FbMessages;

type
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
    function GretInTransaction: Boolean;
    procedure SetDefaultCompletion(const Value: TTransactionCompletion);
    function CheckTransaction:Boolean;
    procedure CreateNewTransaction;
    procedure TRParamsChange(Sender: TObject);
    procedure TRParamsChanging(Sender: TObject);
    function GetDatabase(Index: Integer): TFbApiDatabase;
    function GetDatabaseCount: Integer;
    function GetInTransaction: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure SetDefaultDatabase(const Value: TFbApiDatabase);
    procedure SetTRParams(const Value: TStrings);
    procedure Start;
  protected
    procedure Loaded; override;
    procedure Notification( AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;

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

implementation

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
      if (TFbApiDatabase(FDatabases[i]) <> nil) and
        (TFbApiDatabase(FDatabases[i]).DefaultTransaction = self) then
      begin
        result := TIBDatabase(FDatabases[i]);
        break;
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

function TFbApiTransaction.GretInTransaction: Boolean;
begin
  Result := Assigned(FTransaction) and FTransaction.InTransaction;
end;

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
    {for i := 0 to FSQLObjects.Count - 1 do
      if (FSQLObjects[i] <> nil) and
         (TIBBase(FSQLObjects[i]).Database = nil) then
         SetObjectProp(TIBBase(FSQLObjects[i]).Owner, 'Database', Value);}
  end;
  FDefaultDatabase := Value;
end;

procedure TFbApiTransaction.SetDefaultCompletion(const Value: TTransactionCompletion);
begin
  FDefaultCompletion := Value;
end;

procedure TFbApiTransaction.SetDefaultDatabase(const Value: TFbApiDatabase);
begin
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

procedure TFbApiTransaction.Start;
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
end;

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

end.
