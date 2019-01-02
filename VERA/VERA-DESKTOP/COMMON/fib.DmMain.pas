unit fib.DmMain;

interface

uses
  System.SysUtils, System.Classes, FIBDatabase, pFIBDatabase, FIBQuery,
  pFIBQuery, pFIBQueryVk, Data.DB, FIBDataSet, pFIBDataSet, pFIBDataSetVk, datevk,
  pFIBDatabaseVk, pFIBProps, vkvariable, Variants, SettingsStorage, Forms, u_xmlinit;

type
  PUserInfo = ^RUserInfo;
  RUserInfo = Record
    idgroup      :LargeInt;
    iduser       :LargeInt;
    idmenu       :LargeInt;
    username     :string;
    userpassword :string;
    g_username   :string;
    g_rolename   :string;
  end;

  TOnRequest = reference to procedure(AQuery: TpFIBQuery );

  TMainDm = class(TDataModule)
    pFIBDatabaseMain: TpFIBDatabaseVk;
    pFIBDataSetVk1: TpFIBDataSetVk;
    pFIBQueryVkSelect: TpFIBQueryVk;
    pFIBTransactionReadOnly: TpFIBTransaction;
    pFIBTransactionUpdate: TpFIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FCurrentUser: RUserInfo;
    FStorage: TSettingsStorage;
    FXmlIni : TXmlIni;
    FUsersAccessType: TVkVariableCollection;
    FUsersAccessValues: TVkVariableCollection;
    function CheckValidPassword(const aPassword: String): boolean;
    function CheckRequiredPassword(const aUserName:String):Boolean;
    function ValidUser(const AUserName, APassword:String):Boolean;
    procedure DoAfterLogin;
    procedure InitConstsList(var AVarList: TVkVariableCollection;const ATableName,AIdName:String);
    procedure InternalPrepareQuery(AUIBQuery:TpFIBQuery;const ASql:String;const AParams: array of variant );
  public
    { Public declarations }
    function GetRootKey(bCurrentUser:Boolean = true):String;

    procedure LinkWithDataSet(fib_ds: TpFIBDataSetVk; TrRead,
       TrUpdate: TpFIBTransaction; aTableName:String; aKeyFields:String; aGenName:String);
    procedure LinkWithQuery(fib_qr: TpFIBQueryVk; aTr: TpFIBTransaction);
    function QueryValue(const ASql:String;const AParams: array of variant;
       ATransaction:TpFIBTransaction = nil):Variant;
    procedure QueryValues(AVkVariableList: TVkVariableCollection;const ASql:String;const AParams: array of variant;
       ATransaction:TpFIBTransaction = nil);
    function login(const userName, password:String):Boolean;
    function getAliasesList: TVkVariableCollection;
    function selectAlias: boolean;
    function GenId(const AID: String): Int64;
    function GetTypeGroup( AId: LargeInt):LargeInt;
    procedure DoRequest(const ASql:String;const AParams: array of variant;
       ATransaction:TpFIBTransaction = nil; AOnRequest: TOnRequest = nil);

    property XmlInit:TXmlIni read FXmlIni;
    property CurrentUser:RUserInfo read FCurrentUser;
    property UsersAccessType: TVkVariableCollection read FUsersAccessType;
    property UsersAccessValues: TVkVariableCollection read FUsersAccessValues;
  end;


var
  MainDm: TMainDm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
uses FmSelectDbAlias;
{$R *.dfm}

procedure TMainDm.DataModuleCreate(Sender: TObject);
begin
  pFIBDatabaseMain.SetTransactionReadOnly(pFIBTransactionReadOnly);
  pFIBDatabaseMain.SetTransactionConcurency(pFIBTransactionUpdate );
  LinkWithQuery(pFIBQueryVkSelect, pFIBTransactionReadOnly);
  FStorage := TSettingsStorage.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage.Read;
  with pFIBDataBaseMain do
  begin
    ConnectParams.UserName     := 'task';
    ConnectParams.Password := 'vksoft123';
    ConnectParams.CharSet  := 'UTF8';
    ConnectParams.RoleName := 'RHOPE';
  end;
  FXmlIni := TXmlIni.Create(self,ChangeFileExt(Application.ExeName,'.xml'));

end;

procedure TMainDm.DoAfterLogin;
begin
  InitConstsList(FUsersAccessType,'USERSACCESSTYPE','IDUATYPE');
  InitConstsList(FUsersAccessValues,'USERSACCESSVALUES','IDUAVALUE');
end;

procedure TMainDm.DoRequest(const ASql: String; const AParams: array of variant;
  ATransaction: TpFIBTransaction; AOnRequest: TOnRequest);
var
  bTransactionOwner: Boolean;
begin
  if not Assigned(AOnRequest) then
    Raise Exception.Create('ON Request not defined!');
//  Assert(AOnRequest,'ON Request not defined!');
  with pFIBQueryVkSelect do
  begin
    Close();
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := pFIBTRansactionReadOnly;
    InternalPrepareQuery(pFIBQueryVkSelect,ASql,AParams);
//    SQL.Clear;
//    SQL.Text := ASql;
    bTransactionOwner := not Transaction.InTransaction;
    if bTransactionOwner then
      Transaction.StartTransaction;
    try
      ExecQuery;
{      if not Eof then
        Result := Fields.AsVariant[0]
      else
        Result := null;}
      AOnRequest(pFIBQueryVkSelect);
    finally
      if bTransactionOwner then
        Transaction.Commit;
    end;
  end;


end;

function TMainDm.GenId(const AID: String): Int64;
begin
  Result := CoalEsce(QueryValue(Format('SELECT Gen_Id(%s,1) AS ID FROM RDB$DATABASE',[AId]),[]),0);
end;

function TMainDm.getAliasesList: TVkVariableCollection;
var section: TSettingsStorageItem;
begin
  section := FStorage.GetSection('aliases');
  if Assigned(section)  then
    Result := Section.Items
  else
    Result := nil;
end;

function TMainDm.GetRootKey(bCurrentUser: Boolean): String;
begin
  Result := Format('\Software\VK Soft\%s\%d',[Application.ExeName,FCurrentUser.iduser]);
end;

function TMainDm.GetTypeGroup(AId: LargeInt): LargeInt;
var id : LargeInt;
begin
  id := -1;
  Result := -1;
  pFIBQueryVkSelect.Close;
  pFIBQueryVkSelect.SQL.Clear;
  pFIBQueryVkSelect.SQL.Add('SELECT idgroup, idobject FROM objects WHERE idobject=:idobject');
  pFIBQueryVkSelect.ParamByName('idobject').AsInt64 := AId;
  while id<>0 do
  begin
    pFIBQueryVkSelect.ExecQuery;
    if not pFIBQueryVkSelect.IsEmpty then
    begin
      id := pFIBQueryVkSelect.FieldByName('idgroup').AsInt64;
      if id = 0 then
      begin
        Result := pFIBQueryVkSelect.FieldByName('idobject').AsInt64;
        Break;
      end
      else
      begin
        pFIBQueryVkSelect.Close;
        pFIBQueryVkSelect.ParamByName('idobject').AsInt64 := Id;
      end;
    end
    else
      raise Exception.Create('Error group');
  end;
  pFIBQueryVkSelect.Close;

end;

procedure TMainDm.InitConstsList(var AVarList: TVkVariableCollection;
  const ATableName, AIdName: String);
begin
  if Assigned(AVarList) then
    AVarList.Clear
  else
    AVarList := TVkVariableCollection.Create(self);
  with pFIBQueryVkSelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT * FROM '+ATableName);
    ExecQuery;
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

end;

procedure TMainDm.InternalPrepareQuery(AUIBQuery: TpFIBQuery;
  const ASql: String; const AParams: array of variant);
var i: Integer;
begin
  with AUIBQuery do
  begin
    SQL.Clear;
    SQL.Text := ASql;
    Prepare();
    for I := 0 to ParamCount-1 do
      Params[i].Value := AParams[i];
  end;

end;

//=============================================================
//  Основная процедура установки коннекта
//=============================================================
procedure TMainDm.LinkWithDataSet(fib_ds: TpFIBDataSetVk; TrRead,
  TrUpdate: TpFIBTransaction; aTableName:String; aKeyFields:String; aGenName:String);
begin
  with fib_ds do
  begin
    Database := pFIBDatabaseMain;
    if Assigned(TrRead) then
    begin
      if not Assigned(TrRead.DefaultDatabase) then
        TrRead.DefaultDatabase := pFIBDatabaseMain;
      Transaction := TrRead;
    end
    else
      Transaction := pFIBDatabaseMain.GetNewTransactionReadOnly(fib_ds.Owner);

    if Assigned(TrUpdate) then
    begin
      if not Assigned(TrUpdate.DefaultDatabase) then
        TrUpdate.DefaultDatabase := pFIBDatabaseMain;
      UpdateTransaction := TrUpdate;
    end
    else
      UpdateTransaction := pFIBDatabaseMain.DefaultUpdateTransaction;

    AutoUpdateOptions.AutoReWriteSqls          := True;
    AutoUpdateOptions.CanChangeSQLs            := True;
    AutoUpdateOptions.UpdateOnlyModifiedFields := True;
    if aTableName<>'' then
    begin
      AutoUpdateOptions.UpdateTableName          := UpperCase(aTableName);
      AutoUpdateOptions.KeyFields                := UpperCase(aKeyFields);
      if aGenName<> '' then
      begin
        AutoUpdateOptions.GeneratorName := UpperCase(aGenName);
        AutoUpdateOptions.WhenGetGenID  := wgBeforePost;
      end;
    end;
  end;
end;

procedure TMainDm.LinkWithQuery(fib_qr: TpFIBQueryVk; aTr: TpFIBTransaction);
begin
  with fib_qr do
  begin
    Database := pFIBDatabaseMain;
    if Assigned(aTr) then
    begin
      if not Assigned(aTr.DefaultDatabase) then
        aTr.DefaultDatabase := pFIBDatabaseMain;
      Transaction := aTr;
    end
    else
      Transaction := pFIBDatabaseMain.DefaultTransaction;

  end;
end;

function TMainDm.login(const userName, password: String):boolean;
begin
//  if not SelectAlias then
//    Raise Exception.Create('Не указан путь к базе!');
  pFIBDatabaseMain.Connected := true;
  if not ValidUser(userName, password) then
    pFIBDatabaseMain.Connected := false;
  Result := pFIBDatabaseMain.Connected;
  DoAfterLogin;
end;

function TMainDm.QueryValue(const ASql: String; const AParams: array of variant;
  ATransaction: TpFIBTransaction): Variant;
var
  I: Integer;
  bTransactionOwner: Boolean;
begin
  with pFIBQueryVkSelect do
  begin
    Close;
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := pFIBDatabaseMain.DefaultTransaction;
    SQL.Clear;
    SQL.Add(ASql);
    for I := 0 to Params.Count-1 do
    try
      params[i].Value := AParams[i];
    except
      raise Exception.CreateFmt('Error set param qr2 [%d]',[i]);
    end;
    bTransactionOwner := not Transaction.Active;
    if (bTransactionOwner) then
      Transaction.StartTransaction;
    try
      ExecQuery;
      if not(Eof or Bof) then
        Result := Fields[0].Value
      else
        Result := null;
    finally
      if (bTransactionOwner) then
        Transaction.Commit;
    end;
  end;

end;

procedure TMainDm.QueryValues(AVkVariableList: TVkVariableCollection;
  const ASql: String; const AParams: array of variant;
  ATransaction: TpFIBTransaction);
var
  I: Integer;
  bTransactionOwner: Boolean;
  _v: TVkVariable;

begin
  with pFIBQueryVkSelect do
  begin
    Close;
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := pFIBDatabaseMain.DefaultTransaction;
    SQL.Clear;
    SQL.Add(ASql);
    for I := 0 to Params.Count-1 do
    try
      params[i].Value := AParams[i];
    except
      raise Exception.CreateFmt('Error set param qr2 [%d]',[i]);
    end;
    bTransactionOwner := not Transaction.Active;
    if (bTransactionOwner) then
      Transaction.StartTransaction;
    try
      ExecQuery;
      for I := 0 to FieldCount-1 do
      begin
        _v := TVkVariable.Create(AVkvariableList);
        _v.Name := Fields[i].name;
        if not(Eof or Bof) then
          _v.Value := Fields[i].Value
        else
          _v.Value := null;
      end;
    finally
      if (bTransactionOwner) then
        Transaction.Commit;
    end;
  end;
end;

function TMainDm.selectAlias: boolean;
const ALIASES = 'aliases';
      DBPATH = 'dbpath';
      LIBPATH = 'libpath';
var _List: TSettingsStorageItem;
    _idx: Integer;
begin
  _List := FStorage.GetSection(ALIASES);
  try
    //FStorage.ReadSection(DBALIASES,_List);
    case _List.Items.Count of
      0:begin
          Result := False;
      end;
      1:
        begin
          pFIBDatabaseMain.DBName := FStorage.GetVariable(_List.Items.Items[0].name,DBPATH,'').AsString;
          pFIBDatabaseMain.LibraryName := FStorage.GetVariable(_List.Items.Items[0].Name,LIBPATH,'').AsString;
          Result := True;
        end;
      else
      begin
        if ParamCount=3 then
        begin
          for _idx := 0 to _List.Items.Count-1 do
          begin
            if _List.Items.Items[_idx].name.Equals(ParamStr(3)) then
            begin
              break;
            end;
          end;
        end
        else
          _idx := TSelectDbAliasFm.SelectAliasIndex(_List.getItemValues);
        if _Idx>-1 then
        begin
          pFIBDatabaseMain.DBName := FStorage.GetVariable(_List.Items.Items[_Idx].name,DBPATH,'').AsString;
          pFIBDatabaseMain.LibraryName:= FStorage.GetVariable(_List.Items.Items[_Idx].Name,LIBPATH,'').AsString;
          Result := True;
        end
        else
          Result := False;
      end;
    end;

  finally
//    _List.Free;
  end;

end;

function TMainDm.ValidUser(const AUserName, APassword: String): Boolean;
begin
  Result := False;
  if Trim(AUserName)='' then
  begin
    Raise Exception.Create('Не определенный пользователь!');
    Exit;
  end;
  try
    with pFIBQueryVkSelect do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT ul.*,ug.idmenu FROM userslist ul  ');
      SQL.Add(' INNER JOIN usersgroup ug ON ug.idgroup= ul.idgroup ');
      SQL.Add(' WHERE UPPER(ul.username)=:username ');
      ParamByName('username').AsString := UpperCase(AUserName);
      Transaction.Active := true;
      try
        ExecQuery;
        if not Eof then
        begin
            FCurrentUser.idgroup      := FieldByName('idgroup').AsInt64;
            FCurrentUser.iduser       := FieldByName('iduser').AsInt64;
            FCurrentUser.username     := FieldByName('username').AsString;
            FCurrentUser.userpassword := FieldByName('userpassword').AsString;
            FCurrentUser.idmenu       := FieldByName('idmenu').AsInt64;
            Result := CheckValidPassword(APassword);
        end;
        if (FCurrentUser.iduser>0) and Result then
        begin
          Close;
          SQL.Clear;
          SQL.Add(' SELECT rdb$set_context(:nmsp,:varname,:varval) FROM  rdb$database');
          ParamByName('nmsp').AsString    := 'USER_SESSION';
          ParamByName('varname').AsString := 'iduser';
          ParamByName('varval').AsString := IntToStr(FCurrentUser.iduser);
          ExecQuery;
          Close;
        end;
      finally
        Transaction.Commit;
      end;
    end;
  finally
    if not Result then
      Raise Exception.Create('Неверное имя пользователя или пароль.');
  end;

end;

function TMainDm.CheckRequiredPassword(const aUserName: String): Boolean;
begin
  with pFIBQueryVkSelect do
  begin
    Close;
    try
      Transaction.StartTransaction;
      SQL.Clear;
      SQL.Add('SELECT * FROM userslist WHERE UPPER(username)=:username');
      ParamByName('username').AsString := AnsiUpperCase(aUserName);
      ExecQuery;
      Result :=  not Eof and (FieldByName('requiredpassword').AsBoolean);
    finally
      Close;
    end;
  end;

end;

function TMainDm.CheckValidPassword(const aPassword: String): boolean;
var sHashPassword: String;
begin
  sHashPassword := QueryValue(' SELECT CAST(HASH(CAST('''+IntToStr(FCurrentUser.iduser )+aPassword+''' as CHAR(20))) as CHAR(20)) as pwd FROM rdb$database',[]);
  Result := sHashPassword.trim()= FCurrentUser.userpassword.trim();
end;



end.
