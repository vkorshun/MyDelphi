unit DmMain;

interface

uses
  System.SysUtils, System.Classes, CommonInterface, fbapidatabase, SettingsStorage, FB30Statement, fbapiquery;

type
  TMainDm = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FCurrentUser: PUserInfo;
    { Private declarations }
    FStorage : TSettingsStorage;
    FQuerySelect: TFbApiQuery;
    function CheckValidPassword(const aPassword: String): boolean;
  public
    { Public declarations }
    FbDatabase: TFbApiDatabase;
    function Connected:Boolean;
    procedure Login(const UserName, Password: String);
    property CurrentUser: PUserInfo read FCurrentUser ;
    function ValidUser(const AUserName, APassword: String): Boolean;
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
  FStorage := TSettingsStorage.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FStorage.Read;

//  dbParams := TFBApiDatabaseParams.Create(self);
  FbDatabase := TFBApiDatabase.Create(self);
  FbDatabase.Params.DbName := FStorage.GetVariable('dbParams','DbName','').AsString;//'inet://localhost:3050/d:\FBDATA\VERA_PRO\ledapravo.fdb');
  FbDatabase.Params.UserName := FStorage.GetVariable('dbParams','UserName','sysdba').AsString;
  FbDatabase.Params.Password := FStorage.GetVariable('dbParams','password','masterkey').AsString;
  FbDatabase.Params.LibPath := FStorage.GetVariable('dbParams','LibPath','C:\FIREBIRD-4-32\fbclient.dll').AsString;

  FbDatabase.connect;

  FQuerySelect := TFbApiQuery.Create(self);
  FQuerySelect.Database := FbDatabase;
end;

procedure TMainDm.Login(const UserName, Password: String);
var statement: TFB30Statement;
begin

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
    with FQuerySelect do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT ul.*,ug.idmenu FROM userslist ul  ');
      SQL.Add(' INNER JOIN usersgroup ug ON ug.idgroup= ul.idgroup ');
      SQL.Add(' WHERE UPPER(ul.username)=:username ');
      ParamByName('username').AsString := UpperCase(AUserName);
      try
        Open;
        if not Eof then
        begin
            FCurrentUser.id_group      := FieldByName('idgroup').AsInt64;
            FCurrentUser.id_user       := FieldByName('iduser').AsInt64;
            FCurrentUser.user_name     := FieldByName('username').AsString;
            FCurrentUser.user_password := FieldByName('userpassword').AsString;
            FCurrentUser.id_menu       := FieldByName('idmenu').AsInt64;
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
      finally
        Transaction.Commit;
      end;
    end;
  finally
    if not Result then
      Raise Exception.Create('Неверное имя пользователя или пароль.');
  end;

end;

function TMainDm.CheckValidPassword(const aPassword: String): boolean;
var sHashPassword: String;
begin
  sHashPassword := FbDatabase.QueryValue(' SELECT CAST(HASH(CAST('''+IntToStr(FCurrentUser.id_user )+aPassword+''' as CHAR(20))) as CHAR(20)) as pwd FROM rdb$database',[]);
  Result := sHashPassword.trim()= FCurrentUser.user_password.trim();
end;

end.
