unit fbapiquery;

interface

uses SysUtils, Classes, DB, IB, fbapidatabase, FBMessages;

type

  TFbApiQuery = class(TComponent)
  private
    // FDatabase: TFbApiDatabase;
    // FTransaction: TFbApiTransaction;
    FStatement: IStatement;
    FResultSet: IResultSet;
    FSQL: TStrings;
    FActive: Boolean;
    FParams: TParams;
    FResults: IResults;
    FOnSQLChanging: TNotifyEvent;
    FBOF: Boolean;
    FEOF: Boolean;
    FMetaData: IMetaData;
    FOnSQLChanged: TNotifyEvent;
    FRecordCount: Integer;
    FSQLParams: ISQLParams;
    FParamCheck: Boolean;
    FGenerateParamNames: Boolean;
    FCaseSensitiveParameterNames: Boolean;
    FBase: TIBBase;
    FIsTransactionOwner: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetActive: Boolean;
    // function getStatement: IStatement;
    procedure SQLChanging(Sender: TObject);
    procedure SQLChanged(Sender: TObject);
    function GetEOF: Boolean;
    function GetFieldCount: Integer;
    function GetFieldIndex(FieldName: String): Integer;
    function GetFields(const Idx: Integer): ISQLData;
    function GetOpen: Boolean;
    function GetPlan: String;
    function GetPrepared: Boolean;
    function GetRecordCount: Integer;
    function GetRowsAffected: Integer;
    function GetSQLParams: ISQLParams;
    function GetSQLStatementType: TIBSQLStatementTypes;
    procedure SetDatabase(const Value: TFbApiDatabase);
    function GetDatabase: TFbApiDatabase;
    function GetTransaction: TFbApiTransaction;
    procedure SetTransaction(const Value: TFbApiTransaction);
    procedure SetIsTransactionOwner(const Value: Boolean);
    // function GetOpen:Boolean;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;
    procedure CheckClosed; { raise error if query is not closed. }
    procedure CheckOpen; { raise error if query is not open. }
    procedure CheckValidStatement; { raise error if statement is invalid. }

    procedure Close;
    procedure CloseWithTransaction(bCommit: Boolean = True);
    procedure ExecQuery;
    function HasField(const FieldName: String): Boolean;
    { Note: case sensitive match }
    function FieldByName(const FieldName: String): ISQLData;
    function ParamByName(const ParamName: String): ISQLParam;
    procedure FreeHandle;
    function Next: Boolean;
    procedure Prepare;
    function GetUniqueRelationName: String;
    property Bof: Boolean read FBOF;
    property Eof: Boolean read GetEOF;
    property Current: IResults read FResults;
    property Fields[const Idx: Integer]: ISQLData read GetFields; default;
    property FieldIndex[FieldName: String]: Integer read GetFieldIndex;
    property FieldCount: Integer read GetFieldCount;
    property IsOpen: Boolean read GetOpen;
    property Params: ISQLParams read GetSQLParams;
    property Plan: String read GetPlan;
    property Prepared: Boolean read GetPrepared;
    property RecordCount: Integer read GetRecordCount;
    property RowsAffected: Integer read GetRowsAffected;
    property SQLStatementType: TIBSQLStatementTypes read GetSQLStatementType;
    property UniqueRelationName: String read GetUniqueRelationName;
    property Statement: IStatement read FStatement;
    property MetaData: IMetaData read FMetaData;

    property CaseSensitiveParameterNames: Boolean
      read FCaseSensitiveParameterNames write FCaseSensitiveParameterNames;
    property Database: TFbApiDatabase read GetDatabase write SetDatabase;
    property GenerateParamNames: Boolean read FGenerateParamNames
      write FGenerateParamNames;
    property IsTransactionOwner: Boolean read FIsTransactionOwner
      write SetIsTransactionOwner;
    property Transaction: TFbApiTransaction read GetTransaction
      write SetTransaction;
    property Active: Boolean read GetActive write SetActive;
    property ParamCheck: Boolean read FParamCheck write FParamCheck;
    property SQL: TStrings read FSQL;
    property OnSQLChanging: TNotifyEvent read FOnSQLChanging
      write FOnSQLChanging;
    property OnSQLChanged: TNotifyEvent read FOnSQLChanged write FOnSQLChanged;

  end;

implementation

{ TFbApiQuery }

procedure TFbApiQuery.CheckClosed;
begin
  if FResultSet <> nil then
    IBError(ibxeSQLOpen, [nil]);
end;

procedure TFbApiQuery.CheckOpen;
begin
  if FResultSet = nil then
    IBError(ibxeSQLClosed, [nil]);
end;

procedure TFbApiQuery.CheckValidStatement;
begin
  // FBase.CheckTransaction; ???
  if (FStatement = nil) then
    IBError(ibxeInvalidStatementHandle, [nil]);
end;

procedure TFbApiQuery.Close;
begin
  if FResults <> nil then
    FResults.SetRetainInterfaces(false);
  FResultSet := nil;
  FResults := nil;
  FBOF := false;
  FEOF := false;
  FRecordCount := 0;
  { if (FBase.IsTransactionOwner and Assigned(FTransaction)) then
    begin
    if FTransaction.Active then
    fTransaction.Commit;
    FTransaction.Free;
    end; }
end;

procedure TFbApiQuery.CloseWithTransaction(bCommit: Boolean);
begin
  Close;
  if (Transaction.InTransaction) then
  begin
    if bCommit then
      Transaction.Commit
    else
      Transaction.Rollback;
  end;
end;

constructor TFbApiQuery.Create(Owner: TComponent);
begin
  inherited;
  FSQL := TStringList.Create;
  TStringList(FSQL).OnChanging := SQLChanging;
  TStringList(FSQL).OnChange := SQLChanged;
  FParamCheck := True;
  FBase := TIBBase.Create(self);
end;

destructor TFbApiQuery.Destroy;
begin
  if ((IsTransactionOwner or FBase.IsTransactionOwner) and
    Assigned(FBase.Transaction)) then
  begin
     if FBase.Transaction.Active then
    // FBase.Transaction.Commit;
       FBase.Transaction.Close;
  end;
  FreeAndNil(FSQL);
  FreeAndNil(FBase);
  inherited;
end;

procedure TFbApiQuery.ExecQuery;
{$IFDEF IBXQUERYSTATS}
var
  stats: TPerfCounters;
{$ENDIF}
{$IFDEF IBXQUERYTIME}
var
  tmsecs: comp;
{$ENDIF}
begin
  CheckClosed;
  if not Prepared then
    Prepare;
  CheckValidStatement;
{$IFDEF IBXQUERYTIME}
  tmsecs := TimeStampToMSecs(DateTimeToTimeStamp(Now));
{$ENDIF}
  if SQLStatementType = SQLSelect then
  begin
    FResultSet := FStatement.OpenCursor;
    FResults := FResultSet;
    FResults.SetRetainInterfaces(True);
    FBOF := True;
    FEOF := false;
    FRecordCount := 0;
    // if not (csDesigning in ComponentState) then
    // MonitorHook.SQLExecute(Self);
    // if FGoToFirstRecordOnExecute then
    Next;
  end
  else
  begin
    FResults := FStatement.Execute;
    // if not (csDesigning in ComponentState) then
    // MonitorHook.SQLExecute(Self);
  end;
{$IFDEF IBXQUERYTIME}
  writeln('Executing ', FStatement.GetSQLText, ' Response time= ',
    Format('%f msecs', [TimeStampToMSecs(DateTimeToTimeStamp(Now)) - tmsecs]));
{$ENDIF}
{$IFDEF IBXQUERYSTATS}
  if FStatement.GetPerfStatistics(stats) then
    writeln('Executing ', FStatement.GetSQLText, ' Elapsed time= ',
      FormatFloat('#0.000', stats[psRealTime] / 1000), ' sec');
{$ENDIF}
  // FBase.DoAfterExecQuery(self);

end;

function TFbApiQuery.FieldByName(const FieldName: String): ISQLData;
begin
  if FResults = nil then
    IBError(ibxeNoFieldAccess, [nil]);

  Result := FResults.ByName(FieldName);

  if Result = nil then
    IBError(ibxeFieldNotFound, [FieldName]);
end;

procedure TFbApiQuery.FreeHandle;
begin
  if FStatement <> nil then
    FStatement.SetRetainInterfaces(false);
  Close;
  FStatement := nil;
  FResults := nil;
  FResultSet := nil;
  FMetaData := nil;
  FSQLParams := nil;
end;

function TFbApiQuery.GetActive: Boolean;
begin
  Result := Assigned(FStatement) and Assigned(FResultSet);
end;

function TFbApiQuery.GetDatabase: TFbApiDatabase;
begin
  Result := FBase.Database;
end;

function TFbApiQuery.GetEOF: Boolean;
begin
  Result := FEOF or (FResultSet = nil);
end;

function TFbApiQuery.GetFieldCount: Integer;
begin
  if FResults = nil then
    IBError(ibxeNoFieldAccess, [nil]);
  Result := FResults.GetCount;
end;

function TFbApiQuery.GetFieldIndex(FieldName: String): Integer;
var
  Field: IColumnMetaData;
begin
  if FMetaData = nil then
    IBError(ibxeNoFieldAccess, [nil]);

  Field := FMetaData.ByName(FieldName);

  if Field = nil then
    Result := -1
  else
    Result := Field.GetIndex;
end;

function TFbApiQuery.GetFields(const Idx: Integer): ISQLData;
begin
  if FResults = nil then
    IBError(ibxeNoFieldAccess, [nil]);

  if (Idx < 0) or (Idx >= FResults.GetCount) then
    IBError(ibxeFieldNotFound, [IntToStr(Idx)]);
  Result := FResults[Idx];
end;

function TFbApiQuery.GetOpen: Boolean;
begin
  Result := FResultSet <> nil;
end;

function TFbApiQuery.GetPlan: String;
begin
  if (not Prepared) or
    (not(GetSQLStatementType in [SQLSelect, SQLSelectForUpdate,
    { TODO: SQLExecProcedure, }
    SQLUpdate, SQLDelete])) then
    Result := ''
  else
    Result := FStatement.GetPlan;
end;

function TFbApiQuery.GetPrepared: Boolean;
begin
  Result := (FStatement <> nil) and FStatement.IsPrepared;
end;

function TFbApiQuery.GetRecordCount: Integer;
begin
  Result := FRecordCount;

  { if FResults <> nil then
    Result := FResults.GetCount
    else
    if FMetaData <> nil then
    Result := FMetaData.GetCount
    else
    Result := 0; }
end;

function TFbApiQuery.GetRowsAffected: Integer;
var
  SelectCount, InsertCount, UpdateCount, DeleteCount: Integer;
begin
  if not Prepared then
    Result := -1
  else
  begin
    FStatement.GetRowsAffected(SelectCount, InsertCount, UpdateCount,
      DeleteCount);
    Result := InsertCount + UpdateCount + DeleteCount;
  end;
end;

function TFbApiQuery.GetSQLParams: ISQLParams;
begin
  if not Prepared then
    Prepare;
  Result := Statement.SQLParams;
end;

function TFbApiQuery.GetSQLStatementType: TIBSQLStatementTypes;
begin
  if FStatement = nil then
    Result := SQLUnknown
  else
    Result := FStatement.GetSQLStatementType;
end;

{ procedure TFbApiQuery.Open;
  begin
  if Active then
  raise Exception.Create('Statement is open');
  if not Statement.IsPrepared then
  Statement.Prepare;

  FResultSet := Statement.OpenCursor();
  end; }

{ function TFbApiQuery.getStatement: IStatement;
  var Attachment: IAttachment;
  begin
  if not (Assigned(FStatement)) or SameText(FStatement.GetSQLText,FSQL.Text) then
  begin
  if Assigned(FStatement) then
  FStatement := nil;
  FStatement := Database.Attachment.Prepare(Database.startReadTransaction,
  FSQL.Text,Database.params.SqlDialect);
  end;
  Result := FStatement;
  end; }

function TFbApiQuery.GetTransaction: TFbApiTransaction;
begin
  Result := FBase.Transaction;
end;

function TFbApiQuery.GetUniqueRelationName: String;
begin

end;

function TFbApiQuery.HasField(const FieldName: String): Boolean;
var
  i: Integer;
begin
  if MetaData = nil then
    IBError(ibxeNoFieldAccess, [nil]);

  Result := false;
  for i := 0 to MetaData.Count - 1 do
  begin
    if MetaData.ColMetaData[i].Name = FieldName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TFbApiQuery.Next: Boolean;
begin
  Result := false;
  if not FEOF then
  begin
    CheckOpen;
    try
      Result := FResultSet.FetchNext;
    except
      Close;
      raise;
    end;

    if Result then
    begin
      Inc(FRecordCount);
      FBOF := false;
    end
    else
      FEOF := True;

    // if not (csDesigning in ComponentState) then
    // MonitorHook.SQLFetch(Self);
  end;
end;

function TFbApiQuery.ParamByName(const ParamName: String): ISQLParam;
begin
  Result := Params.ByName(ParamName);
end;

procedure TFbApiQuery.Prepare;
begin
  CheckClosed;
  FBase.CheckDatabase;
  FBase.CheckTransaction;
  Close;
  if Prepared then
    Exit;
  if (FSQL.Text = '') then
    IBError(ibxeEmptyQuery, [nil]);

  if FStatement <> nil then
    FStatement.Prepare(FBase.Transaction.TransactionIntf)
  else if not ParamCheck then
    FStatement := Database.Attachment.Prepare
      (FBase.Transaction.TransactionIntf, SQL.Text)
  else
    FStatement := Database.Attachment.PrepareWithNamedParameters
      (Transaction.TransactionIntf, SQL.Text, GenerateParamNames,
      CaseSensitiveParameterNames);
{$IFDEF IBXQUERYSTATS}
  FStatement.EnableStatistics(True);
{$ENDIF}
  FMetaData := FStatement.GetMetaData;
  FSQLParams := FStatement.GetSQLParams;
  FStatement.SetRetainInterfaces(True);
  // if not (csDesigning in ComponentState) then
  // MonitorHook.SQLPrepare(Self);
end;

procedure TFbApiQuery.SetActive(const Value: Boolean);
begin
  if (Value <> FActive) then
  begin
    if (FActive) then
      Close
    else
      ExecQuery;
  end;
end;

procedure TFbApiQuery.SetDatabase(const Value: TFbApiDatabase);
begin
  if Value = FBase.Database then
    Exit;
  FBase.Database := Value;
  FreeHandle;
end;

procedure TFbApiQuery.SetIsTransactionOwner(const Value: Boolean);
begin
  FIsTransactionOwner := Value;
end;

procedure TFbApiQuery.SetTransaction(const Value: TFbApiTransaction);
begin
  if FBase.Transaction = Value then
    Exit;
  FreeHandle;
  FBase.Transaction := Value;
end;

procedure TFbApiQuery.SQLChanged(Sender: TObject);
begin
  if Assigned(OnSQLChanged) then
    OnSQLChanged(self);
end;

procedure TFbApiQuery.SQLChanging(Sender: TObject);
begin
  if Assigned(OnSQLChanging) then
    OnSQLChanging(self);

  FreeHandle;
end;

end.
