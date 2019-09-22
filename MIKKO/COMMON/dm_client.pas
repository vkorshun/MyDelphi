unit dm_client;

interface

uses
  SysUtils, Classes, DB, adsdata, adsfunc, adstable, adscnnct, doc.variablelist,
  Dm_mikkoads,
  DateVk, Dialogs, Variants, xbase_utils;

const
  // типы параметров
  PARTYP_SUM = -1; // сумма
  PARTYP_N = 0; // число
  PARTYP_C = 1; // строка
  PARTYP_D = 2; // дата
  PARTYP_L = 3; // логика
  PARTYP_S = 4; // счет
  PARTYP_V = 5; // валюта
  PARTYP_OK = 6; // объект колич. учета
  PARTYP_OA = 7; // объект анал. учета
  PARTYP_P = 8; // тип прейскуранта
  PARTYP_PR = 9; // тип цены
  PARTYP_NUM = 10; // тип автономер
  PARTYP_GK = 11; // группа объектов колич. учета
  PARTYP_GA = 12; // группа объектов анал. учета
  PARTYP_PIC = 13; // файл изображения

  ACT_ADDOAU = 25;
  ACT_EDITOAU = 7;
  ACT_DELOAU = 18;

  { /* to-do
     Add sinchro
         */ }
type
  TDocSynchro = class(TObject)
  private
    FDmMikkoAds: TDmMikkoAds;
    FVarList: TDocVariableList;
    FParList: TIntList;
    FFieldList: TStringList;
    FReg: Integer;
    FPriznak: Integer;
    kodkli_field: string;
    kodg_field: String;
    name_field: String;
    ediz_field: String;
    AdsQr: TAdsQuery;
  public
    function InitOnKodg(akodg: Integer): Boolean;
    constructor Create(aDm: TDmMikkoAds);
    destructor Destroy; override;
    procedure WriteChanges(aClientVarList:TDocVariableList);
    property VarList: TDocVariableList read FVarList;
  end;

  TDmClient = class(TDataModule)
    AdsQuery1: TAdsQuery;
    AdsQuery2: TAdsQuery;
    AdsQueryUpdateParam: TAdsQuery;
    AdsQueryInsertParam: TAdsQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FDmMikkoAds: TDmMikkoAds;
    ListComment: TStringList;
    ListChanged: TStringList;
    FDocSynchro: TDocSynchro;
    function GetProtocolComment(aVarList: TDocVariableList;
      bInsert: Boolean): String;
    procedure ReadParamList(aVarList: TDocVariableList; akodkli, akodg: Integer;
      bNew: Boolean);
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    procedure Prepare(aDm: TDmMikkoAds);
    procedure PrepareVarList(aVarList: TDocVariableList;
      akodkli, akodg: Integer; bNew: Boolean);
    procedure CalcVarList213OnClient(aVarListClient,
      aVarListDoc: TDocVariableList);
    /// <summary>  Конвертируем под нужное значение <summary/>
    function CheckParamValue(aKodpar: Integer; aValue: Variant): Variant;
    function GetAnalitPar(aTypPar: Integer): Integer;
    /// <summary>  Возвращает значение с учетом типа параметра <summary/>
    function GetParamValueFromVarList(aVarListClient: TDocVariableList;
      aIndex: Integer): Variant;
    function GetObjectByParam(aKodpar, aValue: Integer): Integer;
    function GetTypPar(aKodParobj: Integer): Integer;
    function EditClient(aVarList: TDocVariableList; bNew: Boolean): Boolean;
    procedure LockClient(akodkli: Integer);
    procedure UpdateParam(aKodpar, aKodObj: Integer; aValue: TDocVariable;
      bInsert: Boolean);
  end;

var
  DmClient: TDmClient;

implementation

{$R *.dfm}
{ TDmClient }

function TDmClient.CheckParamValue(aKodpar: Integer; aValue: Variant): Variant;
// var nType:Integer;
begin
  Result := GetTypPar(aKodpar);
  { case nType of
    PARTYP_OK,PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
    Result := aVarList.AddWithInit(vname,FieldByName('objvalue').AsInteger)
    else
    aVarList.AddWithInit(vname,FieldByName('value').AsString);
    end;

    end; }
end;

constructor TDmClient.Create(aOwner: TComponent);
begin
  Inherited;
  if aOwner is TDmMikkoAds then
    Prepare(TDmMikkoAds(aOwner));
end;

procedure TDmClient.DataModuleCreate(Sender: TObject);
begin
  ListComment := TStringList.Create;
  ListChanged := TStringList.Create;
  FDocSynchro := TDocSynchro.Create(FDmMikkoAds);
end;

procedure TDmClient.DataModuleDestroy(Sender: TObject);
begin
  Inherited;
  ListComment.Free;
  ListChanged.Free;
  FreeAndNil(FDocSynchro);
end;

function TDmClient.EditClient(aVarList: TDocVariableList;
  bNew: Boolean): Boolean;
var
  kodkli: Integer;
  kodg: Integer;
  kodpar: Integer;
  // ListProtocol: TStringList;
  i: Integer;
begin
  // Result := False;
  try
    begin
      kodkli := aVarList.VarByName('kodkli').Value;
      // kodg   := aVarList.VarByName('kodg').Value;
      // BeginTransaction;
      if not bNew and (kodkli > 0) then
      begin
        LockClient(kodkli);
        ListChanged.Clear;
        // ==== Update Client ======
        with AdsQuery1 do
        begin
          if (aVarList.VarByName('name').Value <> aVarList.VarByName('name')
            .InitValue) or (aVarList.VarByName('ediz').Value <>
            aVarList.VarByName('ediz').InitValue) then
          begin
            Active := False;
            SQL.Clear;

            SQL.Add(' UPDATE client SET name=:name, ediz=:ediz WHERE kodkli=:kodkli');
            ParamByName('name').AsString := aVarList.VarByName('name').AsString;
            ParamByName('ediz').AsString := aVarList.VarByName('ediz').AsString;
            ParamByName('kodkli').AsInteger := kodkli;
            ListChanged.Add('name');
            ExecSQL;
          end;
          // ==== Update Params
          for i := 0 to aVarList.Count - 1 do
          begin
            if (aVarList[i].Value <> aVarList[i].InitValue) then
              if pos('p_', aVarList[i].name) = 1 then
              begin
                ListChanged.Add(aVarList[i].name);
                kodpar := StrToInt(Copy(aVarList[i].name, 3, 11));
                UpdateParam(kodpar, kodkli, aVarList[i], False);
              end;
          end;
          FDmMikkoAds.WriteProtocol(ACT_EDITOAU, 'Коррекция ОАУ ',
            GetProtocolComment(aVarList, False), kodkli, 0, 0, 0);

          if FDocSynchro.InitOnKodg(aVarList.VarByName('kodg').AsInteger) then
            FDocSynchro.WriteChanges(aVarList);

        end;
      end
      else
      // ==== Insert Client ======
      begin
        with AdsQuery1 do
        begin
          Active := False;
          SQL.Clear;
          SQL.Add(' INSERT INTO client  (kodg,kodkli,name,ediz)');
          SQL.Add(' VALUES(:kodg,:kodkli,:name,:ediz)');
          if kodkli = 0 then
            kodkli := FDmMikkoAds.NewNum('INFO');
          kodg := aVarList.VarByName('kodg').AsInteger;
          ParamByName('kodg').AsInteger := kodg;
          ParamByName('kodkli').AsInteger := kodkli;
          ParamByName('name').AsString := aVarList.ValueByName['name'];
          ParamByName('name').AsString := aVarList.VarByName('name').AsString;
          ExecSQL;
          aVarList.VarByName('kodkli').AsInteger := kodkli;
        end;
        // ==== Insert Params
        for i := 0 to aVarList.Count - 1 do
        begin
          // if (aVarList[i].value<>aVarList[i].InitValue) then
          if pos('p_', aVarList[i].name) = 1 then
          begin
            // ListChanged.Add(aVarList[i].name);
            kodpar := StrToInt(Copy(aVarList[i].name, 3, 11));
            try
              UpdateParam(kodpar, kodkli, aVarList[i], True);
            except
              ShowMessage(' kodpar - ' + IntToStr(kodpar));
              Raise;
            end;
          end;
        end;
        FDmMikkoAds.WriteProtocol(ACT_ADDOAU, 'Добавление ОАУ ',
          GetProtocolComment(aVarList, True), kodkli, 0, 0, 0);
      end;
      Result := True;
      // AdsConnection1.Commit;
    end;
  except
    // if AdsConnection1.TransactionActive then
    // AdsConnection1.Rollback;
    Raise;
  end;
end;

function TDmClient.GetAnalitPar(aTypPar: Integer): Integer;
begin
  case aTypPar of
    PARTYP_OK, PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
      Result := 1;
  else
    Result := 0;
  end;

end;

function TDmClient.GetObjectByParam(aKodpar, aValue: Integer): Integer;
begin
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT p.kodobj FROM par_obj\par_obj p   ');
    // SQL.Add(' LEFT JOIN client c ON c.kodkli=p.kodobj ');
    SQL.Add(' WHERE kodparobj=:kodparobj AND p.objvalue=:objvalue');
    ParamByName('kodparobj').AsInteger := aKodpar;
    // ParamByName('kodg').AsInteger := aKodg;
    ParamByName('objvalue').AsInteger := aValue;
    Open;
    if IsEmpty then
      Result := 0
    else
      Result := FieldByName('kodobj').AsInteger;

  end;
end;

function TDmClient.GetParamValueFromVarList(aVarListClient: TDocVariableList;
  aIndex: Integer): Variant;
var
  nType: Integer;
  kodpar: Integer;
begin
  if aIndex < 0 then
  begin
    Result := null;
    exit;
  end;
  kodpar := StrToInt(Copy(aVarListClient[aIndex].name, 3, 11));
  nType := GetTypPar(kodpar);
  case nType of
    PARTYP_OK, PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
      Result := aVarListClient[aIndex].AsInteger;
    PARTYP_N:
      Result := aVarListClient[aIndex].AsExtended;
    PARTYP_C:
      Result := aVarListClient[aIndex].AsString;
    PARTYP_L:
      begin
        Result := aVarListClient[aIndex].AsInteger;
        if Result = 0 then
          Result := 2;
      end;
    PARTYP_D:
      begin
        if aVarListClient[aIndex].AsDateTime = 0 then
          Result := null
        else
          Result := aVarListClient[aIndex].AsDateTime;
      end;
  else
    Result := aVarListClient[aIndex].Value;
  end;

end;

function TDmClient.GetProtocolComment(aVarList: TDocVariableList;
  bInsert: Boolean): String;
var
  i: Integer;
  cLabel: String;
  kodpar: Integer;
begin
  if bInsert then
  begin
    ListComment.Clear;
    ListComment.Add('Добавление ОАУ [' + aVarList.ValueByName['name'] + ']')
  end
  else
  begin
    ListComment.Clear;
    ListComment.Add('Коррекция ОАУ [' + aVarList.ValueByName['name'] + ']');

    for i := 0 to ListChanged.Count - 1 do
    begin
      if ListChanged[i] = 'name' then
        cLabel := '[Наименование]'
      else if ListChanged[i] = 'ediz' then
        cLabel := '[Ед. изм.]'
      else
      begin
        if pos('p_', ListChanged[i]) = 1 then
        begin
          kodpar := StrToInt(Copy(ListChanged[i], 3, 10));
          cLabel := FDmMikkoAds.QueryValue
            (' SELECT name FROM par_obj\paramobj WHERE kodparobj=' +
            IntToStr(kodpar));
          cLabel := '[' + cLabel + '(' + IntToStr(kodpar) + ')]';
        end
        else
          cLabel := '[Undef]'
      end;
      ListComment.Add(cLabel);
      ListComment.Add(' Старое значение - ' + aVarList.VarByName(ListChanged[i])
        .VarInitValue.ToString);
      ListComment.Add(' Новое значение - ' + aVarList.VarByName(ListChanged[i])
        .VarValue.ToString);
    end;
  end;
  Result := ListComment.Text;
end;

function TDmClient.GetTypPar(aKodParobj: Integer): Integer;
begin
  Result := FDmMikkoAds.QueryValue
    ('SELECT typ FROM par_obj\paramobj WHERE kodparobj=' +
    IntToStr(aKodParobj));
end;

procedure TDmClient.LockClient(akodkli: Integer);
begin
  with FDmMikkoAds.AdsConnection1 do
  begin
    if TransactionActive then
      with AdsQuery1 do
      begin
        Active := False;
        SQL.Clear;
        SQL.Add(' UPDATE client SET kodkli=kodkli WHERE kodkli=' +
          IntToStr(akodkli));
        ExecSQL;
      end
    else
      raise Exception.Create('Transaction is not active!');
  end;
end;

procedure TDmClient.Prepare(aDm: TDmMikkoAds);
var
  i: Integer;
begin
  if not Assigned(aDm) then
    exit;
  FDmMikkoAds := aDm;
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TAdsQuery then
      with TAdsQuery(Components[i]) do
      begin
        AdsConnection := aDm.AdsConnection1;
        DatabaseName := aDm.name + '.AdsConnection1';
      end;
  end;
  // ListComment := TstringList.Create;
  // ListChanged  := TStringList.Create;

  with AdsQueryUpdateParam do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' UPDATE par_obj\par_obj SET value=:value , objvalue=:objvalue');
    SQL.Add(' WHERE kodparobj=:kodparobj and kodobj=:kodobj');
  end;
  with AdsQueryInsertParam do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' INSERT INTO par_obj\par_obj (kodobj,kodparobj,value,objvalue)');
    SQL.Add(' VALUES(:kodobj,:kodparobj,:value,:objvalue)');
  end;

end;

procedure TDmClient.PrepareVarList(aVarList: TDocVariableList;
  akodkli, akodg: Integer; bNew: Boolean);
begin
  aVarList.Clear;
  if not bNew and (akodkli > 0) then
  begin
    with AdsQuery1 do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add(' SELECT * FROM client WHERE kodkli=' + IntToStr(akodkli));
      Open;
      if not IsEmpty then
      begin
        aVarList.AddWithInit('kodg', FieldByName('kodg').AsInteger);
        aVarList.AddWithInit('kodkli', FieldByName('kodkli').AsInteger);
        aVarList.AddWithInit('name', FieldByName('name').AsString);
        aVarList.AddWithInit('ediz', FieldByName('ediz').AsString);
        ReadParamList(aVarList, akodkli, akodg, bNew);
      end
      else
      begin
        aVarList.Add('kodg', akodg);
        aVarList.Add('kodkli', akodkli);
        aVarList.Add('name', '');
        aVarList.Add('ediz', '');
        ReadParamList(aVarList, akodkli, akodg, bNew);
      end;
    end;
  end
  else
  begin
    if akodg = 0 then
      raise Exception.Create('Invalid kodg');
    aVarList.Add('kodg', akodg);
    aVarList.Add('kodkli', akodkli);
    aVarList.Add('name', '');
    aVarList.Add('ediz', '');
    ReadParamList(aVarList, akodkli, akodg, bNew);
  end;
end;

procedure TDmClient.ReadParamList(aVarList: TDocVariableList;
  akodkli, akodg: Integer; bNew: Boolean);
var
  vname: String;
  kodpar: Integer;
  nType: Integer;
begin
  with AdsQuery1 do
  begin
    if (akodkli > 0) and not(bNew) then
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('SELECT * FROM par_obj\par_obj WHERE kodobj=:kodobj');
      ParamByName('kodobj').AsInteger := akodkli;
      Open;
      while not eof do
      begin
        kodpar := FieldByName('kodparobj').AsInteger;
        vname := 'p_' + IntToStr(kodpar);
        nType := GetTypPar(kodpar);
        case nType of
          PARTYP_OK, PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
            aVarList.AddWithInit(vname, FieldByName('objvalue').AsInteger);
          PARTYP_N:
            aVarList.Add(vname, XbaseStrToFloat(FieldByName('value').AsString));
        else
          aVarList.AddWithInit(vname, FieldByName('value').Value);
        end;
        Next;
      end;
    end
    else
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('SELECT * FROM par_obj\gr_par WHERE kodg=:kodg');
      ParamByName('kodg').AsInteger := akodg;
      Open;
      while not eof do
      begin
        kodpar := FieldByName('kodparobj').AsInteger;
        vname := 'p_' + IntToStr(kodpar);
        nType := GetTypPar(kodpar);
        case nType of
          PARTYP_OK, PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
            aVarList.Add(vname, 0);
        else
          aVarList.Add(vname, '');
        end;
        Next;
      end;

    end;
  end;
end;

procedure TDmClient.CalcVarList213OnClient(aVarListClient,
  aVarListDoc: TDocVariableList);
var
  // kodpar: Integer;
  c_par: String;
  pValue: Variant;
  // nType: Integer;
  nIndex: Integer;
begin
  with AdsQuery2 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT field_name, code FROM TASK\regstru ');
    SQL.Add(' WHERE code is not null and kodreg=213');
    Open;
    while not eof do
    begin
      c_par := 'p_' + FieldByName('code').AsString;
      nIndex := aVarListClient.IndexOf(c_par);
      if nIndex > -1 then
      begin
        // kodpar := StrToInt(FieldByName('code').AsString);
        try
          pValue := DmClient.GetParamValueFromVarList(aVarListClient, nIndex);
          aVarListDoc.VarByName(FieldByName('field_name').AsString).Value
            := pValue;
        except
          ShowMessage(c_par);
          raise;
        end;
      end;
      Next;
    end;

  end;
end;

procedure TDmClient.UpdateParam(aKodpar, aKodObj: Integer; aValue: TDocVariable;
  bInsert: Boolean);
var
  nTypPar: Integer;
  cValue: String;
  // oQr: TAdsQuery;
  nObjValue: Integer;
begin
  nTypPar := GetTypPar(aKodpar);
  nObjValue := 0;
  case nTypPar of
    PARTYP_SUM, // сумма
    PARTYP_N: // число
      cValue := XbaseFloatToStr(aValue.AsExtended);
    PARTYP_C: // строка
      cValue := aValue.AsString;
    PARTYP_D: // дата
      if aValue.AsDateTime <> 0 then
        cValue := aValue.AsString
      else
        cValue := '  .  .  ';
    PARTYP_L: // логика
      if aValue.AsBoolean then
        cValue := '1'
      else
        cValue := aValue.AsString;
    PARTYP_S: // счет
      begin
        cValue := 'S->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;
    PARTYP_V: // валюта
      begin
        cValue := 'V->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;
    PARTYP_OK, // объект колич. учета
    PARTYP_OA: // объект анал. учета
      begin
        cValue := 'O->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;
    PARTYP_P: // тип прейскуранта
      begin
        cValue := 'P->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;
    PARTYP_PR: // тип цены
      begin
        cValue := 'C->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;
    PARTYP_NUM: // тип автономер
      cValue := aValue.AsString;

    PARTYP_GK, // группа объектов колич. учета
    PARTYP_GA: // группа объектов анал. учета
      begin
        cValue := 'G->' + Str11(aValue.AsInteger);
        nObjValue := aValue.AsInteger;
      end;

    PARTYP_PIC: // файл изображения
      cValue := aValue.AsString;

  end;
  if bInsert then
    with AdsQueryInsertParam do
    begin
      ParamByName('kodparobj').AsInteger := aKodpar;
      ParamByName('kodobj').AsInteger := aKodObj;
      ParamByName('value').AsString := cValue;
      ParamByName('objvalue').AsInteger := nObjValue;
      ExecSQL;
    end
  else
    with AdsQueryUpdateParam do
    begin
      ParamByName('kodparobj').AsInteger := aKodpar;
      ParamByName('kodobj').AsInteger := aKodObj;
      ParamByName('value').AsString := cValue;
      ParamByName('objvalue').AsInteger := nObjValue;
      ExecSQL;
    end;

end;

{ TDocSynchro }

constructor TDocSynchro.Create(aDm: TDmMikkoAds);
begin
  Inherited Create;
  FDmMikkoAds := aDm;
  FVarList := TDocVariableList.Create(FDmMikkoAds);
  AdsQr := TAdsQuery.Create(FDmMikkoAds);
  FDmMikkoAds.LinckQuery(AdsQr);
  FParList := TIntList.Create;
  FFieldList := TStringList.Create
end;

destructor TDocSynchro.Destroy;
begin
  FreeAndNil(FVarList);
  FreeAndNil(AdsQr);
  Inherited;
end;

function TDocSynchro.InitOnKodg(akodg: Integer): Boolean;
begin
  Result := true;
  with AdsQr do
  begin
    // === Header ====
    Active := False;
    SQL.Add(' SELECT * FROM gruppa WHERE kodg=' + IntToStr(akodg));
    Active := True;
    if not eof and (FieldByName('kodreg').AsInteger > 0) then
    begin
      FParList.Clear;
      FFieldList.Clear;
      kodkli_field := FieldByName('field_code').AsString;
      kodg_field := FieldByName('field_kodg').AsString;
      FReg := FieldByName('kodreg').AsInteger;
      FPriznak := FieldByName('koddoc').AsInteger;
      name_field := FieldByName('field_name').AsString;
      ediz_field := FieldByName('field_ediz').AsString;
    end
    else
    begin
      Result := False;
      Exit;
    end;



    // === Body ====
    Active := False;
    SQL.Add(' SELECT * FROM regstru WHERE kodreg=' + IntToStr(FReg)+' AND code>0 ');
    Active := True;
    while not Eof do
    begin
      FParList.Add(FieldByName('kode').AsInteger);
      FFieldList.Add(FieldByName('field_name').AsString);
      Next;
    end;
  end;
end;

procedure TDocSynchro.WriteChanges(aClientVarList:TDocVariableList);
var koddoc: integer;
    i: Integer;
    cvar: String;
begin
  koddoc := CoalEsce(FDmMikkoAds.QueryValue(' SELECT koddoc FROM task\dc'+StrZero(FReg,6)+' WHERE priznak='
    +IntToStr(FPriznak)+ ' AND '+kodkli_field+'='+aClientVarList.VarByName('kodkli').AsString),0);

  if koddoc=0 then
    Exit;

  FDmMikkoAds.InitDocVariableList( 'task\dc'+StrZero(FReg,6),FVarList);
  if FDmMikkoAds.LockDoc('task\dc'+StrZero(FReg,6),koddoc) then
  begin
    FDmMikkoAds.CalcVariablesOnDoc('task\dc'+StrZero(FReg,6),koddoc,FVarList);
    //Write Header
    FvarList.VarByName(name_field).Value := aClientVarList.VarByName('name').Value;
    if length(trim(ediz_field))>0 then
      FvarList.VarByName(ediz_field).Value := aClientVarList.VarByName('ediz').Value;

    // Write Par
    for I := 0 to FParList.Count-1 do
    begin
      cvar := 'p_'+IntToStr(FParList[i]);
      if aClientvarList.IndexOf(cvar)>-1 then
        FvarList.VarByName(FFieldList[i]).Value := aClientVarList.VarByName(cvar).Value;
    end;
    FDmMikkoAds.EditDoc(False,koddoc,Freg,FPriznak,fVarList,false,'');
  end;
end;

end.
