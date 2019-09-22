unit fm_remotefingerprint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IniFiles, FingerPrintReader, FasApi, ftrApi,syncobjs, rtcFunction, rtcConn,
  rtcDataCli, rtcHttpCli, rtcDB, rtcInfo, rtcCliModule, dm_remoteserver, MMSystem, SotrudInfo;

const
  WM_BARCODE = WM_USER +101;
  WM_FINGER  = WM_USER +112;
  WM_SCANER  = WM_USER +113;
  WM_ENROLL  = WM_USER +114;
  WM_REFRESH = WM_USER +115;
  WM_CHECKPOS = WM_USER + 116;
  WM_DATASETOPEN = WM_USER + 117;

type
  TFmRemoteFingerPrint = class(TForm)
    Panel2: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    bCancel : Boolean;
    DmRemoteServer: TDmRemoteServer;
    fr: TFingerPrintReader;
    FSotrudInfo: TSotrudInfo;
//    Fkodkli: Integer;
    FIni: TIniFile;
    EnrollBuf: TBytes;
    EnrollEvent: TEvent;
    procedure CheckState;
    procedure InitScaner;
    procedure DoEnroll(Sender:TObject);
    function LockEnroll:Boolean;

    procedure TakeOff(Sender:TObject);
    procedure TakeOn(Sender:TObject);
  public
    { Public declarations }
    ///<summary>
    ///  Обработка отпечатка
    ///</summary>
    procedure WmEnroll(var Mes:TMessage);message WM_ENROLL;
    procedure WmFingere(var Mes:TMessage); message WM_FINGER;

  end;

var
  FmRemoteFingerPrint: TFmRemoteFingerPrint;

implementation

{$R *.dfm}
{$R fingerprint.res}

procedure TFmRemoteFingerPrint.CheckState;
begin
  ShowWindow(Handle, SW_NORMAL);
  SetForegroundWindow(Handle);

end;

procedure TFmRemoteFingerPrint.DoEnroll(Sender: TObject);
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

{    // Подтверждение
    if (DmMikkoServer.FmAlert.Visible)  then
    begin
      PlaySound('notif.wav',0,1);
      PostMessage(DmMikkoServer.FmAlert.Handle,WM_DEFAULT,0,0);
      Exit;
    end
    else }
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

procedure TFmRemoteFingerPrint.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//  FreeAndNil(fr);
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
end;

procedure TFmRemoteFingerPrint.FormCreate(Sender: TObject);
begin
  bCancel := False;
  DmRemoteServer := TDmRemoteServer.Create(Self);


  EnrollEvent := TEvent.Create();
  EnrollEvent.SetEvent;
  FSotrudInfo.SetKodKli(0);
  Label3.Caption := '';


   if DmRemoteServer.RtcHttpClient1.isConnected then
     Caption := DmRemoteserver.QueryValue(' SELECT name FROM client WHERE'+
   ' kodkli='+IntToStr(DmRemoteServer.kodentrance));

  Panel2.Caption := '';

  FIni := TIniFile.create(ChangeFileExt(Application.ExeName,'.ini'));
//  fasserver := AnsiString(FIni.ReadString('SET','fasserver',''));
//  Monitor   := FIni.ReadInteger('SET','monitor',1);
{  fr := TFingerPrintReader.Create(True);
  fr.bIdentification     := True;
  fr.OnEnrollFingerPrint := DoEnroll;
  fr.OnTakeOff           := TakeOff;
  fr.OnTakeOn            := TakeOn;
  FpReader := fr;
  Label1.Caption := 'Ошибка в работе сканера ';
  fr.Start;}
  InitScaner;

{  DmMikkoServer.Fm := self;
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
 }
  label2.Caption := 'Следующий';
  Caption := 'Удаленный регистратор ';
end;

procedure TFmRemoteFingerPrint.InitScaner;
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

function TFmRemoteFingerPrint.LockEnroll: Boolean;
begin
  Result := EnrollEvent.WaitFor(10)= wrSignaled;
  if Result  then
    EnrollEvent.ResetEvent;
end;

procedure TFmRemoteFingerPrint.TakeOff(Sender: TObject);
begin
  Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEON');
  Label1.Caption := 'Уберите палец со сканера';
end;

procedure TFmRemoteFingerPrint.TakeOn(Sender: TObject);
begin
  Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEOFF');
  Label1.Caption := 'Нажмите пальцем на сканер';
end;

procedure TFmRemoteFingerPrint.WmEnroll(var Mes: TMessage);
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
      begin
        FSotrudInfo.setKodkli(0);
        try
          s := StringOf(EnrollBuf);
          try
            DmRemoteServer.CheckConnect;
          except
            DmRemoteServer.RestoreConnect;
          end;
          rec := DmRemoteServer.GetKodkliByFinger('ALL',RtcByteArray(EnrollBuf),rCode);
          FSotrudInfo.setRecord(rec);
        finally
          SetLength(EnrollBuf,0);
        end;
        if FSotrudInfo.kodkli>0 then
          rCode := FTR_RETCODE_OK;
//        Label2.Caption := (IntToStr(Fkodkli));
      end;

      if rCode = FTR_RETCODE_OK then
      begin
        // Новая регистрация
        PlaySound('notif.wav',0,1);
        PostMessage(handle,WM_FINGER,0,0);
      end
      else
      begin
        Label3.Caption := 'Ошибка идентификации '+IntToStr(rCode);
        DmRemoteServer.UnLock;
      end;
    finally
      EnrollEvent.SetEvent;
    end;
  end;

end;

procedure TFmRemoteFingerPrint.WmFingere(var Mes: TMessage);
begin
  try
    Label3.Caption := '';
    if DmRemoteServer.Lock then
    try
      //CheckState;
      //DmMikkoServer.RegisterSotrud(Fkodkli);
      if FSotrudInfo.kodkli>0 then
        Label2.Caption := FSotrudInfo.name//DmRemoteServer.QueryValue(' SELECT name FROM client WHERE kodkli='+IntToStr(Fkodkli))
      else
        Label2.Caption := ' Не определен';
    finally
      FSotrudInfo.setKodKli(0);
      DmRemoteServer.UnLock
    end;
  except
      CheckState;
      Label3.Caption := 'Lock';
      Raise;
  end;
end;

end.
