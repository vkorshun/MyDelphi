unit dm_mikkoads;

interface

uses
  SysUtils, Classes, Ace, adsfunc, adstable, adsset, adscnnct, DB, adsdata,
  IniFiles, Forms,Dialogs, DateVk, Controls, Windows,  mikko_consts, doc.variablelist,
  fmVkDocdialog, variants,Generics.Collections, DbClient, RtcInfo,RtcDb;


const
  KODG_CLIENTSETIK = 27057;
  KODG_ADDOF       = 100900;

  ACT_DELDOC       = 50;
  ACT_DELSODDOC    = 51;
  ACT_ADDDOC       = 52;
  ACT_ADDSODDOC    = 53;
  ACT_EDITDOC      = 54;
  ACT_EDITSODDOC   = 55;

  DATA_DELTA       = 693990;
  QS               = CHR(ORD(''''));

  LEN_BUFFER       = 13;

type
  RUserInfo = Record
    cUserName: String;
    cAlias: String;
    longname: String;
    cPassword: String;
    nUserAliasKodkli: Integer;
    nTaskCode: Integer;
  End;
  TExternalEvent = procedure (Sender: TObject; aId:Integer) of object;

{  TDmMikkoAds = class;
  PDmList = ^RDmList;
  RDmList = record
    handle: THandle;
    dm: TDmMikkoAds;
  end;}

  TDmMikkoAds = class(TDataModule)
    AdsQueryNewNum: TAdsQuery;
    AdsConNewNum: TAdsConnection;
    AdsConnection1: TAdsConnection;
    AdsTableParoll: TAdsTable;
    AdsQueryProtocol: TAdsQuery;
    AdsQuery2: TAdsQuery;
    AdsQueryDoc: TAdsQuery;
    AdsQuery1: TAdsQuery;
    AdsTableLockOper: TAdsTable;
    TbKurs: TAdsTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    sFind: String;
    FDirMail: String;
    FDmClient: TDataModule;
    Ffasserver: AnsiString;
    Ffasserver2: AnsiString;
    FOnExternalEvent: TExternalEvent;
    ///<summary> List changed fields name </summary>
    UpdateList: TStringList;
    function GetProtocolComment(aFields:TDocVariableList;bInsert:Boolean):String;
    procedure InternalSetConnect;
    procedure ValidUser(Sender:TObject; var CanClose:Boolean);
    procedure SetOnExternalEvent(const Value: TExternalEvent);
  public
    { Public declarations }
    class var AdsSetting1:TAdsSettings;
    //class var gDmList: TList;
    pUserInfo: RUserInfo;
    function AddClient(aKodG: Integer; aName: string): Integer;
   ///<summary> Инициализация значений VarList по (DC, kodddoc)
   /// по соответсвующим полям
   ///</summary>
    procedure CalcVariablesOnDoc(const aTableName:String;aKodDoc:Integer; aVarList:TDocVariableList);
   ///<summary> Инициализация массивов VarList по DataSet
   /// по соответсвующим полям
   ///</summary>
    procedure CalcVariablesOnDs(DataSet:TDataSet; aVarList:TDocVariableList);overload;
    procedure CalcVariablesOnDs(DataSet:TRtcDataSetChanges; aVarList:TDocVariableList);overload;

    ///<summary> Удаление временной SQL таблици - если она существует и не занята </summary>
    procedure DropTempSqlTable(const aName:String);

   ///<summary> Обновляем массив VarList по DataSet
   /// по соответсвующим полям
   ///</summary>
    procedure UpdateVariablesOnDs(DataSet:TDataSet; aVarList:TDocVariableList);
   ///<summary> Обновляем массив VarList по DataSet
   /// по соответсвующим полям c учетом только изменившихся полей (DeltaDs)
   ///</summary>
    procedure UpdateVariablesOnDeltaDs(DataSet:TDataSet; aVarList:TDocVariableList);overload;
    procedure UpdateVariablesOnDeltaDs(DataSet:TRtcDataSetChanges; aVarList:TDocVariableList);overload;
   ///<summary> Копируем значения Source в Destination ///</summary>
    procedure CopyVarList(aSource,aDestination:TDocVariableList);
    procedure DeleteDoc(aKodReg,aKodPriznak,aKodDoc:Integer;aRowId:String);
    procedure DoExternalEvent(Sender:TObject; aId:Integer);
    function  DtToXbase(aD:tDateTime):TDateTime;
    function  DtFromXbase(aD:tDateTime):TDateTime;

    procedure EditClient(aKodKli:Integer;aName:string);
    procedure EditDoc(bInsert:Boolean;aKodDoc,aKodReg,aKodPriznak:Integer;aFields:TDocVariableList; bSod:Boolean; aRowId:String);
    procedure Execute(const FileName: string);
   ///<summary> Создание  массива VarList без значений</summary>
    procedure InitDocVariableList(const aTableName:String; aVarList:TDocVariableList);
   ///<summary> Создание и инициализация массива VarList по DS </summary>
   ///<summary> bInit - заполнить InitValue тек. значениями</summary>
    procedure InitDocVariableListOnDs(const aDs:TDataSet; aVarList:TDocVariableList; bInit:Boolean=True);
    procedure Find(ds:TDataSet;bFirst:Boolean);
    procedure LinckQuery(var aQuery:TadsQuery);

   ///<summary> Возвращает герм. дату в формате dd. Month yyyy</summary>
    function GetGermanFulldate(aDate: TDateTime):String;
    function  GetObjectName(aKod:Integer):String;
//    function  GetMaxDate: TDateTime;
//    function  GetMinDate: TDateTime;
//    function  GetControlOrder(cCode: PAnsiChar): AnsiChar;
    procedure SetConnect(const cDirCommon, cUserName:String;nUserAliasKodkli:Integer; bNew:Boolean = False);
//    procedure LockParoll;
    procedure WriteProtocol(aType:Integer;const aAction:String;const aComment:String;
     aKod:Integer; aKodreg:Integer; akodPriznak:Integer; aKodView:Integer);
//    procedure SetBarCode(cCode:PAnsiChar);
    procedure WriteVarListToDs(aVarList:TDocVariableList; aDs:TDataSet);

    function  LockDoc(const aAlias:String; aKodDoc:Integer):Boolean;
    function  LockOper(aKodOper:Integer):Boolean;
    function  OperIsLocked(aKodOper:Integer):Boolean;
    function  UnLockOper(aKodOper:Integer):Boolean;

    function  QueryValue(aSql:string):Variant;
    function SeekKurs(aKodV:Integer; adata: tDateTime):Double;

    function ServerLogin(const auserName,aPassword:String):Boolean;
    function JavaLogin(const AUserName,APassword:String;var AError: String):Boolean;
    function Login: Boolean;
    function NewNum(const pName: String): Integer;
    function SpCrypt(const aString,aKeyString,aParoll:AnsiString): TBytes;
    function SpOba(aKodPar, aKodObj:Integer):variant;
    Property DirMail:string Read FDirMail;
    property fasserver:AnsiString read ffasserver;
    property fasserver2:AnsiString read ffasserver2;
    property DmClient:TDataModule read FDmClient;
    property OnExternalEvent : TExternalEvent read FOnExternalEvent write SetOnExternalEvent;
    class function GetDmMikkoAds(aOwner:TComponent):TDmMikkoAds;
    //class function GetDmMikkoAdsByHandle(aHandle:THandle):TDmMikkoAds;
  end;

var
  DmMikkoAds1: TDmMikkoAds;
  DmList : TObjectList<TDmMikkoAds>;
  AppFilename: String;

implementation

{$R *.dfm}
uses fm_login,  ShellAPI, dm_client, monitor;

function WinToDos(S: AnsiString): AnsiString;
begin

  SetLength(Result,Length(S));
  S:=S+#0;
  if not CharToOemA(PAnsiChar(S),PAnsiChar(Result)) then SetLength(Result,0);
end;

function DosToWin(S: AnsiString): AnsiString;
begin
  SetLength(Result,Length(S));
  S:=S+#0;
  if not OemToCharA(PAnsiChar(S),PAnsiChar(Result)) then SetLength(Result,0);
end;


{ TDmMikkoAds }

function TDmMikkoAds.AddClient(aKodG: Integer; aName: string): Integer;
begin
  Result := NewNum('INFO');
  if Result=0 then
    Raise Exception.Create(msg_nullid);
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' INSERT INTO client (kodg,kodkli,name)');
    SQL.Add(' VALUES(:kodg,:kodkli,:name)');
    ParamByName('kodg').AsInteger   := aKodG;
    ParamByName('kodkli').AsInteger := Result;
    ParamByName('name').AsString    := aName;
    ExecSql;
  end;

end;

procedure TDmMikkoAds.CalcVariablesOnDoc(const aTableName: String;
  aKodDoc: Integer; aVarList: TDocVariableList);
begin
  with AdsQuery2 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT * FROM '+aTableName);
    SQL.Add(' WHERE koddoc='+IntToStr(aKodDoc));
    Open;
    if IsEmpty then
      InitDocVariableList(aTableName,aVarList)
    else
      CalcVariablesOnDs(AdsQuery2,aVarList);
  end;
end;

procedure TDmMikkoAds.CalcVariablesOnDs(DataSet: TRtcDataSetChanges; aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to NewRow.FieldCount - 1 do
    begin
      ind := aVarList.IndexOf(NewRow.FieldName[i]) ;
      if ind >-1 then
      begin
        case NewRow.FieldType[NewRow.FieldName[i]] of
          ft_FMTBcd:    aVarList.Items[ind].InitValue := NewRow.FieldByName(NewRow.FieldName[i]).AsFloat;
          ft_Bcd:       aVarList.Items[ind].InitValue := NewRow.FieldByName(NewRow.FieldName[i]).AsInteger;
        else
          try
            aVarList.Items[ind].InitValue := NewRow.FieldByName(NewRow.FieldName[i]).Value;
          except
            {$IFNDEF APP_SERVICE}
            ShowMessage((' error in InitVariable i = '+IntToStr(i)));
            {$ENDIF}
            Raise
          end;
        end;
      end;
    end;
  end;
end;

procedure TDmMikkoAds.CalcVariablesOnDs(DataSet: TDataSet; aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      ind := aVarList.IndexOf(Fields[i].FieldName) ;
      if ind >-1 then
      begin
        case Fields[i].DataType of
          ftFMTBcd:    aVarList.Items[ind].InitValue := Fields[i].AsFloat;
          ftBcd:       aVarList.Items[ind].InitValue := Fields[i].AsInteger;
        else
          try
            aVarList.Items[ind].InitValue := Fields[i].Value;
          except
            {$IFNDEF APP_SERVICE}
            ShowMessage((' error in InitVariable i = '+IntToStr(i)));
            {$ENDIF}
            Raise
          end;
        end;
      end;
    end;
  end;
end;

procedure TDmMikkoAds.CopyVarList(aSource, aDestination: TDocVariableList);
var i,k: Integer;
begin
  for I := 0 to aSource.Count-1 do
  begin
    k := aDestination.IndexOf(aSource.Items[i].name);
    if k>-1 then
      aDestination.Items[k].Value := aSource.Items[i].Value;
  end;
end;

procedure TDmMikkoAds.InternalSetConnect;
var
  fIni: TIniFile;
begin
  if AdsConnection1.IsConnected then
    Exit;

  fini := TIniFile.Create(ChangeFileExt(AppFileName,'.ini'));
  AdsConnection1.ConnectPath := fini.ReadString('SET','DIRCOMMON','');
  AdsConnection1.IsConnected := True;
  FDirMail := fini.ReadString('SET','DIRMAIL','');
  Ffasserver := AnsiString(FIni.ReadString('SET','fasserver',''));
  Ffasserver2 := AnsiString(FIni.ReadString('SET','fasserver2',''));

end;

function TDmMikkoAds.JavaLogin(const AUserName, APassword: String;var AError: String): Boolean;
var
    cCrypt: AnsiString;
    sParoll: String;
    B1,B2: TBytes;
  I: Integer;
begin
  InternalSetConnect;

  pUserInfo.cUserName := AUsername;
  pUserInfo.cPassword := APassword;
  with AdsTableParoll do
  begin
    Active := true;
    if Locate('alias',pUserInfo.cUserName,[loCaseInsensitive]) then
    begin
      B1 := SpCrypt(AnsiString(PADR('vk123',10)),FieldByName('alias').AsAnsiString,'');
      B2 := BytesoF(APassword);
      for I := 1 to length(APassword) do
        B2[I-1] := ORD(APassword[i]);
      cCrypt := AnsiString(B2);
      cCrypt := DosToWin(cCrypt);
      sParoll := (Copy(FieldByName('paroll').AsString,1,10));
      Result := cCrypt=AnsiString(sparoll);
      if not Result then
      begin
        //sParoll := (Copy(FieldByName('paroll').AsAnsiString,1,10));
        //Result := cCrypt=AnsiString(sparoll);
        AError := 'Неправильный пароль';
      end
      else
      begin
        pUserInfo.nUserAliasKodkli := AdsTableParoll.FieldByName('kodkli').AsInteger;
        pUserInfo.cAlias           := AdsTableParoll.FieldByName('alias').AsString;
        pUserInfo.longname         := AdsTableParoll.FieldByName('longname').AsString;
        pUserInfo.nTaskCode        := AdsTableParoll.FieldByName('taskcode').AsInteger;
      end;
    end
    else
      AError := Format('Пользователь %s не найден',[AUserName]);

  end;

end;

procedure TDmMikkoAds.InitDocVariableList(const aTableName: String; aVarList: TDocVariableList);
var i: Integer;
begin
  with AdsQuery2 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT * FROM '+aTableName);
    aVarList.Clear;
    Open;
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[i].FieldName<>'AXS_TPS' then
      begin
        if (FieldDefs[i].DataType=ftString) or (FieldDefs[i].DataType=ftMemo) then
          aVarList.Add(Fields[i].FieldName,'',ftString,True)
        else
          aVarList.Add(Fields[i].FieldName,0,FieldDefs[i].DataType,True);
      end;
    end;
  end;
end;

//==============================================================================
// bInit - нужен когда тип поля ftUnknown и не понятно что присвоить
// InitValue . И работать надо именно с Fields, FieldDefs - не определено
//==============================================================================
procedure TDmMikkoAds.InitDocVariableListOnDs(const aDs: TDataSet;
  aVarList: TDocVariableList; bInit:Boolean = True);
var
  i: Integer;
  defvalue: variant;
begin
  aVarList.Clear;
  with aDs do
  begin
    for I := 0 to FieldCount - 1 do
    begin

      if (Fields[i].DataType=ftString) or (Fields[i].DataType=ftMemo) then
        defvalue := ''
      else
        if (Fields[i].DataType=ftUnknown) then
          defvalue := null
        else
          defvalue := 0;


      aVarList.Add(Fields[i].FieldName,defvalue,Fields[i].DataType,True);
      if bInit then
         aVarList.Items[i].InitValue := Fields[i].Value;
    end;
  end;
end;

procedure TDmMikkoAds.LinckQuery(var aQuery: TadsQuery);
begin
  with AQuery do
  begin
    DatabaseName  := 'AdsConnection1';
    AdsConnection := AdsConnection1;
    AdsTableOptions.AdsCharType := OEM;
    SourceTableType := ttAdsCdx;
  end;

end;

function TDmMikkoAds.LockDoc(const aAlias:String; aKodDoc:Integer): Boolean;
begin
  try
  with AdsQueryDoc do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('UPDATE '+aAlias);
    SQl.Add(' SET koddoc=koddoc WHERE koddoc=:koddoc');
    ParamByName('koddoc').AsInteger := aKodDoc;
    ExecSql;
    Result := True;
  end;
  except
    {$IFNDEF APP_SERVICE}
      Result := False;
      ShowMessage(msg_RecordLocked);
    {$ELSE}
      Raise;
    {$ENDIF}
  end;
end;

function TDmMikkoAds.LockOper(aKodOper:Integer): Boolean;
begin
  Result := False;
  with AdsTableLockOper do
  begin
    if not Active then
      Open;
    if locate('kod',aKodOper,[]) then
    begin
      Result := AdsLockRecord(AdsGetRecordNum);
      if Not Result then
      {$IFNDEF APP_SERVICE}
        ShowMessage(' Ошибка совместного доступа к операции - '+FieldByName('name').AsString)
      {$ELSE}
         Raise Exception.Create(' Ошибка совместного доступа к операции - '+FieldByName('name').AsString);
      {$ENDIF}
    end;
  end;
end;

function TDmMikkoAds.Login: Boolean;
var fm: TFmLogin;
begin
  InternalSetConnect;
//  Result := False;
  fm := TFmLogin.Create(self);
  fm.OnCloseQuery := ValidUser;
  try
    Result := fm.ShowModal= mrOk;
{    begin
      pUserInfo.cUserName := fm.EdUserName;
      pUserInfo.cPassword := fm.EdPassword;
      REsult
    end;}
  finally
    fm.Free;
  end;
end;

function TDmMikkoAds.NewNum(const pName: String): Integer;
var
  // t1: Int64;
  sTableName: String;
begin
  sTableName := 'tools\newnum';
  with AdsConNewNum do
    if not IsConnected then
    begin
      ConnectPath := AdsConnection1.ConnectPath;
      Connect;
    end;

  Result := 0;

  with AdsQueryNewNum do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT sequence FROM ' + sTableName + ' where name=''' +
      (pName) + '''');
    Open;
    if not IsEmpty and (Ace.AdsLockRecord(Handle, 0) = 0) then
    begin
      Refresh;
      Result := FieldByName('sequence').AsInteger + 1;
      Ace.AdsSetLong(Handle, 'sequence', Result);
      Ace.AdsUnlockRecord(Handle, 0);
    end;
  end;

  if Result = 0 then
    Raise (Exception.Create(msg_ErrorNewNum + pName + ' !'));

end;


function TDmMikkoAds.OperIsLocked(aKodOper:Integer): Boolean;
begin
  Result := False;
  with AdsTableLockOper do
  begin
    if not Active then
      Open;
    if locate('kod',aKodOper,[]) then
    begin
      Result := AdsIsRecordLocked(AdsGetRecordNum);
    end;
  end;
end;

function TDmMikkoAds.SeekKurs(aKodV: Integer; adata: tDateTime): Double;
begin
  TbKurs.Active := False;
  TbKurs.Open;
  TbKurs.IndexName := 'kurs';
  TbKurs.AdsSeek(Str11(aKodv)+DTOS(adata),stSoft);
  if TbKurs.FieldByName('data').AsDateTime<> adata then
    TbKurs.MoveBy(-1);
  if TbKurs.FieldByName('kodv').AsInteger= aKodv then
    Result := TbKurs.FieldByName('summa').AsFloat
  else
    Result := 0;
end;

function TDmMikkoAds.ServerLogin(const aUserName, aPassword: String): Boolean;
var
    cCrypt: AnsiString;
    sParoll: String;
    B: TBytes;
begin
  InternalSetConnect;

  pUserInfo.cUserName := aUserName;
  pUserInfo.cPassword := aPassword;
  with AdsTableParoll do
  begin
    Active := true;
    if Locate('alias',pUserInfo.cUserName,[loCaseInsensitive]) then
    begin
      B := SpCrypt(AnsiString(PADR(pUserInfo.cPassword,10)),FieldByName('alias').AsAnsiString,'');
      cCrypt := AnsiString(StringOf(B));
      cCrypt := DosToWin(cCrypt);
      sParoll := (Copy(FieldByName('paroll').AsString,1,10));
      Result := cCrypt=AnsiString(sparoll);
      begin
        pUserInfo.nUserAliasKodkli := AdsTableParoll.FieldByName('kodkli').AsInteger;
        pUserInfo.cAlias           := AdsTableParoll.FieldByName('alias').AsString;
        pUserInfo.longname         := AdsTableParoll.FieldByName('longname').AsString;
        pUserInfo.nTaskCode        := AdsTableParoll.FieldByName('taskcode').AsInteger;
      end;
    end
    else
       Raise Exception.Create(msg_InvalidUsername);

  end;

end;

procedure TDmMikkoAds.SetConnect(const cDirCommon, cUserName: String;
  nUserAliasKodkli: Integer; bNew:Boolean = False);
var
  hHandle: ADSHANDLE;
//  pPath: PAceChar;
begin
  with AdsConnection1 do
  begin
    IsConnected := False;
    hHandle := 0;
    if not bNew then
      Ace.AdsFindConnection(PAceChar(AnsiString(cDirCommon)+#0),@hHandle);
    if hHandle>0 then
      SetHandle(hHandle)
    else
    begin
      ConnectPath := cDirCommon;
      IsConnected := True;
    end;
  end;
  pUserInfo.cUserName := cUserName;
  with AdsTableParoll do
  begin
    Active := true;
    if Locate('alias',pUserInfo.cUserName,[loCaseInsensitive]) then
    begin
      pUserInfo.nUserAliasKodkli := AdsTableParoll.FieldByName('kodkli').AsInteger;
      pUserInfo.cAlias           := AdsTableParoll.FieldByName('alias').AsString;
      pUserInfo.LongName         := AdsTableParoll.FieldByName('longname').AsString;
      pUserInfo.nTaskCode        := AdsTableParoll.FieldByName('taskcode').AsInteger;
    end
    else
     {$IFNDEF APP_SERVICE}
        ShowMessage(msg_InvalidUsername);
     {$ELSE}
        Raise Exception.Create(msg_InvalidUserName);
     {$ENDIF}

  end;
  TDmClient(FDmClient).Prepare(self);
end;

procedure TDmMikkoAds.SetOnExternalEvent(const Value: TExternalEvent);
begin
  FOnExternalEvent := Value;
end;

function TDmMikkoAds.SpCrypt(const aString,aKeyString,aParoll:AnsiString): TBytes;
var
  cEncrypt: AnsiString;
  cKeyString: AnsiString;
  cString: AnsiString;
  cParoll: AnsiString;
  i: Integer;
  cKeySft: AnsiString;
  d: Double;
  c1,c2,c3: AnsiChar;
  nCount: Integer;
  nOrd: Byte;
begin
  SetLength(Result,10);
  cEncrypt   := '';
  cKeyString := aKeyString;
  cString    := aString;
  if aParoll='' then
   cParoll :='SoftPro'
  else
   cParoll := aParoll;

  if Length(cKeyString) < Length(cString) then
  begin
    d :=  Length(cString)/Length(cKeyString)+0.5;
    nCount :=  Trunc(IbRound(d,0));
    cKeyString := AnsiString(Replicate(String(cKeyString),nCount));
  end;

  cKeySft := AnsiString(Replicate(String(cParoll),Trunc(IbRound(Length(cString)/7+0.5,0))));
  for i:=1 to length(cString) do
  begin
    c1 := cKeystring[i];
    c2 := cKeySft[i];
    c3 := cString[i];
    nOrd := Ord(c1)+Ord(c2)-Ord(c3);
    Result[i-1] := nOrd;
  end;
end;

function TDmMikkoAds.SpOba(aKodPar, aKodObj: Integer): variant;
var dm: TDmClient;
    nType: Integer;
begin
  dm := TDmClient(FDmClient);
  with AdsQuery1 do
  begin
    nType := dm.GetTypPar(aKodPar);
    Active := False;
    SQl.Clear;
    SQL.Add(' SELECT * FROM par_obj\par_obj WHERE kodparobj=:kodparobj AND kodobj=:kodobj');
    ParambyName('kodparobj').AsInteger := aKodPar;
    ParambyName('kodobj').AsInteger := aKodObj;
    Open;
    if IsEmpty then
    begin
      case nType of
        PARTYP_OK,PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
          Result := 0;
        PARTYP_N:
          Result := 0;
        PARTYP_C:
          Result := '';
        PARTYP_L:
          Result := 2;
        PARTYP_D:
          Result := null
        else
          Result := null;
      end;

    end
    else
    begin
      case nType of
      PARTYP_OK,PARTYP_OA, PARTYP_S, PARTYP_V, PARTYP_GK, PARTYP_GA:
        Result := FieldByName('objvalue').AsInteger;
      PARTYP_N:
         Result := FieldByName('value').AsFloat;
      PARTYP_C:
         Result := FieldByName('value').AsString;
      PARTYP_L:
        begin
          Result := FieldByName('value').AsString;
          if length(Result) =0 then
             Result := 2
          else
             Result := StrToInt(Result);
        end;
      PARTYP_D:
        begin
          Result := FieldByName('value').AsString;
          if length(Result) =0 then
             Result := null
          else
             Result := StrToDate(Result);
        end
      else
        Result := FieldByName('value').Value;
      end;
    end;

  end;
end;

function TDmMikkoAds.UnLockOper(aKodOper:Integer): Boolean;
begin
  Result := False;
  with AdsTableLockOper do
  begin
    if locate('kod',aKodOper,[]) then
    begin
      Result := AdsUnLockRecord(AdsGetRecordNum);
      if Not Result then
      {$IFNDEF APP_SERVICE}
        ShowMessage(' Ошибка совместного доступа к операции - '+FieldByName('name').AsString)
      {$ELSE}
         Raise Exception.Create(' Ошибка совместного доступа к операции - '+FieldByName('name').AsString);
      {$ENDIF}
    end;
  end;

end;

procedure TDmMikkoAds.UpdateVariablesOnDeltaDs(DataSet: TDataSet;
  aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
    bDelta: Boolean;
begin
  bDelta := DataSet is TCustomClientDataSet;
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if IfThen(bDelta,Fields[i].NewValue<> Unassigned,True)  then
      begin
        ind := aVarList.IndexOf(Fields[i].FieldName) ;
        if ind>-1 then
         try
            aVarList.Items[ind].Value := Fields[i].Value;
         except
           //{$IFNDEF APP_SERVICE}
           //ShowMessage('Name '+Fields[i].FieldName+', Index - '+IntToStr(ind));
           //{$ELSE}
           //------------------------------------------------------------------
           // Бывает непонятная ошибка с удаленным интерфейсом
           // Исправил для varFMTbcd в TCustomDocVariable.FromVariant
           //------------------------------------------------------------------
           //if aVarList[ind].Value <> Fields[i].Value then
             Raise Exception.Create('Error UpdateVariablesOnDeltaDs VarName- '+Fields[i].FieldName+', Index - '+IntToStr(ind));
           //{$ENDIF}
           //Raise;
         end;
      end;
    end;
  end;

end;

procedure TDmMikkoAds.UpdateVariablesOnDeltaDs(DataSet: TRtcDataSetChanges; aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
//    bDelta: Boolean;
begin
//  bDelta := DataSet is TCustomClientDataSet;
  with DataSet do
  begin
    for I := 0 to OldRow.FieldCount - 1 do
    begin
      //if NewRow.FieldByName(Oldow.FieldName[i]).Value <> null  then
      begin
        ind := aVarList.IndexOf(OldRow.FieldName[i]) ;
        if ind>-1 then
         try
//            if NewRow.asCode[OldRow.FieldName[i]]= OldRow.asCode[OldRow.FieldName[i]] then
            if aVarList.Items[ind].Value<>NewRow.FieldByName(OldRow.FieldName[i]).Value then
            begin
              aVarList.Items[ind].Value := NewRow.FieldByName(OldRow.FieldName[i]).Value;
            end;
         except
           //{$IFNDEF APP_SERVICE}
           //ShowMessage('Name '+Fields[i].FieldName+', Index - '+IntToStr(ind));
           //{$ELSE}
           //------------------------------------------------------------------
           // Бывает непонятная ошибка с удаленным интерфейсом
           //------------------------------------------------------------------
//           if aVarList[ind].Value <> Fields[i].Value then
             Raise Exception.Create('Error UpdateVariablesOnDeltaDs VarName- '+OldRow.FieldName[i]+', Index - '+IntToStr(ind));
           //{$ENDIF}
           //Raise;
         end;
      end;
    end;
  end;

end;

procedure TDmMikkoAds.UpdateVariablesOnDs(DataSet: TDataSet;
  aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      ind := aVarList.IndexOf(Fields[i].FieldName) ;
      if ind>-1 then
        aVarList.Items[ind].Value := Fields[i].Value;
    end;
  end;
end;

procedure TDmMikkoAds.ValidUser(Sender: TObject; var CanClose: Boolean);
var fm: TFmLogin;
    cCrypt: AnsiString;
    sParoll: String;
    B: TBytes;
begin
  fm := TFmLogin(Sender);
  if fm.ModalResult=mrCancel then
    Exit
  else
    CanClose := False;

  pUserInfo.cUserName := fm.EdUserName.Text;
  pUserInfo.cPassword := fm.EdPassword.Text;
  with AdsTableParoll do
  begin
    Active := true;
    if Locate('alias',pUserInfo.cUserName,[loCaseInsensitive]) then
    begin
      B := SpCrypt(AnsiString(PADR(pUserInfo.cPassword,10)),FieldByName('alias').AsAnsiString,'');
      cCrypt := AnsiString(StringOf(B));
      cCrypt := DosToWin(cCrypt);
      sParoll := (Copy(FieldByName('paroll').AsString,1,10));
      CanClose := cCrypt=AnsiString(sparoll);
      if not Canclose then
      begin
        {$IFNDEF APP_SERVICE}
          ShowMessage(msg_InvalidPassword);
        {$ELSE}
          Raise Exception.Create(msg_InvalidPassword);
        {$ENDIF}
      end
      else
      begin
        pUserInfo.nUserAliasKodkli := AdsTableParoll.FieldByName('kodkli').AsInteger;
        pUserInfo.cAlias           := AdsTableParoll.FieldByName('alias').AsString;
        pUserInfo.longname         := AdsTableParoll.FieldByName('longname').AsString;
        pUserInfo.nTaskCode        := AdsTableParoll.FieldByName('taskcode').AsInteger;
      end;
    end
    else
     {$IFNDEF APP_SERVICE}
        ShowMessage(msg_InvalidUsername);
     {$ELSE}
        Raise Exception.Create(msg_InvalidUserName);
     {$ENDIF}

  end;

end;


procedure TDmMikkoAds.DataModuleCreate(Sender: TObject);
//var
//   p: PDmList;
begin
  if not Assigned(AdsSetting1) then
    AdsSetting1 := TAdsSettings.Create(Application);
//  if not Assigned(gDmList) then
//    gDmList := TList.Create;

  AdsSetting1.DateFormat:='dd.mm.yyyy';
  AdsSetting1.SetDelphiDate := True;
  AdsSetting1.ShowDeleted  := False;

  with AdsQueryProtocol do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('INSERT INTO tools\protocol (username,alias,date,time,type,action,') ;
    SQL.Add('comment,kod,kodkli,documents)') ;
    SQL.Add(' VALUES (:username ,:cuseralias ,:date,:time ,');
    SQL.Add(' :type ,:action ,:comment ,');
    SQL.Add(' :kod,:nUserAliasKodKli ,:documents )');
  end;
  UpdateList := TStringList.Create;
  //{$IFNDEF  KURS_LOADER}
  FDmClient := TDmClient.Create(self);
  //{$ENDIF}
  //----------- gDmList ----------------
{  New(p);
  p.handle := Application.Handle;
  p.dm := self;
  gDmList.Add(p);}
end;

procedure TDmMikkoAds.DataModuleDestroy(Sender: TObject);
var i: Integer;
begin
//  {$IFNDEF  KURS_LOADER}
  FreeAndNil(FDmClient);
//  {$ENDIF}

  UpdateList.Free;
  i := DmList.IndexOf(self);
  if i>-1 then
    DmList.Delete(i);

  {for I := 0 to gDmList.Count-1 do
    if PDmList(gDmList[i]).dm=self then
    begin
      Dispose(gDmList[i]);
      gDmList.Delete(i);
      Break;
    end;}
  inherited;
end;

procedure TDmMikkoAds.DeleteDoc(aKodReg,aKodPriznak, aKodDoc: Integer; aRowId:String);
var cAlias: String;
begin
  if aRowId='' then
  begin
    cAlias := 'DC'+StrZero(aKodreg,6)
  end
  else
    cAlias := 'SD'+StrZero(aKodreg,6);

  //---- Delete ---
  with AdsQueryDoc do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('DELETE FROM TASK\'+cAlias);
    if aRowId='' then
    begin
      SQL.Add(' WHERE koddoc=:koddoc');
      ParamByName('koddoc').AsInteger := aKodDoc;
    end
    else
    begin
       SQL.Add(' WHERE rowid=:rowid');
       ParamByName('rowid').AsString := aRowid;
    end;
    ExecSQL;
  end;


  //---- write protocol ---
  if aRowId='' then
     WriteProtocol(ACT_DELDOC,'Удаление документа','',
          aKodDoc,aKodReg,aKodPriznak,0)
  else
     WriteProtocol(ACT_DELSODDOC,'Удаление сод. документа','',
          aKodDoc,aKodReg,aKodPriznak,0)

end;

procedure TDmMikkoAds.DoExternalEvent(Sender: TObject; aId: Integer);
begin
  if Assigned(FOnExternalEvent) then
    FOnExternalEvent(Sender, aId);
end;

procedure TDmMikkoAds.DropTempSqlTable(const aName: String);
begin

  with AdsQuery2 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' DROP TABLE '+aName);
    try
      ExecSQL;
    except
      on E: EAdsDatabaseError do
      begin
        if E.SQLErrorCode<>7112 then  //7112 - temp file not found
          raise E;
      end;

    end;
  end;
end;

function TDmMikkoAds.DtFromXbase(aD: tDateTime): TDateTime;
begin
  Result := aD - DATA_DELTA;
end;

function TDmMikkoAds.DtToXbase(aD: tDateTime): TDateTime;
begin
  Result := aD + DATA_DELTA;
end;

class function TDmMikkoAds.GetDmMikkoAds(aOwner: TComponent): TDmMikkoAds;
var i: Integer;
begin
  Result := nil;
  for I := 0 to DmList.Count-1 do
  begin
    if DmList[i].Owner=aOwner then
      Result := DmList[i]
  end;

  if not Assigned(Result) then//and (DmMikkoAds.Owner=aOwner) then
  begin
    Result := TDmMikkoads.Create(aOwner);
  end;
end;

{class function TDmMikkoAds.GetDmMikkoAdsByHandle(aHandle: THandle): TDmMikkoAds;
var i: Integer;
begin
  for I := 0 to gDmList.Count-1 do
  begin
    if PDmList(gDmList[i]).handle=ahandle then
    begin
      Result := PDmList(gDmList[i]).dm;
      Break;
    end;
  end;
end;
 }
{class function TDmMikkoAds.GetDmMikkoads(Sender: TObject): TDmMikkoAds;
begin

end; }

function TDmMikkoAds.GetGermanFulldate(aDate: TDateTime): String;
var Day, Month, Year: Word;
//    nMonth:Integer;
    aMonth:TStringList;
    cMonth: String;
begin
  aMonth := TStringList.Create;
  try
  DecodeDate(aDate, Year, Month, Day);

  aMonth.Add('Januar');
  aMonth.Add('Februar');
  aMonth.Add('Maerz');
  aMonth.Add('April');
  aMonth.Add('Mai');
  aMonth.Add('Juni');
  aMonth.Add('Juli');
  aMonth.Add('August');
  aMonth.Add('September');
  aMonth.Add('Oktober');
  aMonth.Add('November');
  aMonth.Add('Dezember');

  cMonth := aMonth[Month-1];
  Result := StrZero(Day,2) + '. '+cMonth+' '+IntToStr(Year);
  finally
    aMonth.Free;
  end;
end;

function TDmMikkoAds.GetObjectName(aKod: Integer): String;
begin
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('SELECT name FROM client WHERE kodkli=:kodkli');
    ParamByName('kodkli').AsInteger := aKod;
    Open;
    if not IsEmpty then
      Result := FieldByname('name').AsString
    else
      Result := '';
    Close;
  end;
end;

function TDmMikkoAds.GetProtocolComment(aFields: TDocVariableList;
  bInsert: Boolean): String;
var
  i,k: Integer;
begin
  Result := '';
  if bInsert then
  begin
    for I := 0 to aFields.Count - 1 do
    begin
      if aFields.Items[i].IsLinkField then
      begin
        Result := Result+' Поле :'+ aFields.Items[i].name+#13;
        Result := Result+' Новое значение ='+ CoalEsce(aFields.Items[i].AsString,'')+#13#13;
      end;
    end;
  end
  else
  begin
    for k := 0 to UpdateList.Count - 1 do
    begin
      i := aFields.IndexOf(UpdateList[k]);
      if aFields.Items[i].IsLinkField then
      begin
        Result := Result+' Поле :'+ aFields.Items[i].name+#13;
        Result := Result+' Новое значение ='+ CoalEsce(aFields.Items[i].AsString,'')+#13;
        Result := Result+' Прежнее значение ='+ aFields.Items[i].InitValue.AsString+#13#13;
      end;
    end;
  end;
end;

procedure TDmMikkoAds.EditClient(aKodKli: Integer; aName: string);
begin
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' UPDATE client set name= :name');
    SQL.Add(' WHERE kodkli=:kodkli');
    ParamByName('kodkli').AsInteger := aKodKli;
    ParamByName('name').AsString    := aName;
    ExecSql;
  end;
end;

procedure TDmMikkoAds.EditDoc(bInsert:Boolean;aKodDoc,aKodReg, aKodPriznak: Integer;aFields:TDocVariableList; bSod:Boolean; aRowId:String);
var
  cAlias: String;
  i,k: Integer;
begin
  UpdateList.Clear;
  aFields.VarByName('priznak').value := aKodPriznak;
  if bSod then
    cAlias := 'SD'+StrZero(aKodreg,6)
  else
    cAlias := 'DC'+StrZero(aKodreg,6);

  if bInsert and (aKodDoc=0) then
  begin
    aKodDoc := NewNum('DOCUMENT');
    aFields.VarByName('koddoc').AsInteger := aKodDoc;
  end
  else
    if aKodDoc>0 then
      aFields.VarByName('koddoc').AsInteger := aKodDoc;

  if aFields.VarByName('koddoc').AsInteger=0 then
    Raise Exception.Create(' koddoc= 0 !');

//  if not bSod then
//  begin
  with AdsQueryDoc do
    begin
    Active := False;
    SQL.Clear;
    if bInsert then
    begin
//--------  Insert --------------
      SQL.Add(' INSERT INTO task\'+cAlias);
      SQL.Add(' (');
      for i := 0 to aFields.Count - 1 do
      begin
        if aFields.Items[i].IsLinkField then
        begin
          if i>0 then
           SQL.Add(',');
          SQL.Add(aFields.Items[i].name);
        end;
      end;
      SQL.Add(')');
      SQL.Add(' VALUES(');
      for i := 0 to aFields.Count - 1 do
      begin
        if aFields.Items[i].IsLinkField then
        begin
          if i>0 then
            SQL.Add(',');
          SQL.Add(':'+aFields.Items[i].name);
          UpdateList.Add(aFields.Items[i].name);
        end;
      end;
      SQL.Add(')') ;
    end
    else
    begin
//--------  Update --------------
      aFields.GetChangedList(UpdateList);
      if UpdateList.Count>0 then          {todo GetListChanged}
      begin
        SQL.Add(' UPDATE task\'+cAlias);
        SQL.Add(' SET ');
        for i := 0 to UpdateList.Count - 1 do
        begin
          if (aFields.VarByName(UpdateList[i]).IsLinkField)  then
          begin
            if i>0 then
              SQL.Add(',');
            if aFields.Items[i].IsDelta then
              SQL.Add( UpdateList[i]+' = '+UpdateList[i]+ '+:'+UpdateList[i])
            else
              SQL.Add( UpdateList[i]+' = :'+UpdateList[i]);
          end;
        end;
        if bSod then
          SQL.Add(' WHERE rowid='+''''+aRowId+'''')
        else
          SQL.Add(' WHERE koddoc=:koddoc');
        UpdateList.Add('koddoc');
      end
      else
        Exit;
    end;

//--------  Execute --------------
    for k := 0 to UpdateList.Count - 1 do
    begin
      i := aFields.IndexOf(UpdateList[k]);
      if aFields.Items[i].IsLinkField then
      try
        if  aFields.Items[i].DataType = ftFloat then
           paramByname(aFields.Items[i].name).Value := aFields.Items[i].AsExtended
        else
        if  aFields.Items[i].DataType = ftString then
           paramByname(aFields.Items[i].name).Value := aFields.Items[i].AsString
        else
        if  aFields.Items[i].DataType = ftDate then
           if CoalEsce(aFields.Items[i].AsDateTime,0)=0 then
             ParamByname(aFields.Items[i].name).Clear
           else
             ParamByname(aFields.Items[i].name).AsDateTime := aFields.Items[i].AsDateTime
        else
        if  aFields.Items[i].DataType = ftBoolean then
           paramByname(aFields.Items[i].name).Value := aFields.Items[i].AsBoolean
        else
        if  (aFields.Items[i].DataType = ftInteger) or (aFields.Items[i].DataType = ftSmallInt) then
           paramByname(aFields.Items[i].name).Value := aFields.Items[i].AsInteger
        else
           paramByname(aFields.Items[i].name).Value := aFields.Items[i].Value;

      except
        {$IFNDEF APP_SERVICE}
          ShowMessage(' Error - '+aFields.Items[i].name);
        {$ENDIF}
        Raise;
      end;
    end;
    try
      if bInsert or (UpdateList.Count>0) then
        ExecSQL;
    except
      {$IFNDEF APP_SERVICE}
        ShowMessage(' Error in -'+SQL.Text);
      {$ENDIF}
      Raise;
    end;

//--------  Write Protocol --------------
    if bInsert then
    begin
      if not bSod then
      begin
        WriteProtocol(ACT_ADDDOC,'Добавление документа',GetProtocolComment(aFields,True),
          aKodDoc,aKodReg,aKodPriznak,0);
      end
      else
      begin
        WriteProtocol(ACT_ADDSODDOC,'Добавление сод. документа',GetProtocolComment(aFields,True),
          aKodDoc,aKodReg,aKodPriznak,0);
      end;
    end
    else
    begin
      if not bSod then
      begin
        WriteProtocol(ACT_EDITDOC,'Коррекция документа',GetProtocolComment(aFields,False),
          aKodDoc,aKodReg,aKodPriznak,0);
      end
      else
      begin
        WriteProtocol(ACT_EDITSODDOC,'Коррекция сод. документа',GetProtocolComment(aFields,False),
          aKodDoc,aKodReg,aKodPriznak,0);
      end;

    end;
  end;
end;

procedure TDmMikkoAds.Execute(const FileName: string);
begin
    if (FileName = '') then
      exit;

    // ... launch the file's default application to open it.
    Screen.Cursor := crAppStart;
    try
      Application.ProcessMessages; {otherwise cursor change will be missed}
      ShellExecute(0, nil, PChar(FileName), nil, nil, SW_NORMAL);
    finally
      Screen.Cursor := crDefault;
    end;

end;

procedure TDmMikkoAds.Find(ds: TDataSet; bFirst: Boolean);
var bk: TBookmark;
    bFind: Boolean;
    i: Integer;
begin
   bFind := False;
   ds.DisableControls;
   try
     bk := ds.GetBookmark;
     if bFirst then
     begin
       if not getLocateLine(Application,rs_Find,rs_SearchString,30,sFind) then
         Exit;

     end
     else
       ds.Next;
     while not ds.Eof and not bFind do
     begin
       for i := 0 to ds.FieldCount - 1 do
       begin
         if ds.Fields[i].Visible then
         begin
           if pos(sFind,ds.Fields[i].Text)>0 then
           begin
             bFind := True;
             Break;
           end;
         end;
       end;
       if not bFind then
         ds.Next;
     end;
     if not bFind then
     begin
       {$IFNDEF APP_SERVICE}
       ShowMessage(msg_SearchCompleted);
       {$ENDIF}
       ds.GotoBookmark(bk);
     end;
   finally
     ds.EnableControls;
     ds.FreeBookmark(bk);
   end;
end;

function TDmMikkoAds.QueryValue(aSql: string): Variant;
begin
  with AdsQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(aSql);
    Open;
    if not IsEmpty then
      Result := Fields[0].Value
    else
      Result := null;
    Close;
  end;
end;


procedure TDmMikkoAds.WriteProtocol(aType:Integer;const aAction:String;const aComment:String;
  aKod:Integer; aKodreg:Integer; akodPriznak:Integer; aKodView:Integer);
var
    FormatSettings: TFormatSettings;
begin
  FormatSettings.LongTimeFormat := FormatSettings.ShortTimeFormat;
  with AdsQueryProtocol do
  begin
    Active := False;
    ParamByName('username').AsString          := pUserInfo.longname;
    ParamByName('cUserAlias').AsString        := pUserInfo.cAlias;
    ParamByName('date').AsDateTime            := date();
    ParamByName('time').AsString              := TimeToStr(Time);
    ParamByName('type').AsSmallInt            := aType;
    ParamByName('action').AsString            := aAction;
    ParamByName('comment').AsString           := aComment;
    ParamByName('kod').AsInteger              := aKod;
    ParamByName('nUserAliaskodKli').AsInteger := pUserInfo.nUserAliasKodkli;
    if aKodReg>0 then
      ParamByName('documents').AsString         := Str11(aKodReg)+Str11(aKodPriznak)+str11(aKodView)
    else
      ParamByName('documents').AsString       := '';

    try
      ExecSQL;
    except
      {$IFNDEF APP_SERVICE}
      ShowMessage('Error in - '+SQL.Text);
      {$ENDIF}
      Raise;
    end;
  end;
end;



procedure TDmMikkoAds.WriteVarListToDs(aVarList: TDocVariableList; aDs: TDataSet);
var i: Integer;
    f: TField;
begin
  for I := 0 to aVarList.Count-1 do
  begin
    f := aDs.FindField(aVarList.Items[i].name);
    if Assigned(f) then
    begin
      if f.DataType= ftInteger then
        f.AsInteger := avarList.Items[i].AsInteger
      else
        f.Value := aVarList.Items[i].Value;
    end;
  end;
end;

initialization
  DmList := TObjectList<TDmMikkoAds>.Create;
  AppFileName := ExpandUNCFileName(ParamStr(0))
finalization
  DmList.Free;
  AppFileName :=  '';
end.
