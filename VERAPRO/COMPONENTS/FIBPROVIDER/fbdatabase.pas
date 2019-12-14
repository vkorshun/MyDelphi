unit fbdatabase;

interface

uses System.SysUtils, System.Variants, System.Classes, IB;

const
   TR_READ_ONLY_PARAMS:  array[0..1] of byte = (isc_tpb_read,isc_tpb_nowait);
   TR_READ_COMMITED_PARAMS:  array[0..2] of byte = (isc_tpb_read_committed,isc_tpb_nowait,isc_tpb_write);
   TR_READ_CONCURENCY_PARAMS:  array[0..2] of byte = (isc_tpb_concurrency,isc_tpb_nowait,isc_tpb_write);

type
  TFBDatabaseParams = class(TComponent)
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
    property UserName:String read FUserName write FUserName;
    property Password:String read FPassword write FPassword;
    property SqlDialect: Integer read FSqlDialect write FSqlDialect;
    property LibPath: String read FLibPath write FLibPath;
    property DefaultCharSet: String read FDefaultCharSet write FDefaultCharSet;
    property Role: String read FRole write FRole;
    constructor Create(AOwner:TComponent);
  end;

  TFBDatabase = class(TComponent)
  private
    FBLibrary: IFirebirdLibrary;
    FFirebirdAPI: IFirebirdAPI;
    FParams: TFBDatabaseParams;
    FAttachment: IAttachment;

  public
    constructor Create(AOwner: TComponent; dbParams: TFBDatabaseParams);
    destructor Destroy;
    procedure connect;
    function IsConnected: Boolean;
    function startReadTransaction: ITransaction;
    function startReadCommitedTransaction: ITransaction;
    function startConcurencyTransaction: ITransaction;
    procedure disconnect;
    property Attachment:IAttachment read FAttachment;
    property FirebirdAPI: IFirebirdAPI read FFirebirdAPI;
    property params: TFBDatabaseParams read FParams;

  end;

implementation

{ TFibProviderDatabase }

procedure TFBDatabase.connect;
var
  DPB: IDPB;
begin
  DPB := FFirebirdAPI.AllocateDPB;
  DPB.Add(isc_dpb_user_name).AsString := FParams.UserName;
  DPB.Add(isc_dpb_password).AsString := FParams.Password;
  DPB.Add(isc_dpb_lc_ctype).AsString := FParams.DefaultCharSet;
  DPB.Add(isc_dpb_set_db_SQL_dialect).AsInteger := FParams.SqlDialect;
  FAttachment := FFirebirdAPI.OpenDatabase(FParams.DbName,DPB,True);
end;

constructor TFBDatabase.Create(AOwner: TComponent;
   dbParams: TFBDatabaseParams);
begin
  inherited create(AOwner);
  FParams := dbParams;
  FBLibrary := LoadFBLibrary(FParams.libPath);
  FFirebirdAPI := IB.FirebirdAPI;
end;

destructor TFBDatabase.Destroy;
begin
  FreeAndNil(FParams);
end;

procedure TFBDatabase.disconnect;
begin
  if Attachment.IsConnected then
    Attachment.Disconnect();
end;

function TFBDatabase.startConcurencyTransaction: ITransaction;
begin
  Result := FAttachment.StartTransaction([isc_tpb_concurrency,isc_tpb_write,isc_tpb_nowait]);
end;

function TFBDatabase.startReadCommitedTransaction: ITransaction;
begin
  Result := FAttachment.StartTransaction([isc_tpb_read_committed,isc_tpb_write,isc_tpb_nowait]);

end;

function TFBDatabase.startReadTransaction: ITransaction;
begin
  Result := FAttachment.StartTransaction(TR_READ_ONLY_PARAMS);
end;

function TFBDatabase.IsConnected: Boolean;
begin
  Result := Attachment.IsConnected;
end;

{ TFBDatabaseParams }

constructor TFBDatabaseParams.Create;
begin
  Inherited;
  FSqlDialect := 3;
  FDefaultCharSet := 'UTF8';
end;

end.
