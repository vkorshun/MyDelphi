unit DmMain;

interface

uses
  System.SysUtils, System.Classes, CommonInterface, fbapidatabase, SettingsStorage, FB30Statement, fbapiquery, ServerDocSqlManager,
  System.Generics.Collections;

type
  TMainDm = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FCurrentUser: RUserInfo;
    { Private declarations }
    FStorage : TSettingsStorage;
//    FQuerySelect: TFbApiQuery;
//    FCommand: TFbApiQuery;
//    FReadTransaction: TFbApiTransaction;
//    FReadCommitedTransaction: TFbApiTransaction;
//    FSnapshotTransaction: TFbApiTransaction;
//    FTableStabilityTransaction: TFbApiTransaction;
    FReadOnlyTransactionOptions: TStringList;
    FSnapshotTransactionOptions: TStringList;
    FStabilityTransactionOptions: TStringList;
    FReadCommitedTransactionOptions: TStringList;
    FServerDocSqlManagerList: TDictionary<String,TServerDocSqlManager>;
    FServerDocSqlManager: TServerDocSqlManager;
    function CheckValidPassword(const aPassword: String): boolean;
    procedure SetReadCommitedTransactionOptions(const Value: TStringList);
    procedure SetReadOnlyTransactionOptions(const Value: TStringList);
    procedure SetSnapshotTransactionOptions(const Value: TStringList);
    procedure SetStabilityTransactionOptions(const Value: TStringList);
    procedure SetServerDocSqlManager(const Value: TServerDocSqlManager);
    function GetServerDocSqlManager(const key:String): TServerDocSqlManager;
  public
    { Public declarations }
    FbDatabase: TFbApiDatabase;
    function Connected:Boolean;

    procedure Login(const UserName, Password: String);
    function GetNewQuery: TFbApiQuery; overload;
    function GetNewQuery(const ATransaction: TFbApiTransaction): TFbApiQuery; overload;
    function getNewServerDocSqlManager(const ATableName: String):TServerDocSqlManager;
    function GetNewTransaction(const AParams: TStrings): TFbApiTransaction;
    property CurrentUser: RUserInfo read FCurrentUser ;
    procedure RegisterAdmin;
    function ValidUser(const AUserName, APassword: String): Boolean;
//    property QuerySelect: TFbApiQuery read FQuerySelect;
//    property CommandQuery: TFbApiQuery read FCommand;
    property ReadOnlyTransactionOptions: TStringList read FReadOnlyTransactionOptions write SetReadOnlyTransactionOptions;
    property SnapshotTransactionOptions: TStringList read FSnapshotTransactionOptions write SetSnapshotTransactionOptions;
    property StabilityTransactionOptions: TStringList read FStabilityTransactionOptions write SetStabilityTransactionOptions;
    property ReadCommitedTransactionOptions: TStringList read FReadCommitedTransactionOptions write SetReadCommitedTransactionOptions;
    property ServerDocSqlManager[const key:String]: TServerDocSqlManager read GetServerDocSqlManager;
  end;

var
  MainDm: TMainDm;

implementation


{%CLASSGROUP 'Vcl.Controls.TControl'}
uses Forms;
{$R *.dfm}

{ TMainDm }



function TMainDm.Connected;
begin
  Result := FbDatabase.IsConnected;
end;

procedure TMainDm.DataModuleCreate(Sender: TObject);
var dbParams: TFBApiDatabaseParams;
begin
  FServerDocSqlManagerList := TDictionary<String,TServerDocSqlManager>.Create;


  FReadOnlyTransactionOptions := TStringList.Create;
  FReadOnlyTransactionOptions.Add('read');
  FReadOnlyTransactionOptions.Add('nowait');

  FSnapshotTransactionOptions := TStringList.Create;
  FSnapshotTransactionOptions.Add('concurency');
  FSnapshotTransactionOptions.Add('nowait');

  FStabilityTransactionOptions:= TStringList.Create;
  FStabilityTransactionOptions.Add('consistency');
  FStabilityTransactionOptions.Add('nowait');

  FReadCommitedTransactionOptions:= TStringList.Create;
  FReadCommitedTransactionOptions.Add('read_commited');
  FReadCommitedTransactionOptions.Add('nowait');
  FReadCommitedTransactionOptions.Add('no_rec_version');


  FStorage := TSettingsStorage.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage.Read;

//  dbParams := TFBApiDatabaseParams.Create(self);
  FbDatabase := TFBApiDatabase.Create(self);
  FbDatabase.Params.DbName := FStorage.GetVariable('dbParams','DbName','').AsString;//'inet://localhost:3050/d:\FBDATA\VERA_PRO\ledapravo.fdb');
  FbDatabase.Params.UserName := FStorage.GetVariable('dbParams','UserName','sysdba').AsString;
  FbDatabase.Params.Password := FStorage.GetVariable('dbParams','password','masterkey').AsString;
  FbDatabase.Params.LibPath := FStorage.GetVariable('dbParams','LibPath','C:\FIREBIRD-4-32\fbclient.dll').AsString;

  FbDatabase.connect;

{  FReadTransaction := TFbApiTransaction.Create(self);
  FReadTransaction.DefaultDatabase := FbDatabase;
  FReadTransaction.Params.Add('read');
  FReadTransaction.Params.Add('nowait');

  FReadCommitedTransaction := TFbApiTransaction.Create(self);
  FReadCommitedTransaction.DefaultDatabase := FbDatabase;
  FReadCommitedTransaction.Params.Add('read_commited');
  FReadCommitedTransaction.Params.Add('nowait');
  FReadCommitedTransaction.Params.Add('no_rec_version');

  FSnapshotTransaction := TFbApiTransaction.Create(self);
  FSnapshotTransaction.DefaultDatabase := FbDatabase;
  FSnapshotTransaction.Params.Add('concurency');
  FSnapshotTransaction.Params.Add('nowait');

  FTableStabilityTransaction := TFbApiTransaction.Create(self);
  FTableStabilityTransaction.DefaultDatabase := FbDatabase;
  FTableStabilityTransaction.Params.Add('consistency');
  FTableStabilityTransaction.Params.Add('nowait');

  FQuerySelect := TFbApiQuery.Create(self);
  FQuerySelect.Database := FbDatabase;
  FQuerySelect.Transaction := FReadTransaction;

  FCommand := TFbApiQuery.Create(self);
  FCommand.Database := FbDatabase;
  FCommand.Transaction := FSnapshotTransaction;
 }
end;

procedure TMainDm.DataModuleDestroy(Sender: TObject);
begin
  FServerDocSqlManagerList.Free;
end;

function TMainDm.GetNewQuery(const ATransaction: TFbApiTransaction): TFbApiQuery;
begin
  Result := TFbApiQuery.Create(self);
  Result.Database := FbDatabase;
  Result.Transaction := ATransaction;
end;

function TMainDm.GetNewQuery: TFbApiQuery;
begin
  Result := TFbApiQuery.Create(self);
  Result.Database := FbDatabase;
  Result.IsTransactionOwner := True;
  Result.Transaction := getNewTransaction(FReadOnlyTransactionOptions);
end;

function TMainDm.GetNewTransaction(const AParams: TStrings): TFbApiTransaction;
begin
  Result := TFbApiTransaction.Create(self);
  Result.DefaultDatabase := FbDatabase;
  Result.Params := AParams;
end;

function TMainDm.GetServerDocSqlManager(const key:String): TServerDocSqlManager;
var realKey: String;
begin
  realKey := key.ToUpper;
  if FServerDocSqlManagerList.ContainsKey(realKey) then
    Result := FServerDocSqlManagerList[realKey]
  else
  begin
    Result := GetNewServerDocSqlManager(realKey);
    FServerDocSqlManagerList.Add(realKey, Result);
  end;
end;

procedure TMainDm.Login(const UserName, Password: String);
begin
  ValidUser(UserName, Password);
end;

function TMainDm.ValidUser(const AUserName, APassword: String): Boolean;
var Query: TFbApiQuery;
begin
  Result := False;
  if Trim(AUserName)='' then
  begin
    Raise Exception.Create('Не определенный пользователь!');
    Exit;
  end;
  Query := GetNewQuery;
  try
    with Query do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT ul.*,ug.id_menu FROM userslist ul  ');
      SQL.Add(' INNER JOIN usersgroup ug ON ug.idgroup= ul.idgroup ');
      SQL.Add(' WHERE UPPER(ul.username)=:username ');
      ParamByName('username').AsString := UpperCase(AUserName);
//      ParamByName('password').AsString := UpperCase(APassword);
      ExecQuery;
      if not Eof then
      begin
        FCurrentUser.id_group      := FieldByName('idgroup').AsInt64;
        FCurrentUser.id_user       := FieldByName('iduser').AsInt64;
        FCurrentUser.user_name     := FieldByName('username').AsString;
        FCurrentUser.user_password := FieldByName('userpassword').AsString;
        FCurrentUser.id_menu       := FieldByName('id_menu').AsInt64;
        Result := CheckValidPassword(APassword);
      end;
      if (FCurrentUser.id_user>0) and Result then
      begin
        Close;
        SQL.Clear;
        SQL.Add(' SELECT rdb$set_context(:nmsp,:varname,:varval) FROM  rdb$database');
        ParamByName('nmsp').AsString    := 'USER_SESSION';
        ParamByName('varname').AsString := 'iduser';
        ParamByName('varval').AsString := IntToStr(FCurrentUser.id_user);
        ExecQuery;
        Close;
      end;
    end;
  finally
    FreeAndNil(Query);
  end;
//  on Exception ex do
//  begin
//  finally
  if not Result then
    Raise Exception.Create('Неверное имя пользователя или пароль.');
//  end;

end;

procedure TMainDm.RegisterAdmin();
var qr: TFbApiQuery;
begin
//  qr := TFbApiQuery.Create(self);
//  qr.Database :=
  {FCommand.Active := False;
  FCommand.SQL.Clear;
  FCommand.SQL.Add('UPDATE userslist SET userpasword=:userpasword WHERE id=:id');
  FCommand.Transaction.StartTransaction;
  FCommand.ParamByName('id').AsInt64 := 1;
  FCommand.ParamByName('userpassword').AsString := '111';
  FCommand.ExecQuery;
  FCommand.Transaction.Commit;}
end;


procedure TMainDm.SetReadCommitedTransactionOptions(const Value: TStringList);
begin
  FReadCommitedTransactionOptions := Value;
end;

procedure TMainDm.SetReadOnlyTransactionOptions(const Value: TStringList);
begin
  FReadOnlyTransactionOptions := Value;
end;

procedure TMainDm.SetServerDocSqlManager(const Value: TServerDocSqlManager);
begin
  FServerDocSqlManager := Value;
end;

procedure TMainDm.SetSnapshotTransactionOptions(const Value: TStringList);
begin
  FSnapshotTransactionOptions := Value;
end;

procedure TMainDm.SetStabilityTransactionOptions(const Value: TStringList);
begin
  FStabilityTransactionOptions := Value;
end;

function TMainDm.CheckValidPassword(const aPassword: String): boolean;
var sHashPassword: String;
begin
//  sHashPassword := FbDatabase.QueryValue(' SELECT CAST(HASH(CAST('''+IntToStr(FCurrentUser.id_user )+aPassword+''' as CHAR(20))) as CHAR(20)) as pwd FROM rdb$database',[]);
  Result := aPassword.trim() = FCurrentUser.user_password.trim();
end;

function TMainDm.getNewServerDocSqlManager(const ATableName: String):TServerDocSqlManager;
const  QR_TABLEFIELDS =
    'select ' +
    '  FLD.RDB$FIELD_TYPE' +
    ', FLD.RDB$FIELD_SCALE' +
    ', FLD.RDB$FIELD_LENGTH' +
    ', FLD.RDB$FIELD_PRECISION' +
    ', FLD.RDB$CHARACTER_SET_ID' +   // CHARACTER SET
    ', RFR.RDB$COLLATION_ID' +
    ', COL.RDB$COLLATION_NAME' +     // COLLATE
    ', FLD.RDB$FIELD_SUB_TYPE' +
    ', RFR.RDB$DEFAULT_SOURCE' +     // DEFAULT
    ', RFR.RDB$FIELD_NAME' +
    ', FLD.RDB$SEGMENT_LENGTH' +
    ', FLD.RDB$SYSTEM_FLAG'+
    ', RFR.RDB$FIELD_SOURCE' +       // DOMAIN
    ', RFR.RDB$NULL_FLAG' +          // NULLABLE
    ', FLD.RDB$VALIDATION_SOURCE' +  // CHECK
    ', FLD.RDB$DIMENSIONS'+
    ', FLD.RDB$COMPUTED_SOURCE' +    // COMPUTED BY
    ', RDB$VALIDATION_SOURCE ' +
    'from ' +
    '  RDB$RELATIONS REL ' +
    'join RDB$RELATION_FIELDS RFR on (RFR.RDB$RELATION_NAME = REL.RDB$RELATION_NAME) ' +
    'join RDB$FIELDS FLD on (RFR.RDB$FIELD_SOURCE = FLD.RDB$FIELD_NAME) ' +
    'left outer join RDB$COLLATIONS COL on (COL.RDB$COLLATION_ID = RFR.RDB$COLLATION_ID and COL.RDB$CHARACTER_SET_ID = FLD.RDB$CHARACTER_SET_ID) ' +
    'where ' +
    '  (REL.RDB$RELATION_NAME = :tablename) ' +
    'order by ' +
    '  RFR.RDB$FIELD_POSITION, RFR.RDB$FIELD_NAME';

  QR_PKFIELDS ='select '+
    ' ix.rdb$index_name as index_name, '+
    ' sg.rdb$field_name as field_name, '+
    ' rc.rdb$relation_name as table_name '+
' from '+
    ' rdb$indices ix '+
    ' left join rdb$index_segments sg on ix.rdb$index_name = sg.rdb$index_name '+
    ' left join rdb$relation_constraints rc on rc.rdb$index_name = ix.rdb$index_name '+
' where '+
    ' rc.rdb$constraint_type = :cons and rc.rdb$relation_name= :tablename ';

var query: TFbApiQuery;
begin
  query := GetNewQuery;
  Result := TServerDocSqlManager.Create;
  Result.TableName := ATablename;
  try
    query.SQL.Add(QR_TABLEFIELDS);
    query.ParamByName('tablename').AsString := ATablename.ToUpper;
    query.ExecQuery;
    while not query.Eof do
    begin
      Result.FieldNameList.Add(query.FieldByName('RDB$FIELD_NAME').AsString);
      query.next;
    end;
    query.Close;
    query.SQL.Clear;
    query.SQL.Add(QR_PKFIELDS);
    query.ParamByName('tablename').AsString := ATablename.ToUpper;
    query.ParamByName('cons').AsString :='PRIMARY KEY';
    query.ExecQuery;
    while not query.Eof do
    begin
      Result.KeyFieldsList.Add(query.FieldByName('FIELD_NAME').AsString);
      query.next;
    end;


  finally
    query.Free;
  end;
end;

end.
