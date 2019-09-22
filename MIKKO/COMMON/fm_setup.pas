unit fm_setup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MemTableDataEh, Db, MemTableEh, GridsEh, DBGridEh, DBGridEhVk, Menus,
  ImgList, ToolWin, ActnMan, ActnCtrls, ActionManagerDescription, ActnList, Registry,
   DateVk, Contnrs, DBGridEhGrouping, mikko_consts;

ResourceString
  rs_OnOff       = 'On / Off';//' Вкл. / Откл.'
  rs_namecolumn  = 'Column name ';//' Наименование столбца';
  rs_widthcolumn = 'Column width in pixels';// ' Ширина столбца в пикселях';
const
  IDE_EDIT = 1;
  IDE_UP   = 2;
  IDE_DOWN = 3;
  IDE_SAVE = 4;
  ID_VERSION = 1;
type

  TFmSetUp = class(TForm)
    ActionToolBar1: TActionToolBar;
    ImageList1: TImageList;
    PopupMenu: TPopupMenu;
    DBGridEhVk1: TDBGridEhVk;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
  private
    { Private declarations }
    FBtnList: TListActionManagerDescription;
    FReg: TRegistry;
    FDataSet: TDataSet;
    bChanged: Boolean;
    Reg_UserData: String;
    procedure DoExecuteAction(Sender: TObject);
    procedure MoveItem(bUp:Boolean);
    procedure SetItem;
  public
    { Public declarations }
    procedure Prepare(aDs: TDataSet;const aReg_UserData:String );
//    procedure Prepare2(aList: TObjectList;const aReg_UserData:String );
    procedure SetUpDs(aDs: TDataSet);
    procedure SetItems;
    procedure SaveChanges;
  end;


var
  FmSetUp: TFmSetUp;

implementation

{$R *.dfm}
uses frame_task, dm_task;
//{$R am_setup.res}
function MyCompare(p1,p2:Pointer):Integer;
 var i1,i2: Integer;
begin
//  i1 := TItemVtree(p1).Index;
//  i2 := TItemVtree(p2).Index;
  Result := -1;
  if i1<i2 then
    Result:=0;
  if i1=i2 then
    Result := 1;
  if i1>i2 then
    Result := 2;
end;



procedure TFmSetUp.DoExecuteAction(Sender: TObject);
var mAction: TAction;
begin

  mAction := TAction(Sender);
  case mAction.Tag of
    IDE_EDIT: SetItem;
    IDE_UP: MoveItem(True);
    IDE_DOWN: MoveItem(False);
    IDE_SAVE:
      begin
        SaveChanges;
        SetUpDs(FDataSet);
      end;
  end;

end;

procedure TFmSetUp.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if bChanged then
  begin
    if MessageDlg(msg_SaveChanges, mtConfirmation,mbYesNo,0)=mrYes then
    begin
       SaveChanges;
       SetUpDs(FDataSet);
    end;
  end;
  CanClose := true;
end;

procedure TFmSetUp.FormCreate(Sender: TObject);
var ab: TActionBarItem;
    m_Am: TActionManager;
begin
  Caption := rs_SetForm ;//'Настройка формы';
  FReg := TRegistry.Create;
  FReg.RootKey := HKEY_CURRENT_USER;
  FBtnList := TListActionManagerDescription.Create;

  with MemTableEh1 do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('field_name',ftString,20);
    FieldDefs.Add('bVisible',ftBoolean);
    FieldDefs.Add('caption',ftString,100);
    FieldDefs.Add('width',ftInteger);
    FieldDefs.Add('index',ftInteger);
    FieldDefs.Add('id',ftInteger);
    CreateDataset;
    Open;
  end;

  with FBtnList do
  begin
    Items.Clear;
    AddDescription('doc1',IDE_EDIT,'BITMAP_EDIT',rs_Edit,'F4');
    AddDescription('doc1',IDE_UP,'BITMAP_folderup',rs_Up,'ALT+Up');
    AddDescription('doc1',IDE_DOWN,'BITMAP_folderdn',rs_Down,'ALT+DOWN');
    AddDescription('doc1',IDE_SAVE,'BITMAP_SAVE',rs_Save,'F2');
  end;

  m_aM := TActionManager.Create(self);
  ab := m_Am.ActionBars.Add;
  ab.ActionBar :=  ActionToolBar1;
  m_Am.Images := ImageList1;
  FBtnList.InitActionManager(m_Am,PopUpMenu,DoExecuteAction);


end;

procedure TFmSetUp.FormDestroy(Sender: TObject);
begin
  MemTableEh1.DestroyTable;
  FReg.Free;
  FBtnList.Free;
end;

procedure TFmSetUp.MemTableEh1AfterOpen(DataSet: TDataSet);
begin
  with memTableEh1 do
  begin
    with FieldByName('field_name') do
    begin
      Index := 0;
      Visible := False;
//      DisplayLabel := ' Вкл. / Откл.';
    end;

    with FieldByName('bVisible') do
    begin
      Index := 0;
      DisplayLabel := rs_OnOff;//' Вкл. / Откл.';
    end;
    with FieldByName('caption') do
    begin
      Index := 1;
      DisplayLabel := rs_namecolumn;//' Наименование столбца';
      ReadOnly := True;
    end;
    with FieldByName('width') do
    begin
      Index := 2;
      DisplayLabel :=rs_widthcolumn;// ' Ширина столбца в пикселях';
    end;
    with FieldByName('id') do
    begin
      Visible := False;
    end;
    with FieldByName('index') do
    begin
      Visible := False;
    end;
  end;


end;

procedure TFmSetUp.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  bChanged := true;
end;

procedure TFmSetUp.MoveItem(bUp: Boolean);
var nIndex: Integer;
begin

  nIndex := MemTableEh1.FieldByName('Index').AsInteger;
  with MemTableEh1 do
  begin
    Edit;
    if bUp then
    begin
      if FieldByName('Index').AsInteger=0 then
      begin
        Cancel;
        Exit;
      end;
      FieldByName('Index').AsInteger  :=
        FieldByName('Index').AsInteger - 1
    end
    else
    begin
      if FieldByName('Index').AsInteger=11 then
      begin
        Cancel;
        Exit;
      end;
      FieldByName('Index').AsInteger  :=
        FieldByName('Index').AsInteger + 1;
    end;
    Post;

    if bUp  then
    begin
      if not Locate('Index',nIndex-1,[]) then
        Exit;
    end
    else
      Next;

    Edit;
    if bUp then
      FieldByName('Index').AsInteger  :=
        FieldByName('Index').AsInteger + 1
    else
      FieldByName('Index').AsInteger  :=
        FieldByName('Index').AsInteger - 1;
    Post;

    if bUp  then
      Locate('Index',nIndex-1,[])
    else
      Next;
  end;
end;

procedure TFmSetUp.Prepare(aDs:TDataSet;const aReg_UserData:String);
var SetList: TStringList;
    i: Integer;
    sCaption: String;
    nIndex: Integer;
    nId: Integer;
begin
  FDataSet := aDs;
  Reg_UserData := aReg_UserData;
  SetList := TStringList.Create;
  FReg.OpenKey(Reg_UserData,True);
  nId := 0;
  if Freg.KeyExists(Reg_UserData+'\version') then
  begin
    FReg.OpenKey(Reg_UserData+'\version',True);
    nId := FReg.ReadInteger('ID');
  end;
  SetList.Clear;
  if nId= ID_VERSION then
  begin
    FReg.OpenKey(Reg_UserData+'\dbgrid',true);
    nIndex := -1;
    FReg.GetKeynames(SetList);
    with MemTableEh1 do
    begin
      if not MemTableEh1.IsEmpty then
        EmptyTable;
      begin
        for I := 0 to SetList.Count - 1 do
        begin
          Append;
          FReg.OpenKey(Reg_UserData+'\dbgrid\'+SetList[i],True);
          FieldByName('field_name').AsString  := SetList[i];
//          FieldByName('id').AsInteger     := FReg.ReadInteger('id');
          FieldByName('index').AsInteger  := FReg.ReadInteger('index');
          FieldByName('caption').AsString := FReg.ReadString('caption');
          FieldByName('width').AsInteger  := FReg.ReadInteger('width');
          FieldByName('bvisible').AsBoolean := FReg.ReadBool('bvisible');
          if FieldByName('index').AsInteger > nIndex then
            nIndex := FieldByName('index').AsInteger;
          Post;
        end;
      end;
      for i := 0 to FDataSet.FieldCount - 1 do
      begin
        if FDataSet.Fields[i].Visible then
        begin
          sCaption := FDataSet.Fields[i].FieldName;
          if not Locate('field_name',sCaption,[]) then
          begin
            Append;
            Inc(nIndex);
            FieldByName('field_name').AsString:= sCaption;
            FieldByName('index').AsInteger    := nIndex;
            FieldByName('caption').AsString   := FDataSet.Fields[i].DisplayLabel;
            FieldByName('width').AsInteger    := FDataSet.Fields[i].DisplayWidth;
            FieldByName('bvisible').AsBoolean := True;
            Post;
          end;
        end;
      end;
      SortOrder := 'Index';
    end;
  end
  else
  begin
    FReg.DeleteKey(Reg_UserData);
    FReg.OpenKey(Reg_UserData,True);
    FReg.OpenKey(Reg_UserData+'\version',True);
    fReg.WriteInteger('ID',ID_VERSION);
    FReg.OpenKey(Reg_UserData+'\dbgrid',True);
    nIndex := -1;
    with MemTableEh1 do
    begin
      for i := 0 to FDataSet.FieldCount - 1 do
      begin
        if FDataSet.Fields[i].Visible then
        begin
          sCaption := FDataSet.Fields[i].FieldName;
          if not Locate('field_name',sCaption,[]) then
          begin
            Append;
            Inc(nIndex);
            FieldByName('field_name').AsString := sCaption;
            FieldByName('index').AsInteger     := nIndex;
            FieldByName('caption').AsString    := FDataSet.Fields[i].DisplayLabel;
            FieldByName('width').AsInteger     := FDataSet.Fields[i].DisplayWidth;
            FieldByName('bvisible').AsBoolean  := True;
            Post;
          end;
        end;
      end;
    end;

  end;
  SetList.Free;
  bChanged := False;
end;


{procedure TFmSetUp.Prepare2(aList: TObjectList; const aReg_UserData: String);
var SetList: TStringList;
    i: Integer;
    nIndex: Integer;
    nId: Integer;
begin
  Reg_UserData := aReg_UserData;
  FReg.OpenKey(Reg_UserData,True);
  SetList := TStringList.Create;

  nId := 0;
  if Freg.KeyExists(Reg_UserData+'\version') then
  begin
    FReg.OpenKey(Reg_UserData+'\version',True);
    FReg.GetKeynames(SetList);
    if SetList.IndexOf('ID')>-1 then
    begin
      nId := FReg.ReadInteger('ID');
    end;
  end;
  SetList.Clear;
  nIndex := -1;
  if nId= ID_VERSION then
  begin
    FReg.OpenKey(Reg_UserData+'\vtreeitems',true);
    FReg.GetKeynames(SetList);
    with MemTableEh1 do
    begin
      EmptyTable;
      for I := 0 to SetList.Count - 1 do
      begin
        Append;
        FReg.OpenKey(Reg_UserData+'\vtreeitems\'+SetList[i],True);
        FieldByName('id').AsInteger     := FReg.ReadInteger('id');
        FieldByName('index').AsInteger  := FReg.ReadInteger('index');
        FieldByName('caption').AsString := FReg.ReadString('caption');
        FieldByName('width').AsInteger  := FReg.ReadInteger('width');
        FieldByName('bvisible').AsBoolean := FReg.ReadBool('bvisible');
        if FieldByName('index').AsInteger > nIndex then
          nIndex := FieldByName('index').AsInteger;
        Post;
      end;
    end;
  end
  else
  begin
    FReg.DeleteKey(Reg_UserData);
    FReg.OpenKey(Reg_UserData,True);
    FReg.OpenKey(Reg_UserData+'\version',True);
    fReg.WriteInteger('ID',ID_VERSION);
    FReg.OpenKey(Reg_UserData+'\vtreeitems',True);
    with MemTableEh1 do
    for i := 0 to aList.Count - 1 do
    begin
      begin
        Append;
        Inc(nIndex);
        FieldByName('id').AsInteger       := TItemVTree(aList[i]).id;
        FieldByName('index').AsInteger    := nIndex;
        FieldByName('caption').AsString   := TItemVTree(aList[i]).DisplayLabel;
        FieldByName('width').AsInteger    := TItemVTree(aList[i]).Width;
        FieldByName('bvisible').AsBoolean := TItemVTree(aList[i]).Visible;
        Post;
        TItemVTree(aList[i]).Index := nIndex;
      end;
    end;
    MemTableEh1.SortOrder := 'Index';
  end;
  SetList.Free;
  bChanged := False;

  aList.Sort(MyCompare);


end; }

procedure TFmSetUp.SaveChanges;
begin
//  FReg.OpenKey(Reg_UserData,True);

  with MemTableEh1 do
  begin
    First;
    while not Eof do
    begin
      FReg.OpenKey(Reg_UserData+'\dbgrid\'+(FieldByName('field_name').AsString),True);
      Freg.WriteInteger('Index',FieldByName('Index').AsInteger);
      Freg.WriteInteger('Width',FieldByName('width').AsInteger);
      Freg.WriteBool('bVisible',FieldByName('bVisible').AsBoolean);
      FReg.WriteString('caption',FieldByName('caption').AsString);
      Next;
    end;


  end;
  bChanged := False;
end;

procedure TFmSetUp.SetItem;
begin
  with MemTableEh1 do
  begin
    Edit;
    FieldByName('bVisible').AsBoolean := not     FieldByName('bVisible').AsBoolean;
    Post;
  end;
end;


procedure TFmSetUp.SetItems;
var
  i: Integer;
begin
  for I := 0 to FDataSet.Fields.Count - 1 do
  begin
    if FDataSet.Fields[i].Visible then
    begin
      if MemTableEh1.Locate('field_name',FDataSet.Fields[i].FieldName,[]) then
      begin
        try
          MemTableEh1.Edit;
          MemTableEh1.FieldByName('width').AsInteger := FDataSet.Fields[i].DisplayWidth;
        finally
          MemTableEh1.Post;
        end;
      end;
    end;
  end;
end;

procedure TFmSetUp.SetUpDs(aDs:TDataSet );
var
    i: Integer;
    sCaption: String;
begin
  if not Assigned(aDs) then
    aDs := FDataSet;
  if not Assigned(aDs) then
    Exit;

  if not MemTableEh1.Active then
    Exit;
  if MemTableEh1.IsEmpty then
    Exit;
  with MemTableEh1 do
  begin
    if State = dsEdit then
      Post;
    First;
    while not Eof do
    begin
      aDs.FieldByName(FieldByName('field_name').AsString).Index :=
        FieldByName('index').AsInteger;
      aDs.FieldByName(FieldByName('field_name').AsString).DisplayWidth :=
        FieldByName('width').AsInteger;
      aDs.FieldByName(FieldByName('field_name').AsString).visible :=
        FieldByName('bvisible').AsBoolean;
      Next;
    end;
  end;
end;



end.
