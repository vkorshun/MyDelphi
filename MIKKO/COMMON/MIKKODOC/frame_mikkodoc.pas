unit frame_mikkodoc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBGridEhGrouping, GridsEh, DBGridEh, DBGridEhVk, ToolWin, ActnMan,
  ActnCtrls, dm_mikkodoc, ActionManagerDescription, DB, Menus, ImgList,
  ActnList, doc.mikkodoc, vkEhLibMTE, DbGridEhVkFilterSetting,
  DateVk, doc.variablelist, ComCtrls, fm_setfilter,
  PlatformDefaultStyleActnCtrls, ActnPopup, DBGridEhSimpleFilterDlg;

const
  WM_ENTER = WM_USER + 102;
  IDE_DOC_ADD = 1;
  IDE_DOC_EDIT = 2;
  IDE_DOC_DELETE = 3;
  IDE_DOC_COPY = 4;
  IDE_DOC_PRINT = 5;
  IDE_DOC_SVOD = 6;
  IDE_DOC_MARK = 7;
  IDE_DOC_MARKALL = 8;
  IDE_DOC_UNMARKALL = 9;
  IDE_DOC_FIND = 10;
  IDE_DOC_FINDNEXT = 11;
  IDE_DOC_SETFILTER = 12;
  IDE_DOC_REFRESH = 13;
  IDE_DOC_SELECT = 14;
  IDE_DOC_CHANGEIDTYPE = 15;
  IDE_DOC_NORMAL = 16;
  IDE_DOC_CALENDAR = 17;
  IDE_DOC_GOIN = 18;
  IDE_DOC_GOOUT = 19;
  IDE_DOC_CLEARINI = 20;
  IDE_DOC_VIEWPRVD = 21;
  IDE_DOC_TOEXCEL = 22;
  IDE_DOC_VIEWHISTORY = 23;
  IDE_DOC_REPLACEMARKED = 24;
  IDE_DOC_SETUPFORM = 25;

type
  TTypeDmMikkoDoc = class of TDmMikkoDoc;
  TTableEhEditEvent = procedure(Sender:TObject;const aFieldName:String)  of object ;

  TFrameMikkoDoc = class(TFrame)
    ActionToolBar1: TActionToolBar;
    DBGridEhVkDoc: TDBGridEhVk;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    DataSource1: TDataSource;
    StatusBar1: TStatusBar;
    procedure DBGridEhVkDocKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEhVkDocDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
    procedure DBGridEhVkDocKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridEhVkDocApplyFilter(Sender: TObject);
  private
    { Private declarations }
    /// <summary> Action manager </summary>

    FClMarked: TColor;
    FilterDialog: TDBGridEhSimpleFilterDialog;
    FOnActionManagerEvent: TNotifyEvent;
    FOnInitActionManager: TNotifyEvent;
    FOnMark: TNotifyEvent;
    FOnUnMark: TNotifyEvent;
    FOnAfterEditMemTableEhDoc: TTableEhEditEvent ;
    bFilterDialogCreate: Boolean;
    procedure AddMSum(bAdd: Boolean);
    procedure DoActionManagerEvent(Sender: TObject);
    procedure DoAfteEditMemTableEhDoc(Sender:TObject;const aFieldName:String );
  protected
    FAm: TActionManager;
    FDmMikkoDoc: TDmMikkoDoc;
    FParentForm: TForm;
    FListAm: TActionManagerDescriptionList;
    FFmSetFilter: TFmSetFilter;
    FilterIndex: Integer;
    ItogMarkedList: TDocVariableList;

    procedure DoEnterMs(var Msg: TMessage); Message WM_ENTER;
    procedure CheckPopUp(Key:Word; Shift:TShiftState);

  public
    { Public declarations }
    constructor Create(aOwner: TComponent;
      aTypeDmDoc: TTypeDmMikkoDoc; aDm: TDataModule = nil); reintroduce; virtual;
    destructor Destroy;override;

    /// <summary> Проверяет наличие источника данных для грида и что он не пустой </summary>
    function DataIsEmpty: Boolean;
    /// <summary> Добавление редактирование документа </summary>
    procedure DocEdit(bNew: Boolean);
    /// <summary> Цвета по умолчанию </summary>
    procedure DoDefaultDrawColumnCell(Sender: TDBGridEhVk; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);

    /// <summary> Удаление документа </summary>
    procedure DocDelete;
    procedure DocSetFilter;

    procedure DoMark(bMark: Boolean);
    procedure DoMarkAll;
    procedure DoUnMarkAll;

    /// <summary> Обработка событий по умолчанию </summary>
    procedure DoDefaultActionManagerEvent(Sender: TObject);
    /// <summary> Инициализауия списка описания событий по умолчанию </summary>
    procedure DoDefaultInitActionManagerDescription;
    /// <summary> Инициализация событий  </summary>
    procedure InitActionManager(aForm: TForm);

    /// <summary> Инициализация списка итогов  </summary>
    procedure InitSumList(var VarList: TDocVariableList);

    /// <summary> Поиск формы родителя </summary>
    function FindForm(aComponent: TWinControl): TForm;

    procedure MyFilterDialogShow(Sender:TObject);

    procedure SetFilter(aIndex:Integer );
    procedure SetFilterComment(oSb: TStatusBar);
    procedure SetSumMarked;
    procedure SetUpForm;Virtual;

    property ClMarked:TColor read FClMarked write FClMarked;
    property DmMikkoDoc: TDmMikkoDoc read FDmMikkoDoc;
    /// <summary> Список событий </summary>
    property ListAm: TActionManagerDescriptionList read FListAm;
    property OnActionManagerEvent: TNotifyEvent read FOnActionManagerEvent
      write FOnActionManagerEvent;
    property OnAfterEditMemTableEhDoc: TTableEhEditEvent read FOnAfterEditMemTableEhDoc
       write FOnAfterEditMemTableEhDoc;
    property OnInitActionManager: TNotifyEvent read FOnInitActionManager
      write FOnInitActionManager;
    property OnMark: TNotifyEvent read FOnMark write FOnMark;
    property OnUnMark: TNotifyEvent read FOnUnMark write FOnUnMark;
  end;

implementation

{$R *.dfm}
{ TFrameMikkoDoc }

procedure TFrameMikkoDoc.AddMSum(bAdd: Boolean);
var
  i: Integer;
begin
  for i := 0 to ItogMarkedList.Count - 1 do
  begin
    if bAdd then
    begin
      ItogMarkedList.Value[i] := ItogMarkedList.Value[i] +
        DataSource1.DataSet.FieldByName(ItogMarkedList[i].name).AsFloat
    end
    else
    begin
      ItogMarkedList.Value[i] := ItogMarkedList.Value[i] -
        DataSource1.DataSet.FieldByName(ItogMarkedList[i].name).AsFloat
    end;
  end;
  SetSumMarked;

end;

procedure TFrameMikkoDoc.CheckPopUp(Key: Word; Shift: TShiftState);
var
  vShortCut: TShortCut;
  i: Integer;

  procedure CheckEvent(aItems: TMenuItem);
  var i: Integer;
  begin
    for I := 0 to aItems.Count-1 do
    begin
      if aItems[i].ShortCut=vShortCut then
      begin
        DoActionManagerEvent(aItems[i].Action);
        Break;
      end
      else
        if aItems[i].Count>0 then
          CheckEvent(aItems.Items[i])
    end;
  end;

begin
  {$ifdef  NOTACTIVEX}
    Exit;
  {$endif }
  vShortCut := ShortCut(Key,Shift);
  //for I := 0 to PopUpMenu1.Items.Count-1 do
  //begin
  CheckEvent(PopUpMenu1.Items);
  //end;
end;

constructor TFrameMikkoDoc.Create(aOwner: TComponent;
  aTypeDmDoc: TTypeDmMikkoDoc; aDm: TDataModule = nil);
var
  mparent: TWinControl;
  mDm: TDataModule;
begin
  if aOwner is TDataModule then
  begin
    mparent := TWinControl(aOwner.owner);
    mDm := tDataModule(aOwner);
    FParentForm := FindForm(mparent);
  end
  else
  begin
    mparent := TWinControl(aOwner);
    FParentForm := TForm(mparent);

  end;

  if Assigned(aDm) then
    mDm := aDm;

  inherited Create(aOwner);
  if not Assigned(DBGridEhSimpleFilterDialog) then
  begin
    FilterDialog :=     TDBGridEhSimpleFilterDialog.Create(aOwner);
    DBGridEhSimpleFilterDialog := FilterDialog;
  end;

  Parent := mparent;
  Align := alClient;
  FDmMikkoDoc := aTypeDmDoc.Create(mDm);
  FAm := TActionManager.Create(aOwner);

  { FReg := TRegistry.Create;
    FReg.RootKey := HKEY_CURRENT_USER; }

  // FMarkList := TIntList.Create;
  FDmMikkoDoc.doc.GridDoc := DBGridEhVkDoc;
  DataSource1.DataSet := FDmMikkoDoc.MemTableEhDoc;
  // DataSource1.DataSet.Open;
  ItogMarkedList := TDocVariableList.Create(FDmMikkoDoc.DmMikkoAds);

  FFmSetFilter := TFmSetFilter.Create(self);
//  FDmMikkoDoc.FmSetFilter := FFmSetFilter;
  FClMarked := clBlue;
  DBGridEhCenter.FilterEditCloseUpApplyFilter := True;

  DbGridEhCenter.STFilterDefaultStringOperator := fdoContains;
  DbGridEhCenter.STFilterDefaultNumberOperator := fdoContains;
  DbGridEhCenter.STFilterDefaultDateTimeOperator := fdoContains;
  if not Assigned(DBGridEhSimpleFilterDialog) then
  begin
//    DBGridEhSimpleFilterDialog := TDBGridEhSimpleFilterDialog.Create(Application);
//    DBGridEhSimpleFilterDialog.OnShow := MyFilterDialogShow;
    bFilterDialogCreate := true;
  end;
end;

function TFrameMikkoDoc.DataIsEmpty: Boolean;
begin
  Result := True;
  if Assigned(DBGridEhVkDoc.DataSource) and
    Assigned(DBGridEhVkDoc.DataSource.DataSet) then
    Result := DBGridEhVkDoc.DataSource.DataSet.IsEmpty;

end;

procedure TFrameMikkoDoc.DBGridEhVkDocApplyFilter(Sender: TObject);
begin
  DBGridEhVkDoc.DefaultApplyFilter;
//  DBGridEhSimpleFilterDialog.Close;
//  Application.ProcessMessages;
  DoUnMarkAll;
end;

procedure TFrameMikkoDoc.DBGridEhVkDocDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
begin
  DoDefaultDrawColumnCell(TDBGridEhVk(Sender), Rect, DataCol, Column, State);
end;

procedure TFrameMikkoDoc.DBGridEhVkDocKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var s: String;
begin
  if Key = VK_TAB then
  begin
//    PostMessage(DBGridEhVkDoc.Handle, WM_KEYDOWN, VK_F4, VK_F4);
    FDmMikkoDoc.Doc.DocEdit(desEditDialog);
    Key := 0;
  end;



  if Key = VK_RETURN then
    PostMessage(Handle, WM_ENTER, 0, 0);

  // if not DBGridEhVkDoc.SelectedField.ReadOnly then
  case Key of
    VK_RETURN:
      begin
        if FDmMikkoDoc.MemTableEhDoc.State = dsEdit then
        begin
          FDmMikkoDoc.doc.GridFldEdit.bChange := True;
          FDmMikkoDoc.doc.GridFldEdit.fldname :=
            DBGridEhVkDoc.SelectedField.FieldName;
        end;
      end;
  end;

  if Key>50 then
  begin
    s := GetCharFromVirtualKey(Key);
    if length(s)>0 then
      if ((Shift=[]) or (Shift=[ssShift])) and (CharInset(s[1],['*','-','+']))  then
      begin
        if (CharInset(s[1],['-','+'])) and DmMikkoDoc.MemTableEhDoc.TreeList.Active and
           DmMikkoDoc.MemTableEhDoc.RecView.nodeHasChildren then
          Exit;
        DBGridEhVkDocKeyPress(Sender, s[1])
      end;
  end;
  if Key<>0 then
  CheckPopUp(Key,Shift);
end;

procedure TFrameMikkoDoc.DBGridEhVkDocKeyPress(Sender: TObject; var Key: Char);
begin
  if (DBGridEhVkDoc.DataSource.State <> dsEdit) then
  begin
    if Key = '*' then
    begin
      DoMark(False);
      Key := #0;
    end;
    if Key = '+' then
    begin
      DoMarkAll;
      Key := #0;
    end;
    if Key = '-' then
    begin
      DoUnMarkAll;
      Key := #0;
    end;
  end;
end;

destructor TFrameMikkoDoc.Destroy;
begin
  {if bFilterDialogCreate then
    if Assigned(DBGridEhSimpleFilterDialog) then
      FreeAndNil();}
  {$ifdef ACTIVEX_FORM}
  FreeAndNil(FilterDialog);
  {$endif}
  DBGridEhSimpleFilterDialog := nil;
  FreeAndNil(FDmMikkoDoc);
  inherited;
end;

procedure TFrameMikkoDoc.DoActionManagerEvent(Sender: TObject);
begin
  if Assigned(FOnActionManagerEvent) then
    FOnActionManagerEvent(Sender)
  else
    DoDefaultActionManagerEvent(Sender);
  DBGridEhVkDoc.SetFocus;
end;

procedure TFrameMikkoDoc.DoAfteEditMemTableEhDoc(Sender: TObject; const aFieldName: String);
begin
  if Assigned(FOnAfterEditMemTableEhDoc) then
    FOnAfterEditMemTableEhDoc(Sender,aFieldName);
end;

procedure TFrameMikkoDoc.DocDelete;
begin
  // if MessageDlg('Удалить текущий документ ?',mtConfirmation,mbYesNo,0)<>mrYes then
  // Exit;
  FDmMikkoDoc.doc.DocDelete;
end;

procedure TFrameMikkoDoc.DocEdit(bNew: Boolean);
begin
  if not bNew then
    if DataIsEmpty then
      Exit;
  if bNew then
    FDmMikkoDoc.doc.DocEdit(desInsertDialog)
  else
    FDmMikkoDoc.doc.DocEdit(desEditDialog);
end;

procedure TFrameMikkoDoc.DocSetFilter;
begin
  FDmMikkoDoc.SetFilter(-1, self);
  SetFilterComment(StatusBar1);
  DoUnMarkAll;
end;

procedure TFrameMikkoDoc.DoDefaultActionManagerEvent(Sender: TObject);
var
  Id: Integer;
begin
  Id := TAction(Sender).Tag;
  case Id of
    IDE_DOC_ADD:
      DocEdit(True);
    IDE_DOC_EDIT:
      DocEdit(False);
    IDE_DOC_DELETE:
      DocDelete;
    // IDE_DOC_COPY:      DocCopy;
    IDE_DOC_FIND:
      DBGridEhVkDoc.Find(False);
    IDE_DOC_FINDNEXT:
      DBGridEhVkDoc.Find(True);
    IDE_DOC_MARK:
      DoMark(False);
    IDE_DOC_MARKALL:
      DoMarkAll;
    IDE_DOC_UNMARKALL:
      DoUnMarkAll;
    IDE_DOC_SETFILTER:
      SetFilter(-1);
    IDE_DOC_REFRESH:
      FDmMikkoDoc.doc.FullRefresh(0);
    // IDE_DOC_NORMAL:    nNormalClick(Self);
    // IDE_DOC_CALENDAR:  DoRefreshFilterOnMonth;
    // IDE_DOC_GOIN:      GoIn;
    // IDE_DOC_GOOUT:     GoOut;
    // IDE_DOC_CLEARINI:  ClearIni;
    { IDE_DOC_VIEWPRVD:  begin
      oIFmSodoper := IFmSodoper(LoadInterface('hope_common.bpl','IFmSodoper',Application));
      try
      oIFmSodOper.ViewDocPrvd(DmDoc.pFIBDataSetDoc.FieldByName('id_doc').AsInteger);
      finally
      oIFmSodoper := nil;
      end;
      end; }
    IDE_DOC_TOEXCEL:
      begin
        DBGridEhVkDoc.SetFocus;
        DBGridEhVkDoc.OnAltP(DBGridEhVkDoc);
      end;
    IDE_DOC_VIEWHISTORY:
      FDmMikkoDoc.Doc.ViewHistory;
    IDE_DOC_REPLACEMARKED:
      begin
        FDmMikkoDoc.Doc.ReplaceMarked(DbGridEhVkDoc.SelectedField.FieldName);
        DoUnMarkAll;
      end;
    IDE_DOC_SETUPFORM:
      begin
        SetUpForm;
      end;
  end;

end;

procedure TFrameMikkoDoc.DoDefaultDrawColumnCell(Sender: TDBGridEhVk;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
var
  m_key: variant;
begin
  if Assigned(FDmMikkoDoc) and Assigned(FDmMikkoDoc.doc) then
  begin
    m_key := FDmMikkoDoc.doc.GetKey;
    with TDBGridEhVk(Sender) do
      if FDmMikkoDoc.doc.MarkList.IndexOf(m_key) >= 0 then
      begin
        if (gdSelected in State) and (gdFocused in State) then
        begin
          Canvas.Font.Color := clYellow;
          Canvas.Pen.Color := clGrayText;
        end
        else
          Canvas.Font.Color := FclMarked;
      end;
    Sender.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;

end;

procedure TFrameMikkoDoc.DoDefaultInitActionManagerDescription;
begin
  with FListAm do
  begin
    Items.Clear;
    AddDescription('doc1', IDE_DOC_ADD, 'BITMAP_INSERT', 'Добавить', 'Ins');
    AddDescription('doc1', IDE_DOC_EDIT, 'BITMAP_EDIT', 'Редактировать', 'F4');
    AddDescription('doc1', IDE_DOC_DELETE, 'BITMAP_DELETE', 'Удалить', 'Del');
    // AddDescription('doc1',IDE_DOC_COPY,'BITMAP_COPY','Копировать','F5');
    AddDescription('doc2', 'SEPARATOR', 'EMPTY', '', '');
    AddDescription('doc2', IDE_DOC_FIND, 'BITMAP_FIND', 'Поиск', 'F7');
    AddDescription('doc2', IDE_DOC_FINDNEXT, 'BITMAP_FINDNEXT',
      'Продолжение поиска', 'Shift+F7');
    AddDescription('doc2', 'SEPARATOR', 'EMPTY', '', '');
    AddDescription('doc3', IDE_DOC_SETFILTER, 'BITMAP_FILTER', 'Фильтр',
      'Alt+F5');
    // AddDescription('doc3',IDE_DOC_CALENDAR,'BITMAP_DATE','Календарь','Ctrl+F2');
    AddDescription('doc3', IDE_DOC_REFRESH, 'BITMAP_REFRESH',
      'Обновить экран', 'Alt+R');
    AddDescription('doc4', 'SEPARATOR', 'EMPTY', '', '', tdPopUpOnly);
    AddDescription('doc4', IDE_DOC_MARK, '', 'Пометить строку  (*)', '',
      tdPopUpOnly);
    AddDescription('doc4', IDE_DOC_MARKALL, '', 'Пометить все   (+)', '',
      tdPopUpOnly);
    AddDescription('doc4', IDE_DOC_UNMARKALL, '', 'Снять всю пометку  (-)', '',
      tdPopUpOnly);
    AddDescription('doc5', 'SEPARATOR', 'EMPTY', '', '', tdPopUpOnly);
    AddDescription('doc5', IDE_DOC_REPLACEMARKED, '',
      'Присвоить помеченным', 'Alt+Shift+F2',tdPopUpOnly);
    AddDescription('doc5', IDE_DOC_VIEWHISTORY, '',
      'Просмотр истории изменений', 'Ctrl+Alt+H',tdPopUpOnly);
    AddDescription('doc5', IDE_DOC_SETUPFORM, '',
      'Настройка формы', '',tdPopUpOnly);

  end;

end;

procedure TFrameMikkoDoc.DoEnterMs(var Msg: TMessage);
var
  s: String;
begin
  { if (FDmMikkoDoc.MemTableEhDoc.State = dsEdit) then
    // and (DbGridEh1.SelectedField.ReadOnly) then
    begin
    // DmDoc.bDocEdit := False;
    FDmMikkoDoc.MemTableEhDoc.Post;
    Exit;
    end
    else }
  begin
    if not DBGridEhVkDoc.SelectedField.ReadOnly then
    begin
      if not DmMikkoDoc.doc.DoBeforeDocEdit then
      begin
        DmMikkoDoc.doc.MemTableEhDoc.Cancel;
        Exit;
      end;
      if DmMikkoDoc.doc.MemTableEhDoc.State = dsEdit then
      begin
        s := DBGridEhVkDoc.SelectedField.FieldName;
        DoAfteEditMemTableEhDoc(DmMikkoDoc.doc.MemTableEhDoc,s);
        DmMikkoDoc.doc.MemTableEhDoc.Post;
        DmMikkoDoc.doc.FullRefresh(null);
      end;
      {if not DmMikkoDoc.doc.DocLock then
        Exit; }
    end
    else
    begin
      s := DBGridEhVkDoc.SelectedField.FieldName;
      DmMikkoDoc.doc.DocEdit(desEditInBrowse,s);
      { if Assigned(DmMikkoDoc.doc.OnEditInBrowse) then
        begin
        if DmMikkoDoc.doc.OnEditInBrowse(self,
        ) then
        Exit; }
    end;

  end;

end;

procedure TFrameMikkoDoc.DoMark;
var
  i: Integer;
  Key: variant;
begin
  if DataIsEmpty then
    Exit;
  Key := FDmMikkoDoc.doc.GetKey;

  i := FDmMikkoDoc.doc.MarkList.IndexOf(Key);
  if i >= 0 then
  begin
    if not bMark then
    begin
      FDmMikkoDoc.doc.MarkList.Delete(i);
      AddMSum(False);
      if Assigned(OnUnMark) then
        OnUnMark(DBGridEhVkDoc);
    end;
  end
  else
  begin
    FDmMikkoDoc.doc.MarkList.Add(Key);
    AddMSum(True);
    if Assigned(OnMark) then
      OnMark(DBGridEhVkDoc);
  end;
  DataSource1.DataSet.Next;
  if not bMark then
    if DataSource1.DataSet.Eof then
      DataSource1.DataSet.Prior;
end;

procedure TFrameMikkoDoc.DoMarkAll;
var
  bm: TBookMark;
begin
  if DataIsEmpty then
    Exit;
  bm := DataSource1.DataSet.GetBookmark;
  with DataSource1.DataSet do
    try
      DisableControls;
      First;
      while not Eof do
        DoMark(True);
    finally
      DataSource1.DataSet.GotoBookmark(bm);
      DataSource1.DataSet.FreeBookmark(bm);
      EnableControls;
    end;

end;

procedure TFrameMikkoDoc.DoUnMarkAll;
begin
  FDmMikkoDoc.doc.MarkList.Clear;
  InitSumList(ItogMarkedList);
  DBGridEhVkDoc.Refresh;
// Grid.Refresh - плохо в терминалах
//  FDmMikkoDoc.doc.Fullrefresh(null);
end;

function TFrameMikkoDoc.FindForm(aComponent: TWinControl): TForm;
begin
  if (aComponent is TForm) or not Assigned(aComponent.Parent) then
  begin
    Result := TForm(aComponent);
    Exit
  end
  else
    Result := nil;

  while Assigned(aComponent.Parent) do
  begin
    if aComponent.Parent is TForm then
    begin
      Result := TForm(aComponent.Parent);
      Break;
    end;
    aComponent := aComponent.Parent;
  end;

end;

procedure TFrameMikkoDoc.InitActionManager(aForm: TForm);
var
  ab: TActionBarItem;
  Am: TActionManager;
begin
  if not Assigned(FParentForm) then
    FParentForm := aForm;
  Am := TActionManager.Create(aForm);
  ab := Am.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  Am.Images := ImageList1;

  FListAm := TActionManagerDescriptionList.Create;
  try
    if Assigned(OnInitActionManager) then
      OnInitActionManager(self)
    else
      DoDefaultInitActionManagerDescription;
    ListAm.InitActionManager(Am, PopUpMenu1, DoActionManagerEvent);

  finally
    ListAm.Free;
  end;

end;

procedure TFrameMikkoDoc.InitSumList(var VarList: TDocVariableList);
var
  i: Integer;
begin
  for i := 0 to VarList.Count - 1 do
    VarList.Value[i] := 0;
  SetSumMarked;
end;

procedure TFrameMikkoDoc.MyFilterDialogShow(Sender: TObject);
var
  i: Integer;
  s: String;
  k: Integer;
begin
  with  TDBGridEhSimpleFilterDialog(Sender) do
  begin
  s := Column.Field.AsString;
  k := Pos(',',s)*0;
  if k>0 then
    s := Copy(s,1,k-1);
    if ComboBox1.ItemIndex = 0 then
    begin
      i := ComboBox1.Items.IndexOf('Содержит');
      if i>-1 then
      begin
        ComboBox1.ItemIndex  := i;
        ComboBox1.Text := ComboBox1.Items[i];
        DBComboBoxEh1.Text     := Trim(s);
      end
      else
      begin
        i := ComboBox1.Items.IndexOf('Равно');
        ComboBox1.ItemIndex  := i;
        ComboBox1.Text := ComboBox1.Items[i];
        DBComboBoxEh1.Text     := s;
      end;
    end;
  end;


end;

procedure TFrameMikkoDoc.SetFilter(aIndex:Integer);
var
    oComp: TComponent;
    nSelectedIndex: Integer;
  I: Integer;
begin
  if aIndex>-1 then
  begin
    nSelectedIndex := -1;
    FilterIndex := aIndex;
    for I := 0 to FFmSetFilter.ListBox1.Items.Count-1 do
    begin
      if Integer(FFmSetFilter.ListBox1.Items.Objects[i])=FilterIndex then
      begin
        nSelectedIndex := i;
        Break;
      end;
    end;
  end
  else
  begin
    oComp := Parent;
    while Assigned(oComp) do
    begin
      if oComp is TForm then
      begin
        FFmSetFilter.SetForm(oComp);
        Break;
      end;
      oComp := TWinControl(oComp).Parent;
    end;
    if FFmSetFilter.ShowModal<>mrOk then
      Exit;
    FilterIndex :=  Integer(FFmSetFilter.ListBox1.Items.Objects[FFmSetFilter.ListBox1.ItemIndex]);
    nSelectedIndex := FFmSetFilter.ListBox1.ItemIndex;
  end;
  if nSelectedIndex>-1 then
    StatusBar1.Panels[0].Text := '  '+ FFmSetFilter.ListBox1.Items[nSelectedIndex];
  DoUnMarkAll;
  FDmMikkoDoc.SetFilter(FilterIndex, self);
end;

procedure TFrameMikkoDoc.SetFilterComment(oSb: TStatusBar);
begin
  oSb.SimpleText := '   ' + FFmSetFilter.Description;

end;

procedure TFrameMikkoDoc.SetSumMarked;
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

procedure TFrameMikkoDoc.SetUpForm;
begin
  FDmMikkoDoc.Doc.FmSetUp.ShowModal;
end;

end.
