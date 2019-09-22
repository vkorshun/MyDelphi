unit fm_setupform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MemTableDataEh, Db, MemTableEh, GridsEh, DBGridEh, DBGridEhVk, Menus,
  ImgList, ToolWin, ActnMan, ActnCtrls, ActionManagerDescription, ActnList,
  Registry,
  DateVk, Contnrs, DBGridEhGrouping, mikko_consts, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, DBAxisGridsEh;

ResourceString
{$IFDEF ENGLISH_INTERFACE }
  rs_OnOff = 'On / Off'; // ' Вкл. / Откл.'
  rs_namecolumn = 'Column name '; // ' Наименование столбца';
  rs_widthcolumn = 'Column width in pixels'; // ' Ширина столбца в пикселях';
{$ELSE}
  rs_OnOff = ' Вкл. / Откл.';
  rs_namecolumn = ' Наименование столбца';
  rs_widthcolumn = ' Ширина столбца в пикселях';
{$ENDIF}

const
  IDE_EDIT = 1;
  IDE_UP = 2;
  IDE_DOWN = 3;
  IDE_SAVE = 4;
  ID_VERSION = 1;

type

  TFmSetUpForm = class(TForm)
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
    FNames: TStringList;
    FPrefix: String;
    FOnSetUpDataSet: TNotifyEvent;
    bChanged: Boolean;
    Reg_UserData: String;
    FExcludeFromVisible: TStringList;
    procedure DoExecuteAction(Sender: TObject);
    procedure MoveItem(bUp: Boolean);
    procedure SetItem;
  public
    { Public declarations }
    procedure Prepare(aDs: TDataSet; const aReg_UserData, aPrefix: String);
    procedure SetUpDataSet(aDs: TDataSet);
    procedure SetItems;
    procedure SaveChanges;
    property Names: TStringList read FNames;
    property ExcludeFromVisible: TStringList read FExcludeFromVisible;
    property OnSetUpDataSet: TNotifyEvent read FOnSetUpDataSet
      write FOnSetUpDataSet;
  end;

var
  FmSetUpForm: TFmSetUpForm;

implementation

{$R *.dfm}

procedure TFmSetUpForm.DoExecuteAction(Sender: TObject);
var
  mAction: TAction;
begin

  mAction := TAction(Sender);
  case mAction.Tag of
    IDE_EDIT:
      SetItem;
    IDE_UP:
      MoveItem(True);
    IDE_DOWN:
      MoveItem(False);
    IDE_SAVE:
      begin
        SaveChanges;
        SetUpDataSet(FDataSet);
      end;
  end;

end;

procedure TFmSetUpForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if bChanged then
  begin
    if MessageDlg(msg_SaveChanges, mtConfirmation, mbYesNo, 0) = mrYes then
    begin
      SaveChanges;
      SetUpDataSet(FDataSet);
    end;
  end;
  CanClose := True;
end;

procedure TFmSetUpForm.FormCreate(Sender: TObject);
var
  ab: TActionBarItem;
  m_Am: TActionManager;
begin
  FNames := TStringList.Create;
  FExcludeFromVisible := TStringList.Create;
  Caption := rs_SetForm; // 'Настройка формы';
  FReg := TRegistry.Create;
  FReg.RootKey := HKEY_CURRENT_USER;
  FBtnList := TListActionManagerDescription.Create;

  with MemTableEh1 do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('field_name', ftString, 20);
    FieldDefs.Add('bVisible', ftBoolean);
    FieldDefs.Add('caption', ftString, 100);
    FieldDefs.Add('width', ftInteger);
    FieldDefs.Add('index', ftInteger);
    FieldDefs.Add('id', ftInteger);
    CreateDataset;
    Open;
  end;

  with FBtnList do
  begin
    Items.Clear;
    AddDescription('doc1', IDE_EDIT, 'BITMAP_EDIT', rs_Edit, 'F4');
    AddDescription('doc1', IDE_UP, 'BITMAP_folderup', rs_Up, 'ALT+Up');
    AddDescription('doc1', IDE_DOWN, 'BITMAP_folderdn', rs_Down, 'ALT+DOWN');
    AddDescription('doc1', IDE_SAVE, 'BITMAP_SAVE', rs_Save, 'F2');
  end;

  m_Am := TActionManager.Create(self);
  ab := m_Am.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  m_Am.Images := ImageList1;
  FBtnList.InitActionManager(m_Am, PopupMenu, DoExecuteAction);

end;

procedure TFmSetUpForm.FormDestroy(Sender: TObject);
begin
  MemTableEh1.DestroyTable;
  FReg.Free;
  FBtnList.Free;
  FNames.Free;
end;

procedure TFmSetUpForm.MemTableEh1AfterOpen(DataSet: TDataSet);
begin
  with MemTableEh1 do
  begin
    with FieldByName('field_name') do
    begin
      Index := 0;
      Visible := False;
      // DisplayLabel := ' Вкл. / Откл.';
    end;

    with FieldByName('bVisible') do
    begin
      Index := 0;
      DisplayLabel := rs_OnOff; // ' Вкл. / Откл.';
    end;
    with FieldByName('caption') do
    begin
      Index := 1;
      DisplayLabel := rs_namecolumn; // ' Наименование столбца';
      ReadOnly := True;
    end;
    with FieldByName('width') do
    begin
      Index := 2;
      DisplayLabel := rs_widthcolumn; // ' Ширина столбца в пикселях';
    end;
    with FieldByName('id') do
    begin
      Visible := False;
    end;
    with FieldByName('index') do
    begin
      Visible := True;
    end;
  end;

end;

procedure TFmSetUpForm.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  bChanged := True;
end;

procedure TFmSetUpForm.MoveItem(bUp: Boolean);
var
  nIndex: Integer;
  cFieldName: String;
begin

  with MemTableEh1 do
  begin
    cFieldName := FieldByName('field_name').AsString;
    Edit;
    if bUp then
    begin
      if FieldByName('Index').AsInteger = 0 then
      begin
        Cancel;
        Exit;
      end;
      FieldByName('Index').AsInteger := FieldByName('Index').AsInteger - 1;
      nIndex := MemTableEh1.FieldByName('Index').AsInteger;
    end
    else
    begin
      if Eof then
      begin
        Cancel;
        Exit;
      end;
      FieldByName('Index').AsInteger := FieldByName('Index').AsInteger + 1;
      nIndex := MemTableEh1.FieldByName('Index').AsInteger;
    end;
    Post;

//    if bUp then
//    begin
    Locate('Index', nIndex , []);
    if cFieldName= FieldByName('field_name').AsString then
      Next;

    Edit;
    if bUp then
      FieldByName('Index').AsInteger := FieldByName('Index').AsInteger + 1
    else
      FieldByName('Index').AsInteger := FieldByName('Index').AsInteger - 1;
    Post;

    Locate('Index', nIndex , []);

  end;
end;

procedure TFmSetUpForm.Prepare(aDs: TDataSet;
  const aReg_UserData, aPrefix: String);
var
  SetList: TStringList;
  i: Integer;
  sCaption: String;
  nIndex: Integer;
  nId: Integer;
begin
  FDataSet := aDs;
  FPrefix := aPrefix;
  Reg_UserData := aReg_UserData;
  SetList := TStringList.Create;
  FReg.OpenKey(Reg_UserData, True);
  nId := 0;
  if FReg.KeyExists(Reg_UserData + '\version') then
  begin
    FReg.OpenKey(Reg_UserData + '\version', True);
    nId := FReg.ReadInteger('ID');
  end;
  SetList.Clear;
  if nId = ID_VERSION then
  begin
    FReg.OpenKey(Reg_UserData + '\' + FPrefix, True);
    nIndex := -1;
    FReg.GetKeynames(SetList);
    with MemTableEh1 do
    begin
      if not MemTableEh1.IsEmpty then
        EmptyTable;
      begin
        for i := 0 to SetList.Count - 1 do
        begin
          if FExcludeFromVisible.IndexOf(SetList[i]) > -1 then
            FReg.DeleteKey(Reg_UserData + '\' + FPrefix + '\' + SetList[i])
          else
          begin
            Append;
            FReg.OpenKey(Reg_UserData + '\' + FPrefix + '\' + SetList[i], True);
            FieldByName('field_name').AsString := SetList[i];
            // FieldByName('id').AsInteger     := FReg.ReadInteger('id');
            FieldByName('index').AsInteger := FReg.ReadInteger('index');
            FieldByName('caption').AsString := FReg.ReadString('caption');
            FieldByName('width').AsInteger := FReg.ReadInteger('width');
            FieldByName('bvisible').AsBoolean := FReg.ReadBool('bvisible');
            if FieldByName('index').AsInteger > nIndex then
              nIndex := FieldByName('index').AsInteger;
            Post;
          end;
        end;
      end;
      for i := 0 to FDataSet.FieldCount - 1 do
      begin
        if FDataSet.Fields[i].Visible then
        begin
          sCaption := FDataSet.Fields[i].FieldName;
          if not Locate('field_name', sCaption, []) then
          begin
            Append;
            Inc(nIndex);
            FieldByName('field_name').AsString := sCaption;
            FieldByName('index').AsInteger := nIndex;
            FieldByName('caption').AsString := FDataSet.Fields[i].DisplayLabel;
            FieldByName('width').AsInteger := FDataSet.Fields[i].DisplayWidth;
            FieldByName('bvisible').AsBoolean := True;
            Post;
          end;
        end;
      end;
      SortOrder := 'Index';
      //-------- Normal Index ------------
      First;
      nIndex := 0;
      while not Eof do
      begin
        if FieldByName('index').AsInteger<> nIndex then
        begin
          Edit;
          Fieldbyname('index').Asinteger := nIndex;
          Post;
          Locate('Index',nIndex,[])
        end;
        Next;
        Inc(nIndex);
      end;
      //-------- Normal Index ------------
    end;
  end
  else
  begin
    FReg.DeleteKey(Reg_UserData);
    FReg.OpenKey(Reg_UserData, True);
    FReg.OpenKey(Reg_UserData + '\version', True);
    FReg.WriteInteger('ID', ID_VERSION);
    FReg.OpenKey(Reg_UserData + '\' + FPrefix, True);
    nIndex := -1;
    with MemTableEh1 do
    begin
      for i := 0 to FDataSet.FieldCount - 1 do
      begin
        if FDataSet.Fields[i].Visible then
        begin
          sCaption := FDataSet.Fields[i].FieldName;
          if not Locate('field_name', sCaption, []) then
          begin
            Append;
            Inc(nIndex);
            FieldByName('field_name').AsString := sCaption;
            FieldByName('index').AsInteger := nIndex;
            FieldByName('caption').AsString := FDataSet.Fields[i].DisplayLabel;
            FieldByName('width').AsInteger := FDataSet.Fields[i].DisplayWidth;
            FieldByName('bvisible').AsBoolean := True;
            Post;
          end;
        end;
      end;
    end;

  end;
  // if Assigned(FOnsetUpDataSet) then
  // FOnsetUpDataSet(self);
  SetList.Free;
  bChanged := False;
end;

procedure TFmSetUpForm.SaveChanges;
var
  bk: TBookmark;
begin
  // FReg.OpenKey(Reg_UserData,True);

  with MemTableEh1 do
  begin
    bk := GetBookmark;
    DisableControls;
    First;
    try
      while not Eof do
      begin
        FReg.OpenKey(Reg_UserData + '\' + FPrefix + '\' +
          (FieldByName('field_name').AsString), True);
        FReg.WriteInteger('Index', FieldByName('Index').AsInteger);
        FReg.WriteInteger('Width', FieldByName('width').AsInteger);
        FReg.WriteBool('bVisible', FieldByName('bVisible').AsBoolean);
        FReg.WriteString('caption', FieldByName('caption').AsString);
        Next;
      end;
    finally
      GotoBookmark(bk);
      FreeBookMark(bk);
      EnableControls;
    end;

  end;
  bChanged := False;
end;

procedure TFmSetUpForm.SetItem;
begin
  with MemTableEh1 do
  begin
    Edit;
    FieldByName('bVisible').AsBoolean := not FieldByName('bVisible').AsBoolean;
    Post;
  end;
end;

procedure TFmSetUpForm.SetItems;
var
  i: Integer;
begin
  for i := 0 to FDataSet.Fields.Count - 1 do
  begin
    if FDataSet.Fields[i].Visible then
    begin
      if MemTableEh1.Locate('field_name', FDataSet.Fields[i].FieldName, []) then
      begin
        try
          MemTableEh1.Edit;
          MemTableEh1.FieldByName('width').AsInteger := FDataSet.Fields[i]
            .DisplayWidth;
        finally
          MemTableEh1.Post;
        end;
      end;
    end;
  end;
end;

procedure TFmSetUpForm.SetUpDataSet(aDs: TDataSet);
var
  bk: TBookmark;
begin
  if not Assigned(aDs) then
    aDs := FDataSet;
  if not Assigned(aDs) then
    Exit;

  if not MemTableEh1.Active then
    Exit;
  if MemTableEh1.IsEmpty then
    Exit;
  FNames.Clear;
  with MemTableEh1 do
  begin
    if State = dsEdit then
      Post;
    bk := GetBookmark;
    DisableControls;
    First;
    try
      while not Eof do
      begin
        aDs.FieldByName(FieldByName('field_name').AsString).Index :=
          FieldByName('index').AsInteger;
        aDs.FieldByName(FieldByName('field_name').AsString).DisplayWidth :=
          FieldByName('width').AsInteger;
        aDs.FieldByName(FieldByName('field_name').AsString).Visible :=
          FieldByName('bvisible').AsBoolean;
        if FieldByName('bvisible').AsBoolean then
          FNames.Add(FieldByName('field_name').AsString);
        Next;
      end;
    finally
      GotoBookmark(bk);
      FreeBookMark(bk);
      EnableControls;
    end;
  end;
  if Assigned(FOnSetUpDataSet) then
    FOnSetUpDataSet(self);
end;

end.
