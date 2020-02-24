unit rtc.dmDoc;

interface

uses
  SysUtils, Classes, MemTableDataEh, Db, MemTableEh, DataDriverEh,
  ClientDocSqlManager, VkVariable,
  Generics.Collections, vkdocinstance, Controls, vkvariablebinding,
  fmVkDocDialog, uDocDescription,
  Forms, Variants, VariantUtils, Dialogs, pFIBQueryVk, FIBDatabase,
  pFIBDatabase,
  FIBDataSet, pFIBDataSet, pFIBDataSetVk, FIBQuery, pFIBQuery, DmMainRtc,
  rtcInfo, rtcConn, rtcDataCli, rtcCliModule, commoninterface, RtcFuncResult,
  RtcQueryDataSet;

type
  TFieldViewState = (fvsRead, fvsInsert, fvsEdit);
  TOnStoreVariablesEvent = procedure(Sender: TObject; ASatatus: TUpdateStatus)
    of object;
  TOnWriteVariablesEvent = procedure(Sender: TObject; AInsert: Boolean)
    of object;
  TSetFilterNotifyEvent = procedure(aIndex: Integer; Sender: TObject) of object;
  TDocBoolNotifyEvent = function(Sender: TObject): Boolean of object;
  TTableEhEditEvent = procedure(Sender: TObject; const aFieldName: String)
    of object;
  TDmDocClass = class of TDocDm;
  TDocEditActionEvent = procedure(Sender: TObject; AInsert: Boolean) of object;

  { TDocProperti = class
    private
    FFieldName: String;
    FFieldLabel: String;
    DispalyWidth: Integer;
    FFieldViewState: TFieldViewState;
    public
    end; }

  TDocValidatorError = class(TComponent)
  private
    FErrorMessage: String;
    FVarName: string;
    procedure SetErrorMessage(const Value: String);
    procedure SetVarName(const Value: string);
  public
    property VarName: string read FVarName write SetVarName;
    property ErrorMessage: String read FErrorMessage write SetErrorMessage;
  end;

  TDocValidator = class(TComponent)
  private
    FLastError: TDocValidatorError;
    FNotNullList: TStringList;
    procedure SetNotNullList(const Value: TStringList);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;
    function Vilidate(Items: TVkVariableCollection): Boolean;
    function VilidateNotNull(Items: TVkVariableCollection): Boolean;

    property NotNullList: TStringList read FNotNullList write SetNotNullList;
    property LastError: TDocValidatorError read FLastError;
  end;

  TDocDm = class(TDataModule)
    MemTableEhDoc: TMemTableEh;
    DataSetDriverEhDoc: TDataSetDriverEh;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
      MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
    procedure DataModuleDestroy(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforeClose(DataSet: TDataSet);
    procedure VkUIBDataSetDocAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    FDmMain: TMainRtcDm;
    FDocInstance: TDocInstance;
    FDocSqlManager: TClientDocSqlManager;
    FDocStruDescriptionList: TDocStruDescriptionList;
    FDocValidator: TDocValidator;
    FLastRetval: IRtcFuncResult;
    FMarkList: TList<Variant>;
    FOnStoreVariables: TOnStoreVariablesEvent;
    FOnSetFilter: TSetFilterNotifyEvent;
    FOnInsertAdditionalFields: TNotifyEvent;
    FOnUpdateAdditionalFields: TNotifyEvent;
    FAdditionalDocAfterOpen: TDataSetNotifyEvent;
    FOnBeforeDocEdit: TDocBoolNotifyEvent;
    FOnBeforeDocDelete: TDocBoolNotifyEvent;
    FOnBeforeDocInsert: TDocBoolNotifyEvent;
    FOnAfterEditMemTableEhDoc: TTableEhEditEvent;
    FOnInitVariables: TDocEditActionEvent;
    FOnDocAfterOpen: TDataSetNotifyEvent;
    FOnDocBeforeClose: TDataSetNotifyEvent;
    FPrepared: Boolean;
    FOnFillKeyFields: TNotifyEvent;
    FOnWriteVariables: TOnWriteVariablesEvent;

    function GetDocVariableList: TVkVariableCollection;
    procedure SetPrepared(const Value: Boolean);
    procedure SetOnFillKeyFields(const Value: TNotifyEvent);
    procedure SetOnWriteVariables(const Value: TOnWriteVariablesEvent);
    procedure SetLastRetval(const Value: IRtcFuncResult);
  protected
    FIsInternalTransaction: Boolean;
    FGridOrderList: TStringList;
    FEditOrderList: TStringList;
    FDefineDebug: Boolean;
    FRtcQueryDataSet: TRtcQueryDataSet;
    //procedure DoInsertAdditionalFields;
    //procedure DoUpdateAdditionalFields;
    // procedure OnFillFiledList(Sender: TObject);
    procedure FillKeyFields;
    procedure rtcEditDoc(operation: TDocOperation);
  public
    { Public declarations }
    constructor Create(ADmMain: TMainRtcDm); reintroduce;
    function CursorIsChanged: Boolean;
    procedure DirectInsertDoc; virtual;
    procedure DirectEditDoc; virtual;
    procedure DirectDeleteDoc; virtual;
    function DoBeforeDocEdit: Boolean;
    function DoBeforeDocInsert: Boolean;
    procedure DoAfterEditMemTableEhDoc(ATable: TMemTableEh;
      const aFieldName: String);
    procedure InitClientSqlManager(const ATableName: String);
    procedure InitVariables(AInsert: Boolean);
    function GetFilterCaption: String; Virtual;
    function GetKey: Variant;
    // function GetDocStruItem(const aName: String): PDocStruDescriptionItem;
    function LocateDefaultValues(AVar: TVkVariableCollection): Boolean; virtual;
    // procedure LockDoc(ARecalc: Boolean = false); virtual;
    // procedure UnLockDoc(bCommit: Boolean = True); virtual;
    // function IsLocked: Boolean;
    procedure FullRefreshDoc(ARecalcVariables: Boolean = false);
    procedure Open;
    procedure ReInitVariables;
    procedure SetFilter(nIndex: Integer; Sender: TObject); virtual;
    procedure WriteVariables(AInsert: Boolean);
    function ValidFmEditItems(Sender: TObject): Boolean; virtual;
    procedure VarLog(AVarList: TVkVariableCollection);
    procedure DeleteDoc(ender: TObject);
    procedure UpdateOrInsert(Sender:TObject; bNew: Boolean);

    class procedure SetParamValues(AQuery: TpFIBQueryVk;
      AVarList: TVkVariableCollection);
    class function GetDm: TDocDm; virtual;
    property IsInternalTransaction: Boolean read FIsInternalTransaction;
    property LastRetval: IRtcFuncResult read FLastRetval write SetLastRetval;
    property SqlManager: TClientDocSqlManager read FDocSqlManager
      write FDocSqlManager;
    property DmMain: TMainRtcDm read FDmMain;
    property DocVariableList: TVkVariableCollection read GetDocVariableList;
    property DocValidator: TDocValidator read FDocValidator;
    property DocStruDescriptionList: TDocStruDescriptionList
      read FDocStruDescriptionList;
    property OnDocAfterOpen: TDataSetNotifyEvent read FOnDocAfterOpen
      write FOnDocAfterOpen;
    property OnDocBeforeClose: TDataSetNotifyEvent read FOnDocBeforeClose
      write FOnDocBeforeClose;
    property OnStoreVariables: TOnStoreVariablesEvent read FOnStoreVariables
      write FOnStoreVariables;
    property OnSetFilter: TSetFilterNotifyEvent read FOnSetFilter
      write FOnSetFilter;
    property OnBeforeDocEdit: TDocBoolNotifyEvent read FOnBeforeDocEdit
      write FOnBeforeDocEdit;
    property OnBeforeDocDelete: TDocBoolNotifyEvent read FOnBeforeDocDelete
      write FOnBeforeDocDelete;
    property OnBeforeDocInsert: TDocBoolNotifyEvent read FOnBeforeDocInsert
      write FOnBeforeDocInsert;
    property OnAfterEditMemTableEhDoc: TTableEhEditEvent
      read FOnAfterEditMemTableEhDoc write FOnAfterEditMemTableEhDoc;
    property OnInitVariables: TDocEditActionEvent read FOnInitVariables
      write FOnInitVariables;
    property OnFillKeyFields: TNotifyEvent read FOnFillKeyFields
      write SetOnFillKeyFields;
    property Prepared: Boolean read FPrepared write SetPrepared;
    property OnWriteVariables: TOnWriteVariablesEvent read FOnWriteVariables
      write SetOnWriteVariables;
    property OnUpdateAdditionalFields: TNotifyEvent
      read FOnUpdateAdditionalFields write FOnUpdateAdditionalFields;
    property OnInsertAdditionalFields: TNotifyEvent
      read FOnInsertAdditionalFields write FOnInsertAdditionalFields;
  end;

var
  DocDm: TDocDm;

implementation

{$R *.dfm}

uses vkvariablebindingdialog, uLog;

{ TDmDoc }

constructor TDocDm.Create(ADmMain: TMainRtcDm);
begin
  FLastRetval := nil;
  FDmMain := ADmMain;
  FDocValidator := TDocValidator.Create(Self);
  FDocInstance := TDocInstance.Create;
  inherited Create(ADmMain);
end;

function TDocDm.CursorIsChanged: Boolean;
var
  i: Integer;
  _List: TStringList;
begin
  Result := false;
  { _List := FDocSqlManager.KeyFieldsList;
    for I := 0 to _List.Count-1 do
    begin
    if Assigned(DocVariableList.FindVkVariable(_List[i])) then
    begin
    Result := Result and DocVariableList.VarByName(_List[i]).Value <>
    MemTableEhDoc.FieldByName(_List[i]).Value;
    if Result then
    Break;
    end;
    end; }
end;

procedure TDocDm.DataModuleCreate(Sender: TObject);
begin
  inherited;
  FDocSqlManager := TClientDocSqlManager.Create;
  // FDocSqlManager.OnFillFieldNameList := OnFillFiledList;
  FDocStruDescriptionList := TDocStruDescriptionList.Create;
  FGridOrderList := TStringList.Create;
  FEditOrderList := TStringList.Create;
  FRtcQueryDataSet := MainRtcDm.NewRtcQueryDataSet;
  FRtcQueryDataSet.OnUpdateOrInsert := UpdateOrInsert;
  FRtcQueryDataSet.OnDelete := DeleteDoc;
  // FDmMain.LinkWithDataSet(pFIBDataSetVkDoc,FDmMain.pFIBTransactionReadOnly, FDmMain.pFIBTransactionUpdate,'','','');
  // FDmMain.LinkWithQuery(pFIBQueryVkLock,FDmMain.pFIBTransactionUpdate);
  // FDmMain.LinkWithQuery(pFIBQueryVkUpdate,FDmMain.pFIBTransactionUpdate);
  // FDmMain.LinkWithQuery(pFIBQueryVkDocInfo,FDmMain.pFIBTransactionReadOnly);
end;

procedure TDocDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FDocSqlManager);
  FreeAndNil(FDocStruDescriptionList);
  FreeAndNil(FGridOrderList);
  FreeAndNil(FEditOrderList);
  FreeAndNil(FDocInstance);
  FreeAndNil(FRtcQueryDataSet);
  FLastRetval := nil;
  Inherited;
end;

procedure TDocDm.DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
begin
  {
    if FDocSqlManager.DocVariableList.Count = 0 then
    Exit;

    if Assigned(FOnStoreVariables) then
    FOnStoreVariables(Self, MemRec.UpdateStatus);

    if (MemRec.UpdateStatus = usInserted) then
    DirectInsertDoc
    else if (MemRec.UpdateStatus = usModified) then
    begin
    if not FDocSqlManager.DocVariableList.IsChanged then
    FDocSqlManager.UpdateVariablesOnDeltaDs(MemTableEhDoc,
    FDocSqlManager.DocVariableList);
    DirectEditDoc;
    end
    else if (MemRec.UpdateStatus = usDeleted) then
    DirectDeleteDoc; }

end;

procedure TDocDm.DeleteDoc(ender: TObject);
begin
  rtcEditDoc(TDocOperation.docDelete);
end;

procedure TDocDm.DirectDeleteDoc;
var
  bMyTransaction: Boolean;
  i: Integer;
  _Name: String;
begin
  rtcEditDoc(docDelete);
  bMyTransaction := false;
  { with pFIBQueryVkUpdate do
    begin
    if not Transaction.InTransaction then
    begin
    bMyTransaction := true;
    Transaction.StartTransaction;
    end;

    //    LockDoc;
    try
    //FDCommandUpdate.SQLText.Clear;
    pFIBQueryVkUpdate.SQL.Text := FDocSqlManager.DeleteSQL.Text;
    pFIBQueryVkUpdate.Prepare();
    TDocDm.SetParamValues(pFIBQueryVkUpdate,DocVariableList);
    ExecQuery;
    if bMyTransaction and Transaction.InTransaction then
    Transaction.Commit;
    except
    if bMyTransaction then
    Transaction.RollBack;
    LogMessage(' SQL - '+ pFIBQueryVkUpdate.SQL.Text);
    Raise;
    end;
    end; }
end;

procedure TDocDm.DoAfterEditMemTableEhDoc(ATable: TMemTableEh;
  const aFieldName: String);
begin
  if Assigned(FOnAfterEditMemTableEhDoc) then
    FOnAfterEditMemTableEhDoc(ATable, aFieldName);
end;

function TDocDm.DoBeforeDocEdit: Boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocEdit) then
    Result := FOnBeforeDocEdit(Self);
end;

function TDocDm.DoBeforeDocInsert: Boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocInsert) then
    Result := FOnBeforeDocInsert(Self);
end;

{procedure TDocDm.DoInsertAdditionalFields;
var
  i: Integer;
begin
  if Assigned(FOnUpdateAdditionalFields) then
    for i := 0 to FDocSqlManager.AdditionalList.Count - 1 do
      if FDocSqlManager.AdditionalList[i].FieldList.Count > 0 then
        FOnInsertAdditionalFields(FDocSqlManager.AdditionalList[i]);
end;

procedure TDocDm.DoUpdateAdditionalFields;
var
  i: Integer;
begin
  if Assigned(FOnUpdateAdditionalFields) then
    for i := 0 to FDocSqlManager.AdditionalList.Count - 1 do
      if FDocSqlManager.AdditionalList[i].FieldList.Count > 0 then
        FOnUpdateAdditionalFields(FDocSqlManager.AdditionalList[i]);
end;
}
procedure TDocDm.DirectEditDoc;
var
  bMyTransaction: Boolean;
  i: Integer;
  _Name: String;
  _bChanged: Boolean;
begin
  rtcEditDoc(docUpdate);
  { bMyTransaction := False;
    with pFIBQueryVkUpdate do
    begin
    if not Transaction.InTransaction then
    begin
    bMyTransaction := true;
    Transaction.StartTransaction;
    end;

    LockDoc;
    try
    SQL.Clear;
    FDocSqlManager.GenerateDinamicSQLUpdate(_bChanged);
    if _bChanged then
    begin
    SQL.Text := FDocSqlManager.UpdateSQL.Text;
    Prepare();
    TDocDm.SetParamValues(pFIBQueryVkUpdate,DocVariableList);
    ExecQuery;
    end;
    DoUpdateAdditionalFields;
    if bMyTransaction and Transaction.InTransaction then
    Transaction.Commit;
    except
    if bMyTransaction then
    Transaction.RollBack;
    LogMessage(' SQL - '+ pFIBQueryVkUpdate.SQL.Text);
    Raise;
    end;
    end; }
end;

procedure TDocDm.FillKeyFields;
begin
  if Assigned(FOnFillKeyFields) then
    FOnFillKeyFields(Self);
end;

procedure TDocDm.FullRefreshDoc;
var
  _CurKey: Variant;
begin
  if ARecalcVariables then
    FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,
      FDocSqlManager.DocVariableList);

  _CurKey := FDocSqlManager.GetKeyValues(DocVariableList);
  MemTableEhDoc.DisableControls;
  try
    // FDQueryDoc.Refresh;
    // Close();
    // FDQueryDoc.Open();
    // MemTableEhDoc.Close;
    // MemTableEhDoc.Open;
    FRtcQueryDataSet.Close;
    FRtcQueryDataSet.Open;

    if not VariantIsNull(_CurKey) then
    begin
      if MemTableEhDoc.Locate(FDocSqlManager.KeyFields, _CurKey, []) then
        FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,
          FDocSqlManager.DocVariableList)
        { else
          raise Exception.Create('Error locate!'+ _CurKey); }
    end;
  finally
  //  RestoreState(MemTableEhDoc);

    MemTableEhDoc.EnableControls;

  end;
end;

class function TDocDm.GetDm: TDocDm;
begin
  Result := Self.Create(MainRtcDm);
end;

{ function TDmUibDoc.GetDocStruItem(const aName: String): PDocStruDescriptionItem;
  var
  i: Integer;
  begin
  Result := nil;
  for i := 0 to FDocStruItemList.Count - 1 do
  begin
  if SameText(FDocStruItemList[i].name,AName) then
  begin
  Result := FDocStruItemList[i];
  Break;
  end;
  end;
  end; }

function TDocDm.GetDocVariableList: TVkVariableCollection;
begin
  Result := FDocSqlManager.DocVariableList;
end;

function TDocDm.GetFilterCaption: String;
begin
  Result := '';
end;

function TDocDm.GetKey: Variant;
begin
  Result := FDocSqlManager.GetKeyValues(MemTableEhDoc);
end;

procedure TDocDm.InitClientSqlManager(const ATableName: String);
begin
  with MainRtcDm.RtcClientModule1 do
  begin
    Prepare('RtcGetSqlTableProperties');
    Param.AsString['TABLENAME'] := ATableName;
    MainRtcDm.setUser(Param);
    SetLastRetval(MainRtcDm.rtcExecute(MainRtcDm.RtcClientModule1,
      MainRtcDm.RtcClientModule1.Data.asFunction));
    //ShowMessage(FLastRetval.getRtcValue.asRecord.toJSON);
    TUtils.RtcValueToObject(FLastRetval.getRtcValue.asRecord, FDocSqlManager);
    FRtcQueryDataSet.TableName := ATableName;
  end;
end;

procedure TDocDm.InitVariables(AInsert: Boolean);
begin
  FDocSqlManager.DocVariableList.InitBlank;
  if not AInsert then
    FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,
      FDocSqlManager.DocVariableList);

  if Assigned(FOnInitVariables) then
    FOnInitVariables(Self, AInsert);
end;

{ function TDocDm.IsLocked: Boolean;
  var _KeyFieldsList: TStringList;
  i: Integer;
  begin
  if (pFIBQueryVkLock.Open) then
  begin
  _KeyFieldsList := FDocSqlManager.KeyFieldsList;
  Result := True;
  for I := 0 to _KeyFieldsList.Count-1 do
  begin
  Result := pFIBQueryVkLock.ParamByName(_KeyFieldsList[i]).AsVariant =
  MemTableEhDoc.FieldByName(_KeyFieldsList[i]).Value;
  if not Result  then
  Exit;
  end;
  end
  else
  Result := false;
  end; }

procedure TDocDm.DirectInsertDoc;
var
  bMyTransaction: Boolean;
  i: Integer;
  // _Name: String;
begin
  // bMyTransaction := False;
  rtcEditDoc(docInsert);
  { with pFIBQueryVkUpdate do
    begin
    if not pFIBQueryVkUpdate.Transaction.InTransaction then
    begin
    bMyTransaction := true;
    pFIBQueryVkUpdate.Transaction.StartTransaction;
    end;

    //LockDoc;
    try
    pFIBQueryVkUpdate.SQL.Clear;
    pFIBQueryVkUpdate.SQL.Text := FDocSqlManager.InsertSQL.Text;
    pFIBQueryVkUpdate.Prepare();
    FillKeyFields;
    TDocDm.SetParamValues(pFIBQueryVkUpdate,DocVariableList);
    ExecQuery;
    DoInsertAdditionalFields;
    if bMyTransaction and pFIBQueryVkUpdate.Transaction.InTransaction then
    pFIBQueryVkUpdate.Transaction.Commit;
    except
    if bMyTransaction then
    pFIBQueryVkUpdate.Transaction.RollBack;
    Raise;
    end;
    end; }
end;

function TDocDm.LocateDefaultValues(AVar: TVkVariableCollection): Boolean;
var
  _v: Variant;
begin
  Result := false;
  if (AVar.Count > 0) and MemTableEhDoc.Active then
  begin
    _v := AVar.Items[0].Value;
    Result := MemTableEhDoc.Locate(FDocSqlManager.KeyFields, _v, []);
  end;
end;

procedure TDocDm.ReInitVariables;
begin
  FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc, DocVariableList);
end;

procedure TDocDm.rtcEditDoc(operation: TDocOperation);
var
  i: Integer;
  ret: TRtcRecord;
  changedList: TStringList;

begin
  FillKeyFields;
  ret := nil;
  with MainRtcDm.RtcClientModule1 do
  begin
    Prepare('rtcDocedit');
    Param.asWideString['username'] := MainRtcDm.UserInfo.user_name;
    Param.asWideString['password'] := MainRtcDm.UserInfo.user_password;
    Param.AsString['TABLENAME'] := FDocSqlManager.TableName;
    Param.AsString['COMMAND'] := TUtils.getDocCommand(operation);
    Param.NewRecord('PARAMS');
    if (operation = docDelete) then
    begin
      Param.asRecord['PARAMS'].NewRecord('OLD');
          Param.asRecord['PARAMS'].NewRecord('KEY');
          for i := 0 to SqlManager.KeyFieldsList.Count - 1 do
            Param.asRecord['PARAMS'].asRecord['KEY'].asValue[SqlManager.KeyFieldsList[i]] :=
              DocVariableList[SqlManager.KeyFieldsList[i]].Value;
          {for i := 0 to changedList.Count - 1 do
          begin
            Param.asRecord['PARAMS'].asRecord['OLD'].asValue[changedList[i]] :=
              DocVariableList[changedList[i]].InitValue;
          end;}

{      for i := 0 to SqlManager.KeyFieldsList.Count - 1 do
      begin
        Param.asRecord['PARAMS'].asValue[SqlManager.KeyFieldsList[i]] :=
          DocVariableList[SqlManager.KeyFieldsList[i]].Value;
      end}
    end
    else if (operation = docInsert) then
    begin
      Param.asRecord['PARAMS'].NewRecord('NEW');
      TUtils.VkVariableColectionsToRtc(DocVariableList,
        Param.asRecord['PARAMS'].asRecord['NEW']);
      {for i := 0 to DocVariableList.Count - 1 do
      begin
        Param.asArray['PARAMS'].NewRecord(i);
        Param.asArray['PARAMS'].asRecord[i].AsString['name'] :=
          DocVariableList.Items[i].Name;
        Param.asArray['PARAMS'].asRecord[i].AsString['value'] :=
          DocVariableList.Items[i].Value;
      end;}
    end
    else
    if (operation = docUpdate) then
    begin
      changedList := TStringList.Create;
      try
        DocVariableList.GetChangedList(changedList);
        if changedList.Count>0 then
        begin
          Param.asRecord['PARAMS'].NewRecord('NEW');
          Param.asRecord['PARAMS'].NewRecord('OLD');
          for i := 0 to changedList.Count - 1 do
          begin
            Param.asRecord['PARAMS'].asRecord['NEW'].asValue[changedList[i]] :=
              DocVariableList[changedList[i]].Value;
            Param.asRecord['PARAMS'].asRecord['OLD'].asValue[changedList[i]] :=
              DocVariableList[changedList[i]].InitValue;
          end;
          Param.asRecord['PARAMS'].NewRecord('KEY');
          for i := 0 to SqlManager.KeyFieldsList.Count - 1 do
            Param.asRecord['PARAMS'].asRecord['KEY'].asValue[SqlManager.KeyFieldsList[i]] :=
              DocVariableList[SqlManager.KeyFieldsList[i]].Value;
        end
        else
          exit;
      finally
        FreeAndNil(changedList);
      end;
    end
    else
    if (operation = docDelete) then
    begin
      Param.asRecord['PARAMS'].NewRecord('KEY');
      for i := 0 to SqlManager.KeyFieldsList.Count - 1 do
        Param.asRecord['PARAMS'].asRecord['KEY'].asValue[SqlManager.KeyFieldsList[i]] :=
          DocVariableList[SqlManager.KeyFieldsList[i]].Value;
    end;

      SetLastRetval(MainRtcDm.rtcExecute(MainRtcDm.RtcClientModule1,
        MainRtcDm.RtcClientModule1.Data.asFunction));
    if (operation <> docDelete) then
    begin
      if (FLastRetval.RtcValue.isType=rtc_Record) then
      begin
        ret := FLastRetval.RtcValue.asRecord.asRecord['RESULT']; //.asRecord['RESULT']);
        for i:=0  to ret.FieldCount-1 do
        begin
          DocVariableList.VarByName(ret.FieldName[i]).Value :=
                      ret.asValue[ret.FieldName[i]];
        end;
      end;
    end;
  end;
end;

{ procedure TDocDm.LockDoc;
  begin
  if (pFIBQueryVkLock.Open) then
  Exit;

  if ARecalc or not FDocSqlManager.DocVariableList.IsChanged or CursorIsChanged then
  FDocSqlManager.CalcVariablesOnDs(MemtableEhDoc, DocVariableList);
  FIsInternalTransaction := not pFIBQueryVkLock.Transaction.InTransaction;

  with pFIBQueryVkLock do
  begin
  SQL.Clear;
  SQL.Add(FDocSqlManager.LockSQL.Text);
  Prepare();
  TDocDm.SetParamValues(pFIBQueryVkLock,DocVariableList);
  ExecQuery;
  end;
  end; }

procedure TDocDm.MemTableEhDocAfterOpen(DataSet: TDataSet);
var
  i: Integer;
  PField: PDocStruDescriptionItem;
  field: TField;
  s: String;
begin
  // SetOrd(ListGridOrder,1);
  DocStruDescriptionList.FillFields(DataSet);

  if FGridOrderList.Count = 0 then
    for i := 0 to DocStruDescriptionList.Count - 1 do
      FGridOrderList.Add
        (DocStruDescriptionList.GetDocStruDescriptionItem(i).Name);

  with DataSet do
  begin
    if FDocSqlManager.DocVariableList.Count = 0 then
    begin
      for i := 0 to FieldCount - 1 do
      begin
        Fields[i].Visible := false;
        // Fields[i].ReadOnly := True;
        FDocSqlManager.DocVariableList.CreateVkVariable
          (Fields[i].FieldName, null);
      end
    end;
    // else
    for i := 0 to FGridOrderList.Count - 1 do
    begin
      PField := DocStruDescriptionList.GetDocStruDescriptionItem
        (FGridOrderList[i]);
      if Assigned(PField) and not PField.IsVariable then
      begin
        // Raise Exception.Create(Format(' PField(%S) not found',[FGridOrderList[i]]));
        field := FieldByName(PField.Name);
        with field do
        begin
          DisplayLabel := PField.GridLabel;
          DisplayWidth := PField.DisplayWidth;
          if length(PField.DisplayFormat) > 0 then
            TNumericField(field).DisplayFormat := PField.DisplayFormat;
          Index := i;
          if not PField.bNotInGrid then
            Visible := True;
          ReadOnly := not PField.bEditInGrid;
        end;
      end
      else
      begin
        if Assigned(PField) and PField.IsVariable then
          if not Assigned(FDocSqlManager.DocVariableList.FindVkVariable
            (PField.Name)) then
            FDocSqlManager.DocVariableList.CreateVkVariable(PField.Name, null);
      end;
    end;

  end;

  // Определяем реакцию на редактирование у Грида
  if Assigned(FOnDocAfterOpen) then
    FOnDocAfterOpen(DataSet);

  { if Assigned(FGridDoc) then
    begin
    with FGridDoc do
    begin
    for i := 0 to Columns.Count - 1 do
    Columns[i].OnGetCellParams := FrameDocColumnsGetCellParams;
    end;
    if not FPrepared then
    begin
    //--------- Exclude from visible -----------
    for s in FGridOrderList do
    begin
    PField := self.FieldByName(s);
    if PField.bNotInGrid then
    FFmSetUp.ExcludeFromVisible.Add(s);
    end;
    FFmSetUp.Prepare(MemTableEhDoc,'\Software\WG SoftPro, Kharkov\mikko_forms01\delphi_docs'+
    IntToStr(FDmMikkoAds.pUserInfo.nUserAliasKodkli),'doc'+ GetSetUpReg);
    FPrepared := true;
    end;
    FFmSetUp.SetUpDataSet(MemTableEhDoc);
    end; }

  { if Assigned(FOldAfterOpen) then
    FOldAfterOpen(dataSet); }
  // FDocSqlManager.GenerateDinamicSQLInsert;
  // FDocSqlManager.GenerateDinamicSQLUpdate();
  // FDocSqlManager.GenerateDinamicSQLDelete;
  // FDocSqlManager.GenerateDinamicSQLLock;
end;

procedure TDocDm.MemTableEhDocBeforeClose(DataSet: TDataSet);
begin
  if Assigned(FOnDocBeforeClose) then
    FOnDocBeforeClose(DataSet);
  inherited;
end;

{ procedure TDocDm.OnFillFiledList(Sender: TObject);
  const  QRYTableFields =
  'select ' +
  '  FLD.RDB$FIELD_TYPE' +
  ', FLD.RDB$FIELD_SCALE' +
  ', FLD.RDB$FIELD_LENGTH' +
  ', FLD.RDB$FIELD_PRECISION' +
  ', FLD.RDB$CHARACTER_SET_ID' +   // CHARACTER SET
  ', RFR.RDB$COLLATION_ID' +
  ', COL.RDB$COLLATION_NAME' +     // COLLATE
  ', FLD.RDB$FIELD_SUB_TYPE' +
  ', RFR.RDB$DEFAULT_SOURCE' +     // DEFAULT
  ', RFR.RDB$FIELD_NAME' +
  ', FLD.RDB$SEGMENT_LENGTH' +
  ', FLD.RDB$SYSTEM_FLAG'+
  ', RFR.RDB$FIELD_SOURCE' +       // DOMAIN
  ', RFR.RDB$NULL_FLAG' +          // NULLABLE
  ', FLD.RDB$VALIDATION_SOURCE' +  // CHECK
  ', FLD.RDB$DIMENSIONS'+
  ', FLD.RDB$COMPUTED_SOURCE' +    // COMPUTED BY
  ', RDB$VALIDATION_SOURCE ' +
  'from ' +
  '  RDB$RELATIONS REL ' +
  'join RDB$RELATION_FIELDS RFR on (RFR.RDB$RELATION_NAME = REL.RDB$RELATION_NAME) ' +
  'join RDB$FIELDS FLD on (RFR.RDB$FIELD_SOURCE = FLD.RDB$FIELD_NAME) ' +
  'left outer join RDB$COLLATIONS COL on (COL.RDB$COLLATION_ID = RFR.RDB$COLLATION_ID and COL.RDB$CHARACTER_SET_ID = FLD.RDB$CHARACTER_SET_ID) ' +
  'where ' +
  '  (REL.RDB$RELATION_NAME = :tablename) ' +
  'order by ' +
  '  RFR.RDB$FIELD_POSITION, RFR.RDB$FIELD_NAME';

  begin
  //VkUIBQueryDocInfo.Active := False;
  pFIBQueryVkDocInfo.SQL.Text := QRYTableFields;
  pFIBQueryVkDocInfo.Prepare();
  pFIBQueryVkDocInfo.ParamByName('tablename').AsString :=  TDocSqlManager(Sender).Tablename;
  pFIBQueryVkDocInfo.ExecQuery();
  try
  TDocSqlManager(Sender).FieldNameList.Clear;
  while not pFIBQueryVkDocInfo.Eof do
  begin
  TDocSqlManager(Sender).FieldNameList.Add(pFIBQueryVkDocInfo.FieldByName('RDB$FIELD_NAME').AsString.Trim());
  pFIBQueryVkDocInfo.Next;
  end;
  finally
  pFIBQueryVkDocInfo.Close;
  end;
  //  FDMetaInfoQueryDoc.Active := False;
  //  FDMetaInfoQueryDoc.ObjectName := TDocSqlManager(Sender).Tablename;
  //  FDMetaInfoQueryDoc.Active := True;
  //  FDMetaInfoQueryDoc.GetFieldNames(TDocSqlManager(Sender).FieldNameList);
  //  FDmMain.FDConnectionMain.GetFieldNames('','',TDocSqlManager(Sender).Tablename,'',TDocSqlManager(Sender).FieldNameList);
  end; }

procedure TDocDm.Open;
begin
  MemTableEhDoc.Close;
  with FRtcQueryDataSet do
  begin
    DsMemTableEh := MemTableEhDoc;
    //InitAllSQL(FDocSqlManager.TableName, FDocSqlManager.KeyFields,
    //  FDocSqlManager.GenId);
    SelectSQL.Clear;
    SelectSQL.Text := FDocSqlManager.SelectSQL.Text;
    Params.AssignValues(FDocSqlManager.Params);
    Open;
  end;
  { pFIBDataSetVkDoc.Close;
    pFIBDataSetVkDoc.SelectSQL.Clear;
    pFIBDataSetVkDoc.SelectSQL.Text := FDocSqlManager.SelectSQL.Text;
    try
    MemTableEhDoc.Open;
    except
    TLogWriter.Log(pFIBDataSetVkDoc.SelectSQL.Text);
    Raise;
    end; }
end;

procedure TDocDm.SetFilter(nIndex: Integer; Sender: TObject);
begin
  if Assigned(FOnSetFilter) then
    FOnSetFilter(nIndex, Sender);
end;

procedure TDocDm.SetLastRetval(const Value: IRtcFuncResult);
begin
  if (Assigned(FLastRetval)) then
    FLastRetval := nil;
  FLastRetval := Value;
end;

procedure TDocDm.SetOnFillKeyFields(const Value: TNotifyEvent);
begin
  FOnFillKeyFields := Value;
end;

procedure TDocDm.SetOnWriteVariables(const Value: TOnWriteVariablesEvent);
begin
  FOnWriteVariables := Value;
end;

class procedure TDocDm.SetParamValues(AQuery: TpFIBQueryVk;
  AVarList: TVkVariableCollection);
var
  i: Integer;
  _Name: String;
begin
  for i := 0 to AQuery.Params.Count - 1 do
  begin
    _Name := AQuery.Params[i].Name;
    if AVarList.VarExists(_Name) then
      AQuery.ParamByName(_Name).AsVariant := AVarList.VarByName(_Name).Value
    else
      raise Exception.CreateFmt('Param %s not found', [_Name]);
  end;
end;

procedure TDocDm.SetPrepared(const Value: Boolean);
begin
  FPrepared := Value;
end;

procedure TDocDm.UpdateOrInsert(Sender: TObject; bNew: Boolean);
begin
  if bNew then
    rtcEditDoc(TDocOperation.docInsert)
  else
    rtcEditDoc(TDocOperation.docUpdate);

end;

{ procedure TDocDm.UnLockDoc(bCommit: Boolean = True);
  begin

  if pFIBQueryVkLock.Transaction.InTransaction and pFIBQueryVkLock.Open then
  begin

  if IsInternalTransaction then
  begin
  if bCommit then
  begin
  pFIBQueryVkLock.Transaction.Commit;
  end
  else
  pFIBQueryVkLock.Transaction.Rollback;
  end
  else
  pFIBQueryVkLock.Close;
  end;
  end; }

function TDocDm.ValidFmEditItems(Sender: TObject): Boolean;
var
  _Name: String;
  _fm: TVkDocDialogFm;
  _oControl: TWinControl;
  _Binding: TEditVkVariableBinding;
begin
  _fm := TVkDocDialogFm(Sender);
  Result := DocValidator.Vilidate(DocVariableList);
  if not Result then
  begin
    _Name := DocValidator.LastError.VarName;
    _Binding := TEditVkVariableBinding
      (_fm.BindingList.FindVkVariableBinding(_Name));
    if Assigned(_Binding) then
    begin
      _oControl := _Binding.oControl;
      if Assigned(_oControl) then
      begin
        ShowMessage(DocValidator.LastError.ErrorMessage + Format(' [%s]',
          [_Binding.lb.Caption]));
        if _oControl.CanFocus then
          _oControl.SetFocus;
      end;
    end;
    if not Assigned(_Binding) or not Assigned(_oControl) then
      ShowMessage(DocValidator.LastError.ErrorMessage);
  end;

end;

procedure TDocDm.VarLog(AVarList: TVkVariableCollection);
var
  v: TVkVariable;
  i: Integer;
begin
  for i := 0 to FDocSqlManager.DocVariableList.Count - 1 do
  begin
    v := FDocSqlManager.DocVariableList.Items[i];
    TLogWriter.Log(v.Name + ' = ' + v.AsString);
  end;
end;

procedure TDocDm.VkUIBDataSetDocAfterOpen(DataSet: TDataSet);
var
  i: Integer;
  field: TField;
  PField: PDocStruDescriptionItem;

begin
  { with DataSet do
    begin
    for i := 0 to FieldCount - 1 do
    begin
    Fields[i].Visible := False;
    Fields[i].Visible := False;
    end;

    for i := 0 to FGridOrderList.Count - 1 do
    begin
    PField := DocStruDescriptionList.GetDocStruDescriptionItem(FGridOrderList[i]);
    if  Assigned(PField) and not PField.IsVariable then
    begin
    // Raise Exception.Create(Format(' PField(%S) not found',[FGridOrderList[i]]));
    field := FieldByName(PField.name);
    with field do
    begin
    DisplayLabel := PField.GridLabel;
    DisplayWidth := PField.DisplayWidth;
    if length(PField.DisplayFormat)>0 then
    TNumericField(field).DisplayFormat := PField.DisplayFormat;
    Index := i;
    if not PField.bNotInGrid then
    Visible := True;
    ReadOnly := not PField.bEditInGrid;
    end;
    end
    //else
    //begin
    //if  Assigned(PField) and PField.IsVariable then
    // if not Assigned(FDocSqlManager.DocVariableList.FindVkVariable(PField.Name)) then
    //   FDocSqlManager.DocVariableList.CreateVkVariable(PField.Name,null );
    //end;
    end;
    end; }
end;

procedure TDocDm.WriteVariables(AInsert: Boolean);
begin
  if AInsert then
    MemTableEhDoc.Insert
  else
    MemTableEhDoc.Edit;

  try
    if FDefineDebug then
      VarLog(FDocSqlManager.DocVariableList);
    if Assigned(FOnWriteVariables) then
      FOnWriteVariables(Self, AInsert);
    FDocSqlManager.SaveVariablesInDataSet(MemTableEhDoc,
      FDocSqlManager.DocVariableList);
    MemTableEhDoc.Post;
  except
    MemTableEhDoc.Cancel;
    Raise;
  end;
end;

{ TDocValidatorError }

procedure TDocValidatorError.SetErrorMessage(const Value: String);
begin
  FErrorMessage := Value;
end;

procedure TDocValidatorError.SetVarName(const Value: string);
begin
  FVarName := Value;
end;

{ TDocValidator }

constructor TDocValidator.Create(AOwner: TComponent);
begin
  inherited;
  FNotNullList := TStringList.Create;
  FLastError := TDocValidatorError.Create(Self);
end;

destructor TDocValidator.Destroy;
begin
  FNotNullList.Free;
  inherited;
end;

procedure TDocValidator.SetNotNullList(const Value: TStringList);
begin
  FNotNullList := Value;
end;

function TDocValidator.Vilidate(Items: TVkVariableCollection): Boolean;
begin
  Result := VilidateNotNull(Items);
end;

function TDocValidator.VilidateNotNull(Items: TVkVariableCollection): Boolean;
var
  i: Integer;
  k: Integer;
begin
  Result := True;
  for i := 0 to FNotNullList.Count - 1 do
  begin
    k := Items.IndexOf(FNotNullList[i]);
    if k > -1 then
    begin
      if VariantIsNull(Items.Items[k].Value) then
      begin
        FLastError.VarName := FNotNullList[i];
        FLastError.ErrorMessage := 'Некорректное значение поля';
        Result := false;
        Break;
      end;
    end;
  end;
end;

end.
