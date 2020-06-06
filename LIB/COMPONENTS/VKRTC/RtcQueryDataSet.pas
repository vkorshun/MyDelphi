unit RtcQueryDataSet;

interface

uses
  SysUtils, Classes, rtcFunction, rtcDataCli, rtcCliModule, rtcInfo, rtcConn, rtcHttpCli, rtcLog,
  rtcDB, DB, MemTableDataEh,MemTableEh, variants, rtcSqlQuery,DataDriverEh,
  doc.variablelist, Dialogs, RtcService;

type
  TUpdateOrInsertEvent = procedure (Sender:TObject; ANew: Boolean) of object;

  TRtcQueryDataSet = class(TComponent)
  private
    FbNew: Boolean;
    FFieldList: TStringList;
    FDinamicSQL: Boolean;
    FSQLLock: TStringList;
    FSQLUpdate: TStringList;
    FSQLInsert: TStringList;
    FSQLDelete: TStringList;
    FMemTableEh: TMemTableEh;
    FRtcQuery: TRtcQuery;
    FRtcMapQuery: TRtcQuery;
    FRtcExecute: TRtcSqlExecute;
    FGenID: String;
    FTableName: String;
    FKeyFields: String;
    FKeyValues: Variant;
//    FDatasetDriverEh: TDataSetDriverEh;
    FTableVariableList: TDocVariableList;
    FOnStoreVariables: TNotifyEvent;
    FOnUpdateOrInsert: TUpdateOrInsertEvent;
    FOnDelete: TNotifyEvent;
    FInternalMemtableEh: TMemTableEh;
    FMemTableEhAfterEdit: TDataSetNotifyEvent;
    FMemTableEhAfterInsert: TDataSetNotifyEvent;
    FMemTableEhAfterOpen: TDataSetNotifyEvent;
    FMemTableEhBeforePost: TDataSetNotifyEvent;
    FMemTableEhBeforeDelete: TDataSetNotifyEvent;

    procedure CheckMemtableEh;
    procedure InternalBeforePost(DataSet:TDataSet);
    procedure InternalAfterInsert(DataSet:TDataSet);
    procedure InternalAfterEdit(DataSet:TDataSet);
    procedure InternalBeforeDelete(DataSet:TDataSet);
    procedure InternalBeforeEdit(DataSet:TDataSet);
    procedure InternalBeforeInsert(DataSet:TDataSet);
    procedure InternalMemtableEhEventsDisable;
    procedure InternalMemtableEhEventsEnable;
    procedure SetMemTableEh(const Value: TMemTableEh);

    function GetKeyValues:Variant;
    function GetSQLSelect: TStringList;
//    procedure SetDataSetDriverEh(const Value: TDataSetDriverEh);
    procedure UpdateOrInsertData(ANew:Boolean);
    procedure DeleteData;
    procedure DinamicSQLInsert;
    procedure DinamicSQlUpdate;
    procedure DinamicSQlDelete;
    function GetWhereOnKeyFields:String;
    function GetActive: Boolean;
    function GetParams:TParams;
    procedure SetActive(const Value: Boolean);
    procedure SetTableName(const Value: String);
  public
    constructor Create(AOwner:TComponent;ACurrentUser:PRtcServiceUser);reintroduce;
    destructor Destroy;override;
    procedure Close;
    procedure Clear;
    procedure DataSetDriverEhUpdateRecord(DataDriver: TDataDriverEh;
      MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh); Virtual;
    procedure InitAllSQL(const ATableName:String ='';const AKeyFields:String =''; const AGenId : String = '');
    function FieldByName(const AName:String):TField;
    function Bof: Boolean;
    function Eof: Boolean;
    function IsEmpty: Boolean;
    procedure First;
    procedure FullRefresh;
    procedure Next;
    procedure Open(isRefresh: boolean = false);
    procedure Prior;
    procedure MoveBy(destination: Integer);
    function Locate(const KeyFields: string; const KeyValues: Variant;  Options: TLocateOptions): Boolean ;

    procedure Append;
    procedure Cancel;
    procedure Delete;
    procedure Edit;
    procedure Post;

    procedure DisableControls;
    procedure EnableControls;
    function GetBookmark: TBookMark;
    procedure GotoBookmark(ABk:TBookmark);
    procedure FreeBookmark(ABk:TBookmark);

    function ParamByName(const AParamName:String):TParam;

    class procedure UpdateVariablesOnDeltaDs(DataSet: TDataSet;
      aVarList: TDocVariableList);

    property Active:Boolean read GetActive write SetActive;
    property TableName: String read FTableName write SetTableName;
    property GenId: String read FgenId write FGenId;
    property SQL: TStringList read GetSQLSelect;
    property SelectSQL: TStringList read GetSQLSelect;
    property UpdateSQL: TStringList read FSQLUpdate;
    property InsertSQL: TStringList read FSQlInsert;
    property DsMemTableEh: TMemTableEh read FMemTableEh write SetMemTableEh;
//    property DataSetDriverEh: TDataSetDriverEh read FDatasetDriverEh
//      write SetDataSetDriverEh;
    property RtcQuery:TRtcQuery read FRtcQuery;
    property KeyFields:String read FKeyFields;
    property Params:TParams read GetParams;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
    property OnUpdateOrInsert: TUpdateOrInsertEvent read    FOnUpdateOrInsert write FOnUpdateOrInsert;

  end;

implementation

{ TRtcQueryDataSet }

procedure TRtcQueryDataSet.InternalAfterEdit(DataSet: TDataSet);
begin
  FbNew := False;
  if Assigned(FMemTableEhAfterEdit) then
    FMemTableEhAfterEdit(DataSet)
end;

procedure TRtcQueryDataSet.InternalAfterInsert(DataSet: TDataSet);
begin
  FbNew := True;
  if Assigned(FMemTableEhAfterInsert) then
    FMemTableEhAfterInsert(DataSet)
end;

procedure TRtcQueryDataSet.InternalBeforeDelete(DataSet: TDataSet);
begin
  //CalcVariablesOnDs(FMemtableEh,FTableVariableList);
  if Assigned(FMemTableEhBeforeDelete) then
    FMemTableEhBeforeDelete(DataSet);
  //DeleteData;
end;

procedure TRtcQueryDataSet.InternalBeforeEdit(DataSet: TDataSet);
begin
 // CalcVariablesOnDs(FMemtableEh,FTableVariableList);
end;

procedure TRtcQueryDataSet.InternalBeforeInsert(DataSet: TDataSet);
begin
  FTableVariableList.InitBlank;
end;

procedure TRtcQueryDataSet.InternalBeforePost(DataSet: TDataSet);
begin
  if Assigned(FMemTableEhBeforePost) then
    FMemTableEhBeforePost(DataSet);

{  UpdateVariablesOnDeltaDs(FMemTableEh, FTableVariableList);

  if Assigned(FOnStoreVariables) then
    FOnStoreVariables(self);

  UpdateOrInsertData(FbNew);}
end;

procedure TRtcQueryDataSet.InternalMemtableEhEventsDisable;
begin
  if Assigned(FMemTableEh) then
  begin
    FMemTableEh.AfterInsert := nil;
    FMemTableEh.AfterEdit := nil;
    FMemTableEh.BeforeDelete := nil;
    FMemTableEh.BeforePost := nil;
    FMemTableEh.BeforeInsert := nil;
    FMemTableEh.BeforeEdit := nil;
  end;
end;

procedure TRtcQueryDataSet.InternalMemtableEhEventsEnable;
begin
  if Assigned(FMemTableEh) then
  begin
    FMemTableEh.AfterInsert := InternalAfterInsert;
    FMemTableEh.AfterEdit := InternalAfterEdit;
    FMemTableEh.BeforeDelete := InternalBeforeDelete;
    FMemTableEh.BeforePost := InternalBeforePost;
    FMemTableEh.BeforeInsert := InternalBeforeInsert;
    FMemTableEh.BeforeEdit := InternalBeforeEdit;
  end;
end;

function TRtcQueryDataSet.IsEmpty: Boolean;
begin
  Result := Assigned(FMemTableEh) and FMemTableEh.IsEmpty;
end;

function TRtcQueryDataSet.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  Result := FMemTableEh.Locate(KeyFields,KeyValues,Options);
end;

procedure TRtcQueryDataSet.MoveBy(destination: Integer);
begin
  FMemTableEh.MoveBy(destination);
end;

procedure TRtcQueryDataSet.Append;
begin
  FMemTableEh.Append;
end;

function TRtcQueryDataSet.Bof: Boolean;
begin
  Result := FMemTableEh.Bof;
end;


procedure TRtcQueryDataSet.Cancel;
begin
  FMemTableEh.Cancel;
end;

procedure TRtcQueryDataSet.CheckMemtableEh;
begin
  if not Assigned(FMemTableEh) then
    SetMemTableEh(FInternalMemtableEh);
  if (FMemTableEh.Filter.Length > 0) then
  begin
    FMemTableEh.Filter := '';
  end;

end;

procedure TRtcQueryDataSet.Clear;
begin
  FMemTableEh.EmptyTable;
end;

procedure TRtcQueryDataSet.Close;
begin
  if Assigned(FMemTableEh) then
    FMemTableEh.Active := False;
  FRtcQuery.Close;
end;

constructor TRtcQueryDataSet.Create(AOwner:TComponent;ACurrentUser:PRtcServiceUser);
begin
  inherited Create(AOwner);
  FSQLLock := TStringList.Create;
  FSQLUpdate := TStringList.Create;
  FSQLInsert := TStringList.Create;
  FSQLDelete := TStringList.Create;
  FRtcQuery := TRtcQuery.Create(self,ACurrentUser);
  FRtcMapQuery:= TRtcQuery.Create(self,ACurrentUser);
  FRtcExecute := TRtcSqlExecute.Create(self,ACurrentUser);
  FDinamicSQL := True;
  FFieldList := TStringList.Create;
  FTableVariableList := TDocVariableList.Create(nil);
//  FDatasetDriverEh:= TDataSetDriverEh.Create(nil);
  FInternalMemtableEh := TMemTableEh.Create(nil);
end;

procedure TRtcQueryDataSet.DataSetDriverEhUpdateRecord(DataDriver: TDataDriverEh;
  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
var
  bNew: boolean;
begin

  if FTableVariableList.Count=0 then
    Exit;
    UpdateVariablesOnDeltaDs(FMemTableEh, FTableVariableList);
  bNew := False;
  if (MemRec.UpdateStatus = usInserted) then
  begin
    {if FDocVariableList.VarByName('koddoc').AsInteger = 0 then
      FDocVariableList.VarByName('koddoc').AsInteger :=
        FMemTableEhDoc.FieldByName('koddoc').AsInteger;
    if FDocVariableList.VarByName('koddoc').AsInteger = 0 then
      Raise Exception.Create(' Нулевой koddoc.');
    // FDmMikkoAds.EditDoc(True,FDocVariableList.VarByName('koddoc').AsInteger,FIdReg,FIdPriznak,FDocVariableList,False,'');}
    bNew := True;
  end;

  if Assigned(FOnStoreVariables) then
    FOnStoreVariables(self);
  if (MemRec.UpdateStatus = usModified) or
    (MemRec.UpdateStatus = usInserted) then
  begin
    UpdateOrInsertData(bNew);//, FDocVariableList.VarByName('koddoc').AsInteger,
      //FIdReg, FIdPriznak, FDocVariableList, False, '');
  end
  else if (MemRec.UpdateStatus = usDeleted) then
    DeleteData;
    {FDmMikkoads.DeleteDoc(FIdReg, FIdPriznak,
      FDocVariableList.VarByName('koddoc').AsInteger, '');
     }

end;

procedure TRtcQueryDataSet.Delete;
begin
  FMemTableEh.Delete;
end;

procedure TRtcQueryDataSet.DeleteData;
var i: integer;
begin
  {DinamicSQLDelete;

  with FRtcExecute do
  begin
    SQL.Clear;
    SQL.Add(FSQLDelete.Text);
    for i := 0 to Params.Count-1 do
      Params[i].Value := FTableVariableList.VarByName(Params[i].Name).Value;
    ExecQuery(ttStability);
  end; }
  //if Assigned(FOnDelete) then
  //  FOnDelete(self);
end;

destructor TRtcQueryDataSet.Destroy;
begin
  FreeAndNil(FSQLLock);
  FreeAndNil(FSQLUpdate);
  FreeAndNil(FSQLInsert);
  FreeAndNil(FSQLDelete);
  FreeAndNil(FRtcQuery);
  FreeAndNil(FRtcExecute);
//  FreeAndNil(FDatasetDriverEh);
  FreeAndNil(FFieldList);
  FreeAndNil(FTableVariableList);
  FreeAndNil(FInternalMemtableEh);
  inherited;
end;

procedure TRtcQueryDataSet.DinamicSQlDelete;
begin
  if FDinamicSQL then
  begin
    FSQLDelete.Clear;
    FSQLDelete.Add(' DELETE FROM '+FTableName);
//    FSQLDelete.Add(' WHERE ');
    FSQLDelete.Add(GetWhereOnKeyFields);
  end;
end;

procedure TRtcQueryDataSet.DinamicSQLInsert;
var i: Integer;
begin
  with FSQLInsert do
  begin
    Clear;
    Add(' INSERT INTO '+FTableName);
    Add('(');
    for I := 0 to FTableVariableList.Count-1 do
    begin
      Add(FTableVariableList.Items[i].Name);
      if i<FTableVariableList.Count-1 then
        Add(',')
    end;
    Add(')');
    Add(' VALUES (');
    for I := 0 to FTableVariableList.Count-1 do
    begin
      Add(':'+FTableVariableList.Items[i].name);
      if i<FTableVariableList.Count-1 then
        Add(',')
    end;
    Add(')');
  end;
end;

procedure TRtcQueryDataSet.DinamicSQlUpdate;
var i: Integer;
    _UpdateList: TStringList;
begin

  _UpdateList := TStringList.Create;
  try
    FTablevariableList.GetChangedList(_UpdateList);

  with FSQLUpdate do
  begin
    Clear;
    Add(' UPDATE '+FTableName);
    Add(' SET');
    for I := 0 to _UpdateList.Count-1 do
    begin
      if FTableVariableList.VarByName(_UpdateList[i]).IsDelta then
        Add(_UpdateList[i]+' = '+_UpdateList[i]+'+:'+_UpdateList[i])
      else
        Add(_UpdateList[i]+' = :'+_UpdateList[i]);
      if i<_UpdateList.Count-1 then
        Add(',')
    end;
    Add(GetWhereOnKeyFields);
  end;
  finally
    FreeandNil(_UpdateList);
  end;
end;

procedure TRtcQueryDataSet.DisableControls;
begin
  FMemTableEh.DisableControls;
end;

procedure TRtcQueryDataSet.Edit;
begin
  FMemTableEh.Edit;
end;

procedure TRtcQueryDataSet.EnableControls;
begin
  FMemTableEh.EnableControls;
end;

function TRtcQueryDataSet.Eof: Boolean;
begin
  Result := FMemTableEh.Eof;
end;

function TRtcQueryDataSet.FieldByName(const AName: String): TField;
begin
  Result := FMemTableEh.FieldByName(AName);
end;

procedure TRtcQueryDataSet.First;
begin
  FMemTableEh.First;
end;

procedure TRtcQueryDataSet.FreeBookmark(ABk: TBookmark);
begin
  FMemTableEh.FreeBookmark(ABk);
end;

procedure TRtcQueryDataSet.FullRefresh;
begin
  FMemTableEh.DisableControls;
  try
    if FMemTableEh.Active then
    begin
      FKeyValues := GetKeyValues;
      Clear;
      Open(True);
//    FRtcQuery.Select(FMemTableEh);
      FMemTableEh.Locate(FKeyFields,FkeyValues,[loCaseInsensitive]);
    end
    else
      Open;
  finally
    FMemTableEh.EnableControls;
  end;
end;

function TRtcQueryDataSet.GetActive: Boolean;
begin
  Result := FMemTableEh.Active;
end;

function TRtcQueryDataSet.GetBookmark: TBookMark;
begin
  Result := FMemTableEh.GetBookmark;
end;

function TRtcQueryDataSet.GetKeyValues: Variant;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;
  try
    sList.Delimiter := ';';
    sList.DelimitedText := FKeyFields;
    if sList.Count = 0 then
      Result := null
    else if sList.Count = 1 then
      Result := FMemTableEh.FieldByName(sList[0]).Value
    else
    begin
      Result := VarArrayCreate([0, sList.Count-1], varvariant);
      for i := 0 to sList.Count-1 do
        Result[0] := FMemTableEh.FieldByName(sList[i ]).Value;
    end;
  finally
    sList.Free;
  end;
end;

function TRtcQueryDataSet.GetParams: TParams;
begin
  Result := FRtcQuery.Params;
end;

function TRtcQueryDataSet.GetSQLSelect: TStringList;
begin
  Result := FRtcQuery.SQL;
end;

function TRtcQueryDataSet.GetWhereOnKeyFields: String;
var
  _List: TStringList;
  i: Integer;
begin
  _List := TStringList.Create;
  try
    _List.Delimiter := ';';
    _List.DelimitedText := FKeyFields;
    if _List.Count = 0 then
      Result := ''
    else if _List.Count = 1 then
      Result := ' WHERE '+_List[0]+' = :' +_List[0]
    else
    begin
      Result := ' WHERE ';
      for i := 0 to _List.Count-1 do
      begin
        Result := Result + _List[i]+' = :'+ _List[i];
        if i< _List.Count-1 then
          Result := Result + ' AND ';
      end;
    end;
  finally
    _List.Free;
  end;
end;

procedure TRtcQueryDataSet.GotoBookmark(ABk: TBookmark);
begin
  FMemTableEh.GotoBookmark(ABk);
end;

procedure TRtcQueryDataSet.InitAllSQL(const ATableName, AKeyFields, AGenId: String);
begin
  if ATableName<>'' then
    FTableName := UpperCase(ATableName);

  if AKeyFields<>'' then
    FKeyFields := UpperCase(AKeyFields);

  if AGenId<>'' then
    FGenId := UpperCase(AGenId);


end;


procedure TRtcQueryDataSet.Next;
begin
  FMemTableEh.Next;
end;

procedure TRtcQueryDataSet.Open;
begin
  CheckMemTableEh;
  InternalMemtableEhEventsDisable;
  try
    FRtcQuery.Select(FMemTableEh, isRefresh);
//  FDatasetDriverEh.ProviderDataSet := TDataSet(FRtcQuery.QrResult.asDataSet);
    if Assigned(FMemTableEhAfterOpen) then
      FMemTableEhAfterOpen(FMemTableEh);
  finally
    InternalMemtableEhEventsEnable;
  end;
end;

function TRtcQueryDataSet.ParamByName(const AParamName: String): TParam;
begin
  Result := FRtcQuery.ParamByName(AParamName);
end;

procedure TRtcQueryDataSet.Post;
begin
  FMemTableEh.Post;
end;

procedure TRtcQueryDataSet.Prior;
begin
  FMemTableEh.Prior;
end;

procedure TRtcQueryDataSet.SetActive(const Value: Boolean);
begin
  if Value  then
    Open
  else
    Close;
end;

{procedure TRtcQueryDataSet.SetDataSetDriverEh(const Value: TDataSetDriverEh);
begin
  FDatasetDriverEh := Value;
  FDatasetDriverEh.OnUpdateRecord := DataSetDriverEhUpdateRecord;
end; }

procedure TRtcQueryDataSet.SetMemTableEh(const Value: TMemTableEh);
begin
  if (FMemTableEh <> Value) then
  begin
    FMemTableEh := Value;

    FMemTableEhAfterOpen := FMemTableEh.AfterOpen;
    FMemTableEhAfterEdit := FMemTableEh.AfterEdit;
    FMemTableEhAfterInsert := FMemTableEh.AfterInsert;
    FMemTableEhBeforeDelete := FMemTableEh.BeforeDelete;
    FMemTableEhBeforePost := FMemTableEh.BeforePost;
  end;
  FMemTableEh.AfterOpen := nil;

//  FMemTableEh.DataDriver := FDatasetDriverEh;
end;

procedure TRtcQueryDataSet.SetTableName(const Value: String);
begin
  FTableName := UpperCase(Value);
end;

procedure TRtcQueryDataSet.UpdateOrInsertData(ANew: Boolean);
var i: Integer;
begin
  {if FDinamicSQL then
  begin
    if ANew then
      DinamicSQLInsert
    else
      DinamicSQLUpdate;
  end;

  FRtcExecute.SQL.Clear;
  if ANew then
    FRtcExecute.SQL.Add(FSQLInsert.Text)
  else
  begin
    FRtcExecute.SQL.Add(FSQLUpdate.Text)
  end;
  for i := 0 to FRtcExecute.Params.Count-1 do
    FRtcExecute.Params[i].Value := FTableVariableList.VarByName(FRtcExecute.Params[i].Name).Value;
  FRtcExecute.ExecQuery(ttStability);
  }
//  if Assigned(FOnUpdateOrInsert) then
//    FOnUpdateOrInsert(self, ANew)
end;

class procedure TRtcQueryDataSet.UpdateVariablesOnDeltaDs(DataSet: TDataSet; aVarList: TDocVariableList);
var i: Integer;
    ind: Integer;
begin
  with DataSet do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[i].NewValue<> Unassigned then
      begin
        ind := aVarList.IndexOf(Fields[i].FieldName) ;
        if ind>-1 then
         try
            aVarList.Items[ind].Value := Fields[i].Value;
         except
           ShowMessage('Name '+Fields[i].FieldName+', Index - '+IntToStr(ind));
           Raise;
         end;
      end;
    end;
  end;
end;

end.
