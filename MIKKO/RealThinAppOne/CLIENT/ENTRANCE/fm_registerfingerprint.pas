unit fm_registerfingerprint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Grids, DBGridEh, DBGridEhVk, DB, StdCtrls,
  EditContext, ImgList, IniFiles, fasapi, DateVk, fmVkDocDialog, GridsEh, doc.variablelist,
  DBGridEhGrouping, dm_mikkoserver, Menus, ToolWin, ActnMan, ActnCtrls,
  PlatformDefaultStyleActnCtrls, ActnList, ActionManagerDescription, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, DBAxisGridsEh, System.Actions, EhLibVCL;

const
  SZ_USERITEM = 12;

  IDE_EDIT     = 0;
  IDE_DELETE   = 1;
  IDE_FIND     = 2;
  IDE_FINDNEXT = 3;
  IDE_REFRESH  = 4;
  IDE_IDENTIFICATION = 5;
type
{  TSotrud = class(TObject)
  public
    Sotrud: Integer;
    List: TIntList;
    constructor Create;
    destructor Destroy;override;
  end; }

{  TSotrudList = Class(TObject)
  private
    List:TList;
    procedure SetItem(aIndex:Integer;aSotrud:TSotrud);
    function  GetItem(aIndex:Integer):TSotrud;
  public
    constructor Create;
    destructor  Destroy;override;
    procedure Add(aSotrud:TSotrud);
    procedure Deltete(aIndex:Integer);
    procedure Clear;
    property  Items[i:Integer]:TSotrud read GetItem write SetItem;
    function  IndexOfSotrud(aKod:Integer):Integer;
  end;}

  TFmRegisterFingerPrint = class(TForm)
    DBGridEhVk1: TDBGridEhVk;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    DataSource1: TDataSource;
    Image1: TImage;
    btnRegistration: TButton;
    Panel2: TPanel;
    EditContext1: TEditContext;
    Button1: TButton;
    ImageList1: TImageList;
    BtnUnRegister: TButton;
    ActionManager1: TActionManager;
    ActionToolBar1: TActionToolBar;
    ImageList2: TImageList;
    PopupMenu1: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure btnRegistrationClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBGridEhVk1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure BtnUnRegisterClick(Sender: TObject);
    procedure DBGridEhVk1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
//    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FIni: TIniFile;
    FingerId: Byte;
    FCounterCb :Integer;
    FKodKli: Integer;
    FActList: TListActionManagerDescription;
    abarcode: array [0..13] of ansichar;
    procedure DefineActionManager;
    procedure DoExecuteAction(Sender:TObject);
    procedure InitActionList;
    procedure Internalrefresh;
    function  Login(const aPassword:String):Boolean;
//    procedure Normal;
    procedure Registration;
    procedure UnRegistration;

  public
    { Public declarations }
//    ListSotrud: TSotrudList;
//    procedure SetConnect(aP:String);
//    procedure SetDbgColumns;
    procedure Identification;
    class procedure DoRegistration;
//    procedure ReadFAS;
  end;

var
  FmRegisterFingerPrint: TFmRegisterFingerPrint;

implementation

{$R *.dfm}
uses jpeg, fm_registration,
 DbGridEhImpExp, dm_registerfingerprint;

procedure TFmRegisterFingerPrint.btnRegistrationClick(Sender: TObject);
begin
//  DmRegisterFingerPrint.UnRegistration;
  Registration;
end;

procedure TFmRegisterFingerPrint.BtnUnRegisterClick(Sender: TObject);
begin
  Unregistration;
end;

procedure TFmRegisterFingerPrint.Button1Click(Sender: TObject);
begin
  Identification;
end;


procedure TFmRegisterFingerPrint.DBGridEhVk1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then
    if FCounterCb=13 then
    begin
      try
        FKodkli := StrToInt(Copy(String(StrPas(aBarCode)),2,11));
        if DmRegisterFingerPrint.MemTableEhDc167.Locate('sotrud',FKodkli,[]) then
          Registration;
      finally
        FillChar(abarcode,13,#0);
        FCounterCb := 0;
      end;
    end;

  if Key=VK_F2 then
  begin
    SaveDBGridEhToExportFile(TDbGridEhExportAsXLS,DbGridEhVk1,'d:\tmp.xls',True);
  end;


end;

procedure TFmRegisterFingerPrint.DBGridEhVk1KeyPress(Sender: TObject;
  var Key: Char);
begin
  if CharInSet(AnsiChar(key), ['A'..'Z']) or CharInSet(key, ['a'..'z'])
    or ((key>='А') and (Key<='Я')) or ((key>='а') and (Key<='я'))
  then
  begin
   EditContext1.Visible := True;
   EditContext1.Text := Key;
   EditContext1.SetFocus;
  end
  else
    if CharInSet(key, ['0'..'9']) then
      if FCounterCb<13 then
      begin
        abarcode[FCounterCb] := AnsiChar(key);
        Inc(FCounterCb);
      end
      else
      begin
      // Сброс
        FCounterCb := 0;
        FillChar(abarcode,13,#0);
      end;

end;

procedure TFmRegisterFingerPrint.DefineActionManager;
var ab: TActionBarItem;
begin
  ab := ActionManager1.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  ActionManager1.Images := ImageList2;
  InitActionList;
  FActList.InitActionManager(ActionManager1,PopUpMenu1,DoExecuteAction);

end;

procedure TFmRegisterFingerPrint.DoExecuteAction(Sender:TObject);
var mAction: TAction;
begin

  mAction := TAction(Sender);
  case mAction.Tag of
    IDE_EDIT:   Registration;
    IDE_DELETE: UnRegistration;
    IDE_IDENTIFICATION: Identification;
    IDE_FIND:     DbGridEhVk1.Find(False);
    IDE_FINDNEXT: DbGridEhVk1.Find(True);
    IDE_REFRESH:  DmRegisterFingerPrint.Refresh167;
  end;

end;

procedure TFmRegisterFingerPrint.FormCreate(Sender: TObject);
var  sPassword: String;
begin


  FCounterCb := 0;
  FillChar(abarcode,13,#0);

  EditContext1.Parent := statusBar1;
  EditContext1.Top := 1;
  Caption := 'Регистрация отпечатка пальца для проходной';
  Panel1.Caption := '';
  FIni := TIniFile.Create(Copy(Application.ExeName,1,length(Application.ExeName)-3)+'ini');
  sPassword := FIni.ReadString('SET','password','');
{  if not Login(sPassword) then
     Halt;}



//  SetConnect(FIni.ReadString('SET','DIRCOMMON','d:\mikko.ads\common'));
//  FFasServer := AnsiString(FIni.readString('SET','fasserver',''));
  DmRegisterFingerPrint := TDmRegisterFingerPrint.Create(self);
{  nPlace := FIni.ReadInteger('SET','place',0);
  case nPlace of
    0: DmRegisterFingerPrint.Place := tpMikko;
    1: DmRegisterFingerPrint.Place := tpBelgorod;
  end;
 }

  DataSource1.DataSet :=  DmRegisterFingerPrint.MemTableEhDc167;
  DmRegisterFingerPrint.Refresh167;
//  SetDbgColumns;


  Image1.Picture.RegisterFileFormat('jpg','JPG',TJPEGimage);
{  BtnList := TSpeedButtonList.Create;
  BtnNames := TStringList.Create;
  try
    BtnList.AddDefinition('Find','Поиск','F7');
    BtnList.AddDefinition('Continue','Продолжение поиска','Shift-F7');
    BtnList.AddDefinition('EMPTY','','');
    BtnList.AddDefinition('Filter','Фильтр','');
    BtnList.AddDefinition('Refresh','Перечитать','');
    BtnList.InitList(Panel2,BtnList.DefList);
    BtnList.SetOnClick(SpeedButtonClick);
  finally
    BtnNames.Free;
  end; }
  FActList := TListActionManagerDescription.Create;
  DefineActionManager;
//  ListSotrud := TSotrudList.Create;
  //ReadFAS;
end;

procedure TFmRegisterFingerPrint.FormDestroy(Sender: TObject);
begin
  DataSource1.DataSet := nil;
//  FreeAndNil(ListSotrud);
//  BtnList.Free;
  FActList.Free;
  Inherited;
end;

procedure TFmRegisterFingerPrint.Identification;
begin
  if not Assigned(Fmregistration) then
    FmRegistration := TFmregistration.Create(Application);
  FmRegistration.IdUser := DmRegisterFingerPrint.MemTableEhDc167.FieldByName('sotrud').AsInteger;
  FmRegistration.cUserName := AnsiString(DmRegisterFingerPrint.MemTableEhDc167.FieldByName('name').AsString);
  Fmregistration.bIdentification := True;
  Fmregistration.Prepare('');
  try
    if FmRegistration.showModal=mrOk
      then
    begin
      if FmRegistration.Sotrud.kodkli>0 then
        ShowMessage( FmRegistration.Sotrud.name)
        //DmMikkoServer.Server.QueryValue('SELECT name FROM client WHERE kodkli='+
        //   IntToStr(FmRegistration.IdUser)))
      else
        ShowMessage('Ошибка идентификации!');
    end;
  finally
//    FreeAndNil(FmRegistration);
  end;
end;

procedure TFmRegisterFingerPrint.InitActionList;
begin
  with FActList do
  begin
    Items.Clear;
    AddDescription('doc1',IDE_EDIT,'BITMAP_EDIT','Регистрировать отпечаток','F4');
    AddDescription('doc1',IDE_DELETE,'BITMAP_DELETE','Удалить регистрацию','Del');
    AddDescription('doc1',IDE_IDENTIFICATION,'BITMAP_USER_MALE16','Идентификация','F9');
    AddDescription('doc1','SEPARATOR','EMPTY','','');
    AddDescription('doc2',IDE_FIND,'BITMAP_FIND','Поиск','F7');
    AddDescription('doc2',IDE_FINDNEXT,'BITMAP_FINDNEXT','Продолжение поиска','Shift+F7');
    AddDescription('doc4',IDE_REFRESH,'BITMAP_REFRESH','Обновить','ALT+R');
  end;

//  if DmFinger.Place= tpMikko then
//    FBtnList.AddDefinition('Bitmap_date','График','F10');

end;

procedure TFmRegisterFingerPrint.Internalrefresh;
begin
  DmRegisterFingerPrint.Refresh167;
end;

function TFmRegisterFingerPrint.Login(const aPassword: String): Boolean;
var FmLogin: TVkDocDialogFm;
begin

{  // Временно отключено
  Result := True;
  Exit;
 }
  Result := False;
  FmLogin := TVkDocDialogFm.Create(Application);
  try
    FmLogin.NewControl(TEdit,'Пароль',20,'edpassword');
    FmLogin.DoCenter(nil);
    while not Result do
    with FmLogin do
    begin
      TEdit(BindingList.VkVariableBinding['edpassword'].oControl).PasswordChar:='*';
      Caption := 'Вход в программу';
      if ShowModal =MrOk then
      begin
         Result := FmLogin.InternalVariables.Value[0]= aPassword;
         if not Result then
           ShowMessage('Не верный пароль!');
      end
      else
        Break;
    end;
  finally
    FmLogin.Free;
  end;
end;

class procedure TFmRegisterFingerPrint.DoRegistration;
begin
  FmRegisterFingerPrint := TFmRegisterFingerPrint.Create(Application);
  if FmRegisterFingerPrint.Login('mikko2010') then
    FmRegisterFingerPrint.ShowModal;

end;

{procedure TFmRegisterFingerPrint.Normal;
var s: AnsiString;
    iDataSize: Cardinal;
    i: Cardinal;
    buf:array[0..6] of byte;
    p:PAnsiChar;
    pdata:PInt;
begin
  s := AnsiString(FIni.readString('SET','fasserver',''))+#0;
  FASInitialize(PAnsiChar(s),4900);
  DmregisterFingerPrint.QrDc000167.DisableControls;
  iDataSize := 0;
  FASGetSizeOfUserList(100,iDataSize);
  p := PAnsiChar(StrAlloc(iDataSize+1));
  try
    FasGetUserList(PByte(p));
    FillChar(buf,7,#0);
    i:=0;
    while i<(idataSize-1) do
    begin
      pdata := pInt(@p[i]);
      with DmregisterFingerPrint.QrDc000167 do
      begin
        if Locate('sotrud',varArrayOf([pdata^]),[]) then
          DmregisterFingerPrint.Registration;
      end;
      i:= i+ SZ_USERITEM;
    end;

  finally
    StrDispose(p);
    FasTerminate();
    DmregisterFingerPrint.QrDc000167.EnableControls;
  end;
end;  }

{procedure TFmRegisterFingerPrint.ReadFAS;
var iDataSize: Cardinal;
    i: Cardinal;
    buf:array[0..6] of byte;
    p:PAnsiChar;
    pdata:PInt;
    oSotrud: TSotrud;
    k: Integer;
begin
  FASInitialize(PAnsiChar(FFasServer+#0),4900);
  DmregisterFingerPrint.QrDc000167.DisableControls;
  iDataSize := 0;
  FASGetSizeOfUserList(100,iDataSize);
  p := PAnsiChar(StrAlloc(iDataSize+1));
  try
    FasGetUserList(PByte(p));
//    FillChar(p^,iDataSize+1,#0);
    FillChar(buf,7,#0);
    i:=0;
//    New(pdata);
    while (idatasize>0) and (i<(idataSize-1)) do
    begin
      pdata := pInt(@p[i]);
      k := ListSotrud.IndexOfSotrud(pdata^);
      if k>0 then
        oSotrud := ListSotrud.Items[k]
      else
      begin
        oSotrud := TSotrud.Create;
        ListSotrud.Add(oSotrud);
        oSotrud.Sotrud := pData^;
      end;
      oSotrud.List.Add(pByte(@p[i+6])^);
      i:= i+ SZ_USERITEM;
    end;

  finally
//    Dispose(pdata);
    StrDispose(p);
    FasTerminate();
    DmregisterFingerPrint.QrDc000167.EnableControls;
  end;
end; }

procedure TFmRegisterFingerPrint.registration;
begin
  if DmRegisterFingerPrint.MemTableEhDc167.FieldByName('isfinger').AsInteger=3 then
    Exit;


  FingerId := 6;
  if not Assigned(Fmregistration) then
    FmRegistration := TFmregistration.Create(Application);

  with FmRegistration do
  begin
    IdUser    := DmRegisterFingerPrint.MemTableEhDc167.FieldByName('sotrud').AsInteger;
    cUserName := AnsiString(DmRegisterFingerPrint.MemTableEhDc167.FieldByName('name').AsString);
    FingerId  := Self.FingerId;
    Caption   := String(FmRegistration.cUserName);
    bIdentification := False;
  end;
  FmRegistration.Prepare('');
  if FmRegistration.showModal=mrOk then
  begin
  // Отметка в базе
    DmRegisterFingerPrint.registration;
    //oSotrud.List.Add(FingerId);
    DbGridEhVk1.SetFocus;
    DbGridEhVk1.refresh;
  end;
end;



procedure TFmRegisterFingerPrint.UnRegistration;
begin
  // before delete
  if DmRegisterFingerPrint.MemTableEhDc167.FieldByName('isfinger').AsInteger>0 then
  begin
    if MessageDlg('Удалить регистрацию '+
      DmRegisterFingerPrint.MemTableEhDc167.FieldByName('name').AsString,
      mtConfirmation,[mbYes,mbNo],0)<>mrYes then
      Exit;
  end
  else
    Exit;
  DmMikkoServer.Server.DeleteFingerUser(DmRegisterFingerPrint.MemTableEhDc167.FieldByName('sotrud').AsInteger);
  DmRegisterFingerPrint.UnRegistration;
end;

{ TSotrud }

{constructor TSotrud.Create;
begin
  Inherited ;
  sotrud := 0;
  List := TIntList.Create;
end;

destructor TSotrud.Destroy;
begin
  FreeAndNil(List);
end; }

{ TSotrudList }

{procedure TSotrudList.Add(aSotrud: TSotrud);
begin
  List.Add(aSotrud);
end;

procedure TSotrudList.Clear;
var i: Integer;
begin
  for I := 0 to List.Count - 1 do
    Items[i].Free;
  List.Clear;
end;

constructor TSotrudList.Create;
begin
  List := TList.Create;
end;

procedure TSotrudList.Deltete(aIndex: Integer);
begin
  Items[aIndex].Free;
  List.Delete(aIndex);
end;

destructor TSotrudList.Destroy;
begin
  Clear;
  List.Free;
end;

function TSotrudList.GetItem(aIndex:Integer): TSotrud;
begin
  Result := TSotrud(List[aIndex]);
end;

function TSotrudList.IndexOfSotrud(aKod: Integer): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
    if Items[i].Sotrud= aKod then
    begin
      Result := i;
      Break;
    end;

end;

procedure TSotrudList.SetItem(aIndex:Integer;aSotrud: TSotrud);
begin
  List[aIndex] := aSotrud;
end;
 }
end.
