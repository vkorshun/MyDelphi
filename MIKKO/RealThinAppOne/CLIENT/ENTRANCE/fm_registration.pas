{//---------------------------------------
   Форма для регистрации отпечатков или идентификации.
   Запуск -
      Создать форму
      Установить
         property bIdentification: Boolean True - идентификация иначе регистрация;
         property IdUser:Integer ;
         property cUsername:String ;
         property FingerId:Integer; - номер пальца для регистрации;
      Prepare;
      ShowModal;
   При идентификации в IdUser записывается код сотрудника.
------------------------------------------//}
unit fm_registration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, RtcInfo,
  Dialogs,ftrscanapi,ftrapi, fasapi, ExtCtrls, StdCtrls, fingerprintreader, jpeg, SotrudInfo;

const
  WM_ADDUSER  = WM_USER + 2001;
  WM_IDENTIFY = WM_USER + 2002;
  WM_RUN      = WM_USER + 2003;
  finger_file = 'finger.tmp';

type
{  TFASThread = class(TThread)
    bCancel: Boolean;
    bValue: Integer;
    pRetId: array[0..13] of char;
    sample: FTR_DATA;
    buf1: array[0..4] of byte;
    buf2: array[0..11] of byte;
    buf3: array[0..4] of byte;
    rCode: FTRAPI_RESULT;
    constructor Create(bSuspend:Boolean);
    destructor  Destroy();override;
    procedure Execute;override;
  end;
 }

  TFmRegistration = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    BitMap: TBitMap;
//    FB: TFtrBitmap;
//    fasserver: AnsiString;
    FFingerId: byte;
    FIdUser: Integer;
    FUserName: AnsiString;
    FbIdentification: Boolean;
    // Для прерывания ожидания сигнала от сканера
    bCancel: Boolean;
    bFirst: Boolean;
    FSotrudInfo: TSotrudInfo;

    // Код сотрудника при идентификации
//    pRetId: array[0..13] of AnsiChar;
    // Отпечаток
//    buf1: array[0..4] of byte;
//    buf2: array[0..11] of byte;
//    buf3: array[0..4] of byte;
    //Код возврата
    rCode: FTRAPI_RESULT;
    nCount: Integer;
    // Обработка сигнала со сканера
    procedure DoOk(sender: TObject);
    // Рекурсивная процедура при ожидании сигнала сканера
    procedure  cbControl( Sender: TObject  );
  public
    { Public declarations }
    procedure Prepare(const path_fasserver:AnsiString);
    // Регистрация
    procedure WmAddUaser(var Msg:TMessage);message WM_ADDUSER;
    // Идентификация
    procedure WmIdentify(var Msg:TMessage);message WM_IDENTIFY;
    // Запуск ожидания получения отпечатка
    procedure WmRun(var Msg:TMessage);message WM_RUN;

    property bIdentification: Boolean read FbIdentification write FbIdentification;
    property IdUser:Integer read FIdUser write FIdUser;
    property cUsername:AnsiString read FUserName write FUsername;
    property FingerId:Byte read FFingerId write FFingerId;
    property Sotrud: TSotrudInfo read FSotrudInfo;
  end;

var
  FmRegistration: TFmRegistration;

implementation

{$R *.dfm}
//{$R fingerprint.res}
uses dm_mikkoserver, dm_registerfingerprint;

{ TFmRegistration }


procedure TFmRegistration.WmAddUaser(var Msg: TMessage);
begin
    ModalResult := MrOk;
end;

procedure TFmRegistration.WmIdentify(var Msg: TMessage);
begin
//  IdUser := strToInt(StrPas(PAnsiChar(@pRetId)));
  ModalResult := MrOk;
end;

procedure TFmRegistration.WmRun(var Msg: TMessage);
begin
  FpReader.bIdentification := bIdentification;
  bCancel := False;
  nCount  := 0;
  Label1.Caption := '';
  if bIdentification then
    Caption := 'Идентификация'
  else
    Caption := 'Регистрация '+String(cUsername);
  FPreader.Start;
end;

procedure TFmRegistration.Button1Click(Sender: TObject);
begin
  bCancel := True;
end;

procedure TFmRegistration.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  bCancel := True;
//  Sleep(1000);
  while not FpReader.LockSynchro do
    Application.ProcessMessages;
  FpReader.Terminate;
  FpReader.WaitFor;
  Fpreader.Free;
end;

procedure TFmRegistration.FormCreate(Sender: TObject);
begin
  BitMap := TBitMap.Create;
  Image1.Picture.Bitmap := BitMap;
  bFirst := True;
  Label1.Caption := '';
end;

procedure TFmRegistration.FormDestroy(Sender: TObject);
begin
  Bitmap.Free;
//  FasTerminate();
end;

procedure TFmRegistration.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
  begin
    bCancel := True;
    ModalResult := mrCancel;
  end;

end;

procedure TFmRegistration.FormShow(Sender: TObject);
begin
  PostMessage(Handle,WM_RUN,0,0)
end;

procedure TFmRegistration.Prepare(const path_fasserver:AnsiString);
//var //aValue : LongWord;
//    rCode: FTRAPI_RESULT;
//    pCb:TcbControl;
//    p: Pointer;
//    n: Integer;
begin
//  fasserver := path_fasserver;//'mikko.com.ua';

  FPReader := TFingerPrintReader.Create(True);
  FPReader.OnEnrollFingerPrint := DoOk;
  FPReader.OnTakeOn  := cbControl;
  FPReader.OnTakeOff := cbControl;

//  n := FASInitialize(PAnsiChar(fasserver),4900);
end;




procedure TFmregistration.DoOk(Sender:TObject);

function AddUser:Integer;
var rCode: FTRAPI_RESULT;
    pFile:array[0..255] of AnsiChar;
    pUser:array[0..100] of AnsiChar;
    puserId:array[0..11] of AnsiChar;
begin
  StrPCopy(pFile,AnsiString(ExtractFileDir(Application.ExeName)+'\'+finger_file));
  strPCopy(pUser,cUsername);
  strPCopy(pUserId,AnsiString(IntToStr(IdUser)));
  rCode := FasAddUserFromFile(5,100,pFile,pUser,pUserId,0,FFingerId,6);
  if( rCode <> FTR_RETCODE_OK ) then
  begin
     Panel1.Caption := 'Error '+ IntToStr(rCode);
     ModalResult := mrCancel;
  end;
  Result := rCode;
end;
var
   EnrollBuf:  TBytes;
   i: Integer;
   s: String;
   rec: TRtcRecord;
   nIdFinger: Integer;
   bs: TBytesStream;
   kodkli: Integer;
begin
   FpReader.bCancel := bCancel;

   if not FpReader.HaveSample then
     Exit;

   if( FpReader.rCode <> FTR_RETCODE_OK ) then
   begin
     Fmregistration.Panel1.Caption := 'Error!-'+IntToStr(FpReader.rcode);
	   Exit;
   end;
   FmRegistration.panel1.Caption := ' ';
   //====== Identification ======================
   if FmRegistration.bIdentification then
   begin
     SetLength(EnrollBuf,FpReader.Sample.dwSize);
     for I := 0 to FpReader.Sample.dwSize-1 do
     begin
       EnrollBuf[i] := Byte(PAnsiChar(FpReader.Sample.pData)[i]);
     end;
     kodkli := 0;
     FSotrudInfo.SetKodKli(0);
     try

       s := StringOf(EnrollBuf);
       rec :=DmMikkoServer.Server.GetKodkliByFinger('ALL',RtcByteArray(EnrollBuf),rCode);
       FSotrudInfo.setRecord(rec);
       FIdUser := FSotrudInfo.kodkli;
     finally
       SetLength(EnrollBuf,0);
       PostMessage(Handle,WM_IDENTIFY,0,0);
     end;
//     if kodkli>0 then
//     else
//       ShowMessage('Ошибка идентификации!');
   end
   else
   begin
     {SaveTemplateToFile(FpReader.Sample);
     if AddUser=0 then
     begin
       PostMessage(FmRegistration.Handle,WM_AddUser,0,0);
     end; }
     SetLength(EnrollBuf,FpReader.Sample.dwSize);
     for I := 0 to FpReader.Sample.dwSize-1 do
     begin
       EnrollBuf[i] := Byte(PAnsiChar(FpReader.Sample.pData)[i]);
     end;
     kodkli := FIdUser;
     try
       s := StringOf( EnrollBuf);
       nIdFinger := DmRegisterFingerPrint.MemTableEhDc167.FieldByName('isfinger').AsInteger;
       rCode := DmMikkoServer.Server.AddFingerUser(kodkli,s,6+nIdFinger);
 //      if rCode=0 then
     finally
       SetLength(EnrollBuf,0);
       PostMessage(Handle,WM_ADDUSER,0,0);
       bs.Free;
     end;
   end;
end;

{procedure TFmRegistration.SaveTemplateToFile( p:FTR_DATA);
var fStream: TFileStream;
begin
  fStream := TFileStream.Create(ExtractFileDir(Application.ExeName)+'\'+finger_file,fmCreate);
  FillChar(buf1,0,4);
  StrLCopy(@buf1,PAnsiChar(p.pdata),2);
  fStream.WriteBuffer(buf1,4);
  FillChar(buf2,0,12);
  StrLCopy(@buf2,'1111111111',10);
  fStream.WriteBuffer(buf2,12);
  FillChar(buf3,0,4);
  buf3[0]:=1;
  fStream.WriteBuffer(buf3,4);
  fStream.WriteBuffer(p.pdata^,p.dwSize);
  fStream.Free;
end; }

procedure TFmregistration.cbControl(sender: TObject);
var //Context: LongWord;
{    StateMask: FTR_STATE;
    pResponse: LongWord;
    pBitmap: FTR_BITMAP_PTR;}
//    fb: TFtrBitmap;
    Signal: FTR_SIGNAL;
begin
//   Context := FPReader.CurrentStateFP.Context;
//   StateMask := FPReader.CurrentStateFP.StateMask;
//   pResponse := FPReader.CurrentStateFP.pResponse;
   Signal    := FPReader.CurrentStateFP.Signal;
//   pBitmap   := FPReader.CurrentStateFP.pBitmap;
   if bCancel then
     Exit;
     case Signal of
       FTR_SIGNAL_TOUCH_SENSOR:
          begin
            if bFirst then
            begin
              Image1.Picture.BitMap := BitMap;
              bFirst := False;
            end;
            Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEOFF');
            FmRegistration.panel1.Caption := 'Нажмите пальцем на сканер';
            FmRegistration.Label1.Caption := 'Нажмите пальцем на сканер';
          end;
       FTR_SIGNAL_TAKE_OFF:
          begin
            Inc(nCount);
            if nCount>7 then
              Exit;
            try
              Image1.Picture.BitMap.LoadFromResourceName(hInstance,'TAKEON');
              FmRegistration.panel1.Caption := 'Уберите палец со сканера';
              if not FmRegistration.bIdentification then
                FmRegistration.Label1.Caption := IntTostr(nCount)
              else
                FmRegistration.Label1.Caption := 'Уберите палец со сканера';
            except

            end;
          end;
      end;
end;


end.
