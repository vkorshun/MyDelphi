unit fbapiquery;

interface

uses SysUtils, Classes, DB, IB, fbapidatabase, fbapitransaction, Fb30Statement;

type
  TFbApiStatement = class(TFB30Statement)
  public
    property BOF:Boolean read FBOF;
    property EOF:Boolean read FEOF;
    property Active:Boolean read FOpen;
  end;



  TFbApiQuery = class(TComponent)
  private
    FDatabase: TFbApiDatabase;
    FTransaction: TFbApiTransaction;
    FStatement: TFbApiStatement;
    FSQL: TStrings;
    FActive: Boolean;
    FResultSet: IResultSet;
    procedure SetActive(const Value: Boolean);
    function GetActive: Boolean;
    function getStatement: TFbApiStatement;
  public
    constructor Create(Owner:TComponent );override;
    destructor Destroy(); override;
    procedure Close;
    procedure Open;
    procedure ExecQuery;
    function ParamByName(const name:String):ISQLParam;
    function FieldByName(const name:String):ISQLData;
    property Database:TFbApiDatabase read FDatabase write FDatabase;
    property Transaction:TFbApiTransaction read FTransaction write FTransaction;
    property Active:Boolean read GetActive write SetActive;
    property Statement:TFBApiStatement read getStatement;
    property SQL:TStrings read FSQL;
  end;


implementation


{ TFbApiQuery }

procedure TFbApiQuery.Close;
begin
  if Assigned(FResultSet) then
  begin
    FResultSet := nil;
    Statement.Close;
    FActive := False;
  end;
end;

constructor TFbApiQuery.Create(Owner: TComponent);
begin
  inherited;
  FSQL := TStringList.Create;
  FActive := False;
end;

destructor TFbApiQuery.Destroy;
begin
  FreeAndNil(FSql);
  inherited;
end;

procedure TFbApiQuery.ExecQuery;
begin
  if True then
  
end;

function TFbApiQuery.FieldByName(const name: String): ISQLData;
begin
  if (Statement.Active) and Assigned(FResultSet) then
    Result := FResultSet.ByName(name)
  else
    raise Exception.Create('Statement is not open');
end;

function TFbApiQuery.GetActive: Boolean;
begin
  Result := Assigned(FStatement) and FStatement.Active;
end;

procedure TFbApiQuery.Open;
begin
  if Active then
    raise Exception.Create('Statement is open');
  if not Statement.IsPrepared then
    Statement.Prepare;

  FResultSet := Statement.OpenCursor();
end;

function TFbApiQuery.getStatement: TFbApiStatement;
begin
  if not (Assigned(FStatement)) or SameText(FStatement.GetSQLText,FSQL.Text) then
  begin
    if Assigned(FStatement) then
      fStatement.Destroy;
    FStatement := TFBApiStatement.CreateWithParameterNames(FDatabase.Attachment, FDatabase.startReadTransaction,
    FSQL.Text,FDatabase.params.SqlDialect,true,false);
  end;
  Result := FStatement;
end;

function TFbApiQuery.ParamByName(const name: String): ISQLParam;
begin
  Result := Statement.GetSQLParams.ByName(name);
end;

procedure TFbApiQuery.SetActive(const Value: Boolean);
begin
  if (Value <> FActive) then
  begin
    if (FActive) then
      Close
    else
      Open;
  end;
end;

end.
