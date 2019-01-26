unit frameMenuStru;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fdac.framedoc, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, ActnList, Menus,
  ImgList, DB, GridsEh, DBAxisGridsEh, DBGridEh, DBGridEhVk, ToolWin, ActnMan, ActnCtrls, ExtCtrls, ComCtrls,
  fdac.dmdoc, fdac.dmmain, dmMenuStru, VkVariableBinding, System.Actions, VkVariable, VariantUtils,
  System.ImageList, EhLibVCL, VirtualTrees;

type

  PTreeData = ^RTreeData;
  RTreedata = Record
    namemenu: String;
    id_menu:  Integer;
    id_item:  Integer;
    id_level: Integer;
    mi_id:    Integer;
    num_level: smallint;
    node: PVirtualNode;
  end;

  TMenuStruFrame = class(TDocFrame)
    PanelMenuTree: TPanel;
    PanelMenuFooter: TPanel;
    vstMenu: TVirtualStringTree;
    aDocSubInsert: TAction;
    procedure Panel1Enter(Sender: TObject);
    procedure vstMenuInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var ChildCount: Cardinal);
    procedure vstMenuInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstMenuGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstMenuChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure aDocInsertExecute(Sender: TObject);
    procedure aDocSubInsertExecute(Sender: TObject);
    procedure aDocDeleteExecute(Sender: TObject);
    procedure aDocEditExecute(Sender: TObject);
  private
    { Private declarations }
    FId: Integer;
    FMenuStruDm: TMenuStruDm;
    FCurrentNode: PVirtualNode;
    isSubInsert: Boolean;
    //procedure SetId(const Value: Integer);
    function getCurrentData: PTreeData;
    function internalBeforeDocInsert:Boolean;
    function internalBeforeDocDelete:Boolean;
    function synchroMemPosition(Data: PTreeData):Boolean;
  protected
    procedure FmEditOnActionUpdate(Sender: TObject);override;
    procedure DoDocAfterOpen(DataSet: TDataSet);override;
    procedure DoOnInitVariables(ASender: TObject; AInsert: Boolean);
    procedure DoInitActionManager(Sender: TObject);
    procedure internalAddNode();


  public
    { Public declarations }
    function GetCaption: String; override;
    function GetActiveControl: TWinControl; override;
    class function GetDmDoc:TDocDm;override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm);override;
//    property Id: Integer read FId write SetId;
    class function GetSelectedCaption(AVar: TVkVariableCollection):String;override;
  end;

  {TAttributesFrameOAU = class(TAttributesFrame)
  public
    function GetCaption: String; override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm); override;
  end;

  TAttributesFrameOKU = class(TAttributesFrame)
  public
    function GetCaption: String; override;
    constructor Create(AOwner: TComponent; ADocDm:TDocDm); override;
  end;}

var
  MenuStruFrame: TMenuStruFrame;

implementation

uses systemconsts;
{$R *.dfm}

{ TFrameAttributes }

procedure TMenuStruFrame.aDocDeleteExecute(Sender: TObject);
var Data: PtreeData;
begin
  if internalBeforeDocDelete then
  begin
    inherited;
  end;
end;

procedure TMenuStruFrame.aDocEditExecute(Sender: TObject);
var Data: PTreeData;
begin
  Data := getCurrentData;
  if Assigned(Data) and (Data.id_level > 0) then
  begin
    FMenuStruDm.MemTableEhDoc.Locate('id_item',Data.id_item,[]);
    inherited;
  end;
end;

procedure TMenuStruFrame.aDocInsertExecute(Sender: TObject);
begin
  if internalBeforeDocInsert then
  begin
    FCurrentNode := vstMenu.FocusedNode;
    isSubInsert := False;
    inherited;
    internalAddNode;
  end;
end;

procedure TMenuStruFrame.aDocSubInsertExecute(Sender: TObject);
begin
  FCurrentNode := vstMenu.FocusedNode.Parent;
  isSubInsert := true;
  inherited aDocInsertExecute(Sender);
  internalAddNode;
end;

constructor TMenuStruFrame.Create(AOwner: TComponent; ADocDm: TDocDm);
var nCount: Integer;
    node: PVirtualNode;
begin
  inherited Create(AOwner, ADocDm);
  if Assigned(ADocDm) and (ADocDm is TMenuStruDm) then
  begin
    FMenuStruDm := TMenuStruDm(ADocDm);
    FMenuStruDm.OnInitVariables := DoOnInitVariables;
    FMenuStruDm.Open;
    vstMenu.NodeDataSize := SizeOf(RTreeData);

    FMenuStruDm.MemTableEhDoc.SetFilterText('ID_LEVEL=0');
    FMenuStruDm.MemTableEhDoc.Filtered := True;
    FMenuStruDm.MemTableEhDoc.Last;
    nCount := FMenuStruDm.MemTableEhDoc.RecNo;
    vstMenu.RootNodeCount:= nCount;
    if vstMenu.RootNodeCount>0 then
      begin
        node := vstMenu.GetFirst();
        vstMenu.FocusedNode := node;
        vstMenu.Selected[node] := true;
        while node <>nil do
        begin
          vstMenu.Expanded[node] := true;
          node := node.NextSibling;
        end;

      end;

//    vstMenu.FullExpand(node);
    ConfigureEdit;
  end;
  OnInitActionManager := DoInitActionManager;
//  FmEdit.OnActionUpdate := FmEditOnActionUpdate;
end;

function TMenuStruFrame.internalBeforeDocDelete: Boolean;
var data: PtreeData;
begin
  result := synchroMemPosition(getCurrentData);
end;

function TMenuStruFrame.internalBeforeDocInsert: Boolean;
var data: PtreeData;
begin
  data := getCurrentData;
  if Assigned(data) and (data.id_level=0) then
  begin
    ShowMessage('Добавление на нулевом уровне невозможно! ');
    result := false;
  end
  else
  begin
    result := true;
  end;
end;

procedure TMenuStruFrame.DoDocAfterOpen(DataSet: TDataSet);
var i,k: Integer;
begin
  inherited;
  if DbGridEhVkDoc.Columns.Count>0 then
  begin
    for i:=0 to DbGridEhVkDoc.Columns.Count-1 do
    begin
      if DbGridEhVkDoc.Columns[i].FieldName.Equals('MI_ID') then
      begin
        for k := 0 to miList.Count-1 do
          DbGridEhVkDoc.Columns[i].PickList.Add(miList.Items[k].Name);
      end;

    end;
  end;

end;

procedure TMenuStruFrame.DoInitActionManager(Sender: TObject);
var i: Integer;
begin
  DefaultActionListInit;
  i := FActionDescription.IndexOf(aDocInsert);
  FActionDescription.InsertDescription(i+1,'DOC',aDocSubInsert,'Bitmap_subins');

end;

procedure TMenuStruFrame.DoOnInitVariables(ASender: TObject; AInsert: Boolean);
var data: PTreeData;
begin
  if AInsert then
  begin
    if not isSubInsert then
    begin
      data := vstMenu.GetNodeData(FCurrentNode);
      FMenuStruDm.DocVariableList.VarByName('id_menu').AsInteger := data.id_menu;
      FMenuStruDm.DocVariableList.VarByName('id_level').AsInteger := data.id_level;
      FMenuStruDm.DocVariableList.VarByName('num_level').AsInteger := FMenuStruDm.getNextNumLevel(data.id_menu,data.id_level);
      FMenuStruDm.DocVariableList.VarByName('mi_id').AsInteger := -1;
    end
    else
    begin
//      FCurrentNode := vstMenu.FocusedNode;
      data := vstMenu.GetNodeData(FCurrentNode);
      FMenuStruDm.DocVariableList.VarByName('id_menu').AsInteger := data.id_menu;
      FMenuStruDm.DocVariableList.VarByName('id_level').AsInteger := data.id_level+1;
      FMenuStruDm.DocVariableList.VarByName('num_level').AsInteger := FMenuStruDm.getNextNumLevel(data.id_menu,data.id_level+1);;
      FMenuStruDm.DocVariableList.VarByName('mi_id').AsInteger := -1;
    end;
  end;
end;

procedure TMenuStruFrame.FmEditOnActionUpdate(Sender: TObject);
var _Item: TVkVariableBinding;
  _Item2: TVkVariableBinding;
  _Item3: TVkVariableBinding;
  _ItemGroup: TVkVariableBinding;
begin
{  _Item := FmEdit.BindingList.FindVkVariableBinding('attributetype');
  _Item2 := FmEdit.BindingList.FindVkVariableBinding('ndec');
  _Item3 := FmEdit.BindingList.FindVkVariableBinding('nlen');
  _ItemGroup := FmEdit.BindingList.FindVkVariableBinding('idgroup');
  if Assigned(_Item)  then
  begin
    if Assigned(_Item2) then
    begin
      if (_Item.Variable.AsLargeInt>1) then
      begin
        _Item2.oControl.Enabled := False;
        _Item3.oControl.Enabled := False
      end
      else
      begin
        _Item2.oControl.Enabled := _Item.Variable.AsLargeInt <> 0;
        _Item3.oControl.Enabled := True
      end;
      if Assigned(_ItemGroup) and Assigned(_ItemGroup.oControl) then
        _ItemGroup.oControl.Enabled := (_Item.Variable.AsLargeInt = TA_GROUP) or
            (_Item.Variable.AsLargeInt = TA_OBJECT);

    end;

  end;}
end;

{function TFrameAttributes.GetCaption: String;
begin
  Result := 'not defined'
end; }

function TMenuStruFrame.GetActiveControl: TWinControl;
begin
  Result := panel1;
end;

function TMenuStruFrame.GetCaption: String;
begin
  {if FId>0 then
  begin
    case MainDm.GetTypeGroup(FId) of
      IDGROUP_OKU: Result := 'Атрибуты объектов количественного учета';
      IDGROUP_OAU: Result := 'Атрибуты объектов аналитического учета';
    end;
  end;}
  Result := 'Настройка меню';
end;

function TMenuStruFrame.getCurrentData: PTreeData;
begin
  if Assigned(vstMenu.FocusedNode) then
  begin
    result := vstMenu.GetNodeData(vstMenu.FocusedNode);
  end
  else
    result := nil;
end;

class function TMenuStruFrame.GetDmDoc: TDocDm;
begin
  Result := TMenuStruDm.GetDm;
end;

class function TMenuStruFrame.GetSelectedCaption(AVar: TVkVariableCollection): String;
begin
  if Avar.Count>1 then
    inherited
  else
  begin
    if Avar.Count=1 then
      Result := IfVarEmpty(
      MainDm.QueryValue('SELECT name FROM menulist WHERE id_menu=:id_menu',[Avar.Items[0].AsLargeInt]),'')
    else
      Result := 'not defined';
  end;
end;

procedure TMenuStruFrame.internalAddNode;
var newnode: PVirtualNode;
    Data: PTreeData;
begin
  if isSubInsert then
  begin
    newnode :=    VstMenu.AddChild(FCurrentNode);
  end
  else
  begin
    newnode :=    VstMenu.AddChild(FCurrentNode.Parent);
  end;
  Data := VstMenu.GetNodeData(newnode);
//  := VstMenu.GetNodeData(newnode);
  Data.id_level := FMenuStruDm.MemTableEhDoc.FieldByName('ID_LEVEL').AsLargeInt;
  Data.id_item := FMenuStruDm.MemTableEhDoc.FieldByName('ID_ITEM').AsLargeInt;
  Data.id_menu := FMenuStruDm.MemTableEhDoc.FieldByName('ID_MENU').AsLargeInt;
  Data.mi_id := FMenuStruDm.MemTableEhDoc.FieldByName('MI_ID').AsLargeInt;
  Data.namemenu := FMenuStruDm.MemTableEhDoc.FieldByName('NAMEMENU').AsString;
  Data.num_level := FMenuStruDm.MemTableEhDoc.FieldByName('NUM_LEVEL').AsLargeInt;

  VstMenu.FocusedNode := newnode;
  VstMenu.Selected[newnode] := True;

end;

procedure TMenuStruFrame.Panel1Enter(Sender: TObject);
begin
  inherited;
  vstMenu.SetFocus;
end;

function TMenuStruFrame.synchroMemPosition(Data:PTreeData) : Boolean;
begin
  if Assigned(Data) and (Data.id_level >0) then
     Result := FMenuStruDm.MemTableEhDoc.Locate('id_item',Data.id_item,[])
  else
     Result := false;
end;

procedure TMenuStruFrame.vstMenuChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
  var data:PTreeData;
begin
  inherited;
  StatusBar1.Font.Style := StatusBar1.Font.Style + [fsBold];

  data := VstMenu.GetNodeData(Node);
  if Assigned(data) then
    StatusBar1.Panels[0].Text := '   '+data.Namemenu+' '+IntToStr(data.id_item);

end;

procedure TMenuStruFrame.vstMenuGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTreeData;
begin
  inherited;
  Data := sender.GetNodeData(Node);
  CellText := Data.namemenu;
end;

procedure TMenuStruFrame.vstMenuInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data: PTreeData;
  ChildNode: PVirtualNode;
begin
  inherited;
  with FMenuStruDm do
  begin
    Data := Sender.GetNodeData(Node);
    MemTableEhDoc.SetFilterText('ID_LEVEL='+IntToStr(Data.id_item));
    MemTableEhDoc.Filtered := True;
    MemTableEhDoc.First;
    try
      while not MemTableEhDoc.eof do
      begin
        ChildNode := Sender.AddChild(Node);
        Data := Sender.getNodeData(ChildNode);
        Sender.ValidateNode(Node, False);
        MemTableEhDoc.Next;
      end;
    finally
      MemTableEhDoc.Filtered := false;
    end;
  end;
  ChildCount := Sender.ChildCount[Node];
end;

procedure TMenuStruFrame.vstMenuInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  ParentData: PTreeData;
  Data: PTreeData;
begin
//  inherited;
   Data := Sender.getNodeData(Node);
   if not Assigned(ParentNode) then
   begin
     FMenuStruDm.MemTableEhDoc.First;
     FMenuStruDm.MemTableEhDoc.MoveBy(Node.Index);
   end;


   Data.id_level := FMenuStruDm.MemTableEhDoc.FieldByName('ID_LEVEL').AsLargeInt;
   Data.id_item := FMenuStruDm.MemTableEhDoc.FieldByName('ID_ITEM').AsLargeInt;
   Data.id_menu := FMenuStruDm.MemTableEhDoc.FieldByName('ID_MENU').AsLargeInt;
   Data.mi_id := FMenuStruDm.MemTableEhDoc.FieldByName('MI_ID').AsLargeInt;
   Data.namemenu := FMenuStruDm.MemTableEhDoc.FieldByName('NAMEMENU').AsString;
   Data.num_level := FMenuStruDm.MemTableEhDoc.FieldByName('NUM_LEVEL').AsLargeInt;

   if (FMenuStruDm.MemTableEhDoc.FieldByName('COUNT_SOD').AsLargeInt > 0) then
     Include(InitialStates, ivsHasChildren)
end;

{procedure TMenuStruFrame.SetId(const Value: Integer);
begin
  FId := Value;
  GetParentForm.Caption := GetCaption;
  FDmMenuStru :=  TMenuStruDm(DocDm);
  if not Prepare then
  begin
    FDmMenuStru.Open(FId);
    ConfigureEdit;
  end;
  DataSource1.DataSet := FDmMenuStru.MemTableEhDoc;
end;}


initialization
  RegisterClass(TMenuStruFrame);
end.
