unit fbapitransaction;

interface

uses SysUtils, Classes, DB, IB, fbapidatabase, FB30Transaction;

type
  TFbTransactionParams = array of byte;

  TFbApiTransaction = class(TComponent)
  private
    FTransaction: TFB30Transaction;
    FParams: IB.TByteArray;
    FDatabase: TFbApiDatabase;
    FDefaultCompletion: TTransactionCompletion;
    procedure SetDatabase(const Value: TFbApiDatabase);
    procedure SetParams(const Value: TByteArray);
    function GretInTransaction: Boolean;
    procedure SetDefaultCompletion(const Value: TTransactionCompletion);
    function CheckTransaction:Boolean;
  public
    constructor Create;
    destructor Destroy;
    procedure Start;
    procedure Commit;
    procedure Rollback;
    property Params:TByteArray read FParams write SetParams;
    property Database:TFbApiDatabase read FDatabase write SetDatabase;
    property InTransaction: Boolean read GretInTransaction;
    property Transaction:TFB30Transaction read FTransaction ;
    property DefaultCompletion: TTransactionCompletion read FDefaultCompletion write SetDefaultCompletion;
  end;

implementation

{ TFbTransaction }

function TFbApiTransaction.CheckTransaction: Boolean;
begin
  if not Assigned(FTransaction) then
    raise Exception.Create('Transaction not started');
  Result := true;
end;

procedure TFbApiTransaction.Commit;
begin
  CheckTransaction;
  if FTransaction.InTransaction then
    FTransaction.Commit();
end;

constructor TFbApiTransaction.Create;
var I: Integer;
begin
  SetLength(FParams,3);
  for I := 0 to 2 do
  FParams[i] := TR_READ_CONCURENCY_PARAMS[i];
  FDefaultCompletion := TACommit;
  FTransaction := nil;
end;

destructor TFbApiTransaction.Destroy;
begin
  FTransaction := nil;
end;

function TFbApiTransaction.GretInTransaction: Boolean;
begin
  Result := Assigned(FTransaction) and FTransaction.InTransaction;
end;

procedure TFbApiTransaction.Rollback;
begin
  if FTransaction.InTransaction then
    FTransaction.Rollback();
end;

procedure TFbApiTransaction.SetDatabase(const Value: TFbApiDatabase);
begin
  FDatabase := Value;
end;

procedure TFbApiTransaction.SetDefaultCompletion(const Value: TTransactionCompletion);
begin
  FDefaultCompletion := Value;
end;

procedure TFbApiTransaction.SetParams(const Value: TByteArray);
begin
  FParams := Value;
end;

procedure TFbApiTransaction.Start;
begin
  if not Assigned(FTransaction) then
    FTransaction := TFB30Transaction.Create(FDatabase.FirebirdApi,[FDatabase.Attachment],FParams,FDefaultCompletion);

  if Assigned(FTransaction) and not FTransaction.InTransaction then
    FTransaction.Start(FDefaultCompletion)
//  else
//    fTransaction := FDatabase.Attachment.
//    Attachment.StartTransaction(FParams,FDefaultCompletion);
end;

end.
