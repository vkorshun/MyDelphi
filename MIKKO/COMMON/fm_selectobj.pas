unit fm_selectobj;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, adsdata, adsfunc, adstable,  Menus, ComCtrls, Grids,
  DBGridEh, DBGridEhVk, StdCtrls, EditContext, dateVk, Buttons, ExtCtrls,
  GridsEh, doc.variablelist, DBGridEhGrouping, mikko_consts, ImgList,
   ActionManagerDescription, docdialog.fm_docdialog,
  PlatformDefaultStyleActnCtrls, ActnList, ActnMan, ToolWin, ActnCtrls,
  StdStyleActnCtrls, Rtti, MEditBox, dm_mikkoads;

const
  IDE_SEL_FIND     = 0;
  IDE_SEL_CONTINUE = 1;
  IDE_SEL_SELECT   = 2;
  IDE_SEL_CANCEL   = 3;

type
  TSelectDescription = class (TObject)
  private
    FSQL:TStringList;
    FParams:TParams;
    FAfterOpen: TDataSetNotifyEvent;
    FOld_AfterOpen: TDataSetNotifyEvent;
    FOnSelect: TDataSetNotifyEvent;
    FRetval: TDocVariableList;
  public
    bEdit: Boolean;
    Caption: String;
    KeyField: String;
    KeyFieldFromSearch: String;
    constructor Create;
    destructor Destroy;override;
    procedure AddParam(aParamName: String; aParamValue: Variant);


    property SQL:TStringList read FSQL;
    property Params:TParams read FParams;
    property Retval:TDocVariableList read FRetval;

    property AfterOpen: TDataSetNotifyEvent read FAfterOpen write FAfterOpen;
    property Old_AfterOpen: TDataSetNotifyEvent read FOld_AfterOpen write FOld_AfterOpen;
    property OnSelect: TDataSetNotifyEvent read FOnSelect write FOnSelect;
  end;

  TFmSelectObj = class(TForm)
    DBGridEhVk1: TDBGridEhVk;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    AdsQuery1: TAdsQuery;
    DataSource1: TDataSource;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ComboBox1: TComboBox;
    ActionManager1: TActionManager;
    ImageList1: TImageList;
    ActionToolBar1: TActionToolBar;

    procedure N1Click(Sender: TObject);
    procedure DBGridEhVk1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEhVk1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure AdsQuery1AfterOpen(DataSet: TDataSet);
    procedure N7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DBGridEhVk1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  Private
    { Private declarations }
    KeyField: String;
    EditContext: TEditContext;
//    sLocate: String;
    FbEdit: Boolean;
    FListKodg: TIntList;
    FListAction: TListActionManagerDescription;
    FDmMikkoAds: TDmMikkoAds;
    FDopFields: TStringList;
    FDopCaptions: TStringList;
//    procedure Find(bFirst:Boolean);
    procedure CheckPopUp(Key: Word; Shift: TShiftState);
    procedure DoExecuteAction(Sender: TObject);
    procedure Edit(bAdd: Boolean);
    procedure SetBedit(b:Boolean);
  public
    { Public declarations }
    Constructor Create(aOwner:TComponent);override;
    procedure Prepare(aDm:TDmMikkoads);
    function SelectObjectFromGroup(aKodg,aKodObj:Integer;aDopList:TIntList;aDopListKodg:TIntList):Integer;
    function SelectFromQuery(aParams: TSelectDescription):Integer;
    function SelectObjectFromQuery(Const sQuery, sCaption:String; aKodObj: Integer): Integer;
    procedure SetDmMikkoads(aDm:TDmMikkoads);
//    procedure SetItemDocControlLink(aLink:TItemDocControlLink);
    property bEdit:Boolean read FbEdit Write SetBedit;
    property DopFields:TStringList read FDopFields;
    property DopCaptions:TStringList read FDopCaptions;
    class function GetFmSelectObj(aDm:TDmMikkoads):TFmSelectObj;
  end;

  //============================= TSelectObjItemDocControlLink ===============
  TSelectObjItemDocControlLink = class(TItemDocControlLink)
  private
    Fkodg: Integer;
    FFmInternal: TFmSelectObj;
    FcQuery: String;
    FcCaption: String;
    procedure Setkodg(const Value: Integer);
    procedure SetcCaption(const Value: String);
    function GetDopCaptions: TStringList;
    function GetDopFields: TStringList;

  public
    constructor Create(aVariable:TDocVariable);override;
    destructor  Destroy; override;
    procedure DoDefaultMEditBoxButtonClick(Seneder:TObject);
    function  SelectObjGetValue(Sender:TObject):TValue;
    procedure SelectObjSetValue(Senedr:TObject; aValue:TValue);
    procedure SetControl(const aControl:TWinControl);override;
    property FmInternal:TFmSelectObj read FFmInternal;
    property cCaption: String  read FcCaption write SetcCaption;
    property cQuery:String read FcQuery write FcQuery;
    property kodg:Integer  read Fkodg write Setkodg;
    property DopFields:TStringList read GetDopFields;
    property DopCaptions:TStringList read GetDopCaptions;
  end;

var
  FmselectObj: TFmselectObj;

implementation

{$R *.dfm}
uses  IniFiles;


procedure TFmselectObj.AdsQuery1AfterOpen(DataSet: TDataSet);
var i: Integer;
begin
  with dataset do
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if UpperCase(Fields[i].fieldname)='NAME' then
      begin
        Fields[i].DisplayLabel := rs_Name;
        Fields[i].Index := 0;
      end
      else
        Fields[i].Visible := False;
    end;
    for I := 0 to FDopFields.Count-1 do
    begin
      with FieldByName(FDopFields[i]) do
      begin
        DisplayLabel := FDopCaptions[i];
        Index := i+1;
        Visible := True;
      end

    end;
  end;
end;

procedure TFmSelectObj.CheckPopUp(Key: Word; Shift: TShiftState);
var
  vShortCut: TShortCut;
  i: Integer;
begin
  {$ifdef  NOTACTIVEX}
    Exit;
  {$endif }
  vShortCut := ShortCut(Key,Shift);
  for I := 0 to PopUpMenu1.Items.Count-1 do
  begin
    if PopUpMenu1.Items[i].ShortCut=vShortCut then
    begin
      DoExecuteAction(PopUpMenu1.Items[i].Action);
     //      PopUpMenu1.Items[i].Action.Execute;
      Break;
    end;
  end;

end;

procedure TFmSelectObj.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex>-1 then
  with AdsQuery1 do
  begin
    Active := False;
    ParambyName('kodg').AsInteger := FListKodg[ComboBox1.ItemIndex];
    Open;
    Caption := ComboBox1.Items[ComboBox1.ItemIndex];
  end;
end;

constructor TFmSelectObj.Create(aOwner: TComponent);
begin
  Inherited Create(aOwner);
  if aOwner is TDmMikkoAds then
    SetDmMikkoads(TDmMikkoads(aOwner));
  FDopFields := TStringList.create;
  FDopCaptions := TStringList.create;
end;

procedure TFmselectObj.DBGridEhVk1DblClick(Sender: TObject);
begin
  ModalResult := MrOk;
end;

procedure TFmSelectObj.DBGridEhVk1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key<>0 then
    CheckPopUp(Key,Shift);

end;

procedure TFmselectObj.DBGridEhVk1KeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if not Assigned(EditContext) then
    Exit;

  if CharInSet(key,['A'..'Z']) or CharInSet(key,['a'..'z'])
    or CharInSet(key, ['А'..'Я']) or CharInSet(key , ['а'..'я'])
    or CharInSet(key , ['0'..'9'])
  then
  begin
   EditContext.Text := Key;
   EditContext.SetFocus;
  end;

end;

procedure TFmSelectObj.DoExecuteAction(Sender: TObject);
var mAction: TAction;
begin

  mAction := TAction(Sender);
  case mAction.Tag of
    //IDE_CLIENT_ADD:   EditClientList(True);
    //IDE_CLIENT_EDIT:  EditClientList(False);
    //IDE_CLIENT_DELETE:  ShowMessage('Access denied.') ;
    //IDE_CLIENT_REFRESH: FDmClientList.FullRefresh(0);
    //IDE_CLIENT_PRINT: PrintBlank;
    //IDE_CLIENT_SENDMAIL: SendMail;
    IDE_SEL_SELECT: ModalResult := mrOk;
    IDE_SEL_FIND:   DbGridEhVk1.Find(False);
    IDE_SEL_CONTINUE:   DbGridEhVk1.Find(True);
    IDE_SEL_CANCEL: Modalresult := mrCancel;
  end;
end;

procedure TFmselectObj.Edit(bAdd: Boolean);
var Fm: TFmDocDialog;
    sname: String;
    nkod: Integer;
begin
  Fm := TFmDocDialog.Create(Self);
  try
  with Fm do
  begin
    NewControl(TEdit,rs_Name,60,'name');
    if bAdd then
    begin
      Caption := rs_Add;
    end
    else
    begin
      Caption := rs_Edit;
      Items.ValueByName['name'] := AdsQuery1.FieldByName('name').AsString;
    end;
    if ShowModal= mrOk then
    begin
      sName := Items.ValueByName['name'];
      if Trim(sname)<>'' then
      begin
         if bAdd then
         begin
           nkod := FDmMikkoAds.AddClient(AdsQuery1.FieldByName('kodg').AsInteger,sName);
           AdsQuery1.DisableControls;
           AdsQuery1.Close;
           AdsQuery1.Open;
           AdsQuery1.Locate('kodkli',nkod,[]);
           AdsQuery1.EnableControls;
         end
         else
         begin
           nKod := AdsQuery1.FieldByName('kodkli').AsInteger;
           FDmMikkoAds.EditClient(nkod,sName);
           AdsQuery1.DisableControls;
           AdsQuery1.Close;
           AdsQuery1.Open;
           AdsQuery1.Locate('kodkli',nkod,[]);
           AdsQuery1.EnableControls;
         end;
      end;

    end;

  end;
  finally
    Fm.Free;
  end;
end;

{procedure TFmselectObj.Find(bFirst: Boolean);
var s: String;
    nr: TBookmark;
begin
  s:= sLocate;
  nr := AdsQuery1.GetBookmark;
  AdsQuery1.DisableControls;
  try
  if bFirst then
  begin
    if not InputQuery('Поиск','Строка поиска',s) then
    begin
//      AdsQuery1.EnableControls;
//      AdsQuery1.FreeBookmark(nr);
      Exit;
    end
    else
      AdsQuery1.First;
    sLocate := s;
    if not AdsQuery1.Locate(keyField,s,[loCaseInsensitive]) then
    begin
      AdsQuery1.GotoBookmark(nr);
      ShowMessage('Не найдено!');
    end;
  end;
  finally
    AdsQuery1.FreeBookmark(nr);
    AdsQuery1.EnableControls;
  end;
end;
 }
procedure TFmselectObj.FormCreate(Sender: TObject);
begin
  width := Screen.Width div 2;
  Height:= Screen.Height-40;
  Left  := width;
  Top   := 10;
  Panel1.Caption := '';
  FListAction := TListActionManagerDescription.Create;
  with FListAction do
  begin
    AddDescription('doc1',IDE_SEL_SELECT,'BITMAP_MARK','Выбор','Enter');
    AddDescription('doc1',IDE_SEL_CANCEL,'','Отмена','ESC',tdPopUpOnly);
    AddDescription('doc1','SEPARATOR','EMPTY','','');
    AddDescription('doc2',IDE_SEL_FIND,'BITMAP_FIND',rs_Find,'F7');
    AddDescription('doc2',IDE_SEL_CONTINUE,'BITMAP_FINDNEXT',rs_Continue,'Shift+F7');
  end;
  FListAction.InitActionManager(ActionManager1,PopUpMenu1,DoExecuteAction);

end;

procedure TFmSelectObj.FormDestroy(Sender: TObject);
begin
//  MessageBox(Application.Handle,'QQ','QQ',0);
  FreeAndNil(FDopFields);
  FreeAndNil(FDopCaptions);
end;

class function TFmselectObj.GetFmSelectObj(aDm:TDmMikkoAds): TFmSelectObj;
begin
  FmSelectObj:= TFmSelectObj.Create(aDm);
  Result :=  FmSelectObj;
end;

procedure TFmselectObj.N1Click(Sender: TObject);
begin
  ModalResult := MrOk;
end;

procedure TFmselectObj.N3Click(Sender: TObject);
begin
  //Find(True);
  DbGridEhVk1.Find(False);
end;

procedure TFmselectObj.N4Click(Sender: TObject);
begin
  //Find(False);
  DbGridEhVk1.Find(True);
end;

procedure TFmselectObj.N5Click(Sender: TObject);
begin
  Edit(True);
end;

procedure TFmselectObj.N6Click(Sender: TObject);
begin
  Edit(False);
end;

procedure TFmselectObj.N7Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFmSelectObj.Prepare(aDm: TDmMikkoads);
begin
  SetDmMikkoAds(aDm);
end;

function TFmSelectObj.SelectObjectFromGroup(aKodg,aKodObj:Integer;aDopList:TIntList;aDopListKodg:TIntList): Integer;
var i:Integer;
begin
  Result   := 0;
  keyField := 'name';
  bEdit    := aKodg= KODG_ADDOF;
  Caption := CoalEsce(FDmMikkoAds.QueryValue('select name FROM gruppa WHERE kodg='+IntToStr(aKodg)),'');
  with AdsQuery1 do
  begin
    Active := False;
    SQl.Clear;
    SQl.Add(' SELECT * FROM client WHERE kodg=:kodg ');
    if Assigned(aDopList) and (aDopList.Count>0)then
    begin
      SQL.Add(' OR kodkli in (');
      for I := 0 to aDopList.Count - 1 do
      begin
        SQL.Add(IntToStr(aDopList[i]));
        if i=aDopList.Count - 1 then
          SQL.Add(')')
        else
          SQL.Add(',');
      end;
    end;
    SQl.Add('ORDER BY NAME');
    ParamByName('kodg').AsInteger := aKodG;
    Open;

    if aKodObj>0 then
      Locate('kodkli',aKodObj,[]);

    EditContext:= TEditContext.Create(self);
    with EditContext do
    begin
      Parent := StatusBar1;
      Left := 1;
      Width :=StatusBar1.Panels[0].Width-1;
      Visible := False;
      KeyField:='name';
      DataSource := DbGridEhVk1.DataSource;
      ActiveControl := DbGridEhVk1;
    end;

    if Assigned(aDopListKodg) then
    begin
      FListKodg := aDopListKodg;
      ComboBox1.Items.Clear;
      for I := 0 to FListKodg.Count - 1 do
      begin
        ComboBox1.Items.Add(  CoalEsce(FDmMikkoAds.QueryValue('select name FROM gruppa WHERE kodg='+IntToStr(FListKodg[i])),''));
      end;
      ComboBox1.Visible := True;
      ComboBox1.ItemIndex := 0;
    end;

    if ShowModal=mrOk then
      Result := FieldByName('kodkli').AsInteger;

    ComboBox1.Visible := False;
    FListKodg := nil;

  end;
end;

function TFmselectObj.SelectObjectFromQuery(Const sQuery, sCaption:String; aKodObj: Integer): Integer;
begin
  Result   := 0;
  keyField := 'name';
  bEdit    := False;
  Caption := sCaption;
  with AdsQuery1 do
  begin
    Active := False;
    SQl.Clear;
    SQl.Add(sQuery);
    Open;

    if aKodObj>0 then
      Locate('kodkli',aKodObj,[]);

    EditContext:= TEditContext.Create(self);
    with EditContext do
    begin
      Parent := StatusBar1;
      Left := 1;
      Width :=StatusBar1.Panels[0].Width-1;
      Visible := False;
      KeyField:='name';
      DataSource := DbGridEhVk1.DataSource;
      ActiveControl := DbGridEhVk1;
    end;


    if ShowModal=mrOk then
      Result := FieldByName('kodkli').AsInteger;
  end;
end;



function TFmselectObj.SelectFromQuery(aParams:TSelectDescription): Integer;
var i: Integer;
    FIni: TIniFile;
//    form_width: Integer;
begin
  FIni := nil;
  Result   := 0;
  keyField := aParams.KeyField;
  bEdit    := aParams.bEdit;
  Caption  := aParams.Caption;
  with AdsQuery1 do
  begin
    Active := False;
    SQl.Clear;
    SQl.Add(aParams.FSQL.Text);
    for I := 0 to aParams.FParams.Count - 1 do
      ParamByName(aParams.FParams[i].name).Value := aParams.FParams.Items[i].Value;
    aParams.Old_AfterOpen := AfterOpen;
    AfterOpen   := aParams.AfterOpen;
    try
    Open;

    EditContext:= TEditContext.Create(self);
    with EditContext do
    begin
      Parent := StatusBar1;
      Left := 1;
      Width :=StatusBar1.Panels[0].Width-1;
      Visible := False;
      KeyField:= aParams.KeyFieldFromSearch;
      DataSource := DbGridEhVk1.DataSource;
      ActiveControl := DbGridEhVk1;
    end;

    //=========== Before Show =============
    FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
//    form_width := FIni.ReadInteger('SELECTOBJECTS','FormWidth',0);

    {if form_width > 0 then
    begin
      Width := Form_Width;
      DbGridEhVk1.AutoFitColWidths := False;
      for I := 0 to DbGridEhVk1.Columns.Count - 1 do
      begin
        DbGridEhVk1.Columns[i].Width := FIni.ReadInteger('SELECTOBJECTS','COLUMNS'+IntToStr(i),10);
      end;
    end; }
    //=========== =============

    if ShowModal=mrOk then
    begin
      Result := 1;
      if Assigned(aParams.OnSelect) then
        aParams.OnSelect(AdsQuery1);
    end;
    finally

      // Save Settings
{      FIni.WriteInteger('SELECTOBJECTS','FormWidth',Width);
      for I := 0 to DbGridEhVk1.Columns.Count - 1 do
      begin
        FIni.WriteInteger('SELECTOBJECTS','COLUMNS'+IntToStr(i),DbGridEhVk1.Columns[i].Width);
      end;}
      FreeAndNil(FIni);

      AfterOpen := aParams.Old_AfterOpen;
    end;
  end;

end;




procedure TFmselectObj.SetBedit(b: Boolean);
begin
  FbEdit := b;
  SpeedButton1.Enabled := FbEdit;
  SpeedButton2.Enabled := FbEdit;

end;

procedure TFmSelectObj.SetDmMikkoads(aDm: TDmMikkoads);
begin
  FDmMikkoads := aDm;
  if not AdsQuery1.Active  then
  begin
    AdsQuery1.AdsConnection := FDmMikkoads.AdsConnection1;
    AdsQuery1.DatabaseName := FDmMikkoads.AdsConnection1.Name ;
  end;
end;

procedure TFmselectObj.SpeedButton1Click(Sender: TObject);
begin
  Edit(True);
end;

procedure TFmselectObj.SpeedButton2Click(Sender: TObject);
begin
  Edit(False);
end;

procedure TFmselectObj.SpeedButton4Click(Sender: TObject);
begin
//  Find(True);
  DbGridEhVk1.Find(False);
end;

procedure TFmselectObj.SpeedButton5Click(Sender: TObject);
begin
//  Find(False);
  DbGridEhVk1.Find(True);
end;

{ TSelectFromQueryParam }

constructor TSelectDescription.Create;
begin
  FSQL := TStringList.Create;
  FParams := TParams.Create;
  Fretval := TDocVariableList.Create(nil);
end;

destructor TSelectDescription.Destroy;
begin
  FreeAndNil(FSQL);
  FreeAndNil(FParams);
  FreeAndNil(FRetval);
end;

procedure TSelectDescription.AddParam(aParamName: String;
  aParamValue: Variant);
var p: TParam;
begin
  p := TParam.Create(FParams);
  p.Name := aParamName;
  p.Value := aParamValue;
  FParams.AddParam(p);
end;

{ TSelectObjItemDocControlLink }

constructor TSelectObjItemDocControlLink.Create(aVariable: TDocVariable);
begin
  inherited Create(aVariable);
  FFmInternal := TFmSelectObj.Create(aVariable.Owner.Owner);
  OnGetValue := SelectObjGetValue;
  OnSetValue := SelectObjSetValue;
//  MEditBox.OnButtonClick := DoDefaultMEditBoxButtonClick;
end;

destructor TSelectObjItemDocControlLink.Destroy;
begin
  FreeAndNil(FFmInternal);
  inherited;
end;

procedure TSelectObjItemDocControlLink.DoDefaultMEditBoxButtonClick(
  Seneder: TObject);
var
  kodkli: Integer;
begin
  kodkli := Docvariable.AsInteger;
  if length(FcQuery)=0 then
    DocVariable.AsInteger := FmInternal.SelectObjectFromGroup(Fkodg,kodkli,nil,nil)
  else
    DocVariable.AsInteger := FmInternal.SelectObjectFromQuery(FcQuery, FcCaption, kodkli);
  GetMEditBox.Text := FmInternal.FDmMikkoAds.GetObjectName(Docvariable.AsInteger)
end;

function TSelectObjItemDocControlLink.GetDopCaptions: TStringList;
begin
  Result := FFmInternal.DopCaptions;
end;

function TSelectObjItemDocControlLink.GetDopFields: TStringList;
begin
  Result := FFmInternal.DopFields;
end;

function TSelectObjItemDocControlLink.SelectObjGetValue(
  Sender: TObject): TValue;
begin
  Result := DocVariable.VarValue;
end;

procedure TSelectObjItemDocControlLink.SelectObjSetValue(Senedr: TObject;
  aValue: TValue);
begin
  if Assigned(FmInternal.FDmMikkoAds) then
    GetMEditBox.Text := FmInternal.FDmMikkoAds.GetObjectName(Docvariable.AsInteger)
  else
    GetMEditBox.Text := '';
end;

procedure TSelectObjItemDocControlLink.SetcCaption(const Value: String);
begin
  FcCaption := Value;
end;

procedure TSelectObjItemDocControlLink.SetControl(const aControl: TWinControl);
begin
  if not (aControl is TMEditBox)  then
    Raise Exception.Create('Control is not TItemmeditBox');
  oType := TMEditBox;
  inherited;
  GetMEditBox.OnButtonClick := DoDefaultMEditBoxButtonClick;
end;

procedure TSelectObjItemDocControlLink.Setkodg(const Value: Integer);
begin
  Fkodg := Value;
end;

initialization
  FmSelectObj := nil;

end.
