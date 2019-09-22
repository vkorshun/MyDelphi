unit fm_selectfromquery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dm_mikkoads,ActnCtrls, DbGridEhVk,memTableEh, DB, adsdata, adsfunc, adstable,
  DataDriverEh, ComCtrls, Menus, DBGridEhGrouping, MemTableDataEh, ImgList,
  GridsEh, DBGridEh, ToolWin, ActnMan, Generics.Collections, ActionManagerDescription,
  PlatformDefaultStyleActnCtrls, ActnList;

const
  IDE_DOC_MARK         = 7;
  IDE_DOC_MARKALL      = 8;
  IDE_DOC_UNMARKALL    = 9;
  IDE_DOC_FIND         = 10;
  IDE_DOC_FINDNEXT     = 11;
  IDE_DOC_SELECT       = 14;
  IDE_DOC_TOEXCEL      = 22;

type
  TFmSelectFromQuery = class(TForm)
    ActionToolBar1: TActionToolBar;
    DBGridEhVkDoc: TDBGridEhVk;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    DataSource1: TDataSource;
    PopupMenu1: TPopupMenu;
    AdsQuery1: TAdsQuery;
    MemTableEh1: TMemTableEh;
    DataSetDriverEh1: TDataSetDriverEh;
    ActionManager1: TActionManager;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBGridEhVkDocAdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
      var Params: TColCellParamsEh; var Processed: Boolean);
    procedure DBGridEhVkDocKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEhVkDocGetCellParams(Sender: TObject; Column: TColumnEh;
      AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure DBGridEhVkDocDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
  private
    { Private declarations }
    FSelectedList : TList<Variant>;
    FKeyFields: String;
    procedure DoActionManagerEvent(Sender:TObject);
    procedure DoMark(bMark: Boolean);
    procedure DoMarkAll;
    procedure DoUnMarkAll;
  public
    { Public declarations }
    Constructor Create(aOwner:TComponent);override;
    procedure Prepare(aDm:TDmMikkoAds);
    function Select:Boolean;
    function GetKey: variant;
    property KeyFields:String read FKeyFields write FKeyFields;
    property SelectedList:TList<variant> read FSelectedList;
  end;

var
  FmSelectFromQuery: TFmSelectFromQuery;

implementation

{$R *.dfm}

{ TFmSelectFromQuery }

constructor TFmSelectFromQuery.Create(aOwner: TComponent);
begin
  Inherited;
  if (aOwner is TDmMikkoads) then
    Prepare(TDmMikkoAds(aOwner));
end;

procedure TFmSelectFromQuery.DBGridEhVkDocAdvDrawDataCell(
  Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh;
  const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
var
  m_key: variant;
begin
  begin
    m_key := GetKey;
    if FSelectedList.IndexOf(m_key)>=0 then
    begin
      if  (gdSelected in Params.State) and (gdFocused in Params.State)
      then begin
        Params.SuppressActiveCellColor := False;
        TDbGridEh(Sender).Canvas.Font.Color := clYellow;
        TDbGridEh(Sender).Canvas.Pen.Color := clGrayText;
      end else params.Font.Color := clBlue;
    end;
  end;
end;

procedure TFmSelectFromQuery.DBGridEhVkDocDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
var
  m_key: variant;
begin
  begin
    m_key := GetKey;
    with TDbGridEhVk(Sender) do
    if FSelectedList.IndexOf(m_key)>=0 then
    begin
      if (gdSelected in State) and (gdFocused in State)
      then begin
        Canvas.Font.Color := clYellow;
        Canvas.Pen.Color  := clGrayText;
      end else Canvas.Font.Color := clBlue;
      DefaultDrawColumnCell(Rect,DataCol,Column,State);
    end;
  end;

end;

procedure TFmSelectFromQuery.DBGridEhVkDocGetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
var
  m_key: variant;
begin
  begin
    m_key := GetKey;
    if FSelectedList.IndexOf(m_key)>=0 then
    begin
      if (gdSelected in State) and (gdFocused in State)
      then begin
        Font.Color := clYellow;
        Background := clGrayText;
      end;
    end;
  end;
end;

procedure TFmSelectFromQuery.DBGridEhVkDocKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (DbGridEhVkDoc.DataSource.State<> dsEdit) then
  begin
    if Key='*' then
    begin
      DoMark(False);
      Key := #0;
    end;
    if Key='+' then
    begin
      DoMarkAll;
      Key := #0;
    end;
    if Key='-' then
    begin
      DoUnMarkAll;
      Key := #0;
    end;
  end;
end;

procedure TFmSelectFromQuery.DoActionManagerEvent(Sender: TObject);
var
    Id: Integer;
begin
  Id := TAction(Sender).Tag;
  case Id of
    IDE_DOC_FIND:      DbGridEhVkDoc.Find(False);
    IDE_DOC_FINDNEXT:  DbGridEhVkDoc.Find(True);
    IDE_DOC_MARK:      DoMark(False);
    IDE_DOC_MARKALL:   DoMarkAll;
    IDE_DOC_UNMARKALL: DoUnMarkAll;
    IDE_DOC_SELECT:    ModalResult := MrOk;
    IDE_DOC_TOEXCEL:   DbGridEhVkDoc.OnAltP(DbGridEhVkDoc);
  end;

end;

procedure TFmSelectFromQuery.DoMark(bMark: Boolean);
var key: Variant;
    i:Integer;
begin
  if MemTableEh1.IsEmpty then
    Exit;
    key := GetKey;

  i:= FSelectedList.IndexOf(key);
  if (i>=0)  then
  begin
    if not bMark then
      FSelectedList.Delete(i);
//    AddMSum(False);
//    if Assigned(OnUnMark) then
//      OnUnMark(DbGridEhVkDoc);
  end
  else
    begin
      FSelectedList.Add(key);
//      AddMSum(True);
//      if Assigned(OnMark) then
//        OnMark(DbGridEhVkDoc);
    end;
  MemTableEh1.Next;
  if not bmark then
    if MemtableEh1.Eof then
      MemtableEh1.Prior
end;

procedure TFmSelectFromQuery.DoMarkAll;
var bm: TBookMark;
begin
  if MemTableEh1.IsEmpty then
    Exit;
  bm := MemTableEh1.GetBookmark;
  with MemTableEh1 do
  try
    DisableControls;
    First;
    while not Eof do
      DoMark(True);
  finally
    MemTableEh1.GotoBookmark(bm);
    MemTableEh1.FreeBookmark(bm);
    EnableControls;
  end;

end;

procedure TFmSelectFromQuery.DoUnMarkAll;
begin
  FSelectedList.Clear;
  DbGridEhVkDoc.Refresh;
end;

procedure TFmSelectFromQuery.FormCreate(Sender: TObject);
var ab: TActionBarItem;
    FListAm : TActionManagerDescriptionList;
begin

  FSelectedList := TList<Variant>.Create;

  //=============== Define actions ======================
  ab := ActionManager1.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  ActionManager1.Images := ImageList1;

  FListAm := TActionManagerDescriptionList.Create;
  try
    with FListAm do
    begin
      Items.Clear;
      AddDescription('doc2',IDE_DOC_FIND,'BITMAP_FIND','Поиск','F7');
      AddDescription('doc2',IDE_DOC_FINDNEXT,'BITMAP_FINDNEXT','Продолжение поиска','Shift+F7');
      AddDescription('doc2','SEPARATOR','EMPTY','','',tdPopUpOnly);
      AddDescription('doc4',IDE_DOC_MARK,'','Пометить строку  (*)','',tdPopUpOnly);
      AddDescription('doc4',IDE_DOC_MARKALL,'','Пометить все   (+)','',tdPopUpOnly);
      AddDescription('doc4',IDE_DOC_UNMARKALL,'','Снять всю пометку  (-)','',tdPopUpOnly);
      AddDescription('doc5','SEPARATOR','EMPTY','','');
      AddDescription('doc4',IDE_DOC_SELECT,'BITMAP_BIRD','Выбор','Enter');


      InitActionManager(ActionManager1,PopUpMenu1,DoActionManagerEvent);
    end;

  finally
    FListAm.Free;
  end;

end;

procedure TFmSelectFromQuery.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSelectedList);
end;

function TFmSelectFromQuery.GetKey: variant;
var sList: TStringList;
    i: Integer;
begin
  if not MemtableEh1.Active then
  begin
    Result := null;
    Exit;
  end;

  sList := TStringList.Create;
  try
    sList.Delimiter:=';';
    sList.Text := FkeyFields;
    if sList.Count=0 then
      Result := null
    else
    if sList.Count=1 then
      Result := MemTableEh1.FieldByName(sList[0]).Value
    else
    begin
      Result := VarArrayCreate([1,sList.count],varvariant);
      for I := 1 to sList.count do
        Result[i] := MemTableEh1.FieldByName(sList[i-1]).Value;
    end;
  finally
    sList.Free;
  end;

end;

procedure TFmSelectFromQuery.Prepare(aDm: TDmMikkoAds);
begin
  with AdsQuery1 do
  begin
    DatabaseName  := aDm.AdsConnection1.Name;
    AdsConnection := aDm.AdsConnection1;
    AdsTableOptions.AdsCharType := OEM;
    SourceTableType := ttAdsCdx;
  end;

end;

function TFmSelectFromQuery.Select: Boolean;
begin
  MemTableEh1.Active := False;
  AdsQuery1.Active := False;
  AdsQuery1.Open;
  MemTableEh1.Active := True;

  Result := ShowModal = mrOk;
  if Result and (FSelectedList.Count=0) then
    FSelectedList.Add(getKey);
end;

end.
