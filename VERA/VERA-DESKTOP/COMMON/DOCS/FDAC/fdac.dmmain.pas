unit fdac.dmmain;

interface

uses
  SysUtils, Classes,  IniFiles, Forms, Variants, DB, Generics.Collections, u_xmlinit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.FB, FireDAC.Phys.IBBase, datevk, vkvariable, SettingsStorage, systemconsts,
  FireDAC.Phys.FBDef;


const
{  TRDefault                 : TTransParams = [tpConcurrency,tpWait,tpWrite];
  TRReadOnlyTableStability  : TTransParams = [tpRead, tpConsistency];
  TRReadWriteTableStability : TTransParams = [tpWrite, tpConsistency];}
{  TRSnapShot                : TTransParams = [tpConcurrency, tpNowait];
  TRReadCommitted           : TTransParams = [tpReadCommitted, tpRecVersion, tpNowait];
  TRReadOnly : TTransParams = [tpRead,tpReadCommitted, tpRecVersion, tpNowait];
  TRWriteTableStability: TTransParams = [tpWrite, tpConsistency,tpNowait];
 }
  TRSnapShot =  0;
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

  TShortTransactionList = TList<TFDTransaction> ;
  TOnRequest = reference to procedure(AQuery: TFDQuery );

  TMainDm = class(TDataModule)
    FDConnectionMain: TFDConnection;
    FDTransactionRead: TFDTransaction;
    FDQuerySelect: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDTransactionRC: TFDTransaction;
    FDQueryEx: TFDQuery;
    FDTransactionSS: TFDTransaction;
    FDTransactionSerializ: TFDTransaction;
    FDQueryUpdate: TFDQuery;
    FDTransactionUpdate: TFDTransaction;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDCommandSelect: TFDCommand;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    //FIni: TIniFile;
    FPInterface: Pointer;
    FAlias: String;          // Алиас соединения
    FCurrentUser: PUserInfo; // Инфо о тек. пользователе.
    FDirDocs: String;  // Пть к документам
    FDocPrefix: String; //Префикс к документам комплекса
    FShortTransactionList: TShortTransactionList;
    FXmlIni : TXmlIni; //.Create(self,ChangeFileExt(Application.ExeName,'.xml'));
    FUsersAccessType: TVkVariableCollection;
    FUsersAccessValues: TVkVariableCollection;
    FDbName: String;
    FVendorLib: String;
    FStorage: TSettingsStorage;
    procedure InternalPrepareQuery(AFDQuery:TFDQuery;const ASql:String;const AParams: array of variant );
    procedure InternalPrepareCommand(AFDCommand: TFDCommand; AFDDatsTable: TFDDatSTable;const ASql: String;
      const AParams: array of variant);

    function CheckRequiredPassword(const aUserName:String):Boolean;
    function CheckValidPassword(const aPassword:String):boolean;
    procedure DoAfterLogin;
    procedure FillAttribute(AFDQuery:TFdQuery; var V: TVkVariable );
    function GetPInterface:Pointer;
    procedure InitValList;
    function InternalLogin:Boolean;
    function GetFDDatabaseMain: TFDConnection;
    function ValidUser(const AUserName, APassword:String):Boolean;
  public
    { Public declarations }
    procedure InitConstsList(var AVarList: TVkVariableCollection;const ATableName,AIdName:String);
    function GetRootKey(bCurrentUser:Boolean = true):String;
    procedure Execute(const ASql:String;const AParams:array of variant ; ATransaction:TFDTransaction = nil);
    procedure DoRequest(const ASql:String;const AParams: array of variant;
       ATransaction:TFDTransaction = nil; AOnRequest: TOnRequest = nil);
    procedure LinkWithQuery(AQuery:TFDQuery;ATransaction:TFDTransaction= nil);
    procedure LinkWithCommand(AQuery:TFDCommand;ATransaction:TFDTransaction= nil);
//    procedure LinkWithDataSet(ADataSet:TFDDataSet;ATransaction:TFDTransaction= nil);
    function Login(const AUsername:String; const APassword:String):Boolean;
    function StartShortTransaction(ATrParam:TFDTxIsolation):Cardinal;
    function GetObjectAttribute(AIdObject, AIdAttribute: LargeInt):Variant;
    procedure GetObjectAttributeAsVariable(AIdObject, AIdAttribute: LargeInt;var variable: TVkVariable);
    procedure GetObjectAttributeList(AIdObject: LargeInt;var vlist: TVkVariableCollection);

    function GetShortTransaction(AIndex:Cardinal; var ACurrIndex:Integer): TFDTransaction;
    function GetTypeGroup( AId: LargeInt):LargeInt;
    function SelectAlias: Boolean;

    procedure EndShortTransaction(nType:Integer;AID: Cardinal); // 0- commit, 1- rolback
    function SysLogin(const aDatabaseName:String;const aUserName:String='';const aUserPassword:String=''):Boolean;
    function GenId(const AID: String):Int64;
    function QueryValue(const ASql:String;const AParams: array of variant;
       ATransaction:TFDTransaction = nil):Variant;
    procedure QueryValues(AVkVariableList: TVkVariableCollection;const ASql:String;const AParams: array of variant;
       ATransaction:TFDTransaction = nil);
    property CurrentUser: PUserInfo read FCurrentUser;
    property Strorage: TSettingsStorage read FStorage;
    property XmlInit: TXmlIni read FXmlIni;
    property UsersAccessType: TVkVariableCollection read FUsersAccessType;
    property UsersAccessValues: TVkVariableCollection read FUsersAccessValues;
  end;

var
  MainDm: TMainDm;

implementation

{$R *.dfm}
uses Dialogs, FmSelectDbAlias;

function TMainDm.CheckRequiredPassword(const AUserName: String): Boolean;
begin
  with FDQueryEx do
  begin
    Close;
    Transaction.StartTransaction;
    SQL.Clear;
    SQL.Add('SELECT * FROM userslist WHERE UPPER(username)=:username');
    ParamByName('username').AsString := AnsiUpperCase(aUserName);
    Open;
    Result :=  not Eof and (FieldByName('requiredpassword').AsBoolean);
    Close;
  end;
end;

function TMainDm.CheckValidPassword(const aPassword: String): boolean;
var sHashPassword: String;
begin
  sHashPassword := QueryValue(' SELECT CAST(HASH(CAST('''+IntToStr(FCurrentUser.iduser )+aPassword+''' as CHAR(20))) as CHAR(20)) as pwd FROM rdb$database',[]);
  Result := sHashPassword= FCurrentUser.userpassword;
end;

procedure TMainDm.DataModuleCreate(Sender: TObject);
{begin
  FDDataBaseMain.Connected := true;
  if FDDataBaseMain.Connected then
    ShowMessage('Ok');}
var sXml:string;
begin
  Inherited;
//  FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage := TSettingsStorage.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage.Read;
{  FStorage.WriteVariable('TEST','btest',true);
  FStorage.WriteVariable('TEST','date',now); }
  sXml := ExtractFileDir(Application.ExeName)+'\'+'aliases.xml';
{  FmLogin := TFmDocDialog.Create(Application);
  FmLogin.Items.Clear;
  FmLogin.NewControl(TItemEdit,'Имя',20,'edname');
  FmLogin.NewControl(TItemEdit,'Пароль',20,'edpassword');
  FmLogin.Items.Value[0] := FIni.ReadString('START','LastUsername','');
 }
  New(FCurrentUser);
  FDTransactionRead.Options.Isolation := xiReadCommitted;
  FDTransactionRead.Options.ReadOnly := True;
  FDTransactionRC.Options.Isolation := xiReadCommitted;
  FDTransactionSS.Options.Isolation := xiSnapShot;
  LinkWithQuery(FDQuerySelect,FDTransactionRead);
  FDTransactionSerializ.Options.Isolation := xiSerializible;

  FShortTransactionList := TShortTransactionList.Create;
  FXmlIni := TXmlIni.Create(self,ChangeFileExt(Application.ExeName,'.xml'));
end;

procedure TMainDm.DataModuleDestroy(Sender: TObject);
var i: integer;
begin
  Dispose(FCurrentUser);
  while FShortTransactionList.Count>0 do
  begin
    if FShortTransactionList[0].Active then
      FShortTransactionList[0].RollBack;
    FShortTransactionList[0].Free;
    FShortTransactionList.Delete(0);
  end;
  FreeAndNil(FXmlIni);
  FStorage.Free;
  Inherited;
end;

procedure TMainDm.DoAfterLogin;
begin
  InitConstsList(FUsersAccessType,'USERSACCESSTYPE','IDUATYPE');
  InitConstsList(FUsersAccessValues,'USERSACCESSVALUES','IDUAVALUE');
end;

procedure TMainDm.DoRequest(const ASql: String; const AParams: array of variant;
  ATransaction: TFDTransaction; AOnRequest: TOnRequest);
var
  bTransactionOwner: Boolean;
begin
  if not Assigned(AOnRequest) then
    ShowMessage('ON Request not defined!');
//  Assert(AOnRequest,'ON Request not defined!');
  with FDQueryEx do
  begin
    Close();
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTRansactionRead;
    InternalPrepareQuery(FDQueryEx,ASql,AParams);
//    SQL.Clear;
//    SQL.Text := ASql;
    bTransactionOwner := Transaction.Active;
    if bTransactionOwner then
      Transaction.StartTransaction;
    try
      Open;
{      if not Eof then
        Result := Fields.AsVariant[0]
      else
        Result := null;}
      AOnRequest(FDQueryEx);
    finally
      if bTransactionOwner then
        Transaction.Commit;
    end;
  end;

end;

procedure TMainDm.EndShortTransaction(nType: Integer; AID: Cardinal);
var _Transaction: TFDTransaction;
    nIndex: integer;
begin
  _Transaction := GetShortTransaction(AId, nIndex);
  if not Assigned(_Transaction) then
    raise Exception.CreateFmt('Transaction %d not found',[AID]);
  if nType=0 then
    _Transaction.Commit
  else
    _Transaction.RollBack;
  _Transaction.Free;
  FShortTransactionList.Delete(nIndex);
end;

procedure TMainDm.Execute(const ASql: String; const AParams: array of variant; ATransaction: TFDTransaction);
var
  bTransactionOwner: boolean;
  i: Integer;
begin
  with FDQueryUpdate do
  begin
    Close();
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTRansactionSS;
    InternalPrepareQuery(FDQueryUpdate,ASql,AParams);
    bTransactionOwner := not Transaction.Active;
    if bTransactionOwner then
      Transaction.StartTransaction;
    try
      for I := 0 to High(AParams) do
        Params[i].Value := AParams[i];
      Execute;
      if bTransactionOwner then
        Transaction.Commit;
    except
      if bTransactionOwner then
        Transaction.RollBack;
      Raise;
    end;
  end;
end;

procedure TMainDm.FillAttribute(AFDQuery: TFDQuery; var V: TVkVariable);
begin
  case AFDQuery.FieldByName('ATTRIBUTETYPE').AsInteger of
    TA_STRING : V.AsString := AFDQuery.FieldByName(FLD_ATTR_VAL).AsString;
    TA_NUMERIC : V.AsFloat := AFDQuery.FieldByName(FLD_ATTR_V_DOUBLE).AsFloat;
    TA_CURRENCY : V.AsCurrency := AFDQuery.FieldByName(FLD_ATTR_V_CURRENCY).AsCurrency;
    TA_DATE, TA_TIMESTAMP, TA_TIME : V.AsDateTime := AFDQuery.FieldByName(FLD_ATTR_V_DATA).AsDateTime;
    TA_LOGICAL : V.AsBoolean := AFDQuery.FieldByName(FLD_ATTR_V_BOOLEAN).AsBoolean;
    else
     V.AsLargeInt := AFDQuery.FieldByName(FLD_ATTR_V_INT).AsLargeInt;
  end;
end;

function TMainDm.GetPInterface: Pointer;
begin
  Result := FPInterface;
end;

function TMainDm.GetRootKey(bCurrentUser:Boolean = true): String;
begin
  Result := Format('\Software\VK Soft\%s\%d',[Application.ExeName,FCurrentUser.iduser]);
end;

function TMainDm.GetShortTransaction(AIndex: Cardinal; var ACurrIndex: Integer): TFDTransaction;
var i: Integer;
begin
  Result := nil;
  ACurrIndex := -1;
  for I := 0 to FShortTransactionList.Count-1 do
  begin
    if FShortTransactionList[i].TransactionIntf.SerialID=AIndex then
    begin
      Result := FShortTransactionList[i];
      ACurrIndex := i;
      Break;
    end;
  end;
end;

function TMainDm.GetTypeGroup( AId: LargeInt): LargeInt;
var id : LargeInt;
begin
  id := -1;
  Result := -1;
  FDQuerySelect.Active := False;
  FDQuerySelect.SQL.Clear;
  FDQuerySelect.SQL.Add('SELECT idgroup, idobject FROM objects WHERE idobject=:idobject');
  FDQuerySelect.ParamByName('idobject').AsLargeInt := AId;
  while id<>0 do
  begin
    FDQuerySelect.Open;
    if not FDQuerySelect.IsEmpty then
    begin
      id := FDQuerySelect.FieldByName('idgroup').AsLargeInt;
      if id = 0 then
      begin
        Result := FDQuerySelect.FieldByName('idobject').AsLargeInt;
        Break;
      end
      else
      begin
        FDQuerySelect.Close;
        FDQuerySelect.ParamByName('idobject').AsLargeInt := Id;
      end;
    end
    else
      raise Exception.Create('Error group');
  end;
  FDQuerySelect.Active := false
end;

function TMainDm.GenId(const AID: String): Int64;
begin
  Result := CoalEsce(QueryValue(Format('SELECT Gen_Id(%s,1) AS ID FROM RDB$DATABASE',[AId]),[]),0);
end;

function TMainDm.GetFDDatabaseMain: TFDConnection;
begin
  Result := FDConnectionMain;
end;

function TMainDm.GetObjectAttribute(AIdObject, AIdAttribute: LargeInt): Variant;
begin
  Result := QueryValue('SELECT val FROM attributesofobject WHERE idobject=:idobject and idattribute=:idattribute',
    [AIdObject, AIdAttribute] )
end;

procedure TMainDm.GetObjectAttributeAsVariable(AIdObject, AIdAttribute: LargeInt; var variable: TVkVariable);
begin
  with FDQuerySelect do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT ao.*, al.attributetype FROM ATTRIBUTESOFOBJECT ao');
    SQL.Add('LEFT JOIN ATTRIBUTELIST al on al.idattribute=ao.idattribute');
    SQL.Add('WHERE ao.idobject=:idobject and ao.idattribute=:idattribute');
    ParamByName('idobject').AsLargeInt := AIdObject;
    ParamByName('idattribute').AsLargeInt := AIdAttribute;
    variable.Value := null;
    try
      Open;
      if not eof then
        FillAttribute(FDQuerySelect, variable);
    finally;
      Active := false;
    end;
  end;
end;

procedure TMainDm.GetObjectAttributeList(AIdObject: LargeInt; var vlist: TVkVariableCollection);
var v: TVkVariable;
begin
  vlist.Clear;
  with FDQuerySelect do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT ag.idattribute,ao.*, al.attributetype FROM attributesofgroup ag');
    SQL.Add('LEFT JOIN ATTRIBUTELIST al ON al.idattribute= ag.idattribute');
    SQL.Add('LEFT JOIN ATTRIBUTESOFOBJECT ao on al.idattribute=ao.idattribute and ao.idobject=:idobject');
    SQL.Add('WHERE ag.idgroup=:idgroup');
    ParamByName('idobject').AsLargeInt := AIdObject;
    ParamByName('idgroup').AsLargeInt := MainDm.QueryValue('SELECT idgroup FROM objects WHERE idobject=:idobject',[AIdObject]);
    Open;
    while not eof do
    begin
      v := vlist.CreateVkVariable(FieldByName('idattribute').AsString, null);
      FillAttribute(FDQuerySelect, v);
      Next;
    end;
  end;
end;

procedure TMainDm.InitConstsList(var AVarList: TVkVariableCollection; const ATableName, AIdName: String);
begin
  if Assigned(AVarList) then
    AVarList.Clear
  else
    AVarList := TVkvariableCollection.Create(self);
  with FDQuerySelect do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT * FROM '+ATableName);
    Open;
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

procedure TMainDm.InitValList;
begin

end;

function TMainDm.InternalLogin: Boolean;
begin
  FDConnectionMain.Params.Add('DatabaseName = '+FStorage.GetVariable('SET','DATABASE','').AsString);
end;

procedure TMainDm.InternalPrepareQuery(AFDQuery: TFDQuery; const ASql: String;
  const AParams: array of variant);
var i: Integer;
begin
  with AFDQuery do
  begin
    SQL.Clear;
    SQL.Text := ASql;
    for I := 0 to Params.Count-1 do
      Params[i].Value := AParams[i];
  end;
end;

procedure TMainDm.InternalPrepareCommand(AFDCommand: TFDCommand;AFDDatsTable: TFDDatSTable; const ASql: String;
  const AParams: array of variant);
var i: Integer;
begin
  with AFDCommand do
  begin
    Prepare(ASql);
    for I := 0 to Params.Count-1 do
      Params[i].Value := AParams[i];
  end;
end;

{procedure TDmMain.LinkWithDataSet(ADataSet: TFDDataSet; ATransaction: TFDTransaction);
begin
  with ADataSet do
  begin
    Connection := FDConnectionMain;
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTransactionRead;
  end;

end;}

procedure TMainDm.LinkWithCommand(AQuery: TFDCommand; ATransaction: TFDTransaction);
begin
  with AQuery do
  begin
    Connection := FDConnectionMain;
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTransactionRead;
  end;
end;

procedure TMainDm.LinkWithQuery(AQuery: TFDQuery; ATransaction: TFDTransaction);
begin
  with AQuery do
  begin
    Connection := FDConnectionMain;
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTransactionRead;
  end;
end;

function TMainDm.Login(const AUsername, APassword: String): Boolean;
var
  sDatabaseName :String;
  sUserName: String;
  sCurrDir: String;
  p: Integer;
begin
  //if not SelectAlias then
    //Raise Exception.Create('Не указан путь к базе!');

  sDatabaseName := FDbName;//FIni.ReadString('SET','DATABASE',FDConnectionMain.ConnectionName);
  sCurrDir      := ExtractFileDir(Application.Exename);
//  sUserName     := FIni.ReadString('SET','Username','task');
  with FDConnectionMain do
  begin
//    Params.Add('DriverID=FB');
    Params.Add('User_Name=task');
    Params.Add('password=vksoft123');
    Params.Add('role=RHOPE');
    Params.Add('Database='+sDatabaseName);

    if (FVendorLib <> '') then
    begin
      FDPhysFBDriverLink1.Release;
//      FDPhysFBDriverLink1.VendorHome := ExtractFilePath(FVendorLib);
      FDPhysFBDriverLink1.VendorLib := FVendorLib;
//      FDPhysFBDriverLink1.VendorHome := ExctraxtFilePath(FVendorLib);
    end;
{    DatabaseName := sDatabaseName;
    UserName     := sUserName;
    Password     := FIni.ReadString('SET','password','vksoft123');
    CharacterSet  := csUTF8;
    Role := 'RHOPE';}
    Connected := True;
    if not ValidUser(AUserName,APassword) then
      Connected := False;
  end;
  Result := FDConnectionMain.Connected;
  DoAfterLogin;
end;

function TMainDm.QueryValue(const ASql: String; const AParams: array of variant;
  ATransaction: TFDTransaction): Variant;
var
  bTransactionOwner: Boolean;
  oTable: TFDDatSTable;
begin
  with FDCommandSelect do
  begin
    Close();
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTRansactionRead;
    oTable := TFDDatSTable.Create;
    InternalPrepareCommand(FDCommandSelect,oTable,ASql,AParams);
//    SQL.Clear;
//    SQL.Text := ASql;
    bTransactionOwner := Transaction.Active;
    if bTransactionOwner then
      Transaction.StartTransaction;
    try
      oTable := Define;
      Open;
      Fetch(oTable,True);
      if (RowsAffected>0) then
        Result := oTable.Rows.GetValuesList(oTable.Columns[0].name,';','')
      else
        Result := null;
    finally
      if bTransactionOwner then
        Transaction.Commit;
      oTable.Free;
    end;
  end;
end;

procedure TMainDm.QueryValues(AVkVariableList: TVkVariableCollection;const ASql: String; const AParams: array of variant;
  ATransaction: TFDTransaction);
var
  bTransactionOwner: Boolean;
  oTable: TFDDatSTable;
  i: Integer;
  _v: TVkVariable;
begin
  AVkvariableList.Clear;
  with FDCommandSelect do
  begin
    Close();
    if Assigned(ATransaction) then
      Transaction := ATransaction
    else
      Transaction := FDTRansactionRead;
    oTable := TFDDatSTable.Create;
    try
      InternalPrepareCommand(FDCommandSelect,oTable,ASql,AParams);
      bTransactionOwner := Transaction.Active;
      if bTransactionOwner then
        Transaction.StartTransaction;
      oTable := Define;
      Open;
      Fetch(oTable,True);
      if (RowsAffected>0) then
      begin
        for I := 0 to oTable.Columns.Count-1 do
        begin
          _v := TVkVariable.Create(AVkvariableList);
          _v.Name := oTable.Columns[i].name;
          _v.AsString :=  oTable.Rows.GetValuesList(oTable.Columns[i].name,';','');
        end;
      end;
    finally
      if bTransactionOwner then
        Transaction.Commit;
      oTable.Free;
    end;
  end;
end;

function TMainDm.SelectAlias: Boolean;
const ALIASES = 'aliases';
      DBPATH = 'dbpath';
      LIBPATH = 'libpath';
var _List: TSettingsStorageItem;
    _idx: Integer;
begin
  _List := FStorage.GetSection(ALIASES);
  try
    //FStorage.ReadSection(DBALIASES,_List);
    if Assigned(_List) then
    case _List.Items.Count of
      0:begin
          Result := False;
      end;
      1:
        begin
          FDbName := FStorage.GetVariable(_List.Items.Items[0].name,DBPATH,'').AsString;
          FVendorLib := FStorage.GetVariable(_List.Items.Items[0].Name,LIBPATH,'').AsString;
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
          FDbName := FStorage.GetVariable(_List.Items.Items[_Idx].name,DBPATH,'').AsString;
          FVendorLib:= FStorage.GetVariable(_List.Items.Items[_Idx].Name,LIBPATH,'').AsString;
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

function TMainDm.StartShortTransaction(ATrParam: TFDTxIsolation): Cardinal;
var _Transaction: TFDTransaction;
begin
  _Transaction := TFDTransaction.Create(self);
  with _Transaction do
  begin
    Connection := FDConnectionMain;
    Options.Isolation := ATrParam;
    Options.AutoStart := False;
    Options.AutoStop  := False;
  end;
  _Transaction.StartTransaction;
  Result := _Transaction.TransactionIntf.SerialID;
  FShortTransactionList.Add(_Transaction);
end;

function TMainDm.SysLogin(const aDatabaseName, aUserName, aUserPassword: String): Boolean;
begin
  with FDConnectionMain do
  begin
{    DatabaseName := aDatabaseName;
    if aUserName='' then
      UserName := 'task' //admin
    else
      UserName := aUserName      ;
    if aUserPassword='' then
      Password := 'vksoft123'
    else
      Password := aUserPassword;
    CharacterSet := csWiN1251;
    Role := 'RHOPE'; }
//    ConnectParams.RoleName    := 'task';
    Connected := True;
  end;
  Result := True;
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
    with FDQuerySelect do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT ul.*,ug.idmenu FROM userslist ul  ');
      SQL.Add(' INNER JOIN usersgroup ug ON ug.idgroup= ul.idgroup ');
      SQL.Add(' WHERE UPPER(ul.username)=:username ');
      ParamByName('username').AsString := AnsiUpperCase(AUserName);
      Open;
      if not Eof then
      begin
          CurrentUser.idgroup      := FieldByName('idgroup').AslargeInt;
          CurrentUser.iduser       := FieldByName('iduser').AslargeInt;
          CurrentUser.username     := FieldByName('username').AsString;
          CurrentUser.userpassword := FieldByName('userpassword').AsString;
          CurrentUser.idmenu       := FieldByName('idmenu').AsLargeInt;
          Result := CheckValidPassword(APassword);
      end;
      if (CurrentUser.iduser>0) and Result then
      begin
        Close;
        SQL.Clear;
        SQL.Add(' SELECT rdb$set_context(:nmsp,:varname,:varval) FROM  rdb$database');
        ParamByName('nmsp').AsString    := 'USER_SESSION';
        ParamByName('varname').AsString := 'iduser';
        ParamByName('varval').AsString := IntToStr(CurrentUser.iduser);
        Open;
      end;
    end;
  finally
    if not Result then
      Raise Exception.Create('Неверное имя пользователя или пароль.');
  end;
end;

end.
