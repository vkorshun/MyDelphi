unit doc.mikkodoc;

interface

{ TODO :
  Добавить учет владельца Транзакции
  bOwnerTransaction
  Добавить -> refreshCurrent -> чтобы иметь актуальные данные после Lock
  }
uses
  SysUtils, Classes, Dm_mikkoads, DB, adsdata, adsfunc, adstable,
  MemTableDataEh, MemTableEh, doc.variablelist, Generics.Collections,
  Forms, Controls, docdialog.fm_docdialog, DateVk, DataDriverEh, Dialogs,
  fm_wait, mask, variants, GridsEh, DBGridEh, DbGridEhVk, fm_setupform, fm_viewhistory,
  docdialog.docvariablelink, doc.docinstance;

type
  TFuncEditInGrid = function(Sender: TObject; const fieldName: String)
    : boolean of object;
  TBoolNotifyEvent = procedure(Sender: TObject; var bValid: boolean) of object;
  TDocEditStatus = (desInsertDialog, desEditDialog, desEditInBrowse);
  TSetFilterNotifyEvent = procedure(aIndex: Integer; Sender: TObject) of object;
  TGetDocVarList = function (Sender:TObject): TDocVariableList;
  TArrayOfStr = array of string;

  RGridFldEdit = record
    bChange: boolean;
    fldname: String;
  end;

  TClassWinControl = class of TWinControl;
  PDocStruDescriptionItem = ^RDocStruDescriptionItem;
  TDocReplaceProc = reference to procedure(var aVarList: TDocVariableList);

  RDocStruDescriptionItem = record
    name: String;
    name_owner: String; // Если поле есть наименоваие объекта из owner
    GridLabel: String;
    DialogLabel: String;
    DisplayWidth: Integer;
    DisplayFormat: String;
    EditWidth: Integer;
    bEditInGrid: boolean;
    bNotInGrid: boolean;
    TypeEditControl: TClassWinControl;
    TypeClassItemDocCotrolLinc: TClassItemDocControlLink;
  end;

  TMikkoDoc = class(TComponent)
  private
    FbDocInsert: boolean;
    FbSod: boolean;
    FDocInstance: TDocInstance;
    FIdReg: Integer;
    FIdPriznak: Integer;
    FIdView: Integer;
    FAdsQueryDoc: TAdsQuery;
    FDatasetDriverEhDoc: TDataSetDriverEh;
    FDmMikkoads: TDmMikkoads;
    FDocTablename: String;
    FFmEdit: TFmDocDialog;
    FFmExternalEdit: TForm;
    FFmSetUp: TFmSetUpForm;
    FFmWait: TFmWait;
    FSQL: TStringList;
    FbInGrid: Boolean;
    FDocStruItemList: TList<PDocStruDescriptionItem>;
    FGridOrderList: TStringList;
    FEditOrderList: TStringList;
    FMarkList: TList<variant>;
    FMemTableEhDoc: TMemTableEh;
    FOldAfterOpen: TDataSetNotifyEvent;
    FOnBeforeDocEdit: TBoolNotifyEvent;
    FOnInitVariables: TNotifyEvent;
    FOnWriteVariables: TNotifyEvent;
    /// <summary> Список переменных документа <summary>
    FDocVariableList: TDocVariableList;
    /// <summary> Список переменных MemtableEhDoc <summary>
    FGridDoc: TDbGridEhVk;
    FMemVariableList: TDocVariableList;
    FOnStoreVariables: TNotifyEvent;
    FKeyFields: String;
//    FTableName: String;
    FAdsQuery1: TAdsQuery;
    FOnEditInGrid: TFuncEditInGrid;
    FOnBeforeEditInForm: TNotifyEvent;
//    FGridFldEdit: RGridFldEdit;
    FOnBeforeDocDelete: TBoolNotifyEvent;
    FOnBeforeDocInsert: TBoolNotifyEvent;
    FOnGetEditFormVarList: TGetDocVarList;
    FOnSetFilter: TSetFilterNotifyEvent;
    /// <summary> Триггер готовности <summary>
    FPrepared: Boolean;
    /// <summary> Специальный Setup Reg <summary>
    FSpecSetupReg: String;
    procedure DoBeforeEditInForm;
    function  GetEditFormVarList:TDocVariableList;
    procedure SetDataSetDriverEhDoc(aDataSetDriver: TDataSetDriverEh);
    procedure SetOnStoreVariables(const Value: TNotifyEvent);
    procedure SetDmMikkoAds(const Value: TDmMikkoads);
    procedure SetOnEditInGrid(const Value: TFuncEditInGrid);
//    procedure SetGridFldEdit(const Value: RGridFldEdit);
    procedure SetGridDoc(const Value: TDbGridEhVk);
    procedure SetOnBeforeDocDelete(const Value: TBoolNotifyEvent);
    procedure SetOnBeforeDocInsert(const Value: TBoolNotifyEvent);
    procedure SetOnSetFilter(const Value: TSetFilterNotifyEvent);
    procedure SetIdReg(const Value: Integer);
  public
    GridFldEdit: RGridFldEdit; // read FBrowseFldEdit write FBrowseFldEdit;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function AddDocStruItem(aFieldName, aGridLabel, aDialogLabel: String;
      aDisplayWidth: Integer = 0; aEditWidth: Integer = 0;
      aTypeEditControl: TClassWinControl = nil;
      aTypeItemDocControlLink: TClassItemDocControlLink = nil;
      aEditInGrid: boolean = False): PDocStruDescriptionItem;

    /// <summary>  Создание списков переменных  </summary>
    procedure CreateVariables;
    /// <summary>  Настройка окна редактирования, если aFm не передан то FFmEdit </summary>
    procedure ConfigureEdit(aFm: TFmDocDialog);
    procedure ConfigureEditByList(aFm: TFmDocDialog; aList:TStringList);
    procedure DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
      MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh); Virtual;
    function DoBeforeDocEdit: boolean;
    function DoBeforeDocInsert: boolean;
    procedure DocDelete;
    function DocLock: boolean;
    function GetDocStruItem(const aName: String): PDocStruDescriptionItem;
    procedure MikkoDocAfterOpen(dataSet: TDataSet);

    procedure DocEdit(aStatus: TDocEditStatus; const aFieldName: String = '');
    procedure EditInGrid(fld_name: String);
    function FieldByName(aName: String): PDocStruDescriptionItem;
    function GetSetUpReg:String;
    procedure FrameDocColumnsGetCellParams(Sender: TObject; EditMode: boolean; Params: TColCellParamsEh);

    procedure FullRefresh(aKey: variant; bWait:Boolean = True);
    function GetKey: variant; virtual;
    procedure InitVariables;
    procedure Replace(aProc: TDocReplaceProc);
    /// <summary>  Присвоить помеченным <summary>
    procedure ReplaceMarked(const afld_name:String);overload;
    procedure ReplaceMarked(const afld_name:String; Value:variant);overload;
//  procedure ReplaceMarked(const afld: variant;const aValue: variant);overload;
    procedure SetAfterOpen(aDs: TDataSet);

    /// <summary>  Редактирование без визуализации без внутр. блокировки<summary>
    procedure SaveVariables(FList:TDocVariableList;bNew: Boolean);
    /// <summary>  Просмотр истории <summary>
    procedure ViewHistory;
    // procedure SetOrd(aNames:TStringList; aType:Integer);
    /// <summary>  Запись переменных в memdataset <summary>
    procedure WriteVariables(aVarList:TDocVariableList);
    // procedure SetOrdEdit(aNames:TStringList);

    property AdsQueryDoc: TAdsQuery read FAdsQueryDoc write FAdsQueryDoc;
    property AdsQuery1: TAdsQuery read FAdsQuery1 write FAdsQuery1;
    property bDocInsert: boolean read FbDocInsert write FbDocInsert;
    // property BrowseFldEdit:RBrowseFldEdit;// read FBrowseFldEdit write FBrowseFldEdit;
    property bSod: boolean read FbSod write FbSod;
    property bInGrid: boolean read FbInGrid write FbInGrid;
    property DataSetDriverEhDoc: TDataSetDriverEh read FDatasetDriverEhDoc
      write SetDataSetDriverEhDoc;
    property DmMikkoAds: TDmMikkoads read FDmMikkoads write SetDmMikkoAds;
    property DocTablename:String read FDocTablename write FDocTablename;
    property DocVariableList: TDocVariableList read FDocVariableList;
    property FmEdit: TFmDocDialog read FFmEdit;
    property FmSetUp: TFmSetUpForm read FFmSetUp;
    property FmExternalEdit: TForm read FFmExternalEdit write FFmExternalEdit;
    property GridDoc: TDbGridEhVk read FGridDoc Write SetGridDoc;
    property IdReg: Integer read FIdReg write SetIdReg;
    property IdPriznak: Integer read FIdPriznak write FIdPriznak;
    property IdView: Integer read FIdView write FIdView;
    property SQL: TStringList read FSQL;
    property DocInstance:TDocInstance read FDocInstance;
    property DocStruItemList: TList<PDocStruDescriptionItem>
      read FDocStruItemList;
    property KeyFields: String read FKeyFields write FKeyFields;
    property ListGridOrder: TStringList read FGridOrderList;
    property ListEditOrder: TStringList read FEditOrderList;
    property MarkList: TList<variant>Read FMarkList;
    property MemTableEhDoc: TMemTableEh read FMemTableEhDoc
      write FMemTableEhDoc;
    property MemVariableList: TDocVariableList read FMemVariableList;
    property OnBeforeDocDelete: TBoolNotifyEvent read FOnBeforeDocDelete
      write SetOnBeforeDocDelete;
    property OnBeforeDocEdit: TBoolNotifyEvent read FOnBeforeDocEdit
      write FOnBeforeDocEdit;
    property OnBeforeDocInsert: TBoolNotifyEvent read FOnBeforeDocInsert
      write SetOnBeforeDocInsert;
    property OnEditInGrid: TFuncEditInGrid read FOnEditInGrid
      write SetOnEditInGrid;
    property OnBeforeEditInForm:TNotifyEvent read FOnBeforeEditInForm write FOnBeforeEditInForm;
    property OnInitVariables: TNotifyEvent read FOnInitVariables
      write FOnInitVariables;
    property OnSetFilter: TSetFilterNotifyEvent read FOnSetFilter
      write SetOnSetFilter;
    property SpecSetupReg: String read FSpecSetUpReg write FSpecSetUpReg;
    /// <summary>  Событие при записи данных в memtable <summary>
    property OnWriteVariables: TNotifyEvent read FOnWriteVariables
      write FOnWriteVariables;
    /// <summary>  Событие при непосредственной записи данных в таблицу <summary>
    property OnStoreVariables: TNotifyEvent read FOnStoreVariables
      write SetOnStoreVariables;
  end;

implementation

{ TDocDescription }
//uses Fm_ViewHistory;

function TMikkoDoc.AddDocStruItem(aFieldName, aGridLabel, aDialogLabel: String;
  aDisplayWidth: Integer = 0; aEditWidth: Integer = 0;
  aTypeEditControl: TClassWinControl = nil;
  aTypeItemDocControlLink: TClassItemDocControlLink = nil;
  aEditInGrid: boolean = False): PDocStruDescriptionItem;
var
  p: PDocStruDescriptionItem;
begin
  New(p);
  p.name := aFieldName;
  p.GridLabel := aGridLabel;
  p.DialogLabel := aDialogLabel;
  p.DisplayWidth := aDisplayWidth;
  p.EditWidth := aEditWidth;
  p.TypeEditControl := aTypeEditControl;
  p.TypeClassItemDocCotrolLinc := aTypeItemDocControlLink;
  p.bEditInGrid := aEditInGrid and (p.TypeEditControl <> TItemMEditBox);
  p.bNotInGrid  := False;
  FDocStruItemList.Add(p);
  Result := p;
end;

procedure TMikkoDoc.ConfigureEdit(aFm: TFmDocDialog);
var
  Fm: TFmDocDialog;
  i: Integer;
begin
  if Assigned(aFm) then
    Fm := aFm
  else
    Fm := FFmEdit;

  if FEditOrderList.Count = 0 then
    for i := 0 to DocStruItemList.Count - 1 do
      FEditOrderList.Add(DocStruItemList[i].name);

  ConfigureEditByList(Fm,ListEditOrder);
  {with Fm do
  begin
    Items.Clear;
    for i := 0 to ListEditOrder.Count - 1 do
    begin
      PField := FieldByName(ListEditOrder[i]);
      if not Assigned(PField.TypeEditControl) then
      begin
        raise Exception.Create('Not Assigned TypeEditControl ' + PField.name);
      end;
      if Assigned(PField) then
      begin
        if length(PField.DialogLabel) = 0 then
          mCaption := PField.GridLabel
        else
          mCaption := PField.DialogLabel;

        if PField.EditWidth = 0 then
          mWidth := PField.DisplayWidth
        else
          mWidth := PField.EditWidth;

        NewControl(PField.TypeEditControl, mCaption, mWidth, PField.name,
          PField.TypeClassItemDocCotrolLinc);
        // ========================= Сторонние переменный приводят к краху если их список переинициализируется ============
        // NewControl(pField.TypeEditControl,mCaption,mWidth,
        // pField.name,FMemvariableList.VarByName(ListEditOrder[i]) );
        // =====================================
      end;
    end;

  end;
  }
end;

procedure TMikkoDoc.ConfigureEditByList(aFm: TFmDocDialog; aList: TStringList);
var
  PField: PDocStruDescriptionItem;
  mCaption: String;
  mWidth: Integer;
  i: Integer;
begin
  with aFm do
  begin
    Items.Clear;
    for i := 0 to aList.Count - 1 do
    begin
      PField := FieldByName(aList[i]);
      if not Assigned(PField.TypeEditControl) then
      begin
        raise Exception.Create('Not Assigned TypeEditControl ' + PField.name);
      end;
      if Assigned(PField) then
      begin
        if length(PField.DialogLabel) = 0 then
          mCaption := PField.GridLabel
        else
          mCaption := PField.DialogLabel;

        if PField.EditWidth = 0 then
          mWidth := PField.DisplayWidth
        else
          mWidth := PField.EditWidth;

        NewControl(PField.TypeEditControl, mCaption, mWidth, PField.name,
          PField.TypeClassItemDocCotrolLinc);
        // ========================= Сторонние переменный приводят к краху если их список переинициализируется ============
        // NewControl(pField.TypeEditControl,mCaption,mWidth,
        // pField.name,FMemvariableList.VarByName(ListEditOrder[i]) );
        // =====================================
      end;
    end;

  end;

end;

constructor TMikkoDoc.Create(aOwner: TComponent);
begin
  if aOwner is TDmMikkoads then
  begin
    Inherited Create(aOwner);
    FbSod := False;
    FIdReg := 0;
    FIdPriznak := 0;
    FIdView    := 0;
    FSQL := TStringList.Create;
    FDocStruItemList := TList<PDocStruDescriptionItem>.Create;
    FEditOrderList := TStringList.Create;
    FGridOrderList := TStringList.Create;
    FDmMikkoads := TDmMikkoads(aOwner);
    FDocVariableList := TDocVariableList.Create(FDmMikkoAds);
    FMemVariableList := TDocVariableList.Create(FDmMikkoAds);
    FFmEdit := TFmDocDialog.Create(self);
    FFmWait := TFmWait.Create(self);
    FMarkList := TList<variant>.Create;
    FKeyFields := 'koddoc';
    FFmSetup := TFmSetUpForm.Create(self);
    FDocInstance := TDocInstance.Create;
    FbInGrid := False;
//    FFmSetUp.Prepare(MemTableEh1,'\Software\WG SoftPro, Kharkov\mikko_forms01\second_mater'+IntToStr(nUserAliasKodKli),'vtreeitems');

    // FDmMikkoAds.InitDocVariableListOnDs(FMemTableEhDoc,FMemVariableList, False);
  end
  else
    Raise Exception.Create('Invalid owner type ');
end;

procedure TMikkoDoc.CreateVariables;
begin
  if FDocVariableList.Count = 0 then
  begin
    FDmMikkoads.InitDocVariableList(FDocTablename,
      FDocVariableList);
    FDmMikkoads.InitDocVariableListOnDs(AdsQueryDoc, FMemVariableList);
  end;

  // if FMemVariableList.Count=0 then
  // FDmMikkoAds.InitDocVariableListOnDs(FMemTableEhDoc,FMemVariableList);
  // if FDocVariableList.Count=0 then
  // FDmMikkoAds.InitDocVariableList(,FDocVariableList);
end;

function TMikkoDoc.DoBeforeDocEdit: boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocEdit) then
    FOnBeforeDocEdit(self, Result);
end;

function TMikkoDoc.DoBeforeDocInsert: boolean;
begin
  Result := True;
  FDocInstance.SetDataSourceInstance(MemTableEhDoc);
  if Assigned(FOnBeforeDocInsert) then
    FOnBeforeDocInsert(self, Result);
end;

procedure TMikkoDoc.DocDelete;
begin
  try
    if FMemTableEhDoc.IsEmpty then
      Exit;

    if FMarkList.Count > 0 then
    begin
      if MessageDlg('Удалить помеченные записи', mtConfirmation, mbYesNo, 0) <>
        mrYes then
        Exit;
      FDmMikkoads.AdsConnection1.BeginTransaction;
      try
        while FMarkList.Count > 0 do
        begin
          if MemTableEhDoc.Locate(FKeyFields, FMarkList[0], []) then
          begin
            InitVariables;
            FMemTableEhDoc.Delete;
          end;
          FMarkList.Delete(0);
        end;
        FDmMikkoads.AdsConnection1.Commit;
      except
        FDmMikkoads.AdsConnection1.Rollback;
        Raise;
      end;

    end
    else
    begin
      if MessageDlg('Удалить текущую запись', mtConfirmation, mbYesNo, 0) <>
        mrYes then
        Exit;
      FDmMikkoads.AdsConnection1.BeginTransaction;
      try
        InitVariables;
        FMemTableEhDoc.Delete;
        FDmMikkoads.AdsConnection1.Commit;
      except
        FDmMikkoads.AdsConnection1.Rollback;
        Raise;
      end;
    end;
  finally
    FullRefresh(null);
  end;
end;

destructor TMikkoDoc.Destroy;
begin

  FreeAndNil(FSQL);
  FreeAndNil(FDocStruItemList);
  FreeAndNil(FEditOrderList);
  FreeAndNil(FGridOrderList);
  FreeAndNil(FFmEdit);
  FreeAndNil(FFmWait);
  FreeAndNil(FMarkList);
  FreeAndNil(FFmSetUp);
  FreeAndNil(FDocInstance);

  //======== Может быть нельзя - =============================================================================
  // Но не помню почему!!!
  FreeAndNil(FMemVariableList);
  FreeAndNil(FDocVariableList);
  //==========================================================================================================
  Inherited;
end;

procedure TMikkoDoc.MikkoDocAfterOpen(dataSet: TDataSet);
var
  i: Integer;
  PField: PDocStruDescriptionItem;
  field: TField;
  s: String;
begin
  // SetOrd(ListGridOrder,1);
  if FGridOrderList.Count = 0 then
    for i := 0 to DocStruItemList.Count - 1 do
      FGridOrderList.Add(DocStruItemList[i].name);

  with dataSet do
  begin
    for i := 0 to FieldCount - 1 do
    begin
      Fields[i].Visible := False;
      // Fields[i].ReadOnly := True;
    end;

    for i := 0 to FGridOrderList.Count - 1 do
    begin
      PField := self.FieldByName(FGridOrderList[i]);
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
        ReadOnly := not PField.bEditInGrid
      end;
    end;

  end;

  // Определяем реакцию на редактирование у Грида
  if Assigned(FGridDoc) then
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
  end;

  if Assigned(FOldAfterOpen) then
    FOldAfterOpen(dataSet);

end;

procedure TMikkoDoc.Replace(aProc: TDocReplaceProc);
var bMyTransaction: Boolean;
begin
  FbDocInsert := False;
  bMyTransaction :=  not FDmMikkoads.AdsConnection1.TransactionActive;
  if bMyTransaction then
    FDmMikkoads.AdsConnection1.BeginTransaction;
  try
    if FDmMikkoads.LockDoc(FDocTablename, MemTableEhDoc.FieldByName('koddoc')
      .AsInteger) then
    begin
      FullRefresh(null,False);
      InitVariables;
      //Calcvariables;
      // DocVariableList.VarByName('aVarName')
      aProc(FDocVariableList);
      WriteVariables(FDocVariableList);
      if bMyTransaction and DmMikkoAds.AdsConnection1.TransactionActive then
        DmMikkoAds.AdsConnection1.Commit;
    end;
  except
    if bMyTransaction then
    begin
      if   DmMikkoAds.AdsConnection1.TransactionActive then
      DmMikkoAds.AdsConnection1.Rollback;
      FullRefresh(0);
    end;
    Raise;
  end;

//  aProc(FDocVariableList);
end;

{rocedure TMikkoDoc.ReplaceMarked(const afld: Variant;const aValue: Variant);
var
  i,k: Integer;
begin
    FullRefresh(null);
    for I := 0 to FMarkList.Count-1 do
    begin
      if MemTableEhDoc.Locate(KeyFields,FMarkList[i],[]) then
        Replace( procedure(var aVarList: TDocVariableList)var k: Integer; begin
        for k := varArrayLowBound(aFld,1) to varArrayHighBound(afld,1) do
          aVarList.VarByName(afld[k]).Value := aValue[k]; end);
    end;

end; }

procedure TMikkoDoc.ReplaceMarked(const afld_name: String; Value: variant);
var
  i: Integer;
begin
    FullRefresh(null);
    for I := 0 to FMarkList.Count-1 do
    begin
      if MemTableEhDoc.Locate(KeyFields,FMarkList[i],[]) then
        Replace( procedure(var aVarList: TDocVariableList)begin aVarList.VarByName
    (afld_name).Value := Value; end);
    end;

end;

procedure TMikkoDoc.ReplaceMarked(const afld_name: String);
var
  p: PDocStruDescriptionItem;
  fm: TFmDocDialog;
  i: Integer;
  sList: TStringList;
begin

  p := GetDocStruItem(afld_name);
  if not Assigned(p) then
    Exit;
  if not Assigned(p.TypeEditControl) and not p.bEditInGrid then
    Exit;

  if FMarkList.Count=0 then
  begin
    ShowMessage(' Нет помеченных записйе!');
    Exit;
  end;

  fm := TFmDocDialog.Create(FDmMikkoAds);
  sList := TStringList.Create;
  sList.Add(afld_name);
//  FDocVariableList.OnChange := FmEdit.OnChangeVariables;
  try
    with Fm do
    begin
      Caption := 'Присвоить помеченным';
      ConfigureEditByList(Fm,sList);
{      NewControl(p.TypeEditControl,p.DialogLabel,p.EditWidth,p.name);
      Items.VarByName(p.name).Value := MemTableEhDoc.FieldByName(p.name).Value;}
      PopupMode := pmAuto;
      PopupParent := Screen.ActiveForm;
      if ShowModal<>mrOk then
        Exit;
    end;
    FullRefresh(null);
    for I := 0 to FMarkList.Count-1 do
    begin
      if MemTableEhDoc.Locate(KeyFields,FMarkList[i],[]) then
        Replace( procedure(var aVarList: TDocVariableList)begin aVarList.VarByName
    (p.name).Value := Fm.items.VarByName(p.name).Value; end);
    end;
  finally
    fm.Destroy;
    sList.Free;
//    FDocVariableList.OnChange := nil;
  end;
end;

procedure TMikkoDoc.DocEdit(aStatus: TDocEditStatus;
  const aFieldName: String = '');
var
//  bValid: boolean;
  p: PDocStruDescriptionItem;
  EditFieldName: String;
  mFmEdit: TForm;
  bExternal: Boolean;
  mIsMyTransaction: Boolean;
begin

  if Assigned(FFmExternalEdit) then
  begin
    bExternal  := True;
    mFmEdit := FFmExternalEdit;
  end
  else
  begin
    mFmEdit := FFmEdit;
    // Если не настроена форма редактирования то ничего не делаем.
    if FFmEdit.items.Count=0 then
      Exit;
  end;
  FbDocInsert := (aStatus = desInsertDialog);
  if not FbDocInsert then
  begin
    mIsMyTransaction := not FDmMikkoads.AdsConnection1.TransactionActive;
    if mIsMyTransaction then
      FDmMikkoads.AdsConnection1.BeginTransaction;
  end;
  try
    try
      if not FbDocInsert then
      begin
        if not FDmMikkoads.LockDoc(FDocTablename,
          FMemTableEhDoc.FieldByName('koddoc').AsInteger) then
          Exit;

        FullRefresh(null,False);
        // Проверка - Before Edit
        if not DoBeforeDocEdit then
          Exit;

        mFmEdit.Caption := 'Редактирование';
      end
      else
      begin
        // Проверка - Before Insert
        if not DoBeforeDocInsert then
          Exit;
        mFmEdit.Caption := 'Ввод нового';
      end;
      InitVariables;
      begin
        if aStatus <> desEditInBrowse then
        begin
          DoBeforeEditInForm;
          mFmEdit.PopupMode := pmAuto;
          mFmEdit.PopupParent := Screen.ActiveForm;
          if mFmEdit.ShowModal = mrOk then
          begin
            if not bExternal then
              WriteVariables(GetEditFormVarList)
            else
              WriteVariables(FDocVariableList);
          end;
        end
        else
        begin
          // Edit In Grid;
          p := GetDocStruItem(aFieldName);
          if Assigned(p) then
          begin
            if length(p.name_owner) > 0 then
              EditFieldName := p.name_owner
            else
              EditFieldName := p.name;
            if FmEdit.Items.IndexOf(EditFieldName) > -1 then
            begin
              if FmEdit.Items.NameList[EditFieldName].oType = TItemMEditBox then
              begin
                FmEdit.Items.NameList[EditFieldName].GetMEditBox.OnButtonClick
                  (FmEdit.Items.NameList[EditFieldName].GetMEditBox);
                WriteVariables(FmEdit.items.VarList);
              end;

            end
            else
            begin
              EditInGrid(p.name);
            end;
          end;
        end;
        if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
          FDmMikkoads.AdsConnection1.Commit;
      end;
      // else
      // FDmMikkoads.AdsConnection1.Rollback;
    except
      if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
        FDmMikkoads.AdsConnection1.Rollback;
      FullRefresh(null);
      Raise;
    end
  finally
    if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
      FDmMikkoads.AdsConnection1.Rollback;

  end;;
  FullRefresh(null);
end;

function TMikkoDoc.DocLock;
begin
//  Result := True;
  if not DmMikkoAds.AdsConnection1.TransactionActive then
    DmMikkoAds.AdsConnection1.BeginTransaction;
  Result := FDmMikkoads.LockDoc(FDocTablename,
    MemTableEhDoc.FieldByName('koddoc').AsInteger);
  Fullrefresh(null,False);
end;

procedure TMikkoDoc.DoBeforeEditInForm;
begin
  if Assigned(FOnBeforeEditInForm) then
     FOnBeforeEditInForm(self);
end;

procedure TMikkoDoc.EditInGrid(fld_name: String);
var
//  bContinue: boolean;
  bMyTransaction: Boolean;
begin
  if MemTableEhDoc.FieldByName(fld_name).ReadOnly then
  begin
    if Assigned(FOnEditInGrid) then
    begin
      bMyTransaction := not FDmMikkoads.AdsConnection1.TransactionActive;
      if bMyTransaction then
        FDmMikkoads.AdsConnection1.BeginTransaction;
      try
        if FDmMikkoads.LockDoc(FDocTableName,
          MemTableEhDoc.FieldByName('koddoc').AsInteger) then
        begin
          FullRefresh(null,False);
          InitVariables;
          MemTableEhDoc.Edit;
          FOnEditInGrid(self, fld_name);
//???          WriteVariables();
          MemTableEhDoc.Post;
          // FDmMikkoads.AdsConnection1.Commit;
          // FullRefresh(null);
        end;
      except
        if bMyTransaction then
        begin
          if FDmMikkoads.AdsConnection1.TransactionActive then
            FDmMikkoads.AdsConnection1.Rollback;
          FullRefresh(0);
        end;
        Raise;
      end;
    end;
  end
end;

function TMikkoDoc.FieldByName(aName: String): PDocStruDescriptionItem;
var
  i: Integer;
begin
  Result := nil;
  aName := UpperCase(aName);
  for i := 0 to FDocStruItemList.Count - 1 do
    if UpperCase(FDocStruItemList[i].name) = aName then
    begin
      Result := FDocStruItemList[i];
      Break;
    end;
  if not Assigned(Result) then
    Raise Exception.Create(' DocStruItme not found, name -'+aname);
end;

procedure TMikkoDoc.FrameDocColumnsGetCellParams(Sender: TObject;
  EditMode: boolean; Params: TColCellParamsEh);
var
  bOk: boolean;
begin
  bOk := True;
  FbInGrid := True;
  try
    if Assigned(FOnBeforeDocEdit) then
      FOnBeforeDocEdit(self, bOk)
  finally
    FbInGrid := False;
  end;
//  else
  if (Params.ReadOnly or not bOk) then
    Params.TextEditing := False;

end;

procedure TMikkoDoc.FullRefresh(aKey: variant; bWait:Boolean = True);
var
  r: Integer;
begin
  // FmWait.sMessage := 'Wait...';
//  row := 0;
  bWait := False;
  if bWait then
  begin
    FFmWait.Caption := 'Ожидайте...';
    FFmWait.Show;
  end;
  try
    with FMemTableEhDoc do
    begin
  //    row := FGridDoc.Row;
      if Assigned(FGridDoc) then
        r := FGridDoc.RowCount
      else
        r := 0;
      DisableControls;
      try
        aKey := GetKey;
        Active := False;
        FAdsQueryDoc.Close;
        FAdsQueryDoc.Open;
        Active := True;
        //=====================================================================
        // Для грида !!!
        //=====================================================================
        //Last;
        MoveBy(r);
        Locate(FKeyFields, aKey, []);
      finally
        EnableControls;
        if Assigned(MemTableEhDoc.AfterScroll) then
          MemTableEhDoc.AfterScroll(MemTableEhDoc);
      end;
    end;
  finally
    if bWait then
      FFmWait.Close;
  end;
//  if Assigned(GridDoc) then
//    GridDoc.SetFocus;
end;

function TMikkoDoc.GetDocStruItem(const aName: String): PDocStruDescriptionItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FDocStruItemList.Count - 1 do
  begin
    if LoWerCase(FDocStruItemList[i].name) = LowerCase(aName) then
    begin
      Result := FDocStruItemList[i];
      Break;
    end;
  end;
end;

function TMikkoDoc.GetEditFormVarList: TDocVariableList;
begin
  if Assigned(FFmExternalEdit) then
  begin
    if Assigned(FOnGetEditFormVarList) then
      Result := FOnGetEditFormVarList(FFmExternalEdit);
  end
  else
    Result := FmEdit.GetVarList;
end;

function TMikkoDoc.GetKey: variant;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;
  try
    sList.Delimiter := ';';
    sList.Text := FKeyFields;
    if sList.Count = 0 then
      Result := null
    else if sList.Count = 1 then
      Result := FMemTableEhDoc.FieldByName(sList[0]).Value
    else
    begin
      Result := VarArrayCreate([1, sList.Count], varvariant);
      for i := 1 to sList.Count do
        Result[i] := FMemTableEhDoc.FieldByName(sList[i - 1]).Value;
    end;
  finally
    sList.Free;
  end;
end;

function TMikkoDoc.GetSetUpReg: String;
begin
  if length(FSpecSetUpReg)=0 then
    Result :=    '_'+IntToStr(FIdReg)+'_'+IntToStr(FIdPriznak)+'_'+IntToStr(FIdView)
  else
    Result := '_'+  FSpecSetUpReg;
end;

procedure TMikkoDoc.InitVariables;
begin
  // if FbDocInsert then
  // begin
  FDocVariableList.InInit := True;
  FDocVariableList.InitBlank;
  FDocVariableList.InInit := False;
  FMemVariableList.InInit := True;
  FMemVariableList.InitBlank;
  FMemVariableList.InInit := False;
  // end
  // else
  if not FbDocInsert then
  begin
    // FMemTableEhDoc.Append;
    FDmMikkoads.CalcVariablesOnDs(FMemTableEhDoc, FDocVariableList);
    FDmMikkoads.CalcVariablesOnDs(FMemTableEhDoc, FMemVariableList);
    // FMemTableEhDoc.Cancel;
  end;

  if Assigned(FOnInitVariables) then
    FOnInitVariables(self);
  if Assigned(FFmEdit) then
  begin
    FFmEdit.Items.SynchroWithDocVariableList(FMemVariableList, '', True);
  end;
end;

procedure TMikkoDoc.SaveVariables(FList:TDocVariableList;bNew: Boolean);
var mIsMyTr: Boolean;
begin
  if Assigned(FList) then
    FDmMikkoads.CopyVarList(FList, FDocvariableList);
  FbDocInsert := bNew;
  try
  if bNew or FDocVariableList.GetIsChanged then
  begin
    mIsMyTr := not FDmMikkoAds.AdsConnection1.TransactionActive;
    if mIsMyTr then
      FDmMikkoAds.AdsConnection1.BeginTransaction;
    try
//      if DocLock then
      if mIsMyTr or DocLock then
         WriteVariables(FDocVariableList);
      if mIsMyTr and FDmMikkoAds.AdsConnection1.TransactionActive then
        FDmMikkoAds.AdsConnection1.Commit;
    except
      if FDmMikkoAds.AdsConnection1.TransactionActive and mIsMyTr then
        FDmMikkoAds.AdsConnection1.Rollback;
    end;
  end;
  finally
    FbDocInsert := False;
  end;
end;

procedure TMikkoDoc.SetAfterOpen(aDs: TDataSet);
begin
  if Assigned(aDs.AfterOpen) then
    FOldAfterOpen := aDs.AfterOpen;
  aDs.AfterOpen := MikkoDocAfterOpen;
end;

{procedure TMikkoDoc.SetGridFldEdit(const Value: RGridFldEdit);
begin
  GridFldEdit := Value;
end;}

procedure TMikkoDoc.SetIdReg(const Value: Integer);
begin
  FIdReg := Value;
  FDocTablename := 'task\dc' + StrZero(FIdReg, 6);
  FPrepared := False;
end;

procedure TMikkoDoc.SetDataSetDriverEhDoc(aDataSetDriver: TDataSetDriverEh);
begin
  FDatasetDriverEhDoc := aDataSetDriver;
  FDatasetDriverEhDoc.OnUpdateRecord := DataSetDriverEhDocUpdateRecord;
end;

procedure TMikkoDoc.SetDmMikkoAds(const Value: TDmMikkoads);
begin
  FDmMikkoads := Value;
end;

procedure TMikkoDoc.SetGridDoc(const Value: TDbGridEhVk);
begin
  FGridDoc := Value;
end;

procedure TMikkoDoc.SetOnBeforeDocDelete(const Value: TBoolNotifyEvent);
begin
  FOnBeforeDocDelete := Value;
end;

procedure TMikkoDoc.SetOnBeforeDocInsert(const Value: TBoolNotifyEvent);
begin
  FOnBeforeDocInsert := Value;
end;

procedure TMikkoDoc.SetOnEditInGrid(const Value: TFuncEditInGrid);
begin
  FOnEditInGrid := Value;
end;

procedure TMikkoDoc.SetOnSetFilter(const Value: TSetFilterNotifyEvent);
begin
  FOnSetFilter := Value;
end;

procedure TMikkoDoc.SetOnStoreVariables(const Value: TNotifyEvent);
begin
  FOnStoreVariables := Value;
end;

procedure TMikkoDoc.ViewHistory;
var Fm: TFmViewHistory;
begin
  Fm:= TFmViewHistory.Create(FDmMikkoAds);
  try
    Fm.Prepare(FDmMikkoads,MemTableEhDoc.FieldByName('koddoc').AsInteger);
    Fm.ShowModal;
  finally
    Fm.Free;
  end;

end;

procedure TMikkoDoc.WriteVariables(aVarList:TDocVariableList);
begin
  // FDmMikkoads.EditDoc(bNew,koddoc,FIdReg,FIdPriznak,FDocvariableList,bSod,'');
  with FMemTableEhDoc do
  begin
    if bDocInsert then
    begin
      Append;
      // FDocVariableList.VarByName('koddoc').AsInteger := DmMikkoAds.NewNum('DOCUMENT');
      // FDocVariableList.VarByName('priznak').AsInteger := FIdPriznak;
      MemTableEhDoc.FieldByName('koddoc').AsInteger :=
        DmMikkoAds.NewNum('DOCUMENT');
      MemTableEhDoc.FieldByName('priznak').AsInteger := FIdPriznak;
    end
    else
    begin
      Edit;
      // koddoc := FDocvariableList.VarByName('koddoc').AsInteger;
    end;
    DmMikkoAds.WriteVarListToDs(aVarList, FMemTableEhDoc);
    if Assigned(FOnWriteVariables) then
      FOnWriteVariables(self);
    FMemTableEhDoc.Post;
  end;
end;

procedure TMikkoDoc.DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
var
  bNew: boolean;
begin

  if FDocVariableList.Count=0 then
    Exit;
  FDmMikkoads.UpdateVariablesOnDeltaDs(FMemTableEhDoc, FDocVariableList);
  bNew := False;
  if (MemRec.UpdateStatus = usInserted) then
  begin
    if FDocVariableList.VarByName('koddoc').AsInteger = 0 then
      FDocVariableList.VarByName('koddoc').AsInteger :=
        FMemTableEhDoc.FieldByName('koddoc').AsInteger;
    if FDocVariableList.VarByName('koddoc').AsInteger = 0 then
      Raise Exception.Create(' Нулевой koddoc.');
    // FDmMikkoAds.EditDoc(True,FDocVariableList.VarByName('koddoc').AsInteger,FIdReg,FIdPriznak,FDocVariableList,False,'');
    bNew := True;
  end;

  if Assigned(FOnStoreVariables) then
    FOnStoreVariables(self);
  if (MemRec.UpdateStatus = usModified) or
    (MemRec.UpdateStatus = usInserted) then
  begin
    FDmMikkoads.EditDoc(bNew, FDocVariableList.VarByName('koddoc').AsInteger,
      FIdReg, FIdPriznak, FDocVariableList, False, '');
  end
  else if (MemRec.UpdateStatus = usDeleted) then
    FDmMikkoads.DeleteDoc(FIdReg, FIdPriznak,
      FDocVariableList.VarByName('koddoc').AsInteger, '');

end;

end.
