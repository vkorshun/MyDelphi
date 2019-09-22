unit dm_mikkoserver;

interface

uses
  SysUtils, Classes,  FMTBcd, DB, IniFiles, Dialogs, Forms, DBClient,
  DateVk,Windows, graphics,fm_alert,fm_texteditor, ExtCtrls, rtcInfo, rtcConn, rtcDataCli,
  rtcHttpCli, rtcDB, rtcCliModule, dm_entrancemikkoclient, variants, messages, SoundPlayerEntrance, sotrudinfo;

const

  sRootKey = '\SOFTWARE\MIKKO_ENTRANCE';
  DATA_DELTA       = 693990;
  QS               = CHR(ORD(''''));

  KODREG_PROHOD           = 162;
  PRIZNAK_PROHOD_MIKKO    = 1307;
  PRIZNAK_PROHOD_BELGOROD = 1792;
  PRIZNAK_NOTPROHOD       = 1487;
  PRIZNAK_FREEGR          = 1490;
  KODG_SOTRUD             = 16;

  KOD_ENTRANCE_MIKKO    = 211367;
  KOD_ENTRANCE_BELGOROD = 211368;
  KOD_ENTRANCE_BUH      = 211369;
  KOD_ENTRANCE_VED      = 211370;
  KOD_ENTRANCE_TEHNO    = 211371;

  KOD_SMENA_3 = 213035; // Универсальный
  KOD_SMENA_1 = 213036; // Только 1-я

  KODPAR_CHECKGR = 213032;
  KODPAR_TYPEUCH = 213034;

type
  TDmMikkoServer = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
//    procedure ClientDataSetDc162AfterOpen(DataSet: TDataSet);
//    procedure ClientDataSetDc162BeforePost(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
//    procedure ClientDataSetDc162PostError(DataSet: TDataSet; E: EDatabaseError;
//      var Action: TDataAction);
//    procedure ClientDataSetDc162ReconcileError(DataSet: TCustomClientDataSet;
//      E: EReconcileError; UpdateKind: TUpdateKind;
//      var Action: TReconcileAction);
  private
    { Private declarations }
    comment_omk: String;
    connect_handle: Integer;
    FisCheckTimeOut: Boolean;
    fFm: TForm;
    FFmAlert: TFmAlert;
    FIni: TIniFile;
    FnInterface: Integer;
    FServer: TDmEntranceMikkoClient;
    hSignal: THandle;
    Fkodentrance: Integer; // проходная
    nDebug: Integer;
    RapLabel:RParamAlert;
    RapBtn:RParamAlert;
    EntranceSoundPlayer: TEntranceSoundPlayer;
//    procedure CloseClientDataSet(aClientDataSet:TClientDataSet);
    function GetClientName(aKodKli:Integer):string;
    function LocatePrihod(aKodSotrud:Integer):Boolean;
    procedure OnGetTextDt(Sender: TField; var Text: string; DisplayText: Boolean);
//    procedure CancelUpdate(DataSet:TClientDataSet);
    function isNeedCommentOut(ASotrudInfo: TSotrudInfo): boolean;
  public
    { Public declarations }
    procedure SetFilterDc162(aIndex:Integer);
    procedure SetConnect;
    function DtToXbase(aDt:TDateTime):TDateTime;
    function DtFromXbase(aDt:TDateTime):TDateTime;
    function GetControlOrder(cCode: PAnsiChar): AnsiChar;
    function GetDateTimeStr(dt:TDateTime):String;
    function GetFileName: String;
    function GetObjectName(aKodObj:Integer):String;
    function GetServerTime: TDateTime;
    ///<summary> тип графика - 1 значит проверять </summary>
    function GetTypeGraphic:Integer;
    ///<summary> тип учета (Ун или 1-я смена) </summary>
    function GetTypeUch:Integer;
    function Lock:Boolean;
    ///<summary> Востановлении связи при сбое на сервере </summary>
    procedure RestoreConnect;
    procedure Reconnect;
    procedure RegisterSotrud(ASotrudInfo:TSotrudInfo);

    procedure UnLock;
    procedure ShownotInGraphic(aKodKli:Integer);
    procedure ShownotInOmk(aKodKli:Integer);
    function  ValidBarcode(pBarcode:PAnsiChar):Boolean;

    property Fm:TForm read FFm write FFm;
    property FmAlert:TFmAlert read FFmAlert;
    property kodentrance:Integer read Fkodentrance;
    property nInterface:Integer read FnInterface;
    property Server: TDmEntranceMikkoClient read FServer;
    property isCheckTimeOut: boolean read FisCheckTimeOut write FisCheckTimeOut;
    ///<summary> Возвращает результат запроса cQuery </summary>
    function QueryValue(const cQuery:String):String;

  end;

var
  DmMikkoServer: TDmMikkoServer;

implementation

{$R *.dfm}
//uses Fm_mikko_entrance;

{ TDmMikkoServer }




{procedure TDmMikkoServer.ClientDataSetDc162BeforePost(DataSet: TDataSet);
begin
  with DataSet do
  begin
    if FieldByName('datatim1').AsFloat>0 then
      FieldByname('prih').AsInteger := 1;
    if FieldByName('datatim2').AsFloat>0 then
      FieldByname('uh').AsInteger := 1;

  end;
end; }


procedure TDmMikkoServer.DataModuleCreate(Sender: TObject);
begin
  EntranceSoundPlayer := TEntranceSoundPlayer.Create;
  FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  FnInterface := FIni.ReadInteger('SET','interface',0);
  FServer := TDmEntranceMikkoClient.Create(self);
  SetConnect;
  hSignal := CreateSemaphore(nil,1,1,nil);
  FFmAlert := TFmAlert.Create(Application);
  FmAlert.caption := 'Подтверждение';
  with RapLabel do
  begin
    aFontName := 'Courier New Cyr';
    aFontSize := 36;
    aFontStyle:=  [fsBold];
    aFontColor:=  clBlue;
  end;
  with RapBtn do
  begin
    aFontName := '';
    aFontSize := 24;
    aFontStyle:=  [fsBold];
    aFontColor:=  clWindowText;
  end;
end;

procedure TDmMikkoServer.DataModuleDestroy(Sender: TObject);
begin
  EntranceSoundPlayer.Free;
  Fini.Free;
  FServer.RtcHttpClient1.Disconnect;
  FreeAndNil(Fserver);
  Inherited;
end;

function TDmMikkoServer.DtFromXbase(aDt: TDateTime): TDateTime;
begin
  Result := aDt- DATA_DELTA;
end;

function TDmMikkoServer.DtToXbase(aDt: TDateTime): TDateTime;
begin
  Result := aDt+ DATA_DELTA;
end;

function TDmMikkoServer.GetClientName(aKodKli: Integer): string;
begin
//  if ClientdataSetClients.Locate('kodkli',aKodkli,[]) then
//    Result := ClientdataSetClients.FieldByName('name').AsString
//  else
    Result := FServer.QueryValue(' SELECT name FROM client WHERE kodkli='+IntToStr(aKodKli));
end;

function TDmMikkoServer.GetControlOrder(cCode: PAnsiChar): AnsiChar;
var  n1, n2,n :Integer;
    i: Cardinal;
begin
  i:=0;
  n1 := 0;
  n2 := 0;
  while i<StrLen(cCode) do
  begin
     if i mod 2 = 0 then
        // Нечетные
        n1:= n1+ StrToInt(Char(cCode[i]))
     else
        // Четные
        n2:=n2+ StrToInt(Char(cCode[i]));
     inc(i);
  end;
  n := n1+n2*3;
  n := 10-(n mod 10);

  if n>=10 then
    result :=  '0'
  else
    result := AnsiString(IntToStr(n))[1];

end;

function TDmMikkoServer.GetDateTimeStr(dt: TDateTime): String;
begin
  DateTimeToString(Result,'dd.mm.yyyy hh:nn',dt);
end;

function TDmMikkoServer.GetFileName: String;
begin
  Result := ExtractFileDir(Application.ExeName)+'\'+'entrance.data';
end;

function TDmMikkoServer.GetObjectName(aKodObj: Integer): String;
begin
  Result := fServer.QueryValue(' SELECT name FROM client WHERE kodkli='+IntToStr(aKodObj));
{  if length(Result)=0 then
  begin
    ClientDataSetClients.Close;
    ClientDataSetClients.Open;
    Result := GetClientName(aKodObj);
  end;}
end;

function TDmMikkoServer.GetserverTime: TDateTime;
begin
  Result := FServer.GetSystemTime;
end;

function TDmMikkoServer.GetTypeGraphic: Integer;
var s: String;
begin
  s := FServer.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+IntToStr(Fkodentrance)+
    ' AND kodparobj='+IntToStr(KODPAR_CHECKGR));
  if Trim(s)='1' then
    Result := 1
  else
    Result := 0;
end;

function TDmMikkoServer.GetTypeUch: Integer;
var s: String;
begin
  s := FServer.QueryValue('SELECT objvalue FROM par_obj\par_obj WHERE kodobj='+IntToStr(Fkodentrance)+
    ' AND kodparobj='+IntToStr(KODPAR_TYPEUCH));
  if not TryStrToInt(s,Result) then
    Result := 0;
end;

function TDmMikkoServer.isNeedCommentOut(ASotrudInfo: TSotrudInfo): boolean;
begin
  result := isCheckTimeOut and (Now < DtFromXbase(ASotrudInfo.grTimeOut));
end;

function TDmMikkoServer.LocatePrihod(aKodSotrud: Integer): Boolean;
var
  d: TDateTime;
  koddoc: Integer;
begin
  Result := False;
  with Server.MemTableEhDc162 do
  begin
    DisableControls;
    try
      Filtered := False;
      Filter := ' kodkli='+IntTostr(aKodSotrud);
      Filtered := True;
      Last;
 //     if  Locate('kodkli;datatim2',VarArrayOf([aKodSotrud,null]),[]) or Locate('kodkli;datatim2',VarArrayOf([aKodSotrud,0]),[]) then
      //Filtered := True;
      //Last;
      if not IsEmpty and (FieldByName('datatim2').AsFloat=0) and (FieldByName('kodkli').AsInteger=akodsotrud)then
      begin
        Result := true;
        //----------- для типа учета (1-я смена) дата ухода должна совпадать с приходом ----------
        if GetTypeUch=KOD_SMENA_1 then
        begin
          d := DtFromXbase(FieldByName('datatim1').AsFloat);
          if GetServerTime-d>=1 then
            koddoc := FieldbyName('koddoc').AsInteger;
          Filtered := False;
        end
        else
        begin
          koddoc := FieldbyName('koddoc').AsInteger;
        end;
      end
    finally
      if Filtered then
        Filtered := False;

      if not Result then
        Last
      else
      begin
        Locate('koddoc',koddoc,[]);
        Result :=  koddoc= FieldByName('koddoc').AsInteger ;
      end;
      EnableControls;
    end;
  end;
end;

function TDmMikkoServer.Lock: Boolean;
begin
  Server.TryConnect;
  Result :=  WaitForSingleObject(hSignal, 100)=WAIT_OBJECT_0;
end;

procedure TDmMikkoServer.OnGetTextDt(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  if CoalEsce(Sender.value,0)<>0 then
    Text := GetDateTimeStr(DtFromXbase( CoalEsce(Sender.value,0)))
  else
    Text := '';

end;

function TDmMikkoServer.QueryValue(const cQuery: String): String;
begin
  Result := FServer.QueryValue(cQuery);
end;

procedure TDmMikkoServer.Reconnect;
begin
  SetFilterDc162(0);
end;

procedure TDmMikkoServer.RegisterSotrud;
var n_tektime:TDateTime;
   sINN: String;
  nSex : Integer;
  cText: String;
  bNotInGraphic: Boolean;
  bNotInOmk: Boolean;
  dUvl: TDateTime;
  bPrihod: Boolean;
//  grTime: double;
  sName: String;
  isNeedCommentOut: boolean;
begin
  isNeedCommentOut := false;
//  koduch := GetTypeUch;
//  ClientDataSetDc162.Refresh;
  //Проверка на группу
  if (ASotrudInfo.Kodkli=0) or not ASotrudInfo.isValidGroup then //FServer.ValidGroup(aKodKli)
  begin
//    ShowMessage('Не правильный код!'+TextEdit('Комментарий','', true));
    ShowMessage('Не правильный код!');
    Exit;
  end;

  n_tektime := GetServerTime;
  bPrihod := LocatePrihod(ASotrudInfo.KodKli);
  with Server.MemTableEhDc162 do
  begin
    //1. проверка на увольнение
  //  if (ASotrudInfo.KodKli<>74729) then
    begin
      dUvl := ASotrudInfo.dateFire; //FServer.GetDataUvl(aKodKli);
      if (dUvl>1) and (dUvl< Now) then
      begin
        with FmAlert do
        begin
          Clear;
          AddLabel(' У сотрудника  '+ ASotrudInfo.name,@RapLabel);
          AddLabel(' проставлена дата увольнения',@RapLabel);
          AddLabel(DateToStr(dUvl),@RapLabel);
          AddButton('На работу не пропускаем',@RapBtn);
          ShowModal;
          Exit;
        end;
      end;
    end;

    // bNotInGraphic := FServer.CheckGraphic(aKodKli);
    //3. проверка на график
    bNotInGraphic := False;
    bNotInOmk     := False;
    if GetTypeGraphic=1 then
    begin
      if (kodentrance <> KOD_ENTRANCE_BELGOROD) then
        bNotInGraphic := not FServer.ValidGraphic(ASotrudInfo.Kodkli);

      if  bNotInGraphic then
      begin
        //2. проверка на отпуск
        if (kodentrance <> KOD_ENTRANCE_BELGOROD) then
        begin
          if not Fserver.ValidHoliday(ASotrudInfo.KodKli) then
          begin
            with FmAlert do
            begin
              Clear;
              AddLabel(' У сотрудника  '+ASotrudInfo.name,@RapLabel);
              AddLabel(' проставлен отпуск с',@RapLabel);
              AddButton('Необходимо изменить график!',@RapBtn);
              ShowModal;
            end;
          end;
        end;
      end;



      bNotInOmk := not FServer.ValidOmk(ASotrudInfo.Kodkli);
      if bNotInOmk  then
      begin
         ShowNotInOmk(ASotrudInfo.kodkli);
         Exit;
      end;
    end;

    if bPrihod then
      // Сообщаем об уходе
      EntranceSoundPlayer.play(EntranceSoundPlayer.sound_chimes)
    else
      // Сообщаем о приходе
      EntranceSoundPlayer.play(EntranceSoundPlayer.sound_tada);

    if bPrihod then
    begin
      nDebug := 1;
      //----------- Уход --------------
      if ((n_tektime-DtFromXbase(FieldByName('datatim1').AsFloat))  > (1/60/24)) or (nDebug=1) then
      begin
        RapBtn.aFontSize := 12;
        with FmAlert do
        begin
          Clear;
          RapLabel.aFontColor := clRed;
          sName :=  ASotrudInfo.name;
          AddLabel(sName +' выходит с территории.',@RapLabel);
          RapLabel.aFontColor := clBlue;
          AddLabel(GetDateTimeStr(n_tektime),@RapLabel);
          AddLabel(' отметка о приходе проставлена',@RapLabel);
          AddLabel(GetDateTimeStr(DtFromXbase(FieldByName('datatim1').AsFloat)),@RapLabel);

          AddButton('Да, выходит',@RapBtn);
          AddButton('Нет, пришел',@RapBtn);
          AddButton('Отмена ввода',@RapBtn);
          AddButton('Да, с комментарием',@RapBtn);
          ShowModal;
        end;
        RapBtn.aFontSize := 24;
        if (FmAlert.ButtonId=0) or (FmAlert.ButtonId=3) then
        begin
          //CalcVariables;
          //VarDoc.VarByName('datatim2').AsFloat := DmAds.DtToXbase( n_tektime);
          EntranceSoundPlayer.play(EntranceSoundPlayer.sound_chimes);
          Edit;
          FieldByname('datatim2').AsFloat := DtToXbase( n_tektime);
          if (kodentrance = KOD_ENTRANCE_BELGOROD) then
          begin
           // grTime := ; //.GetGrTimeOut( aKodKli);
           // ShowMessage(TimeToStr(grTime));
            isNeedCommentOut := self.isNeedCommentOut(ASotrudInfo);//Now < DtFromXbase(TDateTime (ASotrudInfo.grTimeOut));
            {with FmAlert do
            begin
              Clear;
              AddLabel(' Необходимо прокоментировать уход раньше времени по графику',@RapLabel);
              AddButton('Комментарий! ('+sname+')',@RapBtn);
              ShowModal;
              FieldByName('com1').AsString := TextEdit('Комментарий выхода раньше времени',FieldByName('com1').AsString);
            end;}
          end;

          if (FmAlert.ButtonId=3) or isNeedCommentOut then
          begin
            if isNeedCommentOut then
            with FmAlert do
            begin
              Clear;
              AddLabel(' Необходимо прокоментировать уход раньше времени по графику',@RapLabel);
              AddButton('Комментарий! ('+sname+')',@RapBtn);
              ShowModal;
            end;
            FieldByName('com1').AsString := TextEdit('Комментарий',FieldByName('com1').AsString, true);
          end;
          // Store - update
          try
            Post;
           // Refresh162(VarDoc.VarByName('koddoc').AsInteger);
          except
            //CancelUpdate(ClientDataSetDc162);
            Raise;
          end;
        end
        else
        begin
          if (FmAlert.ButtonId=1) then
          begin
            // Переназначение на приход
            EntranceSoundPlayer.play(EntranceSoundPlayer.sound_tada);
            Append;
            FieldByName('kodkli').AsInteger  := ASotrudInfo.KodKli;
            FieldByname('name').AsString     := ASotrudInfo.name;
            FieldByName('com1').AsString     := TextEdit('Комментарий','');
            FieldByName('data').AsdateTime   := n_tektime;
            FieldByName('datatim1').AsFloat  := Double(DtToXbase(n_tektime)) ;
            FieldByName('entranc').AsInteger := DmMikkoServer.kodentrance;
            try
              if bNotInGraphic or bNotInOmk then
              begin
                FieldByName('priznak').Asinteger := PRIZNAK_NOTPROHOD;
                Post;
              end
              else
              begin
                FieldByName('priznak').Asinteger := PRIZNAK_PROHOD_MIKKO;
                Post;
              end;
            except
              Delete;
              Raise;
            end;
          end;
          if bNotInGraphic then
            begin
              ShowNotInGraphic(ASotrudInfo.KodKli);
              Exit;
            end;
          if bNotInOmk then
            begin
              ShowNotInOmk(ASotrudInfo.KodKli);
              Exit;
            end;
        end;
      end;
    end
    else
    begin
      //------ Приход ----------------

      //Пол
      sINN := ASotrudInfo.inn;
      //CoalEsce(FServer.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+IntToStr(ASotrudInfo.KodKli)+' AND kodparobj=31'),'');
      if Length(sINN)>0 then
        nSex := StrToInt(sINN[9]) mod 2
      else
        nSex := 1;
      if nSex=0 then
        cText := 'пришла'
      else
        cText := 'пришел';

      //Alert
      with FmAlert do
      begin
        Clear;
        RapLabel.aFontColor := clGreen;
        AddLabel( ASotrudInfo.name+' '+cText+' на работу. ',@RapLabel);
        RapLabel.aFontColor := clBlue;
        AddLabel(GetDateTimeStr(n_tektime),@RapLabel);

        RapBtn.aFontSize := 12;
        AddButton('Да,'+cText,@RapBtn);
        AddButton('Нет, уходит',@RapBtn);
        AddButton('Отмена ввода',@RapBtn);
        AddButton('Да, с комментарием',@RapBtn);
        ShowModal;
      end;
      //----- For test

      RapBtn.aFontSize := 24;
      if (FmAlert.ButtonId=0) or (FmAlert.ButtonId=3) then
      begin
        EntranceSoundPlayer.play(EntranceSoundPlayer.sound_tada);
        Append;
        FieldByName('kodkli').AsInteger := ASotrudInfo.KodKli;
        FieldByname('name').AsString    := ASotrudInfo.name;
        FieldByName('com1').AsString := '';
        FieldByName('data').AsdateTime := n_tektime;
        FieldByname('datatim1').AsFloat:= Double(DtToXbase(n_tektime));
        FieldByName('entranc').AsInteger := DmMikkoServer.kodentrance;
        FieldByName('com1').AsString := '';
        if (FmAlert.ButtonId=3) then
          FieldByName('com1').AsString := TextEdit('Комментарий',FieldByName('com1').AsString);
        try
          if bNotInGraphic or bNotInOmk then
          begin
            FieldByName('priznak').Asinteger := PRIZNAK_NOTPROHOD;
            Post;
          end
          else
          begin
            FieldByName('priznak').Asinteger := PRIZNAK_PROHOD_MIKKO;
            Post;
          end;
        except
          Delete;
          Raise;
        end;
        if bNotInGraphic then
        begin
          ShowNotInGraphic(ASotrudInfo.KodKli);
          Exit;
        end;
        if bNotInOmk then
        begin
          ShowNotInGraphic(ASotrudInfo.KodKli);
          Exit;
        end;
      end
        else
          if (FmAlert.ButtonId=1) then
          begin
            // Переназначение на уход
            EntranceSoundPlayer.play(EntranceSoundPlayer.sound_chimes);
            Append;
            FieldByName('kodkli').AsInteger := ASotrudInfo.KodKli;
            FieldByName('com1').AsString    := TextEdit('Комментарий','');
            FieldByName('data').AsdateTime  := n_tektime;
            FieldByName('datatim2').AsFloat := Double(DtToXbase(n_tektime));
            FieldByName('entranc').AsInteger := DmMikkoServer.kodentrance;
            if (kodentrance = KOD_ENTRANCE_BELGOROD) then
            begin
              isNeedCommentOut := self.isNeedCommentOut(ASotrudInfo);//:= Now < DtFromXbase(TDateTime (ASotrudInfo.grTimeOut));
              if isNeedCommentOut then
              with FmAlert do
              begin
                Clear;
                AddLabel(' Необходимо прокоментировать уход раньше времени по графику',@RapLabel);
                AddButton('Комментарий! ('+sname+')',@RapBtn);
                ShowModal;
                FieldByName('com1').AsString := TextEdit('Комментарий выхода раньше времени',FieldByName('com1').AsString, true);
              end;
            end;
            try
              Post;
            except
              Delete;
              Raise;
            end;
          end;

    end;
  end;


end;

procedure TDmMikkoServer.RestoreConnect;
begin
  FServer.RtcHttpClient1.Disconnect;
  SetConnect;
  SetFilterDc162(0);
end;


procedure TDmMikkoServer.SetConnect;
begin
  try
    with FServer.RtcHttpClient1 do
    begin
      ServerAddr := FIni.ReadString('SERVER','HostName','localhost');
      ServerPort := FIni.ReadString('SERVER','Port','3039');
      Fkodentrance := FIni.ReadInteger('SET','kodentrance',KOD_ENTRANCE_MIKKO);
      FisCheckTimeOut := FIni.ReadBool('SET','isNeedCheckTimeOut',false);
      Connect();
      connect_handle := FServer.RtcConnect('vkorshun','enterprize',Fkodentrance) ;
      //fServer.RtcDataSetMonitor1.DataSet := ClientDataSetDc162;
    end;
  finally
//    FIni.Free;
  end;

end;

procedure TDmMikkoServer.SetFilterDc162(aIndex: Integer);
begin
  if fServer.CheckConnect=-1 then
  begin
    RestoreConnect;
  end;
  fServer.SetFilter(aIndex) ;

end;

procedure TDmMikkoServer.ShownotInGraphic(aKodKli: Integer);
begin
  with FmAlert do
  begin
    Clear;
    AddLabel(' Cотрудника  '+GetObjectName(akodKli),@RapLabel);
    AddLabel(' нет в графике ',@RapLabel);
    AddButton('На фабрику не пропускаем',@RapBtn);
    ShowModal;
    Exit;
  end;
end;

procedure TDmMikkoServer.ShownotInOmk(aKodKli: Integer);
var sList: TStringList;
    i: Integer;
    s: String;
begin
  sList := tStringList.Create;
  try
  with FmAlert do
  begin
    Clear;
//    AddLabel(' У сотрудника  '+DmAds.GetObjectName(akodKli),@RapLabel);
//    AddLabel(' выход заблокирован ОМК! ',@RapLabel);
    sList.Delimiter := #13;
    sList.DelimitedText := comment_omk;
    s := '';
    for I := 0 to sList.Count - 1 do
    begin
      s := s + sList[i]+' ';
      if (length(s)>40) or (i = Slist.Count-1 )then
      begin
        AddLabel(s,@RapLabel);
        s := '';
      end;
    end;
//    AddButton(' Не выпускать!',@RapBtn);
    MessageBeep(MB_ICONEXCLAMATION);
    MessageBeep(MB_ICONEXCLAMATION);
    MessageBeep(MB_ICONEXCLAMATION);
    MessageBeep(MB_ICONEXCLAMATION);
    MessageBeep(MB_ICONEXCLAMATION);

    ShowModal;
  end;
  finally
    sList.Free;
  end;

end;


procedure TDmMikkoServer.UnLock;
begin
  ReleaseSemaphore(hSignal,1,nil);
end;


function TDmMikkoServer.ValidBarcode(pBarcode: PAnsiChar): Boolean;
var aBuf:array[0..12] of AnsiChar ;
begin
  FillChar(aBuf,13,#0) ;
  StrLCopy(aBuf,pBarCode,12);
  result := (GetControlOrder(aBuf)=pBarCode[12]);
end;

end.
