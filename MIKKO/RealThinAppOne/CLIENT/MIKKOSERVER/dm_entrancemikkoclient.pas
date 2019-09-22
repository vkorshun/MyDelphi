unit dm_entrancemikkoclient;

interface

uses
  SysUtils, Classes, Windows,rtcConn, rtcDataCli, rtcHttpCli, rtcInfo, rtcCliModule, Dialogs, rtcFunction,
  rtcDB,  DB, DbClient, Variants, DateVk, MemTableDataEh, MemTableEh, hostdate, rtcSyncObjs, sotrudinfo;

type
  TDmEntranceMikkoClient = class(TDataModule)
    RtcClientModule1: TRtcClientModule;
    RtcHttpClient1: TRtcHttpClient;
    RtcResult1: TRtcResult;
    MemTableEhDc162: TMemTableEh;
    RtcDataSetMonitor1: TRtcDataSetMonitor;
    procedure RtcResult1Return(Sender: TRtcConnection; Data, Result: TRtcValue);
//    procedure RtcDataSetMonitor1DataChange(Sender: TObject);
//    procedure RtcMemDataSetDc162DataChange(Sender: TObject);
//    procedure RtcMemDataSetDc162BeforePost(DataSet: TDataSet);
    procedure MemTableEhDc162AfterOpen(DataSet: TDataSet);
    procedure MemTableEhDc162BeforePost(DataSet: TDataSet);
    procedure RtcDataSetMonitor1DataChange(Sender: TObject);
    procedure RtcHttpClient1Disconnect(Sender: TRtcConnection);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    cs: TRtcCritSec;
    localid: Integer;
    procedure OnGetTextDt(Sender: TField; var Text: string; DisplayText: Boolean);
    function getNextLocalId: Integer;
  public
    { Public declarations }

    function AddFingerUser( UserID:Integer; aData:String; IdFinger:Integer):Integer;
    function RtcConnect(const ausername, apassword:String; akodentrance:Integer):Integer;
//    function GetKodkliByFinger( UserID:String; aData:String;var  rCode:Integer):Integer;
    procedure DeleteFingerUser(UserId:Integer);
    function DtFromXbase(aDt:TdateTime):TDateTime;
    function GetDataUvl(aKodKli:Integer):TDateTime;
//    function GetKodkliByFinger( UserID:String; aData:String;var  rCode:Integer):Integer;overload;
    function GetKodkliByFinger( UserID:String; aData:RtcByteArray;var  rCode:Integer):TRtcRecord;overload;
    function GetKodkliByBarcode( kodkli:Integer;var  rCode:Integer):TRtcRecord;overload;
    function GetClientDataSetDc167:TRtcValue;
    function GetServerTime:TDateTime;
    function GetSystemTime:TDateTime;
    procedure SetFilterOnDc162(aIndex:Integer);
//    function EchoString(Value: string): string;
//    function ReverseString(Value: string): string;
    procedure ClearOldData;
    procedure Prepare;
    procedure SetFilter(aIndex:Integer);
    function ValidGroup(aKodKli:Integer):Boolean;

    ///<summary> Проверка связи </summary>
    function CheckConnect:Integer;
    procedure TryConnect;
    ///<summary> Возвращает результат запроса cQuery </summary>
    function QueryValue(const cQuery:String):String;
    ///<summary> Проверка графика </summary>
    function  ValidGraphic(aKodSotrud:Integer):Boolean;
    ///<summary> Проверка отпуска </summary>
    function  ValidHoliday(aKodSotrud:Integer):Boolean;
    ///<summary> Проверка ОМК </summary>
    function  ValidOmk(aKodSotrud:Integer):Boolean;
    function GetGrTimeOut(aKodSotrud: Integer): Double;

  end;

var
  DmEntranceMikkoClient: TDmEntranceMikkoClient;

implementation

{$R *.dfm}
uses dm_mikkoserver, Fm_Mikko_Entrance;

{ TDmEntranceMikkoClient }

function TDmEntranceMikkoClient.AddFingerUser(UserID: Integer; aData: String; IdFinger: Integer): Integer;
var
  mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('AddFingerUser') do
    begin
      Param.AsInteger['userid'] := UserId;
      Param.asWideString['aData'] := aData;
      Param.asInteger['idfinger'] := IdFinger;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asInteger;
      finally
        FreeAndNil(mResult);
      end;
     end;
   end;

end;

function TDmEntranceMikkoClient.CheckConnect: Integer;
var mResult: TRtcValue;
begin
  with RtcClientModule1 do
  begin
    with Prepare('CheckConnect') do
    begin
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Result := -1 //Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asInteger;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TDmEntranceMikkoClient.ClearOldData;
begin
  with RtcClientModule1 do
  begin
    with Prepare('ClearOldData') do
    begin
      Execute(True);
    end;
  end;
end;

procedure TDmEntranceMikkoClient.DataModuleCreate(Sender: TObject);
begin
  localid := 0;
  cs := TRtcCritSec.Create;
end;

procedure TDmEntranceMikkoClient.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(cs);
end;

procedure TDmEntranceMikkoClient.DeleteFingerUser(UserId: Integer);
begin
  with RtcClientModule1 do
  begin
    with Prepare('DeleteFingerUser') do
    begin
      Param.AsInteger['userid'] := UserId;
      Execute(True);
     end;
   end;
end;

function TDmEntranceMikkoClient.DtFromXbase(aDt: TdateTime): TDateTime;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('DtFromXbase') do
    begin
      Param.asDateTime['aDt'] := aDt;
      try
        mResult := Execute(False);
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asDateTime;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.GetClientDataSetDc167: TRtcValue;
var mResult: TRtcValue;
begin
  Result := nil;
  with RtcClientModule1 do
  begin
    with Prepare('GetClientDataSetDc167') do
    begin
      //Param.asInteger['aKodkli'] := aKodKli;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          //Result := TRtcDataSet.Create;
          Result := mresult;
      except
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.GetDataUvl(aKodKli: Integer): TDateTime;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('GetDataUvl') do
    begin
      Param.asInteger['aKodkli'] := aKodKli;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asDateTime;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

function TDmEntranceMikkoClient.GetKodkliByBarcode(kodkli: Integer;
  var rCode: Integer): TRtcRecord;
var mResult: TRtcValue;
begin
  with RtcClientModule1 do
  begin
    with Prepare('GetKodkliByBarcode') do
    begin
      Param.asInteger['kodkli'] := kodkli;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
        begin
          Result := TRtcRecord(mResult.copyOf);
          rCode := 0;
        end;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.GetKodkliByFinger(UserID: String; aData: RtcByteArray; var rCode: Integer): TRtcRecord;
var mResult: TRtcValue;
//    bs: TBytesStream;
    i: integer;
begin
  Result := nil;
//  bs := TBytesStream.Create;
//  bs.SetSize(length(adata));
//  for I := 0 to bs.Size-1 do
//    bs.Bytes[i] := adata[i];
  with RtcClientModule1 do
  begin
    with Prepare('GetKodkliByFinger') do
    begin
      Param.asWideString['UserId'] := UserId;
      Param.asByteArray['adata'] := Mime_EncodeEx(aData);
      Param.asInteger['rCode'] := rCode;

      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
        begin
          Result := TRtcRecord(mResult.copyOf);
          rCode := 0;
        end;
      finally
        FreeAndNil(mResult);
//        FreeAndNil(bs);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.getNextLocalId: Integer;
begin
  cs.Acquire;
  try
    Inc(localid);
    Result := localid;
  finally
    cs.Release;
  end;
end;

{function TDmEntranceMikkoClient.GetKodkliByFinger(UserID, aData: String; var rCode: Integer): Integer;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('GetKodkliByFinger') do
    begin
      Param.asWideString['UserId'] := UserId;
      Param.asWideString['adata'] := aData;
      Param.asInteger['rCode'] := rCode;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
        begin
          rCode := result;
          Result := TRtcRecord(mResult.copyOf).asInteger[FLD_KODKLI];
        end;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;}

function TDmEntranceMikkoClient.GetServerTime: TDateTime;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('GetServerTime') do
    begin
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asDateTime;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.GetSystemTime: TDateTime;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('GetSystemTime') do
    begin
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := SysDtToLocalTimeZone(mResult.asDateTime);
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;


procedure TDmEntranceMikkoClient.MemTableEhDc162AfterOpen(DataSet: TDataSet);
var i: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
      Fields[i].Visible := False;

    if FieldCount=0 then
    begin
      PostMessage(DmMikkoServer.Fm.Handle,WM_REFRESH,0,0);
      Exit;
    end;

    with FieldByName('name') do
    begin
      Index        := 0;
      DisplayLabel := 'Сотрудник';
      Visible      := True;
    end;

    with FieldByName('datatim1') do
    begin
      Index        := 1;
      DisplayLabel := 'Время прихода';
      Visible      := True;
      OngetText := OnGetTextDt;
      Alignment     := taLeftJustify;
    end;

    with FieldByName('prih') do
    begin
      Index        := 2;
      DisplayLabel := 'О';
      Visible      := True;
    end;

    with FieldByName('datatim2') do
    begin
      Index        := 3;
      DisplayLabel := 'Время ухода';
      Visible      := True;
      OngetText := OnGetTextDt;
      Alignment     := taLeftJustify;
    end;

    with FieldByName('uh') do
    begin
      Index        := 4;
      DisplayLabel := 'У';
      Visible      := True;
    end;

    with FieldByName('data') do
    begin
      Index        := 5;
      DisplayLabel := 'Дата';
      Visible      := True;
    end;

    with FieldByName('propusk') do
    begin
      Index        := 6;
      DisplayLabel := 'C пр.';
      Visible      := True;
    end;

    with FieldByName('com1') do
    begin
      Index        := 7;
      DisplayLabel := 'Комментарий';
      Visible      := True;
      DisplayWidth := 60;
    end;


  end;

  if Assigned(DmMikkoServer.Fm) then
  with TFmMikko_Entrance(DmMikkoServer.Fm) do
  begin
    {if not ListColumnsparams.bInit then
    begin
      InitListDbGridColumnsParams;
    end;
  //  DbGridEhvk1.
    SetDbGridColumnsSize(ListColumnsParams);
     }
    if DbGridEhVk1.Columns.Count=1 then
    begin
      PostMessage(DmMikkoServer.Fm.Handle,WM_DATASETOPEN,0,0);
      Exit;
    end;

    if not DbGridEhvk1.ListDbGridColumnsParam.bInit then
    begin
      DbGridEhvk1.ListDbGridColumnsParam.RegKey := sRootKey+'\DbGridEhVk1_entrance\';
      DbGridEhvk1.ListDbGridColumnsParam.InitFromReg;
    end;
    DbGridEhvk1.SetDbGridColumnsSize(nil);
    for I := 0 to DbGridEhVk1.Columns.Count - 1 do
    begin
      if  (DbGridEhVk1.Columns[i].FieldName ='prih') or
        (DbGridEhVk1.Columns[i].FieldName ='uh') or
        (DbGridEhVk1.Columns[i].FieldName ='PROPUSK')
      then
      begin
         if DbGridEhVk1.Columns[i].FieldName <>'PROPUSK' then
           DbGridEhVk1.Columns[i].KeyList.Add('1')
         else
         begin
           DbGridEhVk1.Columns[i].KeyList.Add('0');
           DbGridEhVk1.Columns[i].KeyList.Add('2');
         end;
         DbGridEhVk1.Columns[i].ImageList := ImageList1;
      end;
    end;
  end;


end;

procedure TDmEntranceMikkoClient.MemTableEhDc162BeforePost(DataSet: TDataSet);
var i: Integer;
begin
 with DataSet do
 begin
//    if length(FieldByName('name').AsString)=0 then
//      FieldByName('name').AsString := QueryValue(' SELECT name FROM client WHERE kodkli='+
//        FieldByName('kodkli').AsString);
    if FieldByName('datatim1').AsFloat>0 then
      FieldByname('prih').AsInteger := 1;
    if FieldByName('datatim2').AsFloat>0 then
      FieldByname('uh').AsInteger := 1;
    if FieldByName('localid').AsInteger = 0 then
      FieldByName('localid').AsInteger := getNextLocalId;
//    TryConnect;
 end;
end;

procedure TDmEntranceMikkoClient.OnGetTextDt(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if CoalEsce(Sender.value,0)<>0 then
    Text := DmMikkoserver.GetDateTimeStr(DmMikkoserver.DtFromXbase( CoalEsce(Sender.value,0)))
  else
    Text := '';
end;

procedure TDmEntranceMikkoClient.Prepare;
begin
  //RtcDataSetMonitor1.DataSet := DmMikkoServer.ClientDataSetDc162;
//  RtcDataSetMonitor2.DataSet := DmMikkoServer.ClientDataSetDc162;
end;

function TDmEntranceMikkoClient.QueryValue(const cQuery: String): String;
var mResult: TRtcValue;
begin
  with RtcClientModule1 do
  begin
    with Prepare('QueryValue') do
    begin
      Param.asWideString['cQuery'] := cQuery;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asWideString;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.RtcConnect(const ausername, apassword: String;
  akodentrance: Integer): Integer;
var mResult: TRtcValue;
begin
  Result := -1;
  with RtcClientModule1 do
  begin
    with Prepare('Connect') do
    begin
      Param.AsWideString['username'] := aUsername;
      Param.AsWideString['password'] := apassword;
      Param.asInteger['kodentrance'] := akodentrance;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          ShowMessage('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asInteger;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TDmEntranceMikkoClient.RtcDataSetMonitor1DataChange(Sender: TObject);
var
  data: TRtcValue;
  i: Integer;
begin
  data:=RtcDataSetMonitor1.ExtractChanges;

  if assigned(data) then
  begin
    RtcClientModule1.Prepare('editentrance'); // We will be calling the "submit" function on the Server
    RtcClientModule1.Param.asObject['delta_data']:=data; // "change_data" parameter is the result of "ExtractChanges"
    RtcClientModule1.Call(RtcResult1); // Make the remote call, sending the result to the "RtcResult1Return" event
  end;

end;

procedure TDmEntranceMikkoClient.RtcHttpClient1Disconnect(Sender: TRtcConnection);
begin
end;

{procedure TDmEntranceMikkoClient.RtcDataSetMonitor1DataChange(Sender: TObject);
var
  data: TRtcValue;
  i: Integer;
begin
  data:=RtcDataSetMonitor1.ExtractChanges;

  for I := 0 to RtcDataSetMonitor1.DataSet.Fields.Count do
    TRtcDataSetChanges(data).NewRow.FieldByName(RtcDataSetMonitor1.DataSet.Fields[i].FieldName).Value :=
      TClientDataSet(RtcDataSetMonitor1.DataSet).Fields[i].Value;

  if assigned(data) then
    begin
    RtcClientModule1.Prepare('editentrance'); // We will be calling the "submit" function on the Server
    RtcClientModule1.Param.asObject['delta_data']:=data; // "change_data" parameter is the result of "ExtractChanges"
    RtcClientModule1.Call(RtcResult1); // Make the remote call, sending the result to the "RtcResult1Return" event
  end;
end;}

{procedure TDmEntranceMikkoClient.RtcMemDataSetDc162BeforePost(DataSet: TDataSet);
var i: Integer;
begin
 with dataset do
 begin
    if FieldByName('datatim1').AsFloat>0 then
      FieldByname('prih').AsInteger := 1;
    if FieldByName('datatim2').AsFloat>0 then
      FieldByname('uh').AsInteger := 1;
 end;

end;}


procedure TDmEntranceMikkoClient.RtcResult1Return(Sender: TRtcConnection; Data, Result: TRtcValue);
var
  koddoc: Integer;
  response: TRtcArray;
  i: Integer;
  bk: TBookMark;
begin
{        if Result.isType=rtc_Exception then
        begin
          Raise Exception.Create('Server-side exception :'+#13#10+Result.asException);
        end;
   }
  koddoc := 0;
  if (Data.asFunction.FunctionName='SetFilter')
    or (Data.asFunction.FunctionName='SetFilterDc162') then
  begin
    if Result.isType=rtc_DataSet then
    begin
      { We have received fresh data from the Server, so we will fill our
        in-memory DataSet with it, replacing anything that might have been in there.

        In this example, we are using the TClientDataSet component included in Delphi,
        but the code below should also work for any other in-memory TDataSet descendant ... }

      // Disable DataSet Monitoring and visual Controls before populating the DataSet
      if MemTableEhDc162.Active  then
        koddoc := MemTableEhDc162.FieldByName('koddoc').AsInteger;
      RtcDataSetMonitor1.Active:=False;
      MemTableEhDc162.DisableControls;
      try
        MemTableEhDc162.Close;
        // Copy field definitions from RTC DataSet to our in-memory Client DataSet
        RtcDataSetFieldsToDelphi(Result.asDataSet, MemTableEhDc162);
        MemTableEhDc162.FieldDefs.Add('localid',
                           ftInteger,
                           0,
                           false);

        MemTableEhDc162.CreateDataSet;
        // Copy all data Rows from RTC DataSet to out in-memory Client DataSet
        RtcDataSetRowsToDelphi(Result.asDataSet, MemTableEhDc162);
      finally
        // Enable DataSet Monitoring and visual Controls afterwards
        MemTableEhDc162.EnableControls;
        RtcDataSetMonitor1.Active:=True;
        // Move to the 1st row to update visual Controls
        MemTableEhDc162.First;
        if koddoc>0 then
           MemTableEhDc162.Locate('koddoc',koddoc,[])
        else
           MemTableEhDc162.Last;

          //PostMessage(DmMikkoServer.Fm.Handle,WM_REFRESH,koddoc,koddoc);
      end;
{      with RtcMemDataSetDc162 do
      begin
        DisableControls;
        if Active  then
          koddoc := FieldByName('koddoc').AsInteger;
        //Active := False;
        try
          asObject:=Result.asDataSet;
          Result.Extract;
        finally
          Active:=True;
          EnableControls;
          First;
          PostMessage(DmMikkoServer.Fm.Handle,WM_REFRESH,koddoc,koddoc);
        end;
      end; }
    end
    else
    begin
      if Sender<>nil then // We should NOT use modal dialogs (ShowMessage) from the context of connection objects,
        PostInteractive; // so we HAVE TO EXIT the context of the connection object by using "PostInteractive".
      if Result.isType=rtc_Exception then
        ShowMessage('Server-side exception after Select:'+#13#10+Result.asException)
      else
        ShowMessage('Unexpected Result after Select');

    end;
  end;
  if (Data.asFunction.FunctionName='editentrance') then
  begin
    cs.Acquire;
    try
      if Result.isType=rtc_Array then
      begin
        RtcDataSetMonitor1.Active := False;
        try
          with MemTableEhDc162 do
          begin
            DisableControls;
            bk := MemTableEhDc162.GetBookmark;
            response :=  Result.asArray;
            for i := 0 to response.Count-1 do
            begin
              if response.asRecord[i].asInteger['localid']>0 then
              begin
                if MemTableEhDc162.Locate('localid', response.asRecord[i].asInteger['localid'],[]) then
                begin
                  if MemTableEhDc162.FieldByName('koddoc').AsInteger = 0 then
                  begin
                    Edit;
                    FieldByName('koddoc').AsInteger := response.asRecord[i].asInteger['koddoc'];
                    Post;
                  end;
                end;
              end;
            end;
          end;
        finally
          MemTableEhDc162.GotoBookmark(bk);
          MemTableEhDc162.FreeBookmark(bk);
          Result.Clear;
          //FreeAndNil(Result);
          MemTableEhDc162.EnableControls;
          RtcDataSetMonitor1.Active := True;
        end;
      end
      else
      begin
        if Sender<>nil then // We should NOT use modal dialogs (ShowMessage) from the context of connection objects,
          PostInteractive; // so we HAVE TO EXIT the context of the connection object by using "PostInteractive".

        if Result.isType=rtc_Exception then
          ShowMessage('Server-side exception after Select:'+#13#10+Result.asException)
        else
          ShowMessage('Unexpected Result after Select');
      end;
    finally
      cs.Release;
    end;
  end;

  {  if Data.asFunction.FunctionName='SetFilterDc162' then
  begin
    if Result.isType=rtc_DataSet then
    begin
      with RtcMemDataSetDc162 do
      begin
        Active := False;
        asObject:=Result.asDataSet;
        Result.Extract;
        Active:=True;
      end;
    end
    else
    begin
      if Sender<>nil then // We should NOT use modal dialogs (ShowMessage) from the context of connection objects,
        PostInteractive; // so we HAVE TO EXIT the context of the connection object by using "PostInteractive".

      if Result.isType=rtc_Exception then
        ShowMessage('Server-side exception after Select:'+#13#10+Result.asException)
      else
        ShowMessage('Unexpected Result after Select');
    end;
  end;  }
end;

procedure TDmEntranceMikkoClient.SetFilter(aIndex: Integer);
begin
  with RtcClientModule1 do
  begin
    with Prepare('SetFilter') do
    begin
      Param.asInteger['aIndex'] := aIndex;
      Call(RtcResult1);
    end;
  end;

end;

procedure TDmEntranceMikkoClient.SetFilterOnDc162(aIndex: Integer);
begin
  with RtcClientModule1 do
  begin
    with Prepare('SetFilterOnDc162') do
    begin
      Param.asInteger['aIndex'] := aIndex;
      Call(RtcResult1);
    end;
  end;
end;

procedure TDmEntranceMikkoClient.TryConnect;
begin
  if CheckConnect=-1 then
    DmMikkoServer.RestoreConnect;
end;

function TDmEntranceMikkoClient.ValidGraphic(aKodSotrud: Integer): Boolean;
var mResult: TRtcValue;
begin
  Result := False;
  with RtcClientModule1 do
  begin
    with Prepare('ValidGraphic') do
    begin
      Param.asInteger['aKodSotrud'] := aKodSotrud;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asBoolean;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.GetGrTimeOut(aKodSotrud: Integer): Double;
var mResult: TRtcValue;
begin
  Result := 0;
  with RtcClientModule1 do
  begin
    with Prepare('GetGrTimeOut') do
    begin
      Param.asInteger['aKodSotrud'] := aKodSotrud;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asFloat;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;


function TDmEntranceMikkoClient.ValidGroup(aKodKli: Integer): Boolean;
var mResult: TRtcValue;
begin
  Result := False;
  with RtcClientModule1 do
  begin
    with Prepare('ValidGroup') do
    begin
      Param.asInteger['aKodSotrud'] := aKodKli;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asBoolean;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.ValidHoliday(aKodSotrud: Integer): Boolean;
var mResult: TRtcValue;
begin
  Result := False;
  with RtcClientModule1 do
  begin
    with Prepare('ValidHoliday') do
    begin
      Param.asInteger['aKodSotrud'] := aKodSotrud;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asBoolean;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

function TDmEntranceMikkoClient.ValidOmk(aKodSotrud: Integer): Boolean;
var mResult: TRtcValue;
begin
  Result := False;
  with RtcClientModule1 do
  begin
    with Prepare('ValidOmk') do
    begin
      Param.asInteger['aKodSotrud'] := aKodSotrud;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asBoolean;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;

end;

end.
