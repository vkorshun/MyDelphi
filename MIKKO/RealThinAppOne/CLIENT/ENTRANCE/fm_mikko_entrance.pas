
unit fm_mikko_entrance;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FingerPrintReader, FasApi, ftrApi, inifiles, datevk, ActionManagerDescription,
  ComCtrls, ExtCtrls, Grids, DBGridEh, DBGridEhVk, DB, ImgList, Menus,  fm_setfilter,  GridsEh,
   DBGridEhGrouping, MMSystem,
  Rtti,  ToolWin, ActnMan, ActnCtrls, PlatformDefaultStyleActnCtrls,
  ActnList, syncobjs, EhLibCDS, fm_registerfingerprint, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  DBAxisGridsEh, soundplayerentrance, sotrudinfo, rtcinfo, rtcTypes,
  System.Actions, EhLibVCL ;//, DbugIntf;


const
  WM_BARCODE = WM_USER +101;
  WM_FINGER  = WM_USER +112;
  WM_SCANER  = WM_USER +113;
  WM_ENROLL  = WM_USER +114;
  WM_REFRESH = WM_USER +115;
  WM_CHECKPOS = WM_USER + 116;
  WM_DATASETOPEN = WM_USER + 117;

  IDE_EDIT      = 1;
  IDE_DELETE    = 2;
  IDE_FIND      = 3;
  IDE_FINDNEXT  = 4;
  IDE_FILTER    = 5;
  IDE_REFRESH   = 6;
  IDE_SCAN      = 7;
  IDE_RECONNECT = 8;
  IDE_SETUP     = 9;
  IDE_REGISTER  = 10;



type

  TFmMikko_Entrance = class(TForm)
    DBGridEhVk1: TDBGridEhVk;
    Panel1: TPanel;
    DataSource1: TDataSource;
    ImageList1: TImageList;
    Panel2: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    PopupMenu: TPopupMenu;
    nAppend: TMenuItem;
    nEdit: TMenuItem;
    nDelete: TMenuItem;
    N9: TMenuItem;
    nFind: TMenuItem;
    nContinue: TMenuItem;
    N1: TMenuItem;
    nFilter: TMenuItem;
    Label3: TLabel;
    N2: TMenuItem;
    nSetting: TMenuItem;
    nScaner: TMenuItem;
    ActionManager1: TActionManager;
    ActionToolBar1: TActionToolBar;
    ImageList2: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckState;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DBGridEhVk1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord;
      Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
  private
    { Private declarations }
    bCancel: Boolean;
    FirstCaption: String;
    fr: TFingerPrintReader;
    //Fkodkli: Integer;
    FSotrudInfo: TSotrudInfo;
    FGrTimeOut: TDateTime;
    Fdatatime: TDateTime;
    Monitor: Integer;
    sbarcode: AnsiString;
    fasserver:AnsiString;
    FCurdoc: Integer;

    FActList: TListActionManagerDescription;
    EnrollBuf: array of byte;
    EnrollEvent: TEvent;
    EntranceSoundPlayer: TEntranceSoundPlayer;

    procedure DefineActionmanager;
    procedure DoBarcode;
    procedure DoEnroll(Sender:TObject);
    procedure DoExecuteaction(Sender:TObject);
    procedure DoRegistration;
    procedure InitActionList;
    procedure InitScaner;
    function  LockEnroll:Boolean;
//    procedure nPopUpClick(Sender:TObject);
//    procedure OnSpButtonClick(Sender: TObject);
    procedure SetFilter;
    procedure RefreshFilter;
    procedure TakeOff(Sender:TObject);
    procedure TakeOn(Sender:TObject);
    procedure ViewGraphics;
  public
    { Public declarations }
    FmFilter: TFmSetFilter;
    FType:   Integer; // Тип ввода - 0- Лазерный ск, 2- отпечаток п.
    procedure SetFilterCaption(aIndex:Integer);
    procedure WmFingere(var Mes:TMessage); message WM_FINGER;
    procedure Wmbarcode(var Mes:TMessage); message WM_BARCODE;
    procedure WmScaner(var Mes:TMessage);message WM_SCANER;
    ///<summary>
    ///  Обработка отпечатка
    ///</summary>
    procedure WmEnroll(var Mes:TMessage);message WM_ENROLL;
    procedure WmDataSetOpen(var Mes:TMessage);message WM_DATASETOPEN;
    procedure WmRefresh(var Mes:TMessage);message WM_REFRESH;
    procedure WmCheckPos(var Mes:TMessage);message WM_CHECKPOS;
    procedure OnTestClick(Sender:TObject);
    procedure OnSotrudClick(Sender:TObject);
  end;

//  procedure SetHook;external 'mikko_hook.dll';
//  procedure DelHook;external 'mikko_hook.dll';

var
  FmMikko_Entrance: TFmMikko_Entrance;
  bDelphi: Boolean;

implementation

{$R *.dfm}
{$R fingerprint.res}
//{$R actionmanagerdescription.res}
uses  fm_alert, Buttons, DbGridColumnsParamList,
 Listparams,  fm_waitbarcode,  dm_mikkoserver, FmAdditionalTest;



procedure TFmMikko_Entrance.CheckState;
begin
  ShowWindow(Handle, SW_SHOWMAXIMIZED);
  SetForegroundWindow(Handle);
end;



procedure TFmMikko_Entrance.DBGridEhVk1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord;
  Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
begin
  if Assigned(DbGridEhVk1.DataSource) and Assigned(DbGridEhVk1.DataSource.DataSet) then
   if DbGridEhVk1.DataSource.DataSet.FieldByName('priznak').AsInteger = PRIZNAK_NOTPROHOD then
     params.Font.Color := clred;
end;

procedure TFmMikko_Entrance.DefineActionmanager;
var ab: TActionBarItem;
begin
  ab := ActionManager1.ActionBars.Add;
  ab.ActionBar := ActionToolBar1;
  ActionManager1.Images := ImageList2;
  InitActionList;
  FActList.InitActionManager(ActionManager1,PopUpMenu,DoExecuteAction);

end;

procedure TFmMikko_Entrance.DoBarcode;
var aBuf:PAnsiChar;
    sAccess: String;
    rCode: Integer;
begin
  Label3.Caption := '';
  try
    CheckState;
    aBuf := FmWaitBarcode.Buffer;
    sBarCode := StrPas(aBuf);
    if DmMikkoServer.ValidBarCode(aBuf) then
    begin
      try
        FSotrudInfo.setKodkli(StrToInt(String(Copy(sBarCode,2,11))));
        FSotrudInfo.setRecord(DmMikkoServer.Server.GetKodkliByBarcode(FSotrudInfo.kodkli, rCode));
        //FSotrudInfo.FGrTimeOut := 0;
        //sAccess := CoalEsce(DmMikkoServer.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+
        //   IntToStr(FSotrudInfo.kodkli)+' AND kodparobj=258470'),'');
        //if (Trim(sAccess)<>'1') then
        if not FSotrudInfo.isBarcodeAccess  then
        begin
          Raise Exception.Create(' Доступ по пропуску запрещен!');
        end;
      except
        FSotrudInfo.SetKodKli(0);
        Exit;
      end;
      if (Ftype=3) or true then//DmFinger.NotFingerTemplate(FKodKli) then
      begin
        FType   := 0;
        //Application.ProcessMessages;
        if FSotrudInfo.kodkli>0 then
        DmMikkoServer.RegisterSotrud(FSotrudInfo);
      end
      else
      begin
        Label3.Caption := FSotrudInfo.name+' должен использовать отпечаток пальца!';
        //DmMikkoServer.GetObjectName(FSotrudInfo.Kodkli)+
      end;

      FSotrudInfo.setKodKLi(0);
    end;
    sbarcode := '';
  except
    on ex: Exception  do
    begin
      try
         if DmMikkoServer.Server.CheckConnect = -1 then
           DmMikkoserver.RestoreConnect;
      except
         DmMikkoserver.RestoreConnect;
      end;
      Raise ex;
    end;
  //  DmFinger.UnLock;
  end

end;

procedure TFmMikko_Entrance.DoEnroll(Sender: TObject);
var
    i: integer;
begin

  fr.bCancel := bCancel;
  if not Visible then
  begin
    fr.bCancel := True
  end;

  if fr.HaveSample and   fr.bIdentification then
  begin

    // Подтверждение
    if (DmMikkoServer.FmAlert.Visible)  then
    begin
      EntranceSoundPlayer.play(EntranceSoundPlayer.sound_notify);
//      PlaySound('notif.wav',0,1);
      PostMessage(DmMikkoServer.FmAlert.Handle,WM_DEFAULT,0,0);
      Exit;
    end
    else
{// ****************************************************************************
//  генерируем  WM_Enroll
// ****************************************************************************
 }
    if LockEnroll then
    begin
      SetLength(EnrollBuf,FpReader.Sample.dwSize);
      try
        for I := 0 to FpReader.Sample.dwSize-1 do
        begin
          EnrollBuf[i] := Byte(PAnsiChar(FpReader.Sample.pData)[i]);
        end;
      finally
        EnrollEvent.SetEvent;
      end;
      PostMessage(Handle,WM_ENROLL,0,0);
    end;
  end;
end;

procedure TFmMikko_Entrance.DoExecuteAction(Sender: TObject);
var mAction: TAction;
begin

  mAction := TAction(Sender);
  case mAction.Tag of
    IDE_EDIT:   ;
    IDE_DELETE: ;
    IDE_FIND:     DbGridEhVk1.Find(False);
    IDE_FINDNEXT: DbGridEhVk1.Find(True);
    IDE_REFRESH:  RefreshFilter;
    IDE_FILTER:   SetFilter;
    IDE_RECONNECT: DmMikkoserver.Reconnect ;
    IDE_SETUP:    ;
    IDE_SCAN:     FmWaitBarcode.ShowModal;
    IDE_REGISTER: DoRegistration;
//    IDE_MARK:     DoMark(True,False);
//    IDE_MARKALL:  DoMark(True,True);
//    IDE_UNMARKALL:DoMark(True,True);
  end;
end;

procedure TFmMikko_Entrance.DoRegistration;
begin
  if Assigned(fr) then
  begin
    while not fr.LockSynchro do
      Application.ProcessMessages;
    while  not LockEnroll do
       Application.ProcessMessages;
    fr.Terminate;
    fr.WaitFor;
    fr.Free;
//    Label3.Caption := ' ';
//    Application.ProcessMessages;
  end;
  try
    TFmRegisterFingerPrint.DoRegistration;
  finally
    InitScaner;
  end;
end;

procedure TFmMikko_Entrance.FormActivate(Sender: TObject);
begin
  if Monitor=1 then
    WindowState := wsMaximized
  else
  begin
    Left := Left +Screen.Width + 10;
    WindowState := wsMaximized;
  end;
  //-------- Init FmWaitBarcode ---------
  Application.CreateForm(TFmWaitBarcode,FmWaitBarcode);
  FmWaitBarcode.FormHandle := Handle;
end;

procedure TFmMikko_Entrance.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  bCancel := True;
  if Assigned(fr) then
  begin
    while not fr.LockSynchro do
      Application.ProcessMessages;
    while not LockEnroll do
      Application.ProcessMessages;

    fr.Terminate;
    fr.WaitFor;
    FreeAndNil(fr);
  end;
  DBGridEhVk1.ReadDbGridColumnsSize;
  DBGridEhVk1.ListDbGridColumnsParam.SaveToReg;
  EntranceSoundPlayer.Free;
end;

procedure TFmMikko_Entrance.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
{  if DmMikkoServer.Server.RtcHttpClient1.isConnected then
  begin
    DmMikkoServer.Server.RtcHttpClient1.Disconnect;
    CanClose:= False;
    Exit;
  end;}
  CanClose:= MessageDlg('Выйти из программы?',mtConfirmation,[mbYes,mbNo],0)=mrYes ;

end;

procedure TFmMikko_Entrance.FormCreate(Sender: TObject);
var FIni:TIniFile;
    iTestItem:TmenuItem;
begin
  EntranceSoundPlayer := TEntranceSoundPlayer.Create;

  DmMikkoServer := TDmMikkoServer.Create(Self);


  EnrollEvent := TEvent.Create();
  EnrollEvent.SetEvent;
  sBarcode := '';
  FSotrudInfo.SetKodKli(0);
  FGrTimeOut := 0;
  Label3.Caption := '';

  //--- Filters ---
  FmFilter := TFmSetFilter.Create(self);
  with FmFilter do
  begin
    ListBox1.AddItem('За сутки',nil);
    ListBox1.AddItem('За месяц',nil);
    ListBox1.AddItem('На территории',nil);
  end;

   if DmMikkoServer.Server.RtcHttpClient1.isConnected then
     Caption := 'Проходная '+DmMikkoServer.Server.QueryValue(' SELECT name FROM client WHERE'+
   ' kodkli='+IntToStr(DmMikkoServer.kodentrance));

  FirstCaption := 'Проходная фабрики МИККО';
  FActList := TListActionManagerDescription.Create;
  DefineActionManager;
  Panel1.Caption := '';
  Panel2.Caption := '';

  FIni := TIniFile.create(ChangeFileExt(Application.ExeName,'.ini'));
  fasserver := AnsiString(FIni.ReadString('SET','fasserver',''));
  Monitor   := FIni.ReadInteger('SET','monitor',1);
{  fr := TFingerPrintReader.Create(True);
  fr.bIdentification     := True;
  fr.OnEnrollFingerPrint := DoEnroll;
  fr.OnTakeOff           := TakeOff;
  fr.OnTakeOn            := TakeOn;
  FpReader := fr;
  Label1.Caption := 'Ошибка в работе сканера ';
  fr.Start;}
  InitScaner;

  DmMikkoServer.Fm := self;
  if DmMikkoServer.Server.RtcHttpClient1.IsConnected then
    DmMikkoServer.SetFilterDc162(0);

  if DmMikkoServer.kodentrance = KOD_ENTRANCE_MIKKO then
  with PopUpMenu do
  begin
    iTestItem := TMenuItem.Create(PopUpMenu);
    iTestItem.Caption := 'Список сотрудников';
    iTestItem.OnClick := OnSotrudClick;
    Items.Add(iTestItem);
  end;

  //---- For Test -----
  if bDelphi then
  begin
    with PopUpMenu do
    begin
      iTestItem := TMenuItem.Create(PopUpMenu);
      iTestItem.Caption := 'Test';
      iTestItem.OnClick := OnTestClick;
      Items.Add(iTestItem);
    end;
  end;
  DataSource1.DataSet := DmMikkoServer.Server.MemTableEhDc162;
  DmMikkoServer.isCheckTimeOut := FIni.ReadBool('SET','isNeedCheckTimeOut',false);
end;

procedure TFmMikko_Entrance.InitActionList;
begin

  with FActList do
  begin
    Items.Clear;
//    AddDescription('doc1',IDE_EDIT,'BITMAP_EDIT','Редактировать','F4');
//    AddDescription('doc1',IDE_DELETE,'BITMAP_DELETE','Удалить','Del');
//    AddDescription('doc1','SEPARATOR','EMPTY','','');
    AddDescription('doc2',IDE_FIND,'BITMAP_FIND','Поиск','F7');
    AddDescription('doc2',IDE_FINDNEXT,'BITMAP_FINDNEXT','Продолжение поиска','Shift+F7');
    AddDescription('doc4',IDE_REFRESH,'BITMAP_REFRESH','Обновить','ALT+R');
    AddDescription('doc2','SEPARATOR','EMPTY','','');
    AddDescription('doc3',IDE_FILTER,'BITMAP_FILTER','Фильтр','ALT+F5');
    AddDescription('doc3',IDE_SCAN,'BITMAP_BARCODE','Сканировать пропуск','F3');
    AddDescription('doc3',IDE_RECONNECT,'BITMAP_UNITE','Пересоеденить','F9');
    AddDescription('doc4',IDE_REGISTER,'BITMAP_SAVE','Регистрация отпечатка пальца','',tdPopUpOnly);
    AddDescription('doc4',IDE_SETUP,'BITMAP_SAVE','Настройки','',tdPopUpOnly);
  end;

//  if DmFinger.Place= tpMikko then
//    FBtnList.AddDefinition('Bitmap_date','График','F10');

end;

procedure TFmMikko_Entrance.InitScaner;
begin
  fr := TFingerPrintReader.Create(True);
  fr.bIdentification     := True;
  fr.OnEnrollFingerPrint := DoEnroll;
  fr.OnTakeOff           := TakeOff;
  fr.OnTakeOn            := TakeOn;
  FpReader := fr;
  Label1.Caption := 'Ошибка в работе сканера ';
  fr.Start;
  EnrollEvent.SetEvent;
end;

function TFmMikko_Entrance.LockEnroll: Boolean;
begin
  Result := EnrollEvent.WaitFor(10)= wrSignaled;
  if Result  then
    EnrollEvent.ResetEvent;
end;


procedure TFmMikko_Entrance.TakeOff(Sender: TObject);
begin
  Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEON');
  Label1.Caption := 'Уберите палец со сканера';
end;

procedure TFmMikko_Entrance.TakeOn(Sender: TObject);
begin
  Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEOFF');
  Label1.Caption := 'Нажмите пальцем на сканер';
end;

procedure TFmMikko_Entrance.ViewGraphics;
//var fm: TFmGraphics;
begin
  {fm := TFmGraphics.create(self);
  fm.Width := Width;
  fm.ShowModal;}
end;

procedure TFmMikko_Entrance.Wmbarcode(var Mes: TMessage);
begin
  SetFocus;
  if not DmMikkoServer.FmAlert.Visible then
    PostMessage(Handle,WM_SCANER,0,0)
  else
    PostMessage(DmMikkoServer.FmAlert.Handle,WM_DEFAULT,0,0);
end;

procedure TFmMikko_Entrance.WmCheckPos(var Mes: TMessage);
begin
  with DmMikkoServer.Server.MemTableEhDc162 do
  begin
    if FCurdoc <> FieldByName('koddoc').AsInteger then
      Locate('koddoc',Fcurdoc,[])
  end;
end;

procedure TFmMikko_Entrance.WmDataSetOpen(var Mes: TMessage);
begin
  Application.HandleMessage;
  DBGridEhVk1.Refresh;
  DmMikkoServer.Server.MemTableEhDc162AfterOpen(DmMikkoServer.Server.MemTableEhDc162);
end;

procedure TFmMikko_Entrance.WmEnroll(var Mes: TMessage);
var rCode: FTRAPI_RESULT;
    // Код сотрудника при идентификации
    pRetId: array[0..13] of AnsiChar;
    i: integer;
//    buf: TBytes;
    s: String;
    p: Pointer;
    nSize: Integer;
    rec: TRtcRecord;
begin
  if LockEnroll then
  begin
    try
      // Если регистрация не закончилась то выходим
      if (FSotrudInfo.kodkli>0) then
        Exit;

      fr.HaveSample := False;
      if length(fasserver)>0  then
      begin
        rCode := FASInitialize(PAnsiChar(fasserver),4900);
        nSize := length(EnrollBuf);
        if rCode=0  then
        begin
          p := GetMemory(nSize);
          try
            for I := 0 to length(EnrollBuf) do
               PAnsiChar(p)[i] := AnsiChar(EnrollBuf[i]);
            FillChar(pRetId,SizeOf(pRetId),#0);
            rCode := FasIdentifyUser('ALL', nSize, p, @pRetID) ;
            FasTerminate;
          finally
            FreeMem(p);
          end;
        end
        else
          Label3.Caption := 'Ошибка связи с базой отпечатков '+IntToStr(rCode);
      end
      else
      begin
        FSotrudInfo.SetKodKli(0);
        try
          //s := StringOf(EnrollBuf);
          try
            if DmMikkoServer.Server.CheckConnect = -1 then
              DmMikkoserver.RestoreConnect;
          except
            DmMikkoserver.RestoreConnect;
          end;
          rec :=DmMikkoServer.Server.GetKodkliByFinger('ALL',RtcByteArray(EnrollBuf),rCode);
          FSotrudInfo.SetRecord(rec);
        finally
          SetLength(EnrollBuf,0);
        end;
        if FSotrudInfo.kodkli>0 then
          rCode := FTR_RETCODE_OK;
      end;

      if rCode = FTR_RETCODE_OK then
      begin
        // Новая регистрация
        if length(fasserver)>0  then
          FSotrudInfo.SetKodKli( StrToInt(String(StrPas(pRetId))));
        Fdatatime := DmMikkoServer.GetServerTime;
        EntranceSoundPlayer.play(EntranceSoundPlayer.sound_notify);
        PostMessage(handle,WM_FINGER,0,0);
      end
      else
      begin
        Label3.Caption := 'Ошибка идентификации '+IntToStr(rCode);
        DmMikkoServer.UnLock;
      end;
    finally
      EnrollEvent.SetEvent;
    end;
  end;
end;

procedure TFmMikko_Entrance.WmFingere(var Mes: TMessage);
begin
  try
    Label3.Caption := '';
    if DmMikkoServer.Lock then
    try
      //CheckState;
      FType := 2;
      DmMikkoServer.RegisterSotrud(FSotrudInfo);
    finally
      FSotrudInfo.setKodKLi(0);
      sbarcode := '';
      DmMikkoServer.UnLock
    end;
  except
      CheckState;
      Label3.Caption := 'Lock';
      Raise;
  end;
end;

procedure TFmMikko_Entrance.WmRefresh(var Mes: TMessage);
var koddoc: Integer;
begin
  koddoc := Mes.lParam;
  if koddoc>0 then
  begin
    if DmMikkoServer.Server.MemTableEhDc162.FieldByName('koddoc').AsInteger<> koddoc then
      DmMikkoServer.Server.MemTableEhDc162.Locate('koddoc',koddoc,[]);
  end
  else
    DmMikkoServer.Server.MemTableEhDc162.Last;
//  FcurDoc := DbGridEhVk1.DataSource.DataSet.FieldByName('koddoc').AsInteger;
//  PostMessage(Handle,WM_CHECKPOS,0,0);
end;

procedure TFmMikko_Entrance.WmScaner(var Mes: TMessage);
begin
  Label3.Caption := '';
  if DmMikkoServer.Lock then
  begin
    try
      DoBarcode;
    finally
      FSotrudInfo.SetKodKli(0);
      sbarcode := '';
      DmMikkoServer.UnLock
    end;
  end
  else
  begin
    CheckState;
    Label3.Caption := 'Lock';
  end;
end;



procedure TFmMikko_Entrance.OnSotrudClick(Sender: TObject);
begin

end;

procedure TFmMikko_Entrance.OnTestClick(Sender: TObject);
var f: TFieldType;
    v: variant;
    sAccess: String;
    rCode: Integer;
begin
//  AdditionalTestFm := TAdditionalTestFm.Create(Application);
//  AdditionalTestFm.ShowModal;
  try
    FSotrudInfo.SetKodKli(74729); //74729; //235101;  // Дагаева Т.// 278096
    FSotrudInfo.setRecord(DmMikkoServer.Server.GetKodkliByBarcode(FSotrudInfo.kodkli, rCode));
  except
    try
      if DmMikkoServer.Server.CheckConnect = -1 then
        DmMikkoserver.RestoreConnect;
    except
      DmMikkoserver.RestoreConnect;
    end;
  end;
//  if not fSotrudInfo.isBbarcodeAccess then
//    Raise Exception.Create(' Доступ по пропуску запрещен!');

//  PostMessage(Handle,WM_FINGER,0,0);
{        sAccess := CoalEsce(DmMikkoServer.QueryValue('SELECT value FROM par_obj\par_obj WHERE kodobj='+
           IntToStr(FKodKli)+' AND kodparobj=258470'),'');
        if (Trim(sAccess)<>'1') then
        begin
//          Raise Exception.Create(' Доступ по пропуску запрещен!');
        end; }

  PostMessage(Handle,WM_FINGER,0,0);

  //v := 11111.11111111;
{  f := VarTypeTodataType(273);
  ShowMessage('Ok!'); }
end;

procedure TFmMikko_Entrance.RefreshFilter;
var nr: TBookMark;
begin
  nr := DmMikkoServer.Server.MemTableEhDc162.GetBookmark;
  try
    DmMikkoServer.SetFilterDc162(FmFilter.ListBox1.ItemIndex);
    DmMikkoServer.Server.MemTableEhDc162.GotoBookmark(nr);
  finally
    DmMikkoServer.Server.MemTableEhDc162.FreeBookmark(nr);
  end;
end;

procedure TFmMikko_Entrance.SetFilter;
begin
  FmFilter.SetForm(FmFilter);
  if FmFilter.ShowModal=mrOk then
  begin
    DmMikkoServer.SetFilterDc162(FmFilter.ListBox1.ItemIndex);
  end;
end;

procedure TFmMikko_Entrance.SetFilterCaption(aIndex: Integer);
begin
  Caption := FirstCaption + ' ('+FmFilter.ListBox1.Items[aIndex]+')';
end;

end.
