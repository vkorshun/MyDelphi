unit fdac.dmDoc;

interface

uses
  SysUtils, Classes, MemTableDataEh, Db, MemTableEh, DataDriverEh, fdac.dmmain, DocSqlManager, VkVariable,
  Generics.Collections, vkdocinstance, Controls, vkvariablebinding, fmVkDocDialog, uDocDescription,
  u_XmlInit, Forms, Variants, VariantUtils, Dialogs,  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TFieldViewState = (fvsRead, fvsInsert, fvsEdit);
  TOnStoreVariablesEvent = procedure (Sender: TObject; ASatatus: TUpdateStatus) of object;
  TOnWriteVariablesEvent = procedure (Sender: TObject; AInsert: Boolean) of object;
  TSetFilterNotifyEvent = procedure(aIndex: Integer; Sender: TObject) of object;
  TDocBoolNotifyEvent = function (Sender:TObject):Boolean of object;
  TTableEhEditEvent = procedure(Sender:TObject;const aFieldName:String)  of object ;
  TDmDocClass = class of  TDocDm;
  TDocEditActionEvent = procedure(Sender:TObject;AInsert: Boolean)  of object ;

  {TDocProperti = class
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

  TDocValidator = class (TComponent)
  private
    FLastError: TDocValidatorerror;
    FNotNullList: TStringList;
    procedure SetNotNullList(const Value: TStringList);
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function Vilidate(Items: TVkVariableCollection): Boolean;
    function VilidateNotNull(Items: TVkVariableCollection): Boolean;

    property NotNullList: TStringList read FNotNullList write SetNotNullList;
    property LastError: TDocValidatorerror read FLastError ;
  end;

  TDocDm = class(TDataModule)
    MemTableEhDoc: TMemTableEh;
    DataSetDriverEhDoc: TDataSetDriverEh;
    FDCommandLock: TFDCommand;
    FDCommandUpdate: TFDCommand;
    FDQueryDoc: TFDQuery;
    FDMetaInfoQueryDoc: TFDMetaInfoQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh; MemTableData: TMemTableDataEh;
      MemRec: TMemoryRecordEh);
    procedure DataModuleDestroy(Sender: TObject);
    procedure MemTableEhDocAfterOpen(DataSet: TDataSet);
    procedure MemTableEhDocBeforeClose(DataSet: TDataSet);
  private
    { Private declarations }
    FDocInstance: TDocInstance;
    FDocSqlManager: TDocSqlManager;
    FDocStruDescriptionList: TDocStruDescriptionList;
    FDocValidator: TDocValidator;
    FMarkList: TList<Variant>;
    FOnStoreVariables: TOnStorevariablesEvent;
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
  protected
    FDmMain: TMainDm;
    FIsInternalTransaction: Boolean;
    FGridOrderList: TStringList;
    FEditOrderList: TStringList;
    FDefineDebug: Boolean;
    procedure DoInsertAdditionalFields;
    procedure DoUpdateAdditionalFields;
    procedure OnFillFiledList(Sender: TObject);
    procedure FillKeyFields;
  public
    { Public declarations }
    constructor Create(ADmMain:TMainDm);reintroduce;
    function CursorIsChanged: Boolean;
    procedure DirectInsertDoc;virtual;
    procedure DirectEditDoc;virtual;
    procedure DirectDeleteDoc;virtual;
    function DoBeforeDocEdit: boolean;
    function DoBeforeDocInsert: boolean;
    procedure DoAfterEditMemTableEhDoc(ATable: TMemTableEh; const AFieldName:String);
    procedure InitVariables(AInsert: Boolean);
    function GetFilterCaption: String; Virtual;
    function GetKey:Variant;
//    function GetDocStruItem(const aName: String): PDocStruDescriptionItem;
    function LocateDefaultValues(AVar: TVkVariableCollection):Boolean;virtual;
    procedure LockDoc(ARecalc: Boolean = false); virtual;
    procedure UnLockDoc(bCommit: Boolean = True); virtual;
    function IsLocked: Boolean;
    procedure FullRefreshDoc(ARecalcVariables: Boolean = false);
    procedure Open;
    procedure ReinitVariables;
    procedure SetFilter(nIndex:Integer;Sender:TObject);virtual;
    procedure WriteVariables(AInsert: Boolean);
    function ValidFmEditItems(Sender:TObject):Boolean;virtual;
    procedure VarLog(AVarList: TVkVariableCollection);

    class procedure SetParamValues(AQuery: TFDCommand; AVarList: TVkVariableCollection);
    class function GetDm: TDocDm;virtual;
    property IsInternalTransaction: Boolean read FIsInternalTransaction;
    property SqlManager:TDocSqlManager read FDocSqlManager write FDocSqlManager;
    property DmMain:TMainDm read FDmMain;
    property DocVariableList: TVkVariableCollection read GetDocVariableList;
    property DocValidator: TDocValidator read FDocValidator;
    property DocStruDescriptionList: TDocStruDescriptionList read FDocStruDescriptionList;
    property OnDocAfterOpen: TDataSetNotifyEvent read FOnDocAfterOpen write FOnDocAfterOpen;
    property OnDocBeforeClose: TDataSetNotifyEvent read FOnDocBeforeClose write FOnDocBeforeClose;
    property OnStoreVariables: TOnStorevariablesEvent read FOnStoreVariables write FOnStoreVariables;
    property OnSetFilter: TSetFilterNotifyEvent read FOnSetFilter write FOnSetFilter;
    property OnBeforeDocEdit: TDocBoolNotifyEvent read FOnBeforeDocEdit write FOnBeforeDocEdit;
    property OnBeforeDocDelete: TDocBoolNotifyEvent read FOnBeforeDocDelete write FOnBeforeDocDelete;
    property OnBeforeDocInsert: TDocBoolNotifyEvent read FOnBeforeDocInsert write FOnBeforeDocInsert;
    property OnAfterEditMemTableEhDoc: TTableEhEditEvent read FOnAfterEditMemTableEhDoc write FOnAfterEditMemTableEhDoc ;
    property OnInitVariables: TDocEditActionEvent read FOnInitVariables write FOnInitVariables;
    property OnFillKeyFields: TNotifyEvent read FOnFillKeyFields write SetOnFillKeyFields;
    property Prepared: Boolean read FPrepared write SetPrepared;
    property OnWriteVariables: TOnWriteVariablesEvent  read FOnWriteVariables write SetOnWriteVariables;
    property OnUpdateAdditionalFields:TNotifyEvent read FOnUpdateAdditionalFields write FOnUpdateAdditionalFields;
    property OnInsertAdditionalFields:TNotifyEvent read FOnInsertAdditionalFields write FOnInsertAdditionalFields;
  end;

var
  DocDm: TDocDm;

implementation

{$R *.dfm}
uses vkvariablebindingdialog, uLog;

{ TDmDoc }

constructor TDocDm.Create(ADmMain: TMainDm);
begin
  FDmMain := ADmMain;
  FDocValidator := TDocValidator.Create(Self);
  FDocInstance := TDocInstance.Create;
  inherited Create(ADmMain);
end;

function TDocDm.CursorIsChanged: Boolean;
//var i: Integer;
    //_List: TStringList;
begin
  Result := False;
{  _List := FDocSqlManager.KeyFieldsList;
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
  FDocSqlManager := TDocSqlManager.Create;
  FDocSqlManager.OnFillFieldNameList := OnFillFiledList;
  FDocStruDescriptionList := TDocStruDescriptionList.Create;
  FGridOrderList := TStringList.Create;
  FEditOrderList := TStringList.Create;

  FDmMain.LinkWithQuery(FDQueryDoc,FDmMain.FDTransactionUpdate);
  FDmMain.LinkWithCommand(FDCommandUpdate,FDmMain.FDTransactionRC);
  FDmMain.LinkWithCommand(FDCommandLock,FDmMain.FDTransactionUpdate);
  FDmMain.LinkWithQuery(TFDQuery(FDMetaInfoQueryDoc),FDmMain.FDTransactionRead);

end;

procedure TDocDm.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FDocSqlManager);
  FreeAndNil(FDocStruDescriptionList);
  FreeAndNil(FGridOrderList);
  FreeAndNil(FEditOrderList);
  FreeAndNil(FDocInstance);
  Inherited;
end;

procedure TDocDm.DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh; MemTableData: TMemTableDataEh;
  MemRec: TMemoryRecordEh);
begin

  if FDocSqlManager.DocVariableList.Count=0 then
    Exit;

  if Assigned(FOnStoreVariables) then
    FOnStorevariables(Self, MemRec.UpdateStatus);

  if (MemRec.UpdateStatus = usInserted) then
    DirectInsertDoc
  else
  if (MemRec.UpdateStatus = usModified) then
  begin
    if not FDocSqlManager.DocVariableList.IsChanged then
      FDocSqlManager.UpdateVariablesOnDeltaDs(MemTableEhDoc, FDocSqlManager.DocVariableList);
    DirectEditDoc;
  end
  else if (MemRec.UpdateStatus = usDeleted) then
    DirectDeleteDoc;

end;

procedure TDocDm.DirectDeleteDoc;
var bMyTransaction: Boolean;
    i: Integer;
    _Name: String;
begin
  bMyTransaction := False;
  with FDCommandUpdate do
  begin
    if not Transaction.Active then
    begin
      bMyTransaction := true;
      Transaction.StartTransaction;
    end;

    try
      //FDCommandUpdate.SQLText.Clear;
      FDocSqlManager.CalcVariablesOnDs(MemtableEhDoc, DocVariableList);
      FDCommandUpdate.CommandText.Text := FDocSqlManager.DeleteSQL.Text;
      FDCommandUpdate.Prepare();
      TDocDm.SetParamValues(FDCommandUpdate,DocVariableList);
      Execute;
      if bMyTransaction and Transaction.Active then
        Transaction.Commit;
    except
      if bMyTransaction then
        Transaction.RollBack;
      LogMessage(' SQL - '+ FDCommandUpdate.CommandText.Text);
      Raise;
    end;
  end;
end;

procedure TDocDm.DoAfterEditMemTableEhDoc(ATable: TMemTableEh; const AFieldName: String);
begin
  if Assigned(FOnAfterEditMemTableEhDoc) then
    FOnAfterEditMemTableEhDoc(ATable,AFieldName);
end;

function TDocDm.DoBeforeDocEdit: boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocEdit) then
    Result := FOnBeforeDocEdit(self);
end;

function TDocDm.DoBeforeDocInsert: boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocInsert) then
    Result := FOnBeforeDocInsert(self);
end;

procedure TDocDm.DoInsertAdditionalFields;
var i: Integer;
begin
  if Assigned(FOnUpdateAdditionalFields) then
  for I := 0 to FDocSqlManager.AdditionalList.Count-1 do
    if FDocSqlManager.AdditionalList[i].FieldList.Count>0 then
      FOnInsertAdditionalFields(FDocSqlManager.AdditionalList[i]);
end;

procedure TDocDm.DoUpdateAdditionalFields;
var i: Integer;
begin
  if Assigned(FOnUpdateAdditionalFields) then
  for I := 0 to FDocSqlManager.AdditionalList.Count-1 do
    if FDocSqlManager.AdditionalList[i].FieldList.Count>0 then
      FOnUpdateAdditionalFields(FDocSqlManager.AdditionalList[i]);
end;

procedure TDocDm.DirectEditDoc;
var bMyTransaction: Boolean;
//    i: Integer;
//    _Name: String;
    _bChanged: Boolean;
begin
  bMyTransaction := False;
  with FDCommandUpdate do
  begin
    if not Transaction.Active then
    begin
      bMyTransaction := true;
      Transaction.StartTransaction;
    end;

    LockDoc;
    try
      CommandText.Clear;
      FDocSqlManager.GenerateDinamicSQLUpdate(_bChanged);
      if _bChanged then
      begin
        CommandText.Text := FDocSqlManager.UpdateSQL.Text;
        Prepare();
        TDocDm.SetParamValues(FDCommandUpdate,DocVariableList);
        Execute;
      end;
      DoUpdateAdditionalFields;
      if bMyTransaction and Transaction.Active then
        Transaction.Commit;
    except
      if bMyTransaction then
        Transaction.RollBack;
      LogMessage(' SQL - '+ FDCommandUpdate.CommandText.Text);
      Raise;
    end;
  end;
end;

procedure TDocDm.FillKeyFields;
begin
  if Assigned(FOnFillkeyFields) then
    FOnFillKeyFields(Self);
end;

procedure TDocDm.FullRefreshDoc;
var _CurKey: Variant;
begin
  if ARecalcVariables then
    FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,FDocSqlManager.DocVariableList);

  _CurKey := FDocSQLManager.GetKeyValues(DocVariableList);
  MemTableEhDoc.DisableControls;
  try
    //FDQueryDoc.Refresh;
    //Close();
    //FDQueryDoc.Open();
    MemTableEhDoc.Close;
    MemTableEhDoc.Open;

    if not VariantIsNull(_CurKey) then
    begin
      if MemTableEhDoc.Locate(FDocSQLManager.KeyFields,_CurKey,[]) then
        FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,FDocSqlManager.DocVariableList)
{      else
        raise Exception.Create('Error locate!'+ _CurKey);}
    end;
  finally
    MemTableEhDoc.EnableControls;
  end;
end;

class function TDocDm.GetDm: TDocDm;
begin
  Result := Self.Create(MainDm);
end;

{function TDmUibDoc.GetDocStruItem(const aName: String): PDocStruDescriptionItem;
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
end;}

function TDocDm.GetDocVariableList: TVkVariableCollection;
begin
  Result := SqlManager.DocVariableList;
end;

function TDocDm.GetFilterCaption: String;
begin
  Result := '';
end;

function TDocDm.GetKey: Variant;
begin
  Result := FDocSqlManager.GetKeyValues(MemTableEhDoc);
end;

procedure TDocDm.InitVariables(AInsert: Boolean);
begin
  FDocSqlManager.DocVariableList.InitBlank;
  if not AInsert then
    FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc, FDocSqlManager.DocVariableList);

  if Assigned(FOnInitVariables) then
    FOnInitVariables(self,AInsert);
end;

function TDocDm.IsLocked: Boolean;
var _KeyFieldsList: TStringList;
    i: Integer;
begin
  Result := false;
  if (FDCommandLock.State = csExecuting) or (FDCommandLock.State = csPrepared) then
  begin
    _KeyFieldsList := FDocSqlManager.KeyFieldsList;
    Result := True;
    for I := 0 to _KeyFieldsList.Count-1 do
    begin
      Result := FDCommandLock.ParamByName(_KeyFieldsList[i]).Value =
        MemTableEhDoc.FieldByName(_KeyFieldsList[i]).Value;
      if not Result  then
        Exit;
    end;
  end;
end;

procedure TDocDm.DirectInsertDoc;
var bMyTransaction: Boolean;
    i: Integer;
//    _Name: String;
begin
  bMyTransaction := False;
  with FDCommandUpdate do
  begin
    if not FDCommandUpdate.Transaction.Active then
    begin
      bMyTransaction := true;
      FDCommandUpdate.Transaction.StartTransaction;
    end;

    //LockDoc;
    try
      FDCommandUpdate.CommandText.Clear;
      FDCommandUpdate.CommandText.Text := FDocSqlManager.InsertSQL.Text;
      FDCommandUpdate.Prepare();
      FillKeyFields;
      TDocDm.SetParamValues(FDCommandUpdate,DocVariableList);
      Execute;
      DoInsertAdditionalFields;
      if bMyTransaction and FDCommandUpdate.Transaction.Active then
        FDCommandUpdate.Transaction.Commit;
    except
      if bMyTransaction then
        FDCommandUpdate.Transaction.RollBack;
      Raise;
    end;
  end;
end;

function TDocDm.LocateDefaultValues(AVar: TVkVariableCollection):Boolean;
var _v: variant;
begin
  Result := false;
  if (Avar.Count>0) and MemTableEhDoc.Active then
  begin
    _v := AVar.Items[0].Value;
    Result := MemTableEhDoc.Locate(FDocSqlManager.KeyFields,_v,[]);
  end;
end;

procedure TDocDm.LockDoc;
begin
  if (FDCommandLock.State= csExecuting) or (FDCommandLock.State= csOpen) then
    Exit;

  if ARecalc or not FDocSqlManager.DocVariableList.IsChanged or CursorIsChanged then
    FDocSqlManager.CalcVariablesOnDs(MemtableEhDoc, DocVariableList);

  with FDCommandLock do
  begin
    FIsInternalTransaction := not Transaction.Active;
    CommandText.Clear;
    CommandText.Add(FDocSqlManager.LockSQL.Text);
    Prepare();
    TDocDm.SetParamValues(FDCommandLock,DocVariableList);
    Open;
  end;
end;

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
      FGridOrderList.Add(DocStruDescriptionList.GetDocStruDescriptionItem(i).name);

  with DataSet do
  begin
    if FDocSqlManager.DocVariableList.Count=0 then
    begin
      for i := 0 to FieldCount - 1 do
      begin
        Fields[i].Visible := False;
        // Fields[i].ReadOnly := True;
        FDocSqlManager.DocVariableList.CreateVkVariable(Fields[i].FieldName,null );
      end
    end
    else
    for i := 0 to FieldCount - 1 do
        Fields[i].Visible := False;

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
      else
      begin
      if  Assigned(PField) and PField.IsVariable then
        if not Assigned(FDocSqlManager.DocVariableList.FindVkVariable(PField.Name)) then
          FDocSqlManager.DocVariableList.CreateVkVariable(PField.Name,null );
      end;
    end;

  end;

  // Определяем реакцию на редактирование у Грида
  if Assigned(FOnDocAfterOpen) then
    FOnDocAfterOpen(DataSet);

  {if Assigned(FGridDoc) then
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
  end;}

{  if Assigned(FOldAfterOpen) then
    FOldAfterOpen(dataSet); }
  FDocSqlManager.GenerateDinamicSQLInsert;
//  FDocSqlManager.GenerateDinamicSQLUpdate();
  FDocSqlManager.GenerateDinamicSQLDelete;
  FDocSqlManager.GenerateDinamicSQLLock;
end;

procedure TDocDm.MemTableEhDocBeforeClose(DataSet: TDataSet);
begin
  if Assigned(FOnDocBeforeClose) then
    FOnDocBeforeClose(DataSet);
  inherited;
end;

procedure TDocDm.OnFillFiledList(Sender: TObject);
begin
  {FDMetaInfoQueryDoc.Active := False;
  FDMetaInfoQueryDoc.ObjectName := TDocSqlManager(Sender).Tablename;
  FDMetaInfoQueryDoc.Active := True;
  FDMetaInfoQueryDoc.GetFieldNames(TDocSqlManager(Sender).FieldNameList);}
  FDmMain.FDConnectionMain.GetFieldNames('','',TDocSqlManager(Sender).Tablename,'',TDocSqlManager(Sender).FieldNameList);
end;

procedure TDocDm.Open;
begin
  FDQueryDoc.Close;
  FDQueryDoc.SQL.Clear;
  FDQueryDoc.SQL.Text := SqlManager.SelectSQL.Text;
  try
    MemTableEhDoc.Open;
  except
    TLogWriter.Log(FDQueryDoc.SQL.Text);
    Raise;
  end;
end;

procedure TDocDm.ReinitVariables;
begin
  FDocSqlManager.CalcVariablesOnDs(MemTableEhDoc,FDocSqlManager.DocVariableList);
end;

procedure TDocDm.SetFilter(nIndex: Integer; Sender: TObject);
begin
 if Assigned(FOnSetFilter) then
   FOnsetFilter(nIndex, Sender);
end;

procedure TDocDm.SetOnFillKeyFields(const Value: TNotifyEvent);
begin
  FOnFillKeyFields := Value;
end;

procedure TDocDm.SetOnWriteVariables(const Value: TOnWriteVariablesEvent);
begin
  FOnWriteVariables := Value;
end;

class procedure TDocDm.SetParamValues(AQuery: TFDCommand; AVarList: TVkVariableCollection);
var i: Integer;
  _Name: String;
begin
  for I := 0 to AQuery.Params.Count-1 do
  begin
    _Name := AQuery.Params[i].Name;
    if AvarList.VarExists(_Name) then
      AQuery.ParamByName(_Name).Value := AVarList.VarByName(_Name).Value
    else
      raise Exception.CreateFmt('Param %s not found',[_Name]);
  end;
end;

procedure TDocDm.SetPrepared(const Value: Boolean);
begin
  FPrepared := Value;
end;

procedure TDocDm.UnLockDoc(bCommit: Boolean = True);
begin

  if not FDCommandLock.Transaction.Active or (FDCommandLock.State <> csOpen) then
    Exit;

  if IsInternalTransaction then
  begin
    if bCommit then
    begin
      FDCommandLock.Transaction.Commit;
    end
    else
      FDCommandLock.Transaction.Rollback;
  end
  else
    FDCommandLock.Close;
end;

function TDocDm.ValidFmEditItems(Sender: TObject): Boolean;
var
   _Name: String;
    _fm: TVkDocDialogFm;
    _oControl: TWinControl;
    _Binding: TEditVkVariableBinding;
begin
  _oControl := nil;
  _fm := TVkDocDialogFm(Sender);
  Result :=  DocValidator.Vilidate(DocVariableList);
  if not Result then
  begin
    _Name :=  DocValidator.LastError.VarName;
    _Binding :=  TEditVkVariableBinding(_fm.BindingList.FindVkVariableBinding(_Name));
    if Assigned(_Binding) then
    begin
      _oControl := _Binding.oControl;
      if Assigned(_oControl) then
      begin
        ShowMessage(DocValidator.LastError.ErrorMessage+Format(' [%s]',[_Binding.lb.Caption]));
        if _oControl.CanFocus then
          _oControl.SetFocus;
      end;
    end;
    if not Assigned(_Binding) or not Assigned(_oControl) then
      ShowMessage(DocValidator.LastError.ErrorMessage);
  end;

end;

procedure TDocDm.VarLog(AVarList: TVkVariableCollection);
var v: TVkVariable;
    i: Integer;
begin
  for i:=0 to FDocSqlManager.DocVariableList.Count-1 do
  begin
    v :=  FDocSqlManager.DocVariableList.Items[i];
    TLogWriter.Log(v.Name+' = '+v.AsString);
  end;
end;

procedure TDocDm.WriteVariables(AInsert: Boolean);
begin
  if AInsert then
    MemtableEhDoc.Insert
  else
    MemtableEhDoc.Edit;

  try
    if FDefineDebug then
      VarLog(FDocSqlManager.DocVariableList);
    if Assigned(FOnWriteVariables) then
      FOnWriteVariables(self,AInsert);
    FDocSqlManager.SaveVariablesInDataSet(MemTableEhDoc,FDocSqlManager.DocVariableList);
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
  I: Integer;
  k: Integer;
begin
  Result := True;
  for I := 0 to FNotNullList.Count-1 do
  begin
    k := Items.IndexOf(FNotNullList[i]);
    if k>-1  then
    begin
      if VariantIsNull(Items.Items[k].Value) then
      begin
        FLastError.VarName := FNotNullList[i];
        FLastError.ErrorMessage := 'Некорректное значение поля';
        Result := False;
        Break;
      end;
    end;
  end;
end;

end.
