unit ServerMethodsMikko;

interface

uses
  SysUtils, Classes, DSServer, Dm_MikkoAds, Dm_Entrance, Provider, Db, DbClient,
  Contnrs, FasApi, DBXJSON;

type
  TServerMethodsMikko1 = class(TDSServerModule)
    DataSetProviderDc162: TDataSetProvider;
    DataSetProviderDc167: TDataSetProvider;
    procedure DataSetProviderDc162AfterUpdateRecord(Sender: TObject;
      SourceDS: TDataSet; DeltaDS: TCustomClientDataSet;
      UpdateKind: TUpdateKind);
    procedure DataSetProviderDc162BeforeUpdateRecord(Sender: TObject;
      SourceDS: TDataSet; DeltaDS: TCustomClientDataSet;
      UpdateKind: TUpdateKind; var Applied: Boolean);
    procedure DataSetProviderDc162AfterApplyUpdates(Sender: TObject;
      var OwnerData: OleVariant);
  private
    { Private declarations }
    FDmMikkoAds: TDmMikkoAds;
    FDmEntrance: TDmEntrance;
    ProviderList: TObjectList;
    function AddUserFomFile(UserID, FileName, aData: String;
      var rCode: Integer): Integer;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent);override;
    destructor  Destroy;override;
    function AddFingerUser( UserID:Integer; aData:String; IdFinger:Integer):Integer;
    function Connect(const aUserName:String;const aPassword:String;aIdOffice:Integer):Integer;
    procedure CreateProvider(const aSQL:String;const aName:String);
    procedure DeleteFingerUser(UserId:Integer);
    function DtFromXbase(aDt:TdateTime):TDateTime;
    function GetDataUvl(aKodKli:Integer):TDateTime;
    function GetKodkliByFinger( UserID:String; aData:String;var  rCode:Integer):Integer;
    function GetServerTime:TDateTime;
    function SetFilterOnDc162(aIndex:Integer):TDataSetProvider;
//    function EchoString(Value: string): string;
//    function ReverseString(Value: string): string;
    procedure ClearOldData;
    procedure SetFilter(aIndex:Integer);

    ///<summary> Проверка связи </summary>
    function CheckConnect:Integer;
    ///<summary> Возвращает результат запроса cQuery </summary>
    function QueryValue(const cQuery:String):String;
    ///<summary> Проверка графика </summary>
    function  ValidGraphic(aKodSotrud:Integer):Boolean;
    ///<summary> Проверка отпуска </summary>
    function  ValidHoliday(aKodSotrud:Integer):Boolean;
    ///<summary> Проверка ОМК </summary>
    function  ValidOmk(aKodSotrud:Integer):Boolean;

  end;
var
  handle_connection: Integer;

implementation

{$R *.dfm}

uses StrUtils, datevk;

function TServerMethodsMikko1.AddFingerUser(UserID: Integer;
  aData: String; IdFinger:Integer): Integer;
var
  dwSize:integer;
  p: Pointer;
  i: Integer;
  buf: TBytes;
begin
  Result := 0;
  buf := BytesOf(adata);
  dwSize := length(buf);
  getMem(p,dwSize);
  try
    for I := 0 to dwSize-1 do
    begin
      PAnsiChar(p)[i] := AnsiChar(buf[i]);
    end;
    Result := FDmEntrance.AddFingerUser(UserId,dwSize,PAnsiChar(buf),IdFinger);
  finally
    FreeMem(p)
  end;
end;

function TServerMethodsMikko1.AddUserFomFile(UserID, FileName, aData: String;
  var rCode: Integer): Integer;
var
  dwSize:integer;
  p: Pointer;
  i: Integer;
  buf: TBytes;
begin
  Result := 0;
  buf := BytesOf(adata);
  dwSize := length(buf);
  getMem(p,dwSize);
  try
    for I := 0 to dwSize-1 do
    begin
      PAnsiChar(p)[i] := AnsiChar(buf[i]);
    end;
    Result := FDmEntrance.GetKodkliByFinger(UserId,dwSize,PAnsiChar(buf),rCode);
  finally
    FreeMem(p)
  end;

end;

function TServerMethodsMikko1.CheckConnect: Integer;
begin
  Result := 1;
end;

procedure TServerMethodsMikko1.ClearOldData;
begin
  FDmEntrance.ClearProtocol;
  FDmEntrance.ClearOpenEntrace;
end;

function TServerMethodsMikko1.Connect(const aUserName, aPassword: String;
  aIdOffice: Integer): Integer;
begin
  Inc(handle_connection) ;
  FDmMikkoAds := TDmMikkoAds.Create(self);
  FDmEntrance := TDmEntrance.Create(self);
  FDmEntrance.DmMikkoAds := FDmMikkoAds;
  FDmEntrance.handle_connection := handle_connection;
  if FDmMikkoAds.ServerLogin(aUserName,aPassword) then
    Result := handle_connection
  else
    Result := 0;
  FDmEntrance.kodEntrance := aIdOffice;
  DataSetProviderDc162.DataSet := FDmEntrance.AdsQueryDc162;
  DataSetProviderDc167.DataSet := FDmEntrance.AdsQueryDc167;
  FDmEntrance.OpenRegistration;
  ClearOldData;
end;

constructor TServerMethodsMikko1.Create;
begin
  inherited Create(aOwner);
  providerList := TObjectList.Create
end;

procedure TServerMethodsMikko1.CreateProvider(const aSQL: String;
  const aName: String);
var
  oProvider: TDatasetProvider;
begin
  oProvider := TDatasetProvider.Create(self);
  try
    oProvider.Name    := aName;
    oProvider.DataSet := FDmEntrance.CreateAdsQuery(aSql);
  except
    oProvider.Free;
    Raise;
  end;
end;

procedure TServerMethodsMikko1.DataSetProviderDc162AfterApplyUpdates(
  Sender: TObject; var OwnerData: OleVariant);
begin
  with TDataSetProvider(Sender).DataSet do
  begin
    Close;
    Open;
  end;
end;

procedure TServerMethodsMikko1.DataSetProviderDc162AfterUpdateRecord(
  Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet;
  UpdateKind: TUpdateKind);
begin
  case UpdateKind of
    ukInsert:;
    ukModify:;
    ukDelete:;
  end;
end;

procedure TServerMethodsMikko1.DataSetProviderDc162BeforeUpdateRecord(
  Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet;
  UpdateKind: TUpdateKind; var Applied: Boolean);
begin
  if not  FDmMikkoads.AdsConnection1.TransactionActive then
    FDmMikkoads.AdsConnection1.BeginTransaction;
  try
    case UpdateKind of
      ukInsert: FDmEntrance.EditEntrance(True,SourceDs,DeltaDs);
      ukModify: FDmEntrance.EditEntrance(False,SourceDs,DeltaDs);
      ukDelete: FDmEntrance.DeleteEntrance(SourceDs,DeltaDs);
    end;
    Applied := True;
    //if  FDmMikkoads.AdsConnection1.TransactionActive then
    //  FDmMikkoads.AdsConnection1.Commit;
  except
    //if  FDmMikkoads.AdsConnection1.TransactionActive then
    //  FDmMikkoads.AdsConnection1.Rollback;
    Applied := False;
    Raise;
  end;
end;

procedure TServerMethodsMikko1.DeleteFingerUser(UserId: Integer);
begin
  FDmEntrance.DeleteFingerUser(UserId);
end;

destructor TServerMethodsMikko1.Destroy;
var i: Integer;
begin
  for I := 0 to ProviderList.Count-1 do
    ProviderList[i].Free;
  ProviderList.Free;
  inherited;
end;

function TServerMethodsMikko1.DtFromXbase(aDt: TdateTime): TDateTime;
begin
  Result := FDmMikkoads.DtFromXbase(aDt);
end;


function TServerMethodsMikko1.GetDataUvl(aKodKli: Integer): TDateTime;
begin
  Result := FDmEntrance.GetDataUvl(aKodkli);
end;

function TServerMethodsMikko1.GetKodkliByFinger(UserID: String;
    aData:String;var rCode: Integer): Integer;
var
  dwSize:integer;
  p: Pointer;
  i: Integer;
  buf: TBytes;
begin
  Result := 0;
  buf := BytesOf(adata);
  dwSize := length(buf);
  getMem(p,dwSize);
  try
    for I := 0 to dwSize-1 do
    begin
      PAnsiChar(p)[i] := AnsiChar(buf[i]);
    end;
    Result := FDmEntrance.GetKodkliByFinger(UserId,dwSize,PAnsiChar(buf),rCode);
  finally
    FreeMem(p)
  end;
end;

function TServerMethodsMikko1.GetServerTime: TDateTime;
begin
  Result := Now;
{ Оказалось что не нужно
 if Assigned(FDmEntrance) and (FDmEntrance.kodEntrance=KOD_ENTRANCE_TEHNO)  then
    Result := Result - 1/24;
 }
end;

function TServerMethodsMikko1.QueryValue(const cQuery: String): String;
begin
  Result := CoalEsce(FDmMikkoads.QueryValue(cQuery),'');
end;


procedure TServerMethodsMikko1.SetFilter(aIndex: Integer);
begin
  FDmEntrance.SetFilter(aIndex);
end;

function TServerMethodsMikko1.SetFilterOnDc162(
  aIndex: Integer): TDataSetProvider;
begin
  try
    FDmEntrance.ClearProtocol;
    FDmEntrance.ClearOpenEntrace;
  except
    // Глушим ошибку т.к. это вспомагательные действия.
  end;
  FDmEntrance.SetFilter(aIndex);
  Result := FDmEntrance.DataSetProvider1;
end;

function TServerMethodsMikko1.ValidHoliday(aKodSotrud: Integer): Boolean;
begin
  Result := FDmEntrance.ValidHoliday(aKodSotrud);
end;

function TServerMethodsMikko1.ValidOmk(aKodSotrud: Integer): Boolean;
begin
  Result := FDmEntrance.ValidOmk(aKodSotrud);
end;

function TServerMethodsMikko1.ValidGraphic(aKodSotrud: Integer): Boolean;
begin
  Result := FDmEntrance.ValidGraphic(aKodSotrud);
end;

initialization
  handle_connection := 0;
end.

