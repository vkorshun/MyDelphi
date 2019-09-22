unit dm_entrance;

interface

uses
  SysUtils, Classes, dm_mikkoads, DB, adsdata, adsfunc, adstable, DbClient,
  doc.variablelist, FasApi, DateVk, forms, RtcInfo, SuperObject, RtcLog;

const
  ID_PRIZNAK_ENTRANCE = 1307;
  KODREG_PROHOD = 162;
  PRIZNAK_PROHOD_MIKKO = 1307;
  PRIZNAK_PROHOD_BELGOROD = 1792;
  PRIZNAK_NOTPROHOD = 1487;
  PRIZNAK_FREEGR = 1490;
  KODG_SOTRUD = 16;
  KODG_SOTRTEHNO = 204281;

  KOD_ENTRANCE_MIKKO = 211367;
  KOD_ENTRANCE_BELGOROD = 211368;
  KOD_ENTRANCE_BUH = 211369;
  KOD_ENTRANCE_VED = 211370;
  KOD_ENTRANCE_TEHNO = 211371;

type
  TDmEntrance = class(TDataModule)
    AdsQueryDc162: TAdsQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    AdsQuery1: TAdsQuery;
    AdsQrSource: TAdsQuery;
    AdsQueryProtocol: TAdsQuery;
    AdsQueryClearProtocol: TAdsQuery;
    fasserver: AnsiString;
    FDmMikkoAds: TDmMikkoAds;
    FHandle_connection: Integer;
    /// <summary> Код проходной </summary>
    Fkodentrance: Integer;
    //FDmMikkoAds: TDmMikkoAds;

    VarListDc162: TDocVariableList;
    procedure RegisterNewFingerUser(aIdUser: Integer);
    procedure SetDmMikkoads(aDm: TDmMikkoAds);
    procedure WriteProtocol(kodkli: Integer);
    procedure SaveTemplateToFile(p: Pointer; dwSize: Integer; const FileName: String);
  public
    { Public declarations }
    AdsQueryDc167: TAdsQuery;

    /// <summary> Регистрация отпечатка пользователя </summary>
    function AddFingerUser(UserID: Integer; dwSize: LongWord; pSample: Pointer; IdFinger: Integer;
      IdFas:Integer = 0): Integer;
    /// <summary> Создание нового Tdataset на основе AdsQuery </summary>
    function CreateAdsQuery(const aSQL: String): TAdsQuery;
    function CheckIsOut(AKodKli: Integer;var  ADt:TDateTime ):Boolean;
    function GetLastEvent(AKodKli: Integer;var  ADt:TDateTime ):ISuperObject;
    function GetLastState(AKodKli: Integer):ISuperObject;
    /// <summary> Удаление регистрации отпечатка </summary>
    procedure DeleteFingerUser(UserID: Integer; IdFas:Integer);
    /// <summary> проверка даты увольнения </summary>
    function GetDataUvl(aKodKli: Integer): TDateTime;
    /// <summary> Фильтр на кол. дней (aCount) </summary>
    procedure FilterOnDay(aCount: Integer);
    /// <summary> Закрытие не закрытых приходов на работу </summary>
    procedure ClearOpenEntrace;
    /// <summary> Сокращение протокола </summary>
    procedure ClearProtocol;
    procedure DeleteEntrance(SourceDS: TDataSet; DeltaDS: TCustomClientDataSet);
    procedure EditEntrance(DeltaDS: TRtcDataSetChanges; var aRtcArray: TRtcArray);

    function GetKodkliByFinger(UserID: String; dwSize: LongWord; pSample: Pointer;
      var rCode: Integer): Integer;
    function GetControlOrder(cCode: PAnsiChar): AnsiChar;
    /// <summary> Фильтр на территории </summary>
    procedure FilterOnToDay;
    procedure OpenRegistration;
    /// <summary> Удаление регистрация пользователя </summary>
    procedure UnRegistrationUser;
    // ///<summary> Регистрация пользователя </summary>
    // procedure RegistrationUser;

    procedure SetFilter(aIndex: Integer);
    /// <summary> Проверка графика </summary>
    function ValidGraphic(aKodSotrud: Integer): Boolean;
    /// <summary> Проверка отпуска </summary>
    function ValidHoliday(aKodSotrud: Integer): Boolean;
    /// <summary> Проверка ОМК </summary>
    function ValidOmk(aKodSotrud: Integer): Boolean;
    function ValidBarcode(pBarcode: PAnsiChar): Boolean;
    function ValidGroup(aKodKli: Integer): Boolean;
    function GetGrTimeOut(aKodSotrud: Integer): Double;

    property kodEntrance: Integer read Fkodentrance write Fkodentrance;
    property DmMikkoAds: TDmMikkoAds read FDmMikkoAds write SetDmMikkoads;
    property handle_connection: Integer read FHandle_connection write FHandle_connection;
  end;

var
  DmEntrance: TDmEntrance;

implementation

{$R *.dfm}

function TDmEntrance.AddFingerUser(UserID: Integer; dwSize: LongWord; pSample: Pointer;
  IdFinger: Integer; IdFas: Integer =0): Integer;
var
  // Код сотрудника при идентификации
  pRetId: array [0 .. 13] of AnsiChar;
  pFile: array [0 .. 255] of AnsiChar;
  pUser: array [0 .. 100] of AnsiChar;
  pUserId: array [0 .. 11] of AnsiChar;
  cUserName: String;
  FileName: String;
begin
  if IdFas=0 then
    fasserver := AnsiString(FDmMikkoAds.fasserver) + #0
  else
    fasserver := AnsiString(FDmMikkoAds.fasserver2) + #0;

  Result := FASInitialize(PAnsiChar(fasserver), 4900);
  FileName := ExtractFileDir(Application.ExeName) + '\' + 'tempalte.tmp';
  try
    if Result=0  then
    begin
      FillChar(pRetId, SizeOf(pRetId), #0);
      StrPCopy(pFile, AnsiString(FileName));
      StrPCopy(pUser, AnsiString(cUserName));
      StrPCopy(pUserId, AnsiString(IntToStr(UserID)));
      SaveTemplateToFile(pSample, dwSize, FileName);
      Result := FasAddUserFromFile(5, 100, pFile, pUser, pUserId, 0, IdFinger, 6);
      XLog(Format(' AddFingerUser userid = %d , Result %d',[UserId, Result]));
      if Result = 0 then
      begin
        // Новая регистрация
        RegisterNewFingerUser(UserID);
        { Result := StrToInt(String(StrPas(pRetId)));
          WriteProtocol(Result); }
      end
      else
        Raise Exception.Create(Format('Error registration = %d',[Result]));
    end
    else
      Raise Exception.Create(' Нет связи с FAS '+String(fasserver));
  finally
    FasTerminate;
  end;

end;

function TDmEntrance.CheckIsOut(AKodKli: Integer;var ADt: TDateTime):Boolean;
var koddoc: Integer;
begin
  with AdsQueryDc162 do
  begin
    Active := False;
    AdsConnection := DmMikkoAds.AdsConnection1;

    SQL.Clear;
    SQL.Add(' SELECT  dc162.*');
    SQL.Add(' FROM task\dc000162 dc162');
    SQL.Add(' WHERE dc162.priznak IN (' + IntToStr(ID_PRIZNAK_ENTRANCE) + ',' + IntToStr(PRIZNAK_NOTPROHOD) +
      ')' + ' AND dc162.data>=curdate()-' + IntToStr(1));
    SQL.Add(' and dc162.entranc=' + IntToStr(Fkodentrance));
    SQL.Add(' AND dc162.kodkli='+IntToStr(AKodKli));
    SQL.Add(' AND dc162.datatim2 is NULL AND not dc162.datatim1 iS null');
    SQL.Add(' ORDER BY dc162.data,dc162.datatim1');
    Open;
    FDmMikkoAds.InitDocVariableListOnDs(AdsQueryDc162,VarListDc162);
    if not IsEmpty then
    begin
      Result := True;
      if (Adt=0) then
      begin
        koddoc := FieldByName('koddoc').AsInteger;
        if FDmMikkoAds.LockDoc('task\dc000162', koddoc) then
        begin
          FDmMikkoAds.CalcVariablesOnDoc('task\dc000162', koddoc, VarListDc162);
          VarListDc162.VarByName('datatim2').AsDateTime := DmMikkoAds.DtToXbase(now);
          //FDmMikkoAds.UpdateVariablesOnDeltaDs(DeltaDS, VarListDc162);
          FDmMikkoAds.EditDoc(False, VarListDc162.VarByName('koddoc').AsInteger, 162, ID_PRIZNAK_ENTRANCE,
              VarListDc162, False, '');
        end
        else
          raise Exception.Create('Error lock dock!' + IntToStr(koddoc));
      end
      else
        ADt := FDmMikkoAds.DtFromXbase(FieldByName('datatim1').AsFloat);
    end
    else
    begin
      Result := False;
      if (Adt=0) then
      begin
        VarListDc162.InitBlank;
        VarListDc162.VarByName('koddoc').AsInteger := FDmMikkoAds.NewNum('DOCUMENT');
        VarListDc162.VarByName('datatim1').AsDateTime := FDmMikkoAds.DtToXbase(now);
        VarListDc162.VarByName('kodkli').AsInteger := AKodKli;
        VarListDc162.VarByName('priznak').AsInteger := ID_PRIZNAK_ENTRANCE;
        VarListDc162.VarByName('data').AsDateTime := Now;
        VarListDc162.VarByName('entranc').AsInteger := Fkodentrance;
        FDmMikkoAds.EditDoc(True, VarListDc162.VarByName('koddoc').AsInteger, 162,
            VarListDc162.VarByName('priznak').AsInteger, VarListDc162, False, '');
       end
       else
       begin
         ADt := now;
       end;
    end;
  end;

end;

procedure TDmEntrance.ClearOpenEntrace;
begin
  // Если вид учета <> '2. Техно и филиалы (Только первая смена)'
  if FDmMikkoAds.SpOba(213034, kodEntrance) <> 213036 then
    Exit;

  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' UPDATE task\dc000162  ');
    SQL.Add(' SET datatim2 = datatim1+8.50/24.00');
    SQL.Add(' WHERE priznak=:priznak and entranc=:entranc AND datatim1<:dt1');
    SQL.Add(' AND datatim1>0 AND datatim2=0');
    ParamByName('priznak').AsInteger := ID_PRIZNAK_ENTRANCE;
    ParamByName('entranc').AsInteger := kodEntrance;
    ParamByName('dt1').AsFloat := DmMikkoAds.DtToXbase(Now - 12 / 25);
    ExecSQL;
  end;
end;

procedure TDmEntrance.ClearProtocol;
begin
  with AdsQueryClearProtocol do
  begin
    Active := False;
    ParamByName('tm').AsDateTime := Now - 30;
    ParamByName('entranc').AsInteger := kodEntrance;
    ExecSQL;
  end;
end;

function TDmEntrance.CreateAdsQuery(const aSQL: String): TAdsQuery;
begin
  Result := TAdsQuery.Create(self);
  with Result do
  begin
    AdsTableOptions.AdsCharType := OEM;
    SourceTableType := ttAdsCdx;
    AdsConnection := FDmMikkoAds.AdsConnection1;
    DataBaseName := 'FDmMikkoads.AdsConnection1';
    SQL.Text := aSQL;
  end;
  Result.AdsConnection := FDmMikkoAds.AdsConnection1;
end;

procedure TDmEntrance.DataModuleCreate(Sender: TObject);
begin
  FDmMikkoAds := TDmMikkoAds.Create(self);
  VarListDc162 := TDocVariableList.Create(FDmMikkoAds);
  SetDmMikkoads(FDmMikkoAds);
end;

procedure TDmEntrance.DataModuleDestroy(Sender: TObject);
begin
  VarListDc162.Free;
end;

procedure TDmEntrance.DeleteEntrance(SourceDS: TDataSet; DeltaDS: TCustomClientDataSet);
var
  koddoc: Integer;
begin
  koddoc := DeltaDS.FieldByName('koddoc').AsInteger;
  if FDmMikkoAds.LockDoc('task\dc000162', koddoc) then
    FDmMikkoAds.DeleteDoc(162, ID_PRIZNAK_ENTRANCE, koddoc, '');
end;

procedure TDmEntrance.DeleteFingerUser(UserID: Integer; IdFas:Integer);
var
  s: AnsiString;
begin
  // delete;
  if IdFas=0 then
    fasserver := AnsiString(FDmMikkoAds.fasserver) + #0
  else
    fasserver := AnsiString(FDmMikkoAds.fasserver2) + #0;
  FASInitialize(PAnsiChar(fasserver), 4900);
  try
    s := AnsiString(IntToStr(UserID) + #0);
    if FasDeleteUser(1, 100, PAnsiChar(AnsiString(s))) = 0 then
    begin
      with AdsQrSource do
      begin
        Active := False;
        SQL.Clear;
        SQL.Add(' UPDATE task\dc000167 SET isfinger=0  WHERE priznak=1316 ');
        SQL.Add(' AND sotrud=' + IntToStr(UserID));
        ExecSQL;
      end;
    end;
  finally
    FasTerminate();
    with AdsQueryDc167 do
    begin
      Close;
      Open;
    end;
  end;

end;

procedure TDmEntrance.EditEntrance(DeltaDS: TRtcDataSetChanges; var aRtcArray: TRtcArray);
var
  koddoc: Integer;
  rtcRecord: TRtcRecord;
begin
  FDmMikkoAds.InitDocVariableList('task\dc000162', VarListDc162);
  FDmMikkoAds.AdsConnection1.BeginTransaction;
  try
    DeltaDS.First;
    while not DeltaDS.eof do
    begin
      if DeltaDS.Action = rds_Insert then
      begin
        // while not DeltaDs.Eof do
        begin
          FDmMikkoAds.CalcVariablesOnDs(DeltaDS, VarListDc162);
          VarListDc162.VarByName('koddoc').AsInteger := FDmMikkoAds.NewNum('DOCUMENT');

          // VarListDc162.VarByName('priznak').AsInteger :=   FDmMikkoAds.NewNum('DOCUMENT');

          FDmMikkoAds.EditDoc(True, VarListDc162.VarByName('koddoc').AsInteger, 162,
            VarListDc162.VarByName('priznak').AsInteger, VarListDc162, False, '');

          rtcRecord := aRtcArray.NewRecord(aRtcArray.count);

          rtcRecord.asInteger['koddoc'] := VarListDc162.VarByName('koddoc').AsInteger;
          rtcRecord.asInteger['localid'] := DeltaDS.NewRow.FieldByName('localid').asInteger;
          // DeltaDs.Next;
        end;
      end
      else
      begin
        // while not DeltaDs.Eof do
        begin
          koddoc := DeltaDS.OldRow.FieldByName('koddoc').AsInteger;
          rtcRecord := aRtcArray.NewRecord(aRtcArray.count);
          rtcRecord.asInteger['koddoc'] := koddoc;
          rtcRecord.asInteger['localid'] := DeltaDS.NewRow.FieldByName('localid').asInteger;
          // if SourceDs.Locate('koddoc',koddoc,[]) then
          // begin
          // koddoc := SourceDs.FieldByName('koddoc').AsInteger;
          if FDmMikkoAds.LockDoc('task\dc000162', koddoc) then
          begin
            FDmMikkoAds.CalcVariablesOnDoc('task\dc000162', koddoc, VarListDc162);
            FDmMikkoAds.UpdateVariablesOnDeltaDs(DeltaDS, VarListDc162);
            FDmMikkoAds.EditDoc(False, VarListDc162.VarByName('koddoc').AsInteger, 162, ID_PRIZNAK_ENTRANCE,
              VarListDc162, False, '');
          end
          else
            raise Exception.Create('Error lock dock!' + IntToStr(koddoc));
          // end
          // else
          // raise Exception.Create('Error locate koddoc!'+IntToStr(koddoc));
          // DeltaDs.Next;
        end;
      end;
      DeltaDS.Next;
    end;
    FDmMikkoAds.AdsConnection1.Commit;
  except
    FDmMikkoAds.AdsConnection1.Rollback;
    Raise;
  end;
end;

procedure TDmEntrance.FilterOnDay(aCount: Integer);
begin
  with AdsQueryDc162 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT  dc162.*, c.name, IIF(dc162.datatim1>0,1,0) as prih, IIF(dc162.datatim2>0,1,0) as uh');
    SQL.Add(' FROM task\dc000162 dc162');
    SQL.Add(' LEFT JOIN client c ON c.kodkli=dc162.kodkli ');
    SQL.Add(' WHERE dc162.priznak IN (' + IntToStr(ID_PRIZNAK_ENTRANCE) + ',' + IntToStr(PRIZNAK_NOTPROHOD) +
      ')' + ' AND dc162.data>=curdate()-' + IntToStr(aCount));
    SQL.Add(' and entranc=' + IntToStr(Fkodentrance));
    SQL.Add(' ORDER BY dc162.data,dc162.datatim1');
    Open;
  end;

end;

procedure TDmEntrance.FilterOnToDay;
begin
  with AdsQueryDc162 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT  dc162.*, c.name, IIF(dc162.datatim1>0,1,0) as prih, IIF(dc162.datatim2>0,1,0) as uh');
    SQL.Add(' FROM task\dc000162 dc162');
    SQL.Add(' LEFT JOIN client c ON c.kodkli=dc162.kodkli ');
    SQL.Add(' WHERE dc162.priznak= IN (' + IntToStr(ID_PRIZNAK_ENTRANCE) + ',' + IntToStr(PRIZNAK_NOTPROHOD) +
      ')' + ' AND dc162.datatim2 IS NULL  ');
    SQL.Add(' and entranc=' + IntToStr(Fkodentrance));
    SQL.Add(' ORDER BY dc162.data,dc162.datatim1');
    Open;
  end;
end;

function TDmEntrance.GetControlOrder(cCode: PAnsiChar): AnsiChar;
var
  n1, n2, n: Integer;
  i: Cardinal;
begin
  i := 0;
  n1 := 0;
  n2 := 0;
  while i < StrLen(cCode) do
  begin
    if i mod 2 = 0 then
      // Нечетные
      n1 := n1 + StrToInt(Char(cCode[i]))
    else
      // Четные
      n2 := n2 + StrToInt(Char(cCode[i]));
    inc(i);
  end;
  n := n1 + n2 * 3;
  n := 10 - (n mod 10);

  if n >= 10 then
    Result := '0'
  else
    Result := AnsiString(IntToStr(n))[1];

end;

function TDmEntrance.GetDataUvl(aKodKli: Integer): TDateTime;
begin
  with AdsQuery1 do
  begin
    // 1. проверка на увольнение
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT d33.* From task\dc000033 d33 WHERE d33.sotrud=' + IntToStr(aKodKli) +
      ' AND d33.priznak=440 ORDER BY d33.data DESC');
    Open;
    if IsEmpty then
      Result := 0
    else
      Result := FieldByName('datauv').AsDateTime;
  end;
end;

function TDmEntrance.GetKodkliByFinger(UserID: String; dwSize: LongWord; pSample: Pointer;
  var rCode: Integer): Integer;
var
  // Код сотрудника при идентификации
  pRetId: array [0 .. 13] of AnsiChar;

begin
  fasserver := AnsiString(FDmMikkoAds.fasserver) + #0;
  Result := 0;
  rCode := FASInitialize(PAnsiChar(fasserver), 4900);
  if rCode<>0 then
  begin
    fasserver := AnsiString(FDmMikkoAds.fasserver2) + #0;
    rCode := FASInitialize(PAnsiChar(fasserver), 4900);
  end;
  try
    if rCode = 0 then
    begin
      FillChar(pRetId, SizeOf(pRetId), #0);
      rCode := FasIdentifyUser('ALL', dwSize, pSample, @pRetId);
      if rCode = 0 then
      begin
        // Новая регистрация
        Result := StrToInt(String(StrPas(pRetId)));
        WriteProtocol(Result);
      end;
    end;
  finally
    FasTerminate;
  end;
end;

function TDmEntrance.GetLastEvent(AKodKli: Integer; var ADt: TDateTime): ISuperObject;
var dt: TDateTime;
    counter: Integer;
  procedure AddItem(dt: TDateTime; id: Integer);
  var obj: ISuperObject;
      s: String;
  begin
    if dt>= Adt then
    begin
      obj := SO;
      obj.I['id'] := id;
      if (id=1) then
        s := ' Приход '
      else
        s := ' Уход ';
      obj.S['message'] := s +DateToStr(dt)+' '+TimeToStr(dt);
      Result.A['entrance'].add(obj);
      Inc(counter);
    end;
  end;
var _obj: ISuperObject;
begin
  Result := SO('{}');
  Result.O['entrance'] := SA([]);
  try
  with AdsQueryDc162 do
  begin
    Active := False;
    AdsConnection := DmMikkoAds.AdsConnection1;

    SQL.Clear;
    SQL.Add(' SELECT  dc162.*');
    SQL.Add(' FROM task\dc000162 dc162');
    SQL.Add(' WHERE dc162.priznak IN (' + IntToStr(ID_PRIZNAK_ENTRANCE) + ',' + IntToStr(PRIZNAK_NOTPROHOD) +
      ')' + ' AND dc162.data>=curdate()-' + IntToStr(1));
    SQL.Add(' and dc162.entranc=' + IntToStr(Fkodentrance));
    SQL.Add(' AND dc162.kodkli='+IntToStr(AKodKli));
    SQL.Add(' AND dc162.data >= :data');

//    SQL.Add(' AND dc162.datatim2 is NULL AND not dc162.datatim1 iS null');
    SQL.Add(' ORDER BY dc162.data,dc162.datatim1');
    ParamByName('data').AsDateTime := Adt -30;
    Open;
//    FDmMikkoAds.InitDocVariableListOnDs(AdsQueryDc162,VarListDc162);
    if not IsEmpty then
    begin
      Last;
      counter := 0;
      AddItem(FDmMikkoAds.DtFromXbase(FieldByName('datatim1').AsFloat),1);
      AddItem(FDmMikkoAds.DtFromXbase(FieldByName('datatim2').AsFloat),2);
    end
    else
    begin
      _obj := SO;
      _obj.I['id'] := 0;
      _obj.S['message'] := 'Нет отметок на проходной';
      Result.A['entrance'].Add(_obj);
    end;
  end;
  except
    on E:exception do
    begin
      Result.S['error'] := E.Message;
    end;
  end;

end;

function TDmEntrance.GetLastState(AKodKli: Integer): ISuperObject;
begin

end;

procedure TDmEntrance.OpenRegistration;
begin
  // FPlace := aPlace;

  // Последний месяц в зарплате
  with AdsQrSource do
  begin
    SQL.Clear;
    SQL.Add(' SELECT  Max(data) as data FROM task\dc000033 where priznak=440 ');
    Open;
    Last;
  end;

  // Сотрудники
  with AdsQueryDc167 do
  begin
    SQL.Clear;
    if Fkodentrance <> KOD_ENTRANCE_TEHNO then
    begin
      SQL.Add(' SELECT dc33.sotrud,dc167.isfinger, c.name, p.value, 0 as kolfin ');
      SQL.Add(' FROM task\dc000033 dc33 left join task\dc000167 dc167 ON dc167.sotrud=dc33.sotrud AND dc167.priznak=1316');
      SQL.Add(' LEFT JOIN client c ON c.kodkli= dc33.sotrud');
      SQL.Add(' LEFT JOIN Par_obj\par_obj p  ON p.kodobj= dc33.sotrud and p.kodparobj=42300');
      SQL.Add(' LEFT JOIN Par_obj\par_obj pcountry ON pcountry.kodobj= dc33.firma AND pcountry.kodparobj=207');
      SQL.Add(' WHERE dc33.priznak=440 and dc33.data>=:d1 AND dc33.data<=:d2 AND (dc33.datauv IS NULL OR dc33.dataprih>dc33.datauv)');
      if Fkodentrance = KOD_ENTRANCE_BELGOROD then
        SQL.Add(' AND pcountry.objvalue = 2529');
//        SQL.Add(' AND dc33.kodv= 162 AND dc33.firma=48494');
      ParamByName('d1').AsDateTime := FirstDateMonth(AdsQrSource.FieldByName('data').AsDateTime);
      ParamByName('d2').AsDateTime := LastDateMonth(AdsQrSource.FieldByName('data').AsDateTime);
    end
    else
    begin
      SQL.Add(' SELECT c.kodkli as sotrud,dc167.isfinger, c.name, p.value, 0 as kolfin ');
      SQL.Add(' FROM client c left join task\dc000167 dc167 ON dc167.sotrud=c.kodkli AND dc167.priznak=1316');
      SQL.Add(' LEFT JOIN Par_obj\par_obj p  ON p.kodobj= c.kodkli and p.kodparobj=42300');
      SQL.Add(' WHERE c.kodg=' + IntToStr(KODG_SOTRTEHNO));

    end;
    SQL.Add(' ORDER BY c.name');
    Open;
  end;

end;

procedure TDmEntrance.RegisterNewFingerUser(aIdUser: Integer);
var
  koddoc: Integer;
begin
  koddoc := CoalEsce(FDmMikkoAds.QueryValue(' SELECT koddoc FROM task\dc000167 where priznak=1316 and sotrud='
    + IntToStr(aIdUser)), 0);
  if koddoc = 0 then
  begin
    with AdsQrSource do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add(' INSERT INTO task\dc000167 (koddoc,priznak,sotrud, isfinger)');
      SQL.Add(' VALUES (:koddoc,1316,:sotrud,1)');
      ParamByName('koddoc').AsInteger := FDmMikkoAds.NewNum('DOCUMENT');
      ParamByName('sotrud').AsInteger := aIdUser;
      ExecSQL;
    end;
  end
  else
  begin
    with AdsQrSource do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add(' UPDATE task\dc000167 set isfinger=isfinger+1');
      SQL.Add(' WHERE priznak=1316 AND sotrud=:sotrud');
      ParamByName('sotrud').AsInteger := aIdUser;
      ExecSQL;
    end;

  end;
  with AdsQueryDc167 do
  begin
    Close;
    Open;
  end;

end;

{ procedure TDmEntrance.RegistrationUser;
  var koddoc:Integer;
  begin

  koddoc := CoalEsce(DmMikkoAds.QueryValue(' SELECT koddoc FROM task\dc000167 where priznak=1316 and sotrud='+
  AdsQueryDc167.FieldByName('sotrud').AsString),0);
  if koddoc=0 then
  begin
  with AdsQrSource do
  begin
  Active := False;
  SQL.Clear;
  SQL.Add(' INSERT INTO task\dc000167 (koddoc,priznak,sotrud, isfinger)');
  SQL.Add(' VALUES (:koddoc,1316,:sotrud,1)');
  ParamByName('koddoc').AsInteger := DmMikkoAds.NewNum('DOCUMENT');
  ParamByName('sotrud').AsInteger := AdsQueryDc167.FieldByName('sotrud').AsInteger;
  ExecSQL;
  end;
  end
  else
  begin
  with AdsQrSource do
  begin
  Active := False;
  SQL.Clear;
  SQL.Add(' UPDATE task\dc000167 set isfinger=1');
  SQL.Add(' WHERE priznak=1316 AND sotrud=:sotrud');
  paramByName('sotrud').AsInteger := AdsQueryDc167.FieldByName('sotrud').AsInteger;
  ExecSQL;
  end;

  end;
  with AdsQueryDc167 do
  begin
  Close;
  Open;
  end;
  end; }

procedure TDmEntrance.SaveTemplateToFile(p: Pointer; dwSize: Integer; const FileName: String);
var
  fStream: TFileStream;
  // Отпечаток
  buf1: array [0 .. 4] of byte;
  buf2: array [0 .. 11] of byte;
  buf3: array [0 .. 4] of byte;

begin
  fStream := TFileStream.Create(FileName, fmCreate);
  try
    FillChar(buf1, 0, 4);
    StrLCopy(@buf1, PAnsiChar(p), 2);
    fStream.WriteBuffer(buf1, 4);
    FillChar(buf2, 0, 12);
    StrLCopy(@buf2, '1111111111', 10);
    fStream.WriteBuffer(buf2, 12);
    FillChar(buf3, 0, 4);
    buf3[0] := 1;
    fStream.WriteBuffer(buf3, 4);
    fStream.WriteBuffer(p^, dwSize);
  finally
    fStream.Free;
  end;

end;

procedure TDmEntrance.SetDmMikkoads(aDm: TDmMikkoAds);
begin
  FDmMikkoAds := aDm;
  with AdsQueryDc162 do
  begin
    DataBaseName := 'FDmMikkoAds.AdsConnection1';
    if Assigned(FDmMikkoAds.AdsConnection1) then
      AdsConnection := FDmMikkoAds.AdsConnection1;
  end;

  // Init other
  AdsQuery1 := CreateAdsQuery('');
  AdsQueryDc167 := CreateAdsQuery('');
  AdsQrSource := CreateAdsQuery('');

  AdsQueryProtocol := TAdsQuery.Create(self);
  with AdsQueryProtocol do
  begin
    SourceTableType := ttAdsADT;
    AdsConnection := FDmMikkoAds.AdsConnection1;
    DataBaseName := 'FDmMikkoads.AdsConnection1';
    SQL.Clear;
    SQL.Add(' INSERT INTO hardprot\entrance_protocol (kodkli,tm,entranc) ');
    SQL.Add(' VALUES (:kodkli,:tm,:entranc) ');
  end;
  AdsQueryProtocol.AdsConnection := FDmMikkoAds.AdsConnection1;

  AdsQueryClearProtocol := TAdsQuery.Create(self);
  with AdsQueryClearProtocol do
  begin
    SourceTableType := ttAdsADT;
    AdsConnection := FDmMikkoAds.AdsConnection1;
    DataBaseName := 'FDmMikkoads.AdsConnection1';
    SQL.Clear;
    SQL.Add(' DELETE FROM  hardprot\entrance_protocol WHERE tm<:tm AND entranc=:entranc ');
  end;
  AdsQueryProtocol.AdsConnection := FDmMikkoAds.AdsConnection1;
  AdsQueryClearProtocol.AdsConnection := FDmMikkoAds.AdsConnection1;

end;

procedure TDmEntrance.SetFilter(aIndex: Integer);
begin
  case aIndex of
    0, -1:
      FilterOnDay(1);
    1:
      FilterOnDay(31);
    2:
      FilterOnToDay;
  end;
end;

procedure TDmEntrance.UnRegistrationUser;
begin
  with AdsQrSource do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' UPDATE task\dc000167 set isfinger=0');
    SQL.Add(' WHERE priznak=1316 AND sotrud=:sotrud');
    ParamByName('sotrud').AsInteger := AdsQueryDc167.FieldByName('sotrud').AsInteger;
    ExecSQL;
  end;

end;

function TDmEntrance.ValidHoliday(aKodSotrud: Integer): Boolean;
begin
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT d185.* From task\dc000185 d185 ');
    SQL.Add('WHERE d185.kodkli=' + IntToStr(aKodSotrud));
    SQL.Add(' AND d185.priznak=1351 AND d185.p_date_s<=:data AND d185.p_date_f>= :data');
    ParamByName('data').AsDateTime := Now;
    Open;
    Result := IsEmpty;
    Close;
  end;

end;

function TDmEntrance.ValidOmk(aKodSotrud: Integer): Boolean;
begin
  Result := True;
end;

procedure TDmEntrance.WriteProtocol(kodkli: Integer);
begin
  with AdsQueryProtocol do
  begin
    Active := False;
    ParamByName('kodkli').AsInteger := kodkli;
    ParamByName('tm').AsDateTime := Now;
    ParamByName('entranc').AsInteger := kodEntrance;
    ExecSQL;
  end;
end;

function TDmEntrance.ValidBarcode(pBarcode: PAnsiChar): Boolean;
var
  aBuf: array [0 .. 12] of AnsiChar;
begin
  FillChar(aBuf, 13, #0);
  StrLCopy(aBuf, pBarcode, 12);
  Result := (GetControlOrder(aBuf) = pBarcode[12]);
end;

function TDmEntrance.ValidGraphic(aKodSotrud: Integer): boolean;
begin
  Result := false;
  with AdsQuery1 do
  begin
    // Проверка на свободный график
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT kodkli From task\dc000162 dc162 ');
    SQL.Add('WHERE dc162.kodkli=' + IntToStr(aKodSotrud));
    SQL.Add(' AND dc162.priznak= ' + IntToStr(PRIZNAK_FREEGR));
    Open;
    if not IsEmpty then
    begin
      Result := true;
      Exit;
    end;

    // 3. проверка на график
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT dc164.kodkli, dc164.p_time_f From task\dc000164 dc164 ');
    SQL.Add('WHERE dc164.kodkli=' + IntToStr(aKodSotrud));
    SQL.Add(' AND dc164.priznak=1311 AND dc164.data=:data ');
    ParamByName('data').AsDateTime := Now;
    Open;
    Result :=  not IsEmpty;
  end;

end;

function TDmEntrance.GetGrTimeOut(aKodSotrud: Integer): double;
begin
  Result := 0;
  with AdsQuery1 do
  begin
    // Проверка на свободный график
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT kodkli From task\dc000162 dc162 ');
    SQL.Add('WHERE dc162.kodkli=' + IntToStr(aKodSotrud));
    SQL.Add(' AND dc162.priznak= ' + IntToStr(PRIZNAK_FREEGR));
    Open;
    if not IsEmpty then
    begin
      Result := 1;
      Exit;
    end;

    // 3. проверка на график
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT dc164.kodkli, dc164.p_time_f From task\dc000164 dc164 ');
    SQL.Add('WHERE dc164.kodkli=' + IntToStr(aKodSotrud));
    SQL.Add(' AND dc164.priznak=1311 AND dc164.data=:data ');
    ParamByName('data').AsDateTime := Now;
    Open;
    if not IsEmpty then
      Result := FieldByname('p_time_f').AsFloat;
  end;

end;

function TDmEntrance.ValidGroup(aKodKli: Integer): Boolean;
begin
  with AdsQuery1 do
  begin
    // Проверка на свободный график
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT kodg From client ');
    SQL.Add('WHERE kodkli=' + IntToStr(aKodKli));
    SQL.Add(' AND kodg IN ( SELECT kodg FROM GRUPPA WHERE kodmother=84147)'); // Сотрудники
    Open;
    if not IsEmpty then
    begin
      Result := True;
    end
    else
      Result := False;
    Close;
  end;

end;

end.
