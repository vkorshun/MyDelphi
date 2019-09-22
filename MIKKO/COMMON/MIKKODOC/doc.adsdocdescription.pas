unit doc.adsdocdescription;

interface

uses
  SysUtils, Classes, Dm_mikkoads, DB, adsdata, adsfunc, adstable,
  MemTableDataEh, MemTableEh, doc.variablelist, Generics.Collections,
  Forms,Controls, docdialog.fm_docdialog, DateVk, DataDriverEh, Dialogs,
  fm_wait, mask;

type

  TClassWinControl = class of TWinControl;
  PDialogField = ^RDialogField;
  RDialogField = record
    name:          String;
    GridLabe:      String;
    DialogLabel:   String;
    DisplayWidth:  Integer;
    EditWidth:     Integer;
    //GridOrder:     Integer;
    //insert_order:  Integer;
    //EditOrder:     Integer;
    TypeEditControl: TClassWinControl;
  end;

  TAdsDocDescription = class(TObject)
  private
    FbDocInsert: Boolean;
    FbSod: Boolean;
    FIdReg: Integer;
    FIdPriznak: Integer;
    FAdsQueryDoc: TAdsQuery;
    FDatasetDriverEhDoc: TDataSetDriverEh;
    FDmMikkoads: TDmMikkoads;
    FFmEdit: TFmDocDialog;
    FFmWait: TFmWait;
    FSQL:TStringList;
    FFieldList: TList<PDialogField>;
    FGridOrderList: TStringList;
    FEditOrderList: TStringList;
    FMemTableEhDoc: TMemTableEh;
    FOldAfterOpen: TDataSetNotifyEvent;
    FOnInitVariables: TNotifyEvent;
    FOnWriteVariables: TNotifyEvent;
    FDocVariableList: TDocVariableList;
    procedure SetDataSetDriverEhDoc(aDataSetDriver: TDataSetDriverEh);
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddDialogField(aFieldName, aGridLabel, aDialogLabel: String;
      aDisplayWidth: Integer =0; aEditWidth:Integer = 0;aTypeEditControl: TClassWinControl = nil);
    ///<summary>  Настройка окна редактирования, если aFm не передан то FFmEdit </summary>
    procedure ConfigureEdit(aFm:TFmDocDialog);
    procedure DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
                                  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);Virtual;
    procedure DeleteDoc;
    procedure DocDescriptionAfterOpen(dataSet:TDataSet);

    procedure EditDoc(bNew:Boolean);
    function  FieldByName(aName:String):PDialogField;
    procedure FullRefresh(aKodDoc: Integer);
    function  GetKey:Integer;virtual;
    procedure InitVariables;
    procedure SetAfterOpen(aDs:TDataSet);
//    procedure SetOrd(aNames:TStringList; aType:Integer);
    procedure WriteVariables;
//    procedure SetOrdEdit(aNames:TStringList);

    property AdsQueryDoc : TAdsQuery read FAdsQueryDoc write FAdsQueryDoc;
    property bDocInsert:Boolean read FbDocInsert write FbDocInsert;
    property bSod:Boolean read FbSod write FbSod;
    property DataSetDriverEhDoc: TDataSetDriverEh read FDataSetDriverEhDoc write SetDataSetDriverEhDoc;
    property DmMikkoAds: TDmMikkoAds read FDmMikkoads write FDmMikkoAds;
    property FmEdit:TFmDocDialog read fFmEdit;
    property IdReg:Integer read FIdReg write FIdReg;
    property IdPriznak:Integer read FIdPriznak write FIdPriznak;
    property SQL:TStringList read FSQL;
    property FieldList:TList<PDialogField> read FFieldList;
    property ListGridOrder: TStringList read FGridOrderList;
    property ListEditOrder: TStringList read FEditOrderList;
    property MemTableEhDoc: TMemTableEh read FMemTableEhDoc write FMemTableEhDoc;
    property OnInitVariables: TNotifyEvent read FOnInitVariables write FOnInitvariables;
    property OnWriteVariables: TNotifyEvent read FOnWritevariables write FOnWriteVariables;
  end;


implementation



{ TDocDescription }


procedure TAdsDocDescription.AddDialogField(aFieldName, aGridLabel, aDialogLabel: String;
      aDisplayWidth: Integer =0; aEditWidth:Integer = 0;aTypeEditControl: TClassWinControl = nil);
var p: PDialogField;
begin
  New(p);
  p.name        := aFieldName;
  p.GridLabe    := aGridLabel;
  p.DialogLabel := aDialogLabel;
  p.DisplayWidth:= aDisplayWidth;
  p.EditWidth   := aEditWidth;
  p.TypeEditControl := aTypeEditControl;
  FFieldList.Add(p);
end;

procedure TAdsDocDescription.ConfigureEdit(aFm: TFmDocDialog);
var Fm: TFmDocDialog;
    i: Integer;
    PField: PDialogField;
begin
  if Assigned(aFm) then
    Fm := aFm
  else
    Fm := FFmEdit;

  with Fm do
  begin
    Items.Clear;
    for I := 0 to ListEditOrder.Count-1 do
    begin
      pField := FieldByName(ListEditOrder[i]);
      if Assigned(pField) then
        NewControl(pField.TypeEditControl,pField.GridLabe,30, pField.name,FDocVariableList.VarByName(pField.Name));
    end;

  end;

end;

constructor TAdsDocDescription.Create;
begin
  Inherited;
  FbSod := False;
  FIdReg := 0;
  FIdPriznak := 0;
  FSQL := TStringList.Create;
  FFieldList := TList<PDialogField>.Create;
  FEditOrderList := TStringList.Create;
  FGridOrderList := TStringList.Create;
  FDocVariableList := TDocVariableList.Create;
end;

procedure TAdsDocDescription.DeleteDoc;
begin
  try
    if FMemTableEhDoc.IsEmpty then
      Exit;
    if MessageDlg('Удалить текущую запись',mtConfirmation,mbYesNo,0)<> mrYes then
      Exit;
    FDmMikkoads.AdsConnection1.BeginTransaction;
    try
      FMemTableEhDoc.Delete;
      FDmMikkoads.AdsConnection1.Commit;
    except
      FDmMikkoads.AdsConnection1.Rollback;
      Raise;
    end;
  finally
    FullRefresh(0);
  end;
end;

destructor TAdsDocDescription.Destroy;
begin
  FSQL.Free;
  FFieldList.Free;
  FEditOrderList.Free;
  FGridOrderList.Free;
  FDocVariableList.Free;
  Inherited;
end;

procedure TAdsDocDescription.DocDescriptionAfterOpen(dataSet: TDataSet);
var i: Integer;
    pField: PDialogField;
begin
  //SetOrd(ListGridOrder,1);
  with DataSet do
  begin
    for i := 0 to FieldCount-1 do
      Fields[i].Visible := False;

    for I := 0 to  FEditOrderList.Count-1 do
    begin
      pField := self.FieldByName(FEditOrderList[i]);
      with FieldByName(pField.name) do
      begin
        DisplayLabel := pField.DialogLabel;
        DisplayWidth := pField.DisplayWidth;
        Index        := i;
      end;
    end;

  end;


  if Assigned(FOldAfterOpen) then
    FOldAfterOpen(Dataset);
end;

procedure TAdsDocDescription.EditDoc(bNew: Boolean);
begin
  FbDocInsert := bNew;
  FDmMikkoAds.AdsConnection1.BeginTransaction;
  try
    if not FbDocInsert then
      FDmMikkoAds.LockDoc('TASK\'+StrZero(FIdReg,11),FMemTableEhDoc.FieldByName('koddoc').AsInteger);
    InitVariables;
    if FmEdit.ShowModal= mrOk then
    begin
      Writevariables;
    end;
    FDmMikkoAds.AdsConnection1.Commit;
  except
    FDmMikkoAds.AdsConnection1.Rollback;
    FullRefresh(0);
    Raise;
  end;

end;

function TAdsDocDescription.FieldByName(aName: String): PDialogField;
var I: Integer;
begin
  Result := nil;
  aName := UpperCase(aName);
  for I := 0 to FFieldList.Count-1 do
    if Uppercase(FFieldList[i].name)=aName then
    begin
      Result := FFieldList[i];
      Break;
    end;
end;

procedure TAdsDocDescription.FullRefresh(aKodDoc:Integer);
begin
//  FmWait.sMessage := 'Wait...';
  FFmWait.Caption  := 'Ожидайте...';
  FFmWait.Show;
  try
  with FMemTableEhDoc do
  begin
    DisableControls;
    try
      if aKodDoc=0 then
        aKodDoc := MemTableEhDoc.FieldByName('koddoc').AsInteger;
      Active := False;
      FAdsQueryDoc.Close;
      FAdsQueryDoc.Open;
      Active := True;
      Locate('koddoc',aKodDoc,[]);
    finally
      EnableControls;
    end;
  end;
  finally
    FFmWait.Close;
  end;

end;

function TAdsDocDescription.GetKey: Integer;
begin
  Result := FMemTableEhDoc.FieldByName('koddoc').AsInteger;
end;

procedure TAdsDocDescription.InitVariables;
begin
  if FbDocInsert then
  begin
    FDmMikkoAds.InitDocVariableListOnDs(FMemTableEhDoc,FDocVariableList);
  end
  else
  begin
    FDmMikkoAds.CalcVariablesOnDs(FMemTableEhDoc,FDocVariableList);
  end;
  if Assigned(FOnInitVariables) then
    FOnInitVariables(Self);
end;

procedure TAdsDocDescription.SetAfterOpen(aDs: TDataSet);
begin
  if Assigned(ads.AfterOpen) then
    FOldafterOpen := ads.AfterOpen;
  aDs.AfterOpen := DocDescriptionafterOpen;
end;

procedure TAdsDocDescription.SetDataSetDriverEhDoc(
  aDataSetDriver: TDataSetDriverEh);
begin
  FDataSetDriverEhDoc := aDataSetDriver;
  FDataSetDriverEhDoc.OnUpdateRecord := DataSetDriverEhDocUpdateRecord;
end;

{procedure TAdsDocDescription.SetOrd(aNames: TStringList; aType: Integer);
var i,k: Integer;
begin
  for I := 0 to FFieldList.Count-1 do
  begin
    k := aNames.IndexOf(FFieldList[i].name);
    begin
      if aType=1 then
        FFieldList[i].GridOrder := k
      else
        FFieldList[i].EditOrder := k;
    end;
  end;
end;}

procedure TAdsDocDescription.WriteVariables;
begin
//  FDmMikkoads.EditDoc(bNew,koddoc,FIdReg,FIdPriznak,FDocvariableList,bSod,'');
  with FMemTableEhDoc do
  begin
    if bDocInsert then
    begin
      Append;
      FDocVariableList.VarByName('koddoc').AsInteger := DmMikkoAds.NewNum('DOCUMENT');
      FDocVariableList.VarByName('priznak').AsInteger := FIdPriznak;
    end
    else
    begin
      Edit;
//      koddoc := FDocvariableList.VarByName('koddoc').AsInteger;
    end;
    DmMikkoAds.WriteVarListToDs(FDocVariableList,FMemTableEhDoc);
    if Assigned(FOnWritevariables) then
      FOnWritevariables(Self);
    FMemTableEhDoc.Post;
  end;
end;

procedure TAdsDocDescription.DataSetDriverEhDocUpdateRecord(DataDriver: TDataDriverEh;
  MemTableData: TMemTableDataEh; MemRec: TMemoryRecordEh);
begin

  if (MemRec.UpdateStatus = usInserted ) then
  begin
    if FDocVariableList.VarByName('koddoc').AsInteger=0 then
      FDocVariableList.VarByName('koddoc').AsInteger := FMemTableEhDoc.FieldByName('koddoc').AsInteger;
    if FDocVariableList.VarByName('koddoc').AsInteger=0 then
       Raise Exception.Create(' Нулевой koddoc.');
    FDmMikkoAds.EditDoc(True,FDocVariableList.VarByName('koddoc').AsInteger,FIdReg,FIdPriznak,FDocVariableList,False,'');
  end
  else
  if (MemRec.UpdateStatus = usModified ) then
  begin
    FDmMikkoAds.EditDoc(False,FDocVariableList.VarByName('koddoc').AsInteger,FIdReg,FIdPriznak,FDocVariableList,False,'');
  end
  else
  if (MemRec.UpdateStatus = usDeleted ) then ;
    FDmMikkoAds.DeleteDoc(FIdReg,FIdPriznak,FDocVariableList.VarByName('koddoc').AsInteger,'');

end;

end.
