unit frameobjectsgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fib.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ImgList, Data.DB, GridsEh, DBAxisGridsEh, DBGridEh,
  DBGridEhVk, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, fib.dmdoc,dmobjects,
  frameObjectsItems, Vcl.StdCtrls, VkVariable, VariantUtils, fib.fmcustomdoc,
  System.ImageList, EhLibVCL;

type
  TObjectsGrFrame = class(TDocFrame)
    aDocSubInsert: TAction;
    TreeImages: TImageList;
    aGroupAttributes: TAction;
    procedure aDocSubInsertExecute(Sender: TObject);
    procedure DocActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure aDocEditExecute(Sender: TObject);
    procedure aDocCloneExecute(Sender: TObject);
    procedure aGroupAttributesExecute(Sender: TObject);
    procedure aDocRefreshExecute(Sender: TObject);
    procedure aDocInsertExecute(Sender: TObject);
  private
    { Private declarations }
    FCurrentKodg: LargeInt;
    FObjectsDm: TObjectsDm;
    FObjectsItemsFr: TObjectsItemsFrame;
    FCurrentIdGroup: LargeInt;
    FRootIdGroup: LargeInt;
    FTypeGroup: LargeInt;
    function GetDeleteMessage:String;
    function GetDmObjectsType: TTypeDmObjects;
    procedure SetDmObjectsType(const Value: TTypeDmObjects);
    procedure DBGridEh2Columns0GetCellParams(Sender: TObject;
      EditMode: Boolean; Params: TColCellParamsEh);
    procedure SetObjectsItemsVisible(AVisible: Boolean);
    procedure SetRootIdGroup(const Value: LargeInt);
    procedure SetCurrentIdGroup(const Value: LargeInt);
    procedure ViewGroupAttributes;
  protected
    procedure DoDocAfterOpen(DataSet: TDataSet);override;
    procedure DoInitActionManager(Sender: TObject);
    procedure DoWriteVariables(Sender: TObject; AInsert: Boolean);
    function GetSelected: TVkVariableCollection;override;
    procedure SetIsSelect(const Value: Boolean);override;
  public
    { Public declarations }
    constructor Create(AOwner:TComponent; ADocDm:TDocDm); override;
    function Locate(AValue: TVkVariableCollection):Boolean;override;
    class function GetDmDoc:TDocDm;override;
    property DmObjectsType : TTypeDmObjects read GetDmObjectsType write SetDmObjectsType;
    function GetCaption: String; override;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
    property RootIdGroup: LargeInt read FRootIdGroup write SetRootIdGroup;
    property CurrentIdGroup: LargeInt read FCurrentIdGroup write SetCurrentIdGroup;
  end;

  TFrameGOAU = class(TObjectsGrFrame)
  public
    constructor Create(AOwner:TComponent; ADocDm:TDocDm); override;
  end;

  TFrameGOKU = class(TObjectsGrFrame)
  public
    constructor Create(AOwner:TComponent; ADocDm:TDocDm); override;
  end;

var
  ObjectsGrFrame: TObjectsGrFrame;

implementation

{$R *.dfm}
uses systemconsts, fib.DmMain, ActionManagerDescription;

{ TFrameObjectsGr }

procedure TObjectsGrFrame.aDocCloneExecute(Sender: TObject);
begin
  FCurrentKodg := FObjectsDm.MemTableEhDoc.FieldByName('IDGROUP').AsLargeInt;
  FObjectsDm.BranchedNode := nil;
  inherited;
end;

procedure TObjectsGrFrame.aDocEditExecute(Sender: TObject);
begin
  FObjectsDm.BranchedNode := nil;
  inherited;
end;

procedure TObjectsGrFrame.aDocInsertExecute(Sender: TObject);
begin
  FCurrentKodg := FObjectsDm.MemTableEhDoc.FieldByname('IDGROUP').AsLargeInt;
  inherited;
end;

procedure TObjectsGrFrame.aDocRefreshExecute(Sender: TObject);
var _IdGroup: Integer;
begin
  inherited;
  _IdGroup := FCurrentIdGroup;
  FCurrentIdGroup := 0;
  CurrentIdGroup := _IdGroup;
end;

procedure TObjectsGrFrame.aDocSubInsertExecute(Sender: TObject);
begin
//  inherited;
  if MessageDlg(Format('Разветвить группу %s',[FObjectsDm.MemTableEhDoc.FieldByName('name').AsString]),
    mtConfirmation,mbYesNo,0)<> mrYes then
  Exit;

  FCurrentKodg := FObjectsDm.MemTableEhDoc.FieldByname('IDOBJECT').AsLargeInt;
  FObjectsDm.BranchedNode := FObjectsDm.MemTableEhDoc.RecView;
  inherited aDocInsertExecute(Sender);
end;

procedure TObjectsGrFrame.aGroupAttributesExecute(Sender: TObject);
begin
  inherited;
  ViewGroupAttributes;
end;

constructor TObjectsGrFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  FTypeGroup := 0;
  OnInitActionManager := DoInitActionManager;
  OnGetDeleteMessage := GetDeleteMessage;
  FObjectsItemsFr := TObjectsItemsFrame.GetObjectsItemsFrame(Self);
  FObjectsItemsFr.Parent := Panel2;
  FObjectsItemsFr.Align := alClient;
  FCurrentIdGroup := -1;
end;

procedure TObjectsGrFrame.DBGridEh2Columns0GetCellParams(Sender: TObject; EditMode: Boolean;
  Params: TColCellParamsEh);
begin
  if (gdSelected in Params.State) or (gdFocused in Params.State)  then
    Params.ImageIndex := 1
  else
    Params.ImageIndex := 0;
end;

procedure TObjectsGrFrame.DocActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  inherited;
  if Assigned(FObjectsDm) then
  begin
    aDocDelete.Enabled := not FObjectsDm.MemTableEhDoc.IsEmpty and
      (FObjectsDm.MemTableEhDoc.FieldByName('IDGROUP').AsLargeInt>0) and
      (FObjectsDm.MemTableEhDoc.TreeNodeChildCount = 0);
    aDocEdit.Enabled := not FObjectsDm.MemTableEhDoc.IsEmpty and
      (FObjectsDm.MemTableEhDoc.FieldByName('IDGROUP').AsLargeInt>0);
    aDocInsert.Enabled := FObjectsDm.MemTableEhDoc.FieldByName('IDGROUP').AsLargeInt>0;
    aDocClone.Enabled := FObjectsDm.MemTableEhDoc.FieldByName('IDGROUP').AsLargeInt>0;
    if FObjectsDm.MemTableEhDoc.Active then
    begin
      if CurrentIdGroup<> FObjectsDm.MemTableEhDoc.FieldByname('idobject').AsLargeInt then
      begin
         CurrentIdGroup := FObjectsDm.MemTableEhDoc.FieldByname('idobject').AsLargeInt;
        //  SetObjectsItemsVisible( not FObjectsDm.MemTableEhDoc.RecView.NodeHasChildren);
      end;
    end;
  end;
end;

procedure TObjectsGrFrame.DoDocAfterOpen(DataSet: TDataSet);
begin
  inherited;
  if DbGridEhVkDoc.Columns.Count>0 then
  begin
    DbGridEhVkDoc.Columns[0].ImageList := TreeImages;
    DbGridEhVkDoc.Columns[0].OnGetCellParams :=  DBGridEh2Columns0GetCellParams;
    DbGridEhVkDoc.Columns[0].ShowImageAndText := true;
  end;
  if IsSelect then
  begin
    panel1.Visible := (DocDm.MemTableEhDoc.RecordCount>1) or FObjectsDm.MemTableEhDoc.RecView.NodeHasChildren;
    Splitter1.Visible := false;
    GetParentForm.Caption :=  DocDm.MemTableEhDoc.FieldByName('name').AsString;
  end;
  if (not panel1.Visible) then
      CurrentFrame := FObjectsItemsFr;
end;

procedure TObjectsGrFrame.DoInitActionManager(Sender: TObject);
var i: Integer;
begin
  DefaultActionListInit;
  i := FActionDescription.IndexOf(aDocInsert);
  FActionDescription.InsertDescription(i+1,'DOC',aDocSubInsert,'Bitmap_subins');
  FActionDescription.AddDescription('GROUPPROPERTY',aGroupAttributes,'',tdPopUpOnly);
{  if Assigned(FObjectsItemsFr) then
    if Assigned(FObjectsItemsFr.OnInitActionManager) then
      FObjectsItemsFr.OnInitActionManager(FObjectsItemsFr);
 }
//  i:= FActionDescription.IndexOf(aDocClone);
end;

procedure TObjectsGrFrame.DoWriteVariables(Sender: TObject; AInsert: Boolean);
begin
  if AInsert then
  begin
    if FCurrentKodg=0 then
      raise Exception.Create('Current kodg = 0');
    FObjectsDm.DocVariableList.VarByName('idgroup').AsLargeInt :=  FCurrentKodg;
    FObjectsDm.DocVariableList.VarByName('idobject').AsLargeInt :=  FObjectsDm.DmMain.GenId('IDOBJECT');
    FObjectsDm.DocVariableList.VarByName('isgroup').AsBoolean :=  True;
  end;
end;

function TObjectsGrFrame.GetCaption: String;
begin
  Result := 'Объекты аналитического учета';
  Result := 'Объекты количественного учета';

end;

function TObjectsGrFrame.GetDeleteMessage: String;
begin
  Result := Format('Удалить группу %s ?',[FObjectsDm.MemTableEhDoc.FieldByName('name').AsString])
end;

class function TObjectsGrFrame.GetDmDoc: TDocDm;
begin
  Result := TObjectsDm.GetDm;
end;

function TObjectsGrFrame.GetDmObjectsType: TTypeDmObjects;
begin
  Result := FObjectsDm.ObjectsTypeDm;
end;

function TObjectsGrFrame.GetSelected: TVkVariableCollection;
begin
  if FObjectsItemsFr.Selected.Count>0 then
    Result := FObjectsItemsFr.Selected
  else
    Result := inherited;
end;

class function TObjectsGrFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  if Avar.Count>1 then
    inherited
  else
  begin
    if Avar.Count=1 then
      Result := IfVarEmpty(MainDm.QueryValue(
        'SELECT name FROM objects WHERE idobject=:idobject',[Avar.Items[0].AsLargeInt]),'')
    else
      Result := 'not defined';
  end;
end;

function TObjectsGrFrame.Locate(AValue: TVkVariableCollection):Boolean;
var v: TVkVariableCollection;
    _nv: TVkVariableCollection;
begin
  Result := false;
  if (AValue.Count>0) and not AValue.Items[0].IsNull then
  begin
    v := TVkVariableCollection.Create(Self);
    try
      MainDm.QueryValues(v,'SELECT idgroup, isgroup FROM objects WHERE idobject=:idobject',
        [AValue.Items[0].AsLargeInt]);
      if v.Count>0 then
      begin
        if v.VarByName('isgroup').AsBoolean then
        begin
          Result := DocDm.LocateDefaultValues(Avalue);
          if Panel1.Visible then
            CurrentFrame := Self
          else
            CurrentFrame := FObjectsItemsFr;
        end
        else
        begin
          _nv := TVkVariableCollection.Create(self);
          try
            _nv.CreateVkVariable('idobject0',v.VarByName('idgroup').AsLargeInt);
            if DocDm.LocateDefaultValues(_nv) then
            begin
              CurrentIdGroup := FObjectsDm.MemTableEhDoc.FieldByname('idobject').AsLargeInt;
              if FObjectsItemsFr.Locate(AValue) then
              begin
                Result := true;
                if FObjectsItemsFr.DocDm.MemTableEhDoc.Active then
                  CurrentFrame := FObjectsItemsFr;
              end;
            end
            else
            begin
              if Panel1.Visible then
              begin
                CurrentIdGroup := FObjectsDm.MemTableEhDoc.FieldByname('idobject').AsLargeInt;
                CurrentFrame := self;
              end
              else
                CurrentFrame := FObjectsItemsFr;
            end;
          finally
            _nv.Free;
          end;
        end;
      end;
    finally
      v.Free;
    end;
  end
  else
  begin
    if Panel1.Visible then
      CurrentFrame := Self
    else
      CurrentFrame := FObjectsItemsFr;
  end;
end;

procedure TObjectsGrFrame.SetCurrentIdGroup(const Value: LargeInt);
begin
  if CurrentIdGroup<> Value then
  begin
    FCurrentIdGroup := FObjectsDm.MemTableEhDoc.FieldByname('idobject').AsLargeInt;
    SetObjectsItemsVisible( not FObjectsDm.MemTableEhDoc.RecView.NodeHasChildren);
  end;
end;

procedure TObjectsGrFrame.SetDmObjectsType(const Value: TTypeDmObjects);
begin
  FObjectsDm := TObjectsDm(DocDm);
  FObjectsDm.ObjectsTypeDm := Value;
  FObjectsDm.OnWriteVariables := DoWriteVariables;
end;

procedure TObjectsGrFrame.SetIsSelect(const Value: Boolean);
begin
  inherited;
  FObjectsItemsFr.IsSelect := Value;
end;

procedure TObjectsGrFrame.SetObjectsItemsVisible(AVisible: Boolean);
begin
  Panel2.Visible := AVisible;
  Splitter1.Visible := AVisible;
  if Panel2.Visible then
  begin
    if FObjectsItemsFr.IdGroup <> CurrentIdGroup then
      FObjectsItemsFr.IdGroup := CurrentIdGroup;
  end;
  if not Panel2.Visible then
    Panel1.Visible := True;
end;

procedure TObjectsGrFrame.SetRootIdGroup(const Value: LargeInt);
begin
  FRootIdGroup := Value;
  DmObjectsType := tdmoGroups;
  FTypeGroup := MainDm.getTypeGroup(FRootIdGroup);
  if not Prepare then
  begin
    FObjectsDm.Open(Value);
    ConfigureEdit;
    GetParentForm.Caption := ifVarEmpty(MainDm.QueryValue('SELECT name FROM objects WHERE idobject=:idobject',
     [FRootIdGroup]),'');
  end;
end;

procedure TObjectsGrFrame.ViewGroupAttributes;
var _IdGroup: TVkVariable;
begin
  _IdGroup := TVkVariable.Create(nil);
  _IdGroup.AsLargeInt := FObjectsDm.MemTableEhDoc.FieldByName('idobject').AsLargeInt;
  try
    TCustomDocFm.ViewDoc('TAttributesOfGroupFrame',_IdGroup);
  finally
    _IdGroup.Free;
  end;
end;

{ TFrameGOAU }

constructor TFrameGOAU.Create(AOwner: TComponent; ADocDm:TDocDm);
begin
  inherited;
  SetRootIdGroup(IDGROUP_OAU);
end;


{ TFrameGOKU }

constructor TFrameGOKU.Create(AOwner: TComponent; ADocDm: TDocDm);
begin
  inherited;
  SetRootIdGroup(IDGROUP_OKU);
  FullRefresh;
end;

initialization
  RegisterClass(TObjectsGrFrame);
  RegisterClass(TFrameGOAU);
  RegisterClass(TFrameGOKU);
end.
