unit rtc.framedoc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGridEh, Menus, DB, ComCtrls, ExtCtrls,  monitor,
  buttons, rtc.dmdoc, datevk, DBGridEhVk, StdCtrls, Registry, DbGridColumnsParamList,
  GridsEh, vkvariable, ActionManagerDescription, ToolWin, ActnMan, fmVkDocDialog,
  ActnCtrls, ImgList,ActnList, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, DBAxisGridsEh,
  VkVariableBinding, MEditBox, uDocDescription, fmsetupform, System.Actions, System.Generics.Collections, EhLibMTE,
  EhLibVCL;

const
  WM_ENTER = WM_USER +2;
  IDE_DOC_ADD          = 1;
  IDE_DOC_EDIT         = 2;
  IDE_DOC_DELETE       = 3;
  IDE_DOC_COPY         = 4;
  IDE_DOC_PRINT        = 5;
  IDE_DOC_SVOD         = 6;
  IDE_DOC_MARK         = 7;
  IDE_DOC_MARKALL      = 8;
  IDE_DOC_UNMARKALL    = 9;
  IDE_DOC_FIND         = 10;
  IDE_DOC_FINDNEXT     = 11;
  IDE_DOC_SETFILTER    = 12;
  IDE_DOC_REFRESH      = 13;
  IDE_DOC_SELECT       = 14;
  IDE_DOC_CHANGEIDTYPE = 15;
  IDE_DOC_NORMAL       = 16;
  IDE_DOC_CALENDAR     = 17;
  IDE_DOC_GOIN         = 18;
  IDE_DOC_GOOUT        = 19;
  IDE_DOC_CLEARINI     = 20;
  IDE_DOC_VIEWPRVD     = 21;
  IDE_DOC_TOEXCEL      = 22;

type
  TDocFrameClass = class of TDocFrame;

  TBlankSelectEvent          = procedure(Sender:TObject; aIndex:Integer) of object;
  TNotifyDocEvent            = procedure(Sender:TObject; aId: Integer) of object;
  TNotifyDefineActionManager = procedure( Sender:TObject; Am:tActionManager) of object;
  TLocalStoreVariables       = function(Sender:TObject; bAppend:Boolean):Boolean of object;
  TFocusToDocEvent           = procedure (Sender:TObject; AId_doc:largeInt) of object;
  TDocEditStatus             = (desInsertDialog, desEditDialog, desEditInBrowse, desCloneDialog);
  TDocReplaceProc = reference to procedure(var AVarList: TVkVariableCollection);
  TFuncEditInGrid = function(Sender: TObject; const fieldName: String): boolean of object;
  TFuncGetMessage = function: String of object;
  TProcOnActionEvent = procedure (Sender: TObject; AAction: TAction);
  TOnShowDocument = procedure(const AFrameDocClassName: String; AParams:TVkVariableCollection) of object;

  TDocFrame = class(TFrame)
    StatusBar1: TStatusBar;
    DataSource1: TDataSource;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    ActionToolBar1: TActionToolBar;
    DBGridEhVkDoc: TDBGridEhVk;
    Splitter1: TSplitter;
    DocActionList: TActionList;
    aDocInsert: TAction;
    aDocEdit: TAction;
    aDocDelete: TAction;
    aDocFind: TAction;
    aDocContinueFind: TAction;
    aDocRefresh: TAction;
    aDocClone: TAction;
    aDocMark: TAction;
    aDocMarkAll: TAction;
    aDocUnMarkAll: TAction;
    aDocToExcel: TAction;
    procedure est1Click(Sender: TObject);
    procedure nMarkClick(Sender: TObject);
    procedure DBGridEhVkDocKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridEhVkDocKeyPress(Sender: TObject; var Key: Char);
    procedure nUnmarkAllClick(Sender: TObject);
    procedure DBGridEhVkDocDblClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure DataSource1StateChange(Sender: TObject);
    procedure DBGridEhVkDocGetCellParams(Sender: TObject; Column: TColumnEh;
      AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure nFindClick(Sender: TObject);
    procedure nContinueClick(Sender: TObject);
    procedure DbGridEhVkDocAfterApplayUserFilter(Sender: TObject);
    procedure DBGridEhVkDocDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
    procedure aDocInsertExecute(Sender: TObject);
    procedure aDocEditExecute(Sender: TObject);
    procedure aDocDeleteExecute(Sender: TObject);
    procedure aDocFindExecute(Sender: TObject);
    procedure aDocContinueFindExecute(Sender: TObject);
    procedure aDocRefreshExecute(Sender: TObject);
    procedure aDocCloneExecute(Sender: TObject);
    procedure DBGridEhVkDocEnter(Sender: TObject);
    procedure aDocEditUpdate(Sender: TObject);
    procedure aDocDeleteUpdate(Sender: TObject);
    procedure DBGridEhVkDocFillSTFilterListValues(Sender: TCustomDBGridEh;
      Column: TColumnEh; Items: TStrings; var Processed: Boolean);
  private
    FbHaveSod: Boolean;
    FOnSetCaption: TNotifyEvent;
    FOnDocEvent:       TNotifyDocEvent;
    FOnStoreVariables: TNotifyEvent;
    FParentForm: TForm;
    FLocalstoreVariables: TLocalStoreVariables;
    ItogMarkedList: TVkVariableCollection;
    FDocDm: TDocDm;
    FFmEdit: TVkDocDialogFm;
    FExternalFmEdit: TVkDocDialogFm;
    FOnMark: TNotifyEvent;
    FOnUnmark: TNotifyEvent;
    FOnBeforeEditInForm: TNotifyEvent;
    FOnEditInGrid: TFuncEditInGrid;
    FRootKey: String;
    FOnInitActionManager: TNotifyEvent;
    FOnGetDeleteMessage: TFuncGetMessage;
    FOnEditAction: TProcOnActionEvent;
    FIsSelect: Boolean;
    FPrepared: Boolean;
    _bDocInsert: Boolean;
    _bDocClone: Boolean;

    procedure Init(Component: TComponent);
//    function bHaveSod: Boolean;
    { Private declarations }
    procedure AddMSum(bAdd:Boolean);
    procedure EditInGrid(fld_name: String);
    procedure SetFocusToGrid;
    procedure SetOnBeforeEditInForm(const Value: TNotifyEvent);
    procedure SetOnDeleteGetMessage(const Value: TFuncGetMessage);
    procedure SetOnGetDeleteMessage(const Value: TFuncGetMessage);
    procedure SetOnEditAction(const Value: TProcOnActionEvent);
    function GetCurrentFrame: TDocFrame;
    procedure SetCurrentFrame(const Value: TDocFrame);
    procedure SetPrepare(const Value: Boolean);
  protected
    bAppend: Boolean;
    FFrameDoc: TDocFrame;
    FFrameSod: TDocFrame;
    FActionDescription: TActionListDescriptionList;
    FMarkAll: Boolean;
    FMarkList: TList<Variant>;
    ValList: TVkVariableCollection;
    FSelected: TVkVariableCollection;
    FInEdit: Boolean;
    FCurrentParams: TVkVariableCollection;
    FActionSuccess: Boolean;

    FOnDefineActionManager: TNotifyDefineactionManager;
    FOnDeleteGetMessage: TFuncgetMessage;
    FCaption:String;
    FReg:TRegistry;
    FFmSetUp: TSetUpFormFm;
    nIndex: Integer;

    procedure ClearIni;
    procedure DefaultActionListInit;
    procedure DefaultDocEvent(aId:Integer);
    function  DoBeforeDocEdit:Boolean;
    function  DoBeforeDocInsert:Boolean;
    function  DoBeforeDocDelete:Boolean;
    procedure DoBeforeEditInForm;

    //    procedure DocEdit(bNew: boolean);virtual;
    procedure DocCopy;
    procedure DocExecuteAction(Sender:TObject);
    procedure DocDelete;virtual;
    procedure DocSetFilter;
    procedure DoDocEvent(aId:Integer);
    procedure ConfigureEdit;virtual;
    procedure OnChangeEditItem(Sender:TObject);virtual;
    function  StoreVariables:Boolean;virtual;

    procedure FrameDocColumnsGetCellParams(Sender: TObject; EditMode: boolean; Params: TColCellParamsEh);

    procedure FrameDestroy(Sender:TObject);
    procedure DoMark(bMark: Boolean);
    procedure DoMarkAll;
    procedure DoUnMarkAll;
    procedure DoEnterMs(var Msg:TMessage); Message WM_ENTER;

    procedure DoDocAfterOpen(DataSet: TDataSet);virtual;
    procedure DoDocBeforeClose(DataSet: TDataSet);

    /// <summary> Инициализация списка итогов  </summary>
    procedure InitSumList(var VarList:TVkVariableCollection);

    function  GetParentForm:TForm;
    function GetSelected: TVkVariableCollection;virtual;
    function GetSetUpKeyName:String;virtual;
    procedure FmEditOnActionUpdate(Sender: TObject);virtual;
    procedure SetIsSelect(const Value: Boolean);virtual;
    procedure SetFilter(aId_doc:Integer);
    procedure SetParentForm(aForm:TForm);
    procedure SetSumMarked;
    function ValidAccess(aIdAccess:LargeInt): boolean;
    function onSaveDialog(Sender: TObject):Boolean;
    class var onShowDocument: TOnShowDocument;

  public
    { Public declarations }
    VarMDoc: TVkVariableCollection;
    DocFrame: TFrame;
    procedure DocEdit(AStatus: TDocEditStatus; const AFieldName: String = '');

    property DocDm:TDocDm read FDocDm;
    property FmEdit: TVkDocDialogFm read FFmEdit;
    property OnMark: TNotifyEvent read FOnMark write FOnMark;
    property OnUnMark: TNotifyEvent read FOnUnmark write FOnUnMark;

    constructor Create(AOwner: TComponent; ADocDm:TDocDm); reintroduce;virtual;
    destructor  Destroy;override;
    function CheckIdObject(AIdObject:TObject):Boolean;virtual;
    function CheckParams(AParams:TVkVariableCollection):Boolean;virtual;
    procedure   DefineActionManager(Am: TActionManager);
    procedure  DoOk;
    procedure   FullRefresh;
    function IsEqualParams(AParams: TVkVariableCollection): Boolean;
    function GetActiveControl: TWinControl; virtual;

    procedure OnFilteredSetCaption(Sender: TObject);
    procedure SetCaption;
    property  ActionDescription: TActionListDescriptionList read FActionDescription;
    function GetCaption:String;virtual;
    procedure Load;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;virtual;
    class procedure SetOnShowDocument(const AOnShowDocument: TOnShowDocument);

    procedure OnCloseQueryFmEdit(Sender: TObject;  var CanClose: Boolean);
    function  ValidDataFmEdit(Sender:TObject):Boolean;virtual;
    procedure OnBeforeEditDataSetDoc(DataSet: TDataSet);
    procedure OnAfterPostDataSetDoc(DataSet:TDataSet);
    procedure OnBeforeCloseDataSetDoc(Sender:TObject);
    procedure OnBeforeCloseDataSetSod(Sender:TObject);
    procedure OnAfterOpenDataSetDoc(Sender:TObject);
//    procedure OnAfterOpenDataSetSod(Sender:TObject);
    procedure RecalcInternalSize;
    procedure DocMarkDrawDataCell(Sender:TDbGridEhVk; State: TGridDrawState);
//    class procedure ViewFrame;
    class procedure ViewFrame(const className:String;AParams:TVkVariableCollection);
//    class function Select(Aparam: TVkvaraibleCollection):Boolean;
    procedure WmCalendarChanged(var aMes:TMessage);
    //message WM_CALENDARCHANGED;
    class function GetDmDoc: TDocDm;virtual;
    /// <summary> Инициализация событий  </summary>
    procedure InitActionManager(aForm: TForm);
    procedure InitBeforeSelect(AValue: TVkVariableCollection);virtual;
    function Locate(AValue: TVkVariableCollection):Boolean;virtual;

    property ExternalFmEdit: TVkDocDialogFm read FExternalFmEdit write FExternalFmEdit;
    property OnBeforeEditInForm: TNotifyEvent read FOnBeforeEditInForm write SetOnBeforeEditInForm;
    property OnDocEvent:TNotifyDocEvent read FOnDocEvent write FOnDocEvent;
    property OnDefineActionManager: TNotifyDefineactionManager read FOnDefineActionManager write FOnDefineActionManager;
    property OnSetCaption:TNotifyEvent read FOnSetCaption write FOnSetCaption;
    property OnInitActionManager: TNotifyEvent read FOnInitActionManager write FOnInitActionManager;

    property ParentForm:TForm read FParentForm write FParentForm;
    property CurrentFrame: TDocFrame read GetCurrentFrame write SetCurrentFrame;
    property OnGetDeleteMessage:TFuncGetMessage read FOnGetDeleteMessage write SetOnGetDeleteMessage;
    property OnEditAction: TProcOnActionEvent read FOnEditAction write SetOnEditAction;
    property IsSelect: Boolean read FIsSelect write SetIsSelect;
    property Selected: TVkVariableCollection read GetSelected;
    property Prepared: Boolean  read FPrepared write SetPrepare;
  end;

implementation

uses  Types, DocSqlManager,  rtc.fmCustomDoc,
       rtc.docbinding;
{$R *.dfm}

procedure TDocFrame.FmEditOnActionUpdate(Sender: TObject);
begin

end;

procedure TDocFrame.FrameDestroy(Sender:TObject);
begin
  FFmSetUp.UpdateChanges;
  FFmSetUp.SaveChanges;
  FreeAndNil(FMarkList);
  FreeAndNil(ValList);
end;

procedure TDocFrame.FrameDocColumnsGetCellParams(Sender: TObject; EditMode: boolean;
  Params: TColCellParamsEh);
var
  bOk: boolean;
begin
  bOk := True;
{  FbInGrid := True;
  try
    if Assigned(FOnBeforeDocEdit) then
      FOnBeforeDocEdit(self, bOk)
  finally
    FbInGrid := False;
  end; }
  if (Params.ReadOnly or not bOk) then
    Params.TextEditing := False;
end;

procedure TDocFrame.FullRefresh;
begin
  //DBGridEhVkDoc.DataSource
  if Assigned(DocDm) then
    DocDm.FullRefreshDoc;

  DBGridEhVkDoc.STFilter.Visible := true;
end;

function TDocFrame.GetActiveControl: TWinControl;
begin
  Result := DbGridEhVkDoc;
end;

function TDocFrame.GetCaption: String;
begin
  Result := 'ABSTRACT DOC';
end;

function TDocFrame.GetCurrentFrame: TDocFrame;
begin
  Result := TCustomDocFm(GetParentForm).CurrentFrame;
end;

class function TDocFrame.GetDmDoc: TDocDm;
begin
  Result := nil;
end;

function TDocFrame.GetParentForm: TForm;
var _oControl: TWinControl;
begin
  Result := FParentForm;
  if not Assigned(Result) then
  begin
    _oControl := Parent;
    while Assigned(_oControl) do
    begin
      _oControl := _oControl.Parent;
      if (_oControl is TForm) then
      begin
        Result := TForm(_oControl);
        Exit;
      end;
    end;
  end;
end;



function TDocFrame.GetSelected: TVkVariableCollection;
begin
  Result := FSelected;
end;

class function TDocFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  Result := Format('Selected %d',[Avar.Count]);
end;

function TDocFrame.GetSetUpKeyName: String;
begin
  Result := ClassName;
end;

{function TFrameDoc.GetListFuncEdit: TStringList;
begin

end; }

{function TFrameDoc.GetOnValidDataFmEdit: TBoolFunction;
begin
  Result := FOnValidDataFmEdit;
end;  }


procedure TDocFrame.nContinueClick(Sender: TObject);
begin
//  DocDm.oIDmMain.InternalFind(DocDm.pFIBDataSetDoc,True);
  DbGridEhVkDoc.Find(True);
end;

procedure TDocFrame.nFindClick(Sender: TObject);
begin
  DbGridEhVkDoc.Find(False);
end;

procedure TDocFrame.AddMSum(bAdd:Boolean);
var VarList: TVkVariableCollection;
    i: Integer;
begin
  VarList := VarMDoc;

  for i:=0 to VarList.Count - 1 do
  begin
    if bAdd then
    begin
      VarList.Value[i]:= VarList.Value[i]+DocDm.MemTableEhDoc.FieldByName(VarList.Items[i].name).AsFloat
    end
    else
    begin
      VarList.Value[i]:= VarList.Value[i]-DocDm.MemTableEhDoc.FieldByName(VarList.Items[i].name).AsFloat
    end;
  end;
  SetSumMarked;
end;

procedure TDocFrame.aDocCloneExecute(Sender: TObject);
begin
  if Assigned(FOnEditAction) then
    FOnEditAction(self,aDocClone);
  DocEdit(desCloneDialog);
end;

procedure TDocFrame.aDocContinueFindExecute(Sender: TObject);
begin
  DbGridEhVkDoc.Find(True);
end;

procedure TDocFrame.aDocDeleteExecute(Sender: TObject);
begin
  if Assigned(FOnEditAction) then
    FOnEditAction(self,aDocDelete);
  DocDelete;
end;

procedure TDocFrame.aDocDeleteUpdate(Sender: TObject);
begin
//  if FDocDm.MemTableEhDoc.IsEmpty then
//    TAction(Sender).Enabled := false ;
end;

procedure TDocFrame.aDocEditExecute(Sender: TObject);
begin
  if Assigned(FOnEditAction) then
    FOnEditAction(self,aDocEdit);
  DocEdit(desEditDialog);
end;

procedure TDocFrame.aDocEditUpdate(Sender: TObject);
begin
//  TAction(Sender).Enabled := FDocDm.MemTableEhDoc.IsEmpty;
end;

procedure TDocFrame.aDocFindExecute(Sender: TObject);
begin
  DbGridEhVkDoc.Find(False);
end;

procedure TDocFrame.aDocInsertExecute(Sender: TObject);
begin
  if Assigned(FOnEditAction) then
    FOnEditAction(self,aDocInsert);
  DocEdit(desInsertDialog);
  //DocDm.DirectInsertDoc;
end;

procedure TDocFrame.aDocRefreshExecute(Sender: TObject);
begin
  DocDm.FullRefreshDoc(true);
  DBGridEhVkDoc.STFilter.Visible := True;
end;

function TDocFrame.CheckIdObject(AIdObject: TObject): Boolean;
begin
   Result := True;
end;

function TDocFrame.CheckParams(AParams: TVkVariableCollection): Boolean;
begin
  FCurrentParams := AParams;
  Result := true;
end;

procedure TDocFrame.ClearIni;
begin
  Inherited;
end;

procedure TDocFrame.ConfigureEdit;
var i: Integer;
  _DescriptionList: TDocStruDescriptionList;
  _Item: PDocStruDescriptionItem;
  _vname: String;
begin
{  DocDm.OnBeforeEditDataSetDoc  := OnBeforeEditDataSetDoc;
  DocDm.OnAfterPostDataSetDoc   := OnAfterPostDataSetDoc;
  DocDm.OnAfterCancelDataSetDoc := OnAfterPostDataSetDoc;
  DocDm.OnBeforeCloseDataSetDoc := OnBeforeCloseDataSetDoc;
  DocDm.OnBeforeCloseDataSetSod := OnBeforeCloseDataSetSod;
  DocDm.OnAfterOpenDataSetDoc   := OnAfterOpenDataSetDoc;
//  DocDm.OnAfterOpenDataSetSod   := OnAfterOpenDataSetSod;
  if Assigned(FOnConfigureEdit) then
    FOnConfigureEdit(Self);}
  FmEdit.Clear;
  _DescriptionList := DocDm.DocStruDescriptionList;
  for I := 0 to _DescriptionList.Count-1 do
  begin
    _Item :=  _DescriptionList.GetDocStruDescriptionItem(i);
    if Assigned(_Item.BindingDescription) then
    begin
      if _Item.name_owner<>'' then
        _vname := _Item.name_owner
      else
        _vname := _Item.name;
      if (_DescriptionList.PageCaptionList.Count<=2) and (_DescriptionList.Count<16) then
        FmEdit.NewControl('',_Item.BindingDescription.TypeClassItemBinding.GetDefaultTypeOfControl,
        _Item.DialogLabel,_Item.EditWidth,_vname,_Item.BindingDescription.TypeClassItemBinding,
           DocDm.DocVariableList.FindVkVariable(_vname))
      else
        FmEdit.NewControl(_Item.PageName,_Item.BindingDescription.TypeClassItemBinding.GetDefaultTypeOfControl,
        _Item.DialogLabel,_Item.EditWidth,_vname,_Item.BindingDescription.TypeClassItemBinding,
           DocDm.DocVariableList.FindVkVariable(_vname));
      if _Item.BindingDescription is TDocMEditBoxBindingDescription then
      begin
        with TCustomDocFmVkVariableBinding(FmEdit.BindingList.Items[FmEdit.BindingList.Count-1]) do
        begin
          DocMEditBox.Prepare(TDocMEditBoxBindingDescription(_Item.BindingDescription).DocMEditBoxClass, true);
          DocMEditBox.OnInitBeforeSelect :=
            TDocMEditBoxBindingDescription(_Item.BindingDescription).OnInitBeforeSelect;
        end;
      end;
    end;
  end;
  FmEdit.OnActionUpdate := FmEditOnActionUpdate;
  FmEdit.OnValidData := DocDm.ValidFmEditItems;
  _DescriptionList.Initialize(FmEdit.BindingList);
end;


{constructor TFrameDoc.create(Component: TComponent);
begin
  inherited Create(Component);

  FReg := TRegistry.Create;
  FReg.RootKey := HKEY_CURRENT_USER;
  nIndex := 0;

  Fid_view:= 0;
  Init(Component);
  DocDm := TDocDm.Create(self);
//  FrameCreate(self);
  FMarkList := TIntList.Create;
  ValList:= TVarList.Create;
  FBlankList := TStringList.Create;
  FmSelectBlank := TFmSetFilter.Create(self);


  DocDm.SetView(0);
  DataSource1.DataSet := DocDm.pFIBDataSetDoc;
  DataSource1.DataSet.Open;
//  DbGridEhVkDoc.DefineUserFilters := True;
  VarMDoc := TVarList.Create;
end;}

destructor TDocFrame.destroy;
begin

  FrameDestroy(self);
  if Assigned(FActionDescription) then
     FreeAndNil(FActionDescription);

//  if Assigned(FOnFrameDestroy) then
//     (FOnFrameDestroy(self));
  FreeAndNil(VarMDoc);
  FReg.Free;
  inherited;
end;


constructor TDocFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  FReg := TRegistry.Create;
  FReg.RootKey := HKEY_CURRENT_USER;
  FbHaveSod := False;
  nIndex := 0;
  inherited Create(AOwner);
  Name:= AOwner.Name+name;
  FActionDescription    := TActionListDescriptionList.Create;
  FFmEdit := TVkDocDialogFm.Create(self);
  FFmEdit.OnSaveData := onSaveDialog;
  DbGridEhVkDoc.PopupMenu := PopUpMenu1;
  FFmSetUp := TSetUpFormFm.Create(Self);

  Parent := TWinControl(AOwner);
  FMarkList := TList<variant>.Create;
  ValList:= TVkVariableCollection.Create(Self);
  VarMDoc:= TVkVariableCollection.Create(Self);
  ItogMarkedList:= TVkVariableCollection.Create(Self);

  //=======
  Panel1.Caption := '';
  Panel2.Caption := '';
  FDocDm := ADocDm;
  if not Assigned(DocDm) then
  begin
    Raise Exception.Create(' DocDm not Created!');
  end;
  FDocDm.OnDocAfterOpen := DoDocAfterOpen;
  FDocDm.OnDocBeforeClose := DoDocBeforeClose;
  //Fid_reg  :=   DocDm.oIDmMain.oFIBDatabaseHope.QueryValue('SELECT id_reg FROM doclist WHERE id_type=:id_type and id_view=:id_view',0,[Fid_type,Fid_view]);
  Align := alClient;

{*
  FRootkey := FDocDm.DmMain.GetRootKey()+'\'+ClassName;
  *}
  DataSource1.DataSet := DocDm.MemTableEhDoc;
  FDocDm.Open;
  if FDocDm.MemTableEhDoc.Active then
  begin
    ConfigureEdit;
  end;
  FSelected := TVkVariableCollection.Create(self);
end;

procedure TDocFrame.Init(Component: TComponent);
begin
end;

procedure TDocFrame.InitActionManager(aForm: TForm);
var
  ab: TActionBarItem;
  Am: TActionManager;
begin
  if not Assigned(FParentForm) then
    FParentForm := aForm;
  Am := TActionManager.Create(aForm);
  ab := Am.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  ab.AutoSize := false;

  Am.Images := ImageList1;
  ActionToolBar1.ActionManager := Am;

  if Assigned(FOnInitActionManager) then
    FOnInitActionManager(self)
  else
    DefaultActionListInit;
  FActionDescription.InitActionManager(Am, PopUpMenu1, nil);

end;

procedure TDocFrame.InitBeforeSelect(AValue: TVkVariableCollection);
begin

end;

procedure TDocFrame.InitSumList(var VarList:TVkVariableCollection);
var i: Integer;
begin
  for I := 0 to VarList.Count - 1 do
    varList.Value[i] := 0;
  SetSumMarked;
end;

function TDocFrame.IsEqualParams(AParams: TVkVariableCollection): Boolean;
var v: TVkVariable;
    i: Integer;
begin
   Result := True;
   if (Assigned(FCurrentParams) and Assigned(AParams)) then
   begin
     if FCurrentParams.Count <> AParams.count then
     begin
       Result := False;
     end
     else
     begin
       for I := 0 to AParams.Count-1 do
       begin
         v := FCurrentParams.FindVkVariable(AParams.Items[i].Name);
         if not Assigned(v) or (v.Value <> AParams.Items[i].Value) then
         begin
           Result := False;
           exit;
         end;
       end;
     end;
   end
   else
     Result := (not Assigned(FCurrentParams) and not Assigned(AParams))

end;

procedure TDocFrame.Load;
begin

end;

function TDocFrame.Locate(AValue: TVkVariableCollection):Boolean;
begin
  Result := DocDm.LocateDefaultValues(AValue);
end;

procedure TDocFrame.est1Click(Sender: TObject);
begin
  DocDm.SetFilter(-1,self);
end;

procedure TDocFrame.DoMark(bMark: Boolean);
var i:Integer;
    key: Variant;
begin
  if DocDm.MemTableEhDoc.IsEmpty then
    Exit;

  key := DocDm.GetKey;

    if bMark then
    begin
      i:= FMarkList.IndexOf(key);
      if i=-1 then
      begin
        FMarkList.Add(key);
        AddMSum(True);
        if Assigned(OnMark) then
          OnMark(DbGridEhVkDoc);
      end;
    end
    else
    begin
      i:= FMarkList.IndexOf(key);
      if i>=0 then
      begin
        FMarkList.Delete(i);
        AddMSum(False);
        if Assigned(OnUnMark) then
          OnUnMark(DbGridEhVkDoc);
      end
      else
      begin
        FMarkList.Add(key);
        AddMSum(True);
        if Assigned(OnMark) then
          OnMark(DbGridEhVkDoc);
      end;
    end;
    DocDm.MemTableEhDoc.Next;
    DbGridEhVkDoc.Refresh;
end;

procedure TDocFrame.DoMarkAll;
var bm: TBookMark;
begin
  if DocDm.MemTableEhDoc.IsEmpty then
    Exit;
  bm := DocDm.MemTableEhDoc.GetBookmark;
  with DocDm.MemTableEhDoc do
  try
    DisableControls;
    First;
    while not Eof do
      DoMark(True);
  finally
    DocDm.MemTableEhDoc.GotoBookmark(bm);
    DocDm.MemTableEhDoc.FreeBookmark(bm);
    EnableControls;
  end;

end;

procedure TDocFrame.DoOk;
var _var: TVkVariable;
begin
  FSelected.Clear;
  _var := TVkVariable.Create(FSelected);
  _var.Name := 'selected';
  if FMarkList.Count=0 then
  begin
    _var.Value := DocDm.GetKey;
  end
  else
    _var.AsRefObject := FMarkList;
//  FCurrentFrame := self;
//  FSelected.AddVkVariable(_var);
  GetParentForm.ModalResult := mrOk;
end;

{procedure TFrameDoc.DoRefreshFilterOnMonth;
var d1: TDateTime;
begin
  d1 := DocDm.oIDmMain.oIFmCalendar.DataBegin;
  DocDm.oIDmMain.oIFmCalendar.View;
  if d1 = DocDm.oIDmMain.oIFmCalendar.DataBegin then
    Exit;

  SendMessage(Application.MainForm.Handle,WM_CALENDARCHANGED,0,0);

end;}

procedure TDocFrame.DBGridEhVkDocDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
begin
  with TDbGridEh(Sender) do
  begin
    DocMarkDrawDataCell(TDbGridEhVk(Sender),State);
    //DefaultDrawDataCell(Rect,Field,State);
  end;

end;

procedure TDocFrame.DBGridEhVkDocEnter(Sender: TObject);
begin
  if self.Visible then
    CurrentFrame := self;
end;

procedure TDocFrame.DBGridEhVkDocFillSTFilterListValues(Sender: TCustomDBGridEh;
  Column: TColumnEh; Items: TStrings; var Processed: Boolean);
var i: Integer;
begin
  {*if Assigned(DataSource1.DataSet) then
  for i :=0 to DataSource1.DataSet.Fields.Count -1 do
  begin
    if (DataSource1.DataSet.Fields[i].Index = Column.Index) then
      if (not DataSource1.DataSet.Fields[i].FieldName.Equals(Column.FieldName)) then
        Column.FieldName := DataSource1.DataSet.Fields[i].FieldName;
  end;*}
end;

procedure TDocFrame.nMarkClick(Sender: TObject);
begin
  DoMark(False);
end;

procedure TDocFrame.DBGridEhVkDocKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
//     Perform(WM_ENTER,0,0);
    PostMessage(Handle,WM_ENTER,0,0);
{  begin
    if DocDm.MemTableEhDoc = DocDm.pFIBDataSetDoc then
      GoIn;
    Key:=0;
    Exit
  end;}
  if (Key=VK_ESCAPE) and (DocDm.MemTableEhDoc.State <> dsEdit)then
  begin
    Exit;
  end;



  if Assigned(DbGridEhVkDoc.SelectedField) and  not DbGridEhVkDoc.SelectedField.ReadOnly then
  case Key of

    VK_RETURN:
      begin
         if DocDm.MemTableEhDoc.State = dsEdit then
         begin
           //DocDm.BrowseFldEdit.bChange := True;
           //DocDm.BrowseFldEdit.fldname := DbGridEhVkDoc.SelectedField.FieldName;
//           DocDm.MemTableEhDoc.Post;
 //          PostMessage(DbGridEhVkDoc.Handle,WM_KEYDOWN,VK_RETURN,VK_RETURN);
         end;
//         else
//           DocDm.MemTableEhDoc.Edit;
      end;
  end;

end;

procedure TDocFrame.DBGridEhVkDocKeyPress(Sender: TObject; var Key: Char);
begin
  if FInEdit then
    PostMessage(Handle,WM_ENTER,0,0);
{  if (dsEdit = DbGridEhVkDoc.DataSource.DataSet.state ) then
    Exit;
  case Key of
    '*': begin
           DoDocEvent(IDE_DOC_MARK);
           Key := #0;
         end;
    '+':begin
          DoDocEvent(IDE_DOC_MARKALL);
          Key := #0;
        end;
    '-':begin
          DoDocEvent(IDE_DOC_UNMARKALL);
          Key := #0;
        end;
//    else
//      DbGridEhVkDoc.PopUpMenu:=nil;
  end;  }
end;



procedure TDocFrame.DefineActionManager(Am: TActionManager);
var ab: TActionBarItem;
    m_Am: TActionManager;
begin
  m_aM := TActionManager.Create(FParentForm);
  ab := m_Am.ActionBars.Add;
  ab.ActionBar :=  ActionToolBar1;
//  ActionToolBar1.ActionManager := Am;
  m_Am.Images := ImageList1;
  FActionDescription.InitActionManager(m_Am,PopUpMenu,DocExecuteAction);
  if Assigned(FOnDefineActionManager) then
    FOnDefineActionManager(self,m_Am);
{  if GetHaveSod then
    GetFrameSod.DefineActionManager(am);}
end;

procedure TDocFrame.DoUnMarkAll;
begin
  FMarkList.Clear;
  InitSumList(VarMDoc);
  DbGridEhVkDoc.Refresh;
end;


procedure TDocFrame.EditInGrid(fld_name: String);
var
//  bContinue: boolean;
  bMyTransaction: Boolean;
begin
  if DocDm.MemTableEhDoc.FieldByName(fld_name).ReadOnly then
  begin
    if Assigned(FOnEditInGrid) then
    begin
      try
        //FDocDm.LockDoc;
        FDocDm.MemTableEhDoc.Edit;
        FOnEditInGrid(self, fld_name);
        FDocDm.MemTableEhDoc.Post;
      except
        Raise;
      end;
    end;
  end
end;

procedure TDocFrame.nUnmarkAllClick(Sender: TObject);
begin
  DoUnMarkAll;
end;


function TDocFrame.DoBeforeDocDelete: Boolean;
begin
  Result := not DocDm.MemTableEhDoc.IsEmpty;
end;

function TDocFrame.DoBeforeDocEdit: Boolean;
begin
  Result := not DocDm.MemTableEhDoc.IsEmpty;
end;

function TDocFrame.DoBeforeDocInsert: Boolean;
begin
  FDocDm.InitVariables(True);
  Result := True;
end;

procedure TDocFrame.DoBeforeEditInForm;
begin
  if Assigned(FOnBeforeEditInForm) then
    FOnBeforeEditInForm(Self);
end;

procedure TDocFrame.DocCopy;
begin
{  if not ValidAccess(ACCESS_INS) then Exit;
  DocDm.DoInitVarListValues(False);
  if MessageDlg('Копировать текущий документ?',mtConfirmation,mbYesNo,0)<> mrYes then
    Exit;
  bAppend := True;
  StoreVariables;
 }
end;

procedure TDocFrame.DocDelete;
var _Key: Variant;
    bValid: Boolean;
    KeyField: string;
    _msg: String;
begin

  bValid := True;

  if DocDm.MemTableEhDoc.IsEmpty then
    Exit;


  if FMarkList.Count=0 then
  begin
    if Assigned(OnGetDeleteMessage) then
      _msg := OnGetDeleteMessage
    else
      _msg := 'Удалить текущую запись?';
    if MessageDlg(_msg,mtConfirmation,[mbYes,mbNo],0)<> mrYes then
       Exit;
    _Key :=  DocDm.GetKey;
    FMarkList.Add(_Key);
  end
  else
     if MessageDlg('Удалить помеченные записи?',mtConfirmation,[mbYes,mbNo],0)<> mrYes then
        Exit;
  while (FMarkList.Count)>0 do
  begin
    _Key := FMarkList[0];
    if DocDm.MemTableEhDoc.Locate(DocDm.SqlManager.KeyFields,_Key,[]) then
    try
      //DocDm.LockDoc;
      DocDm.MemTableEhDoc.Delete;
      //DocDm.UnLockDoc;
      if DocDm.MemTableEhDoc.Eof then
        DocDm.MemTableEhDoc.Last;
      FMarkList.Delete(0);
    except
      //DocDm.UnLockDoc(False);
      Raise;
    end;
  end;
  DocDm.FullRefreshDoc(True);
end;


procedure TDocFrame.OnAfterOpenDataSetDoc(Sender: TObject);
begin
  if DbGridEhVkDoc.DataSource.dataSet = DocDm.MemTableEhDoc then
end;


procedure TDocFrame.OnAfterPostDataSetDoc(DataSet: TDataSet);
begin
  DbGridEhVkDoc.PopupMenu := PopUpMenu;
end;

procedure TDocFrame.OnBeforeCloseDataSetDoc(Sender: TObject);
begin
//  DbGridEhVkDoc.ReadDbGridColumnsSize(GetCurrentDbGridColumnsParamListOfDoc);//,FListDbGridColumnsParams1);
end;

procedure TDocFrame.OnBeforeCloseDataSetSod(Sender: TObject);
begin
//  DbGridEhVkDoc.ReadDbGridColumnsSize(GetCurrentDbGridColumnsParamListOfDoc);//,FListDbGridColumnsParams1);
end;

procedure TDocFrame.OnBeforeEditDataSetDoc(DataSet: TDataSet);
begin
  DbGridEhVkDoc.PopupMenu := nil;
end;

procedure TDocFrame.OnChangeEditItem(Sender: TObject);
begin

end;

procedure TDocFrame.OnCloseQueryFmEdit(Sender: TObject; var CanClose: Boolean);
begin

end;

procedure TDocFrame.OnFilteredSetCaption(Sender: TObject);
begin
  TForm(Parent).Caption := FCaption;
  StatusBar1.Panels[0].Text :=    ' '+DocDm.GetFilterCaption;
end;

function TDocFrame.onSaveDialog(Sender: TObject): Boolean;
begin
  try
    if _bDocInsert or DocDm.DocVariableList.IsChanged then
      DocDm.WriteVariables(_bDocInsert or _bDocClone);
    Result := true;
  except
     on e:Exception  do
     begin
       ShowMessage(e.message);
       Result := false;
     end;
  end;

end;

procedure TDocFrame.DbGridEhVkDocAfterApplayUserFilter(Sender: TObject);
begin
//  Inherited;
  DoUnmarkAll;
end;

procedure TDocFrame.DBGridEhVkDocDblClick(Sender: TObject);
begin
  Inherited;
  if not IsSelect and not  DbGridEhVkDoc.DataSource.DataSet.IsEmpty then
    PostMessage(DbGridEhVkDoc.Handle,WM_KEYDOWN,VK_RETURN,VK_RETURN)
  else
  begin
    if IsSelect then
      DoOk;
  end;
end;



procedure TDocFrame.SetCaption;
begin
  if Not Assigned(Parent) or Not Assigned(DocDm) then
    Exit;
//  TForm(Parent).Caption := FCaption;
//  StatusBar1.Panels[0].Text :=    ' '+DocDm.GetFilterCaption;
  if Assigned(FOnSetCaption) then
    FOnSetCaption(Self)
end;

procedure TDocFrame.SetCurrentFrame(const Value: TDocFrame);
begin
  TCustomDocFm(GetParentForm).CurrentFrame := Value;
end;

{procedure TFrameDoc.SetDbGridColumnsSize(aDbGrid: TDbGridEhVk;
  List: TListDbGridColumnsParams);
var i: Integer;
begin
  if not List.bInit then
    Exit;
  if not Assigned(aDbGrid.DataSource) then
    Exit;
  if not Assigned(aDbGrid.DataSource.DataSet) then
    Exit;
  if not aDbGrid.DataSource.DataSet.Active then
    Exit;

  for I := 0 to List.Count - 1 do
  begin
    if Assigned(aDbGrid.DataSource.DataSet.FindField(List.Items[i].name)) then
    with aDbGrid.DataSource.DataSet.FieldByName(List.Items[i].name) do
    begin
      Index := List.Items[i].id;
      DisplayWidth := List.Items[i].width;
    end;
  end;
end;
 }
procedure TDocFrame.SetFilter(aId_doc: Integer);
begin
  DocDm.SetFilter(aId_Doc,Self);
end;

procedure TDocFrame.SetFocusToGrid;
begin
  DbGridEhVkDoc.SetFocus;
  TForm(Parent).ActiveControl := DbGridEhVkDoc;
end;


procedure TDocFrame.SetIsSelect(const Value: Boolean);
begin
  FIsSelect := Value;

end;

procedure TDocFrame.SetOnBeforeEditInForm(const Value: TNotifyEvent);
begin
  FOnBeforeEditInForm := Value;
end;

procedure TDocFrame.SetOnDeleteGetMessage(const Value: TFuncGetMessage);
begin
  FOnDeleteGetMessage := Value;
end;

procedure TDocFrame.SetOnEditAction(const Value: TProcOnActionEvent);
begin
  FOnEditAction := Value;
end;

procedure TDocFrame.SetOnGetDeleteMessage(const Value: TFuncGetMessage);
begin
  FOnGetDeleteMessage := Value;
end;

class procedure TDocFrame.SetOnShowDocument(const AOnShowDocument: TOnShowDocument);
begin
  onShowDocument := AOnShowDocument;
end;

procedure TDocFrame.PopupMenuPopup(Sender: TObject);
begin
  //nNormal.Enabled := not DocDm.bSod;
end;

procedure TDocFrame.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  SetCaption;
end;

procedure TDocFrame.DataSource1StateChange(Sender: TObject);
var ds:TDataSource;
begin
  ds:= TDataSource(Sender);
  if ds.State = dsEdit then
  begin
    DbGridEhVkDoc.PopupMenu := nil;
//    if DocDm.MemTableEhDoc.State = dsEdit then
    FInEdit := True;
  end
  else
    if not Assigned(DbGridEhVkDoc.PopupMenu) then
    DbGridEhVkDoc.PopupMenu := PopUpMenu;
end;


procedure TDocFrame.SetParentForm(aForm: TForm);
begin
  FParentForm := aForm;
end;

procedure TDocFrame.SetPrepare(const Value: Boolean);
begin
  FPrepared := Value;
end;

procedure TDocFrame.SetSumMarked;
var
  i, k: Integer;
begin

  if DataSource1.DataSet.Active then
  begin
    for i := 0 to Pred(DBGridEhVkDoc.Columns.Count) do
      with DBGridEhVkDoc.Columns[i] do
      begin
        k := ItogMarkedList.IndexOf(LowerCase(FieldName));
        if k > -1 then
        begin
          if DBGridEhVkDoc.FooterRowCount=0 then
          begin
            DBGridEhVkDoc.FooterRowCount := 1;
            DBGridEhVkDoc.FooterColor := clBtnFace;
          end;
          Footer.ValueType := fvtStaticText;
          Footer.Value := FloatToStrF(ItogMarkedList.Value[k], ffNumber, 16, 2);
        end;
      end;
  end;
end;

function TDocFrame.StoreVariables: Boolean;
begin

end;


procedure TDocFrame.RecalcInternalSize;
var
    h: Integer;
begin
end;

procedure TDocFrame.DBGridEhVkDocGetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
var DbGrid: TDbGridEhVk;
begin

  inherited;
  DbGrid := TDbGridEhVk(Sender);
  if not Assigned(DbGrid.DataSource) or not Assigned(DbGrid.DataSource.DataSet) then
    Exit;
  if (gdSelected in State) and (gdFocused in State) then
  begin
     State := State + [gdFixed];
  end
end;

{procedure TFrameDoc.DocEdit(bNew: boolean);
var KeyField:String;
begin
  if not bNew and DocDm.MemTableEhDoc.IsEmpty then
    Exit;

  KeyField := DocDm.SqlManager.KeyFields;

  if bNew then
  begin
    FmEdit.Caption := 'Добавление';
    with FmEdit.BindingList do
    begin
        //DocDm.DoInit;
    end;
  end
  else
  begin
    DocDm.LockDoc;
    FmEdit.Caption := 'Коррекция';
    //DocDm.DoInitVarListValues(False);
    //FmEdit.Items.SynchroWithVarList(DocDm.VarList,'');
  end;
  FmEdit.OnCloseQuery := OnCloseQueryFmEdit;
  FmEdit.ShowModal;
end; }

procedure TDocFrame.DocEdit(AStatus: TDocEditStatus; const AFieldName: String = '');
var
//  bValid: boolean;
  p: PDocStruDescriptionItem;
  EditFieldName: String;
  _FmEdit: TForm;
  bExternal: Boolean;
  _IsMyTransaction: Boolean;
  _pBinding: TVkVariableBinding;
begin

  if Assigned(FExternalFmEdit) then
  begin
    bExternal  := True;
    _FmEdit := FExternalFmEdit;
  end
  else
  begin
    _FmEdit := FFmEdit;
    // Если не настроена форма редактирования то ничего не делаем.
    if FFmEdit.BindingList.Count=0 then
      Exit;
  end;

  _bDocInsert := (AStatus = desInsertDialog);
  _bDocClone  := (AStatus = desCloneDialog);

  try
    if not _bDocInsert and not _bDocClone then
    begin
      //DocDm.LockDoc(True);
      DocDm.ReinitVariables;
        // Проверка - Before Edit
      if not DoBeforeDocEdit then
      begin
        //DocDm.UnLockDoc(True);
        Exit;
      end;
//    DocDm.InitVariables(_bDocInsert);
      _FmEdit.Caption := 'Редактирование';
    end
    else
    begin
      // Проверка - Before Insert
      if not DoBeforeDocInsert then
        Exit;
//      DocDm.InitVariables(_bDocInsert);
      _FmEdit.Caption := 'Ввод нового';
    end;

    DocDm.InitVariables(_bDocInsert);

    if AStatus <> desEditInBrowse then
    begin
      DoBeforeEditInForm;
      _FmEdit.PopupMode := pmAuto;
      _FmEdit.PopupParent := Screen.ActiveForm;
      if _FmEdit.ShowModal = mrOk then
      begin
        //if not _bDocInsert and not _bDocClone then
        //begin
          //DocDm.LockDoc;
        //end;
        FActionSuccess := True;
      end;
    end
    else
    begin
      // Edit In Grid;
      p := DocDm.DocStruDescriptionList.GetDocStruDescriptionItem(AFieldName);
      if Assigned(p) then
      begin
        if length(p.name_owner) > 0 then
          EditFieldName := p.name_owner
        else
          EditFieldName := p.name;
        _pBinding :=  FmEdit.BindingList.FindVkVariableBinding(EditFieldName);
        if Assigned(_pBinding) then
        begin
          DocDm.DocStruDescriptionList.Initialize(_pBinding);
          if _pBinding.oControl is TMEditBox then
          begin
            TMEditBox(_pBinding.oControl).OnButtonClick(TMEditBox(_pBinding.oControl));
            if DocDm.DocVariableList.IsChanged then
            begin
              //DocDm.LockDoc(True);
              DocDm.WriteVariables(_bDocInsert);
            end;
          end;
        end
        else
        begin
          EditInGrid(p.name);
        end;
      end;
    end;
    //if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
    //  FDmMikkoads.AdsConnection1.Commit;
    //DocDm.UnLockDoc(True);
    DocDm.FullRefreshDoc;
  except
      //if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
      //  FDmMikkoads.AdsConnection1.Rollback;
    //DocDm.UnLockDoc(False);
    DocDm.FullRefreshDoc;
    FActionSuccess := False;
    Raise;
  end
{  finally
    if FDmMikkoads.AdsConnection1.TransactionActive and mIsMyTransaction then
      FDmMikkoads.AdsConnection1.Rollback;

  end;;
  FullRefresh(null);}

end;

procedure TDocFrame.DocExecuteAction(Sender: TObject);
var mAction: TAction;
begin

  mAction := TAction(Sender);
  DoDocEvent(mAction.Tag)

end;

procedure TDocFrame.DocMarkDrawDataCell(Sender: TDbGridEhVk; State: TGridDrawState);
var i: Integer;
    Key: Variant;
begin
  with Sender do
  begin
    if DocDm.MemTableEhDoc.IsEmpty then
      Exit;
    Key := DocDm.GetKey;
    i:= FMarkList.IndexOf(Key);
    if i>-1 then
    begin
      if (gdSelected in State) and (gdFocused in State)
      then begin
        Canvas.Font.Color := clYellow;
        Canvas.Pen.Color := clGrayText;
      end else Canvas.Font.Color := clBlue;
    end;
  end;
end;

procedure TDocFrame.DocSetFilter;
begin
  DocDm.SetFilter(-1,self);
//  DocDm.SetFilterComment(StatusBar1);
//  DbGridEhVkDoc.ClearUserFliterImages;
  DoUnmarkAll;
end;

procedure TDocFrame.DefaultActionListInit;
begin
  with FActionDescription do
  begin
    Items.Clear;
    AddDescription('doc1',aDocInsert,'BITMAP_INSERT');
    AddDescription('doc1',aDocEdit,'BITMAP_EDIT');
    AddDescription('doc1',aDocDelete,'BITMAP_DELETE');
    AddDescription('doc1',aDocClone,'BITMAP_COPY');
    AddDescription('doc2',nil,'EMPTY');
    AddDescription('doc2',aDocFind,'BITMAP_FIND');
    AddDescription('doc2',aDocContinueFind,'BITMAP_FINDNEXT');
    AddDescription('doc2',nil,'EMPTY');
    AddDescription('doc3',aDocRefresh,'BITMAP_REFRESH');
    AddDescription('doc3',nil,'EMPTY',tdPopUpOnly);
    AddDescription('doc4',aDocMark,'',tdPopUpOnly);
    AddDescription('doc4',aDocMarkAll,'',tdPopUpOnly);
    AddDescription('doc4',aDocUnMarkAll,'',tdPopUpOnly);
    AddDescription('doc5',nil,'EMPTY',tdPopUpOnly);
    AddDescription('doc5',aDocToExcel,'',tdPopUpOnly);
  end;
end;

{procedure TFrameDoc.DefaultActionListInitSod;
begin
  with FActionDescription do
  begin
    Items.Clear;
    AddDescription('doc1',IDE_DOC_ADD,'BITMAP_INSERT','+Добавить','Ins');
    AddDescription('doc1',IDE_DOC_EDIT,'BITMAP_EDIT','Редактировать','F4');
    AddDescription('doc1',IDE_DOC_DELETE,'BITMAP_DELETE','Удалить','Del');
    AddDescription('doc1',IDE_DOC_COPY,'BITMAP_COPY','Копировать','F5');
    AddDescription('doc2','SEPARATOR','EMPTY','','');
    AddDescription('doc2',IDE_DOC_FIND,'BITMAP_FIND','Поиск','F7');
    AddDescription('doc2',IDE_DOC_FINDNEXT,'BITMAP_FINDNEXT','Продолжение поиска','Shift+F7');
    AddDescription('doc2','SEPARATOR','EMPTY','','');
    AddDescription('doc3',IDE_DOC_REFRESH,'BITMAP_REFRESH','Обновить экран','Alt+R');
    AddDescription('doc3',IDE_DOC_GOOUT,'BITMAP_GOOUT','Вернуться в список документов','');
    AddDescription('doc3','SEPARATOR','EMPTY','','',tdPopUpOnly);
    AddDescription('doc4',IDE_DOC_MARK,'','Пометить/Снять пометку ','CTRL+M',tdPopUpOnly);
    AddDescription('doc4',IDE_DOC_MARKALL,'','Пометить все ','CTRL+A',tdPopUpOnly);
    AddDescription('doc4',IDE_DOC_UNMARKALL,'','Отменить всю пометку ','CTRL+U',tdPopUpOnly);
    AddDescription('doc5','SEPARATOR','EMPTY','','',tdPopUpOnly);
    AddDescription('doc5',IDE_DOC_NORMAL,'','Нормализация','Shift+F12',tdPopUpOnly);
    AddDescription('doc5',IDE_DOC_CLEARINI,'','Очистить сохранения','CTRL+R',tdPopUpOnly);
    AddDescription('doc5',IDE_DOC_TOEXCEL,'','Экспорт в '+'Excel','Alt+P',tdPopUpOnly);
  end;

end; }

procedure TDocFrame.DefaultDocEvent(aId: Integer);
begin
  {case aId of
    IDE_DOC_ADD:       DocEdit(True);
    IDE_DOC_EDIT:      DocEdit(False);
    IDE_DOC_DELETE:    DocDelete;
    IDE_DOC_COPY:      DocCopy;
    IDE_DOC_FIND:      DbGridEhVkDoc.Find(False);
    IDE_DOC_FINDNEXT:  DbGridEhVkDoc.Find(True);
    IDE_DOC_MARK:      DoMark(False);
    IDE_DOC_MARKALL:   DoMarkAll;
    IDE_DOC_UNMARKALL: DoUnMarkAll;
    IDE_DOC_SETFILTER: DocSetFilter;
    IDE_DOC_REFRESH:   DocDm.FullRefreshDoc;
    IDE_DOC_CLEARINI:  ClearIni;
    IDE_DOC_TOEXCEL:   DbGridEhVkDoc.OnAltP(DbGridEhVkDoc);
  end; }
end;

procedure TDocFrame.DoDocBeforeClose(DataSet: TDataSet);
begin
  FFmSetUp.SaveChanges;
  inherited;
end;

procedure TDocFrame.DoDocAfterOpen(DataSet: TDataSet);
var i: Integer;
    PField: PDocStruDescriptionItem;
begin
    with DBGridEhVkDoc do
    begin
      for i := 0 to Columns.Count - 1 do
        Columns[i].OnGetCellParams := FrameDocColumnsGetCellParams;
    end;
//    if not DocDm.Prepared then
    begin
      //--------- Exclude from visible -----------
      for i:=0 to DocDm.DocStruDescriptionList.Count-1 do
      begin
        PField := DocDm.DocStruDescriptionList.GetDocStruDescriptionItem(i);
        if PField.bNotInGrid then
          FFmSetUp.ExcludeFromVisible.Add(PField.name)
        else
          DBGridEhVkDoc.DataSource.DataSet.FieldByName(PField.name).Visible := True;
      end;
      FFmSetUp.Prepare(DBGridEhVkDoc.DataSource.DataSet,DocDm.DmMain.XmlInit.GetXmlIni(getSetUpKeyName(),true) ,DbGridEhVkDoc.Name);

//      DocDm.Prepared := true;
    end;
    //else
    // To DO
      //for i := 0 to DBGridEhVkDoc.DataSource.DataSet.FieldCount - 1 do
        //DBGridEhVkDoc.DataSource.DataSet.Fields[i].Visible := False;

   FFmSetUp.SetUpDataSet(DBGridEhVkDoc.DataSource.DataSet);
   DBGridEhVkDoc.STFilter.Visible := true;
end;

procedure TDocFrame.DoDocEvent(aId: Integer);
begin
  if Assigned(FOnDocEvent) then
    FOnDocEvent(Self,aId)
  else
    DefaultDocEvent(aId);
end;

function TDocFrame.ValidAccess(aIdAccess:LargeInt): boolean;
var iAccess: Integer;
begin
end;

function TDocFrame.ValidDataFmEdit(Sender: TObject): Boolean;
begin
    Result := True;
end;

class procedure TDocFrame.ViewFrame(const className:String; AParams:TVkVariableCollection);
begin
  if Assigned(onShowDocument) then
    onShowDocument(className, AParams)
end;

procedure TDocFrame.WmCalendarChanged(var aMes: TMessage);
begin
end;

procedure TDocFrame.DoEnterMs(var Msg: TMessage);
var s: String;
begin
  if IsSelect then
  begin
    DoOk;
    Exit;
  end;
  if not DBGridEhVkDoc.SelectedField.ReadOnly then
  try
    if FinEdit and not DocDm.DoBeforeDocEdit then
    begin
      DocDm.MemTableEhDoc.Cancel;
      Exit;
    end;
    if (DocDm.MemTableEhDoc.State = dsEdit) and (not FInEdit) then
    begin
      s := DBGridEhVkDoc.SelectedField.FieldName;
      DocDm.DoAfterEditMemTableEhDoc(DocDm.MemTableEhDoc,s);
      DocDm.MemTableEhDoc.Post;
      DocDm.FullRefreshDoc(True);
    end;
  finally
    if FinEdit  then
      FinEdit := False;
  end
  else
  begin
    s := DBGridEhVkDoc.SelectedField.FieldName;
    try
      DocEdit(desEditInBrowse,s);
    finally
      FinEdit := False;
    end;
  end;
end;

initialization
  RegisterClass(TDocFrame);

end.
