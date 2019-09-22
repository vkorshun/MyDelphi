unit dm_EntranceMethodsMikko;

interface

uses
  SysUtils, Classes, rtcDataSrv, rtcSrvModule, rtcLink, rtcInfo, rtcConn, rtcFunction, dm_mikkoads,
  dm_entrance, SyncObjs, Windows, dateVk, RtcDb, hostdate,Generics.Collections, Dialogs, RtcLog;

const
  FLD_KODKLI = 'kodkli';
  FLD_NAME = 'name';
  FLD_GRTIMEOUT = 'grTimeOut';
  FLD_ISVALIDGROUP = 'isValidGroup';
  FLD_DATEFIRE = 'dateFire';
  FLD_ISBARCODEACCESS = 'isBarCodeAccess';
  FLD_INN = 'INN';

type
  PDmEntranceListItem = ^RDmEntranceListItem;
  RDmEntranceListItem = record
    rtcCon: TRtcConnection;
    dm: TDmEntrance;
  end;

  TDmEntranceMethodsMikko = class(TDataModule)
    RtcEntranceGroup: TRtcFunctionGroup;
    RtcServModuleEntrance: TRtcServerModule;
    RtcDataServerLink1: TRtcDataServerLink;
    RtcFunction1: TRtcFunction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure fillSotrudInfo(Sender: TRtcConnection; var ARec:TRtcRecord);
  private
    { Private declarations }
    ListDmEntrance: TList<PDmEntranceListItem>;
    CritSection: TCriticalSection;
//    FDmMikkoAds: TDmMikkoAds;
//    FDmEntrance: TDmEntrance;
    procedure ClearDmEntranceList;
    function GetDmEntrance(aCon: TRtcConnection):TDmEntrance;
    procedure LockCritsection;
    procedure RegisterEntranceFunction(const aname:String; fExecute: TRtcFunctionCallEvent);
    procedure RtcFunConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcAddFingerUser(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcDeleteFingerUser(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcDtFromXbase(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcEditEntrance(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure RtcGetDataUvl(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetKodkliByFinger(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetKodkliByBarcode(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    procedure RtcGetServerTime(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetSystemTime(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcSetFilterOnDc162(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
//    function EchoString(Value: string): string;
//    function ReverseString(Value: string): string;
    procedure RtcClearOldData(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcSetFilter(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetClientDataSetDc167(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

    ///<summary> Проверка связи </summary>
    procedure RtcCheckConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    ///<summary> Возвращает результат запроса cQuery </summary>
    procedure RtcQueryValue(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    ///<summary> Проверка графика </summary>
    procedure RtcValidGraphic(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    ///<summary> Проверка отпуска </summary>
    procedure RtcValidHoliday(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    ///<summary> Проверка ОМК </summary>
    procedure RtcValidOmk(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    ///<summary> Проверка группы </summary>
    procedure RtcValidGroup(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
    procedure RtcGetGrTimeOut(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);

  public
    { Public declarations }
    procedure DeleteDmEntrance(Sender: TRtcConnection);
  end;

var
  DmEntranceMethodsMikko: TDmEntranceMethodsMikko;
  handle_connection: Integer;

implementation

{$R *.dfm}

{ TDataModule1 }

procedure TDmEntranceMethodsMikko.ClearDmEntranceList;
begin
  while ListDmEntrance.Count>0 do
    begin
      FreeAndNil(ListDmEntrance[0].dm);
      Dispose(ListDmEntrance[0]);
      ListDmEntrance.Delete(0);
    end;
end;

procedure TDmEntranceMethodsMikko.DataModuleCreate(Sender: TObject);
begin
  //FDmMikkoAds := nil;
  //FDmEntrance := nil;
  ListDmEntrance := TList<PDmEntranceListItem>.Create;
  RegisterEntranceFunction('Connect',RtcFunConnect);
  RegisterEntranceFunction('AddFingerUser',RtcAddFingerUser);
  RegisterEntranceFunction('DeleteFingerUser',RtcDeleteFingerUser);
  RegisterEntranceFunction('DtFromXbase',RtcDtFromXbase);
  RegisterEntranceFunction('GetDataUvl',RtcGetDataUvl);
  RegisterEntranceFunction('GetKodkliByFinger',RtcGetKodkliByFinger);
  RegisterEntranceFunction('GetKodkliByBarcode',RtcGetKodkliByBarcode);
  RegisterEntranceFunction('GetServerTime', RtcGetServerTime);
  RegisterEntranceFunction('SetFilter', RtcSetFilter);
  RegisterEntranceFunction('SetFilterOnDc162', RtcSetFilterOnDc162);
  RegisterEntranceFunction('ClearOldData', RtcClearOldData);
  RegisterEntranceFunction('RtcSetFilter', RtcSetFilter);
  RegisterEntranceFunction('GetClientDataSetDc167', RtcGetClientDataSetDc167);
  RegisterEntranceFunction('CheckConnect', RtcCheckConnect);
  RegisterEntranceFunction('QueryValue', RtcQueryValue);
  RegisterEntranceFunction('ValidGraphic', RtcValidGraphic);
  RegisterEntranceFunction('ValidHoliday', RtcValidHoliday);
  RegisterEntranceFunction('ValidOmk', RtcValidOmk);
  RegisterEntranceFunction('EditEntrance', RtcEditEntrance);
  RegisterEntranceFunction('ValidGroup', RtcValidGroup);
  RegisterEntranceFunction('GetSystemTime', RtcGetSystemTime);
  RegisterEntranceFunction('GetGrTimeOut', RtcGetGrTimeOut);
  CritSection := TCriticalSection.Create;
end;

procedure TDmEntranceMethodsMikko.DataModuleDestroy(Sender: TObject);
begin
  CritSection.Release;
  CritSection.Free;
  ClearDmEntranceList;
end;

procedure TDmEntranceMethodsMikko.DeleteDmEntrance(Sender: TRtcConnection);
var i: Integer;
begin
  for I := 0 to ListDmEntrance.Count-1 do
  begin
    if ListDmEntrance[i].rtcCon=Sender then
    begin
      FreeAndNil(ListDmEntrance[i].dm);
      Dispose(ListDmEntrance[i]);
      ListDmEntrance.Delete(i);
      Break;
    end;
  end;

end;

procedure TDmEntranceMethodsMikko.fillSotrudInfo(Sender: TRtcConnection; var ARec: TRtcRecord);
var kodkli: Integer;
    sAccess: String;
begin
  kodkli :=  ARec.asInteger[FLD_KODKLI];
  if kodkli>0 then
  begin
    ARec.asFloat[FLD_GRTIMEOUT]  := GetDmEntrance(Sender).GetGrTimeOut(kodkli);
    ARec.asWidestring[FLD_NAME]  := CoalEsce(GetDmEntrance(Sender).DmMikkoads.QueryValue('SELECT name FROM client WHERE kodkli='+IntToStr(kodkli)),'');
    ARec.asBoolean[FLD_ISVALIDGROUP] := GetDmEntrance(Sender).ValidGroup(kodkli);
    sAccess := CoalEsce(GetDmEntrance(Sender).DmMikkoAds.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+
           IntToStr(kodkli)+' AND kodparobj=258470'),'');
    ARec.asBoolean[FLD_ISBARCODEACCESS] :=  Trim(sAccess) = '1';
    ARec.asDateTime[FLD_DATEFIRE] := GetDmEntrance(Sender).GetDataUvl(kodkli);
    ARec.asString[FLD_INN] := CoalEsce(GetDmEntrance(Sender).DmMikkoAds.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+IntToStr(KodKli)+' AND kodparobj=31'),'');
    XLog(ARec.toJSON);
  end
  else
    XLog(' kodkli = 0');
end;

function TDmEntranceMethodsMikko.GetDmEntrance(aCon: TRtcConnection): TDmEntrance;
var p: PDmEntranceListItem;
begin
  Result := nil;
  for p in ListDmEntrance do
  begin
    if p.rtcCon= aCon then
      Result := p.Dm;
  end;
  if not Assigned(Result) then

end;

procedure TDmEntranceMethodsMikko.LockCritsection;
var t1: Int64;
begin
  t1 := GetTickCount;
  while not CritSection.TryEnter do
    if GetTickCount-t1>10 then
      raise Exception.Create(' Error lock IdHandle');
end;

procedure TDmEntranceMethodsMikko.RegisterEntranceFunction(const aname: String; fExecute: TRtcFunctionCallEvent);
var mRtcFunction: TRtcFunction;
begin
  mRtcFunction := TRtcFunction.Create(self);
  with mRtcFunction do
  begin
    FunctionName := aname;
    Group := RtcEntranceGroup;
    OnExecute := fExecute;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcAddFingerUser(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  dwSize:integer;
//  p: Pointer;
//  i: Integer;
  buf: TBytes;
  UserID: Integer;
//  aData: AnsiString;
  IdFinger:Integer;  //): Integer;
  mDmEntrance: TDmEntrance;
begin
  try
  Result.asInteger := 0;
  UserId := Param.asInteger['UserId'];
  buf := BytesOf(Param.asWideString['aData']);
  IdFinger := Param.asInteger['IdFinger'];
  mDmEntrance := GetDmEntrance(Sender);

  dwSize := length(buf);
  //getMem(p,bs.Size);
  try
{    for I := 0 to bs.Size-1 do
    begin
      PAnsiChar(p)[i] := AnsiChar(bs.Bytes[i]);
    end;}
    Result.asInteger := mDmEntrance.AddFingerUser(UserId,dwSize,PAnsiChar(buf),IdFinger,0);
    if Result.asInteger=0 then
      Result.asInteger := mDmEntrance.AddFingerUser(UserId,dwSize,PAnsiChar(buf),IdFinger,1);
  finally
    //FreeMem(p);
    //bs.Free;
  end;
  except
    on E: exception do
    begin
      XLog('RtcFunAddUser');
      XLog(E.Message);
      Raise;
    end;
  end;

end;

procedure TDmEntranceMethodsMikko.RtcCheckConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  if  Assigned(GetDmEntrance(Sender)) then
    Result.asInteger := 1
  else
    Result.asInteger := -1;
  except
    on E: exception do
    begin
      XLog('RtcFunCheckConnect');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcClearOldData(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  GetDmEntrance(Sender).ClearProtocol;
  GetDmEntrance(Sender).ClearOpenEntrace;
  except
    on E: exception do
    begin
      XLog('RtcFunClearOldData');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcDeleteFingerUser(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  UserId: Integer;
begin
  try
  UserId := Param.asInteger['UserId'];
  GetDmEntrance(Sender).DeleteFingerUser(UserId,0);
  GetDmEntrance(Sender).DeleteFingerUser(UserId,1);
  except
    on E: exception do
    begin
      XLog('RtcFunDeleteUser');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcDtFromXbase(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  Result.asDateTime := GetDmEntrance(Sender).DmMikkoads.DtFromXbase(Param.asDateTime['aDt']);
  except
    on E: exception do
    begin
      XLog('RtcFunDtFromXBase');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcEditEntrance(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  chg:TRtcDataSetChanges;
  koddoc: Integer;
  response: TRtcArray;
begin
  try
  if Param.isNull['delta_data'] then
    raise Exception.Create('Change_Data parameter is required');
  chg := TRtcDataSetChanges.Create(Param.AsObject['delta_data']);
  response := Result.NewArray;
  try
    GetDmEntrance(Sender).EditEntrance(chg, response);
  finally
    Result.asArray := response;
    FreeAndNil(chg);
  end;
  except
    on E: exception do
    begin
      XLog('RtcFunEditEntrance');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcFunConnect(Sender: TRtcConnection; Param: TRtcFunctionInfo; Result: TRtcValue);
var aUserName, aPassword: string;
    aIdOffice: Integer;
    mDmEntrance: TDmEntrance;
    p: PDmEntranceListItem;
begin
  if Assigned(GetDmEntrance(Sender)) then
    Exit;
  LockCritSection;
  Inc(handle_connection) ;
  //FHandleConnection := handle_connection;
  CritSection.Release;
  try
    aUserName := Param.AsWideString['username'];
    aPassword := Param.AsWideString['password'];
    aIdOffice := Param.AsInteger['kodentrance'];
  //FDmMikkoAds := TDmMikkoAds.Create(self);
    mDmEntrance := TDmEntrance.Create(self);
    New(p);
    p.rtcCon := Sender;
    p.dm := mDmEntrance;
    ListDmEntrance.Add(p);
  //FDmEntrance.DmMikkoAds := FDmMikkoAds;
    mDmEntrance.handle_connection := handle_connection;
    if mDmEntrance.DmMikkoAds.ServerLogin(aUserName,aPassword) then
      Result.asInteger := handle_connection
    else
      Result.asInteger := 0;
    mDmEntrance.kodEntrance := aIdOffice;
  //DataSetProviderDc162.DataSet := FDmEntrance.AdsQueryDc162;
  //DataSetProviderDc167.DataSet := FDmEntrance.AdsQueryDc167;
    mDmEntrance.OpenRegistration;
  //ClearOldData;
  except
    On E: exception do
    begin
      XLog('RtcFunConnect');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetClientDataSetDc167(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  mDmEntrance: TDmEntrance;
begin
  try
  mDmEntrance := GetDmEntrance(Sender);
  if not mDmEntrance.AdsQueryDc167.Active then
    mDmEntrance.OpenRegistration
  else
  begin
    mDmEntrance.AdsQueryDc167.Close;
    mDmEntrance.AdsQueryDc167.Open;
  end;
  DelphiDataSetToRtc(mDmEntrance.AdsQueryDc167, Result.NewDataSet);
//  Result.asDataSet :=
  except
    on E: exception do
    begin
      XLog('RtcFunDc167');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetDataUvl(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  Result.asDateTime := GetDmEntrance(Sender).GetDataUvl(Param.asInteger['aKodkli']);
  except
    on E: exception do
    begin
      XLog('RtcFunDataUvl');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetKodkliByBarcode(Sender: TRtcConnection;
  Param: TRtcFunctionInfo; Result: TRtcValue);
var
  rec: TRtcRecord;

begin
  rec := Result.NewRecord;
  rec.asInteger['kodkli'] := Param.asInteger['kodkli'];
  try
     fillSotrudInfo(Sender,rec);
  except
    on E: exception do
    begin
      XLog('RtcFunKodKliByBarcode');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetKodkliByFinger(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  UserID: String;
  aData:String;
  rCode: Integer;
  dwSize:integer;
  buf: TBytes;
//  bs: TBytesStream;
  rec: TRtcRecord;
begin
  try
    rec := Result.NewRecord;
    rec.asInteger['kodkli'] := 0;
    UserId := Param.asWideString['UserId'];
    //bs:= TBytesStream.Create;
    try
      rCode  := param.asInteger['rCode'];
      //------------ Stream --------------------
      if Param.isType['adata']=rtc_ByteArray then
      begin
        //bs.LoadFromStream(Param.asByteStream['adata']);
        buf := TBytes(MIME_decodeex(Param.asByteArray['adata']));
        rec.asInteger[FLD_KODKLI] := GetDmEntrance(Sender).GetKodkliByFinger(UserId,length(buf),PAnsiChar(buf),rCode);
        fillSotrudInfo(Sender,rec);
      end
      else
      begin
        //----------- String ----------------------
        adata  := Param.asWideString['adata'];
        buf := BytesOf(adata);
        dwSize := length(buf);
        rec.asInteger[FLD_KODKLI] := GetDmEntrance(Sender).GetKodkliByFinger(UserId,dwSize,PAnsiChar(buf),rCode);
        fillSotrudInfo(Sender,rec);
     end;
     XLog('kodkli = '+IntToStr(rec.asInteger['kodkli']));
    finally
     // FreeAndNil(bs);
    end;
  except
    on E: exception do
    begin
      XLog('RtcFunKodKliByFinger');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetServerTime(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  Result.asDateTime := Now;
  except
    on E: exception do
    begin
      XLog('RtcFunServerTime');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetSystemTime(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  Result.asDateTime := DtToSysDt(Now);
  except
    on E: exception do
    begin
      XLog('RtcFunSysytemTyme');
      XLog(E.Message);
      Raise;
    end;
  end;

end;

procedure TDmEntranceMethodsMikko.RtcQueryValue(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
  Result.asWideString := CoalEsce(GetDmEntrance(Sender).DmMikkoads.QueryValue(Param.asWideString['cQuery']),'');
  except
    on E: exception do
    begin
      XLog('RtcFunQueryValue');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcSetFilter(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  mDmEntrance: TDmEntrance;
begin
  try
    mDmEntrance := GetDmEntrance(Sender);
    mDmEntrance.SetFilter(Param.AsInteger['aIndex']);
    DelphiDataSetToRtc(mDmEntrance.AdsQueryDc162, Result.NewDataSet);
  except
    on E: exception do
    begin
      XLog('RtcFunSetFilter');

      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcSetFilterOnDc162(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
var
  mDmEntrance: TDmEntrance;
begin
  mDmEntrance := GetDmEntrance(Sender);
  try
    mDmEntrance.ClearProtocol;
    mDmEntrance.ClearOpenEntrace;
  except
    // Глушим ошибку т.к. это вспомагательные действия.
  end;
  mDmEntrance.SetFilter(Param.AsInteger['aIndex']);
  DelphiDataSetToRtc(mDmEntrance.AdsQueryDc162, Result.NewDataSet);
end;

procedure TDmEntranceMethodsMikko.RtcValidGraphic(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
    Result.asBoolean := GetDmEntrance(Sender).ValidGraphic(Param.AsInteger['aKodSotrud']);
  except
    on E: exception do
    begin
      XLog('RtcFunValidGrafic');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcGetGrTimeOut(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
    Result.asFloat := GetDmEntrance(Sender).GetGrTimeOut(Param.AsInteger['aKodSotrud']);
  except
    on E: exception do
    begin
      XLog('RtcGetGrTimeOut');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcValidGroup(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
    Result.asBoolean := GetDmEntrance(Sender).ValidGroup(Param.AsInteger['aKodSotrud']);
  except
    on E: exception do
    begin
      XLog('RtcFunValidGroup');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcValidHoliday(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
    Result.asBoolean := GetDmEntrance(Sender).ValidHoliday(Param.AsInteger['aKodSotrud']);
  except
    on E: exception do
    begin
      XLog('RtcFunValidHoliday');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

procedure TDmEntranceMethodsMikko.RtcValidOmk(Sender: TRtcConnection; Param: TRtcFunctionInfo;
  Result: TRtcValue);
begin
  try
    Result.asBoolean := GetDmEntrance(Sender).ValidOmk(Param.AsInteger['aKodSotrud']);
  except
    on E: exception do
    begin
      XLog('RtcFunValidOmk');
      XLog(E.Message);
      Raise;
    end;
  end;
end;

Initialization;
  handle_connection := 0;
end.
