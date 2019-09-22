unit fingerprintreader;
{******************************************
  RCurrentStateFP = Record - содержит информацию о текущем состоянии сканера.
  Используется в сallback функции для индикации состояния.

  TFingerPrintReader = поток для работы со сканером

  OnTakeOn и OnTakeOff - ипользуются для обработки нажатия и отпускания пальца со сканера.
  В этих обработчиках достаточно обратиться к CurrentStatusFP.

  OnEnrollFingerPrint - выполняется после окончания сканирования отпечатка.
  Следует анализировать CurrentStatusFP и Sample.

  Для прерывания потока необходимо bCancel выставить в False.

******************************************}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FtrApi, FtrScanApi, SyncObjs; //, DbugIntf ;

type


  RCurrentStateFP = Record
    Context:  LongWord;
    StateMask: FTR_STATE;
    pResponse: LongWord;
    Signal: FTR_SIGNAL;
    pBitmap: FTR_BITMAP_PTR;
  end;


  TFingerPrintReader = class(TThread)
  private
    FbCancel: Boolean;
    FrCode: FTRAPI_RESULT;
    FbIdentification: Boolean;
    FHaveSample: Boolean;
    FSample: FTR_DATA;
    FMutex: TMutex;
    FTakeOn: TNotifyEvent;
    FTakeOff: TNotifyEvent;
    FCurrentStateFP: RCurrentStateFP;
    FOnEnrollFingerPrint: TNotifyEvent;
    FWithSynchro: Boolean;
    FMyEvent: THandle;
    procedure DoTakeOn;
    procedure DoTakeOff;
    procedure DoEnrollFingerPrint;
  public
    constructor Create(aSuspend:Boolean);
    destructor  Destroy;override;
    procedure   Execute;override;
    procedure FtrInit;
    function LockSynchro:Boolean;

    property bIdentification: Boolean read FbIdentification write FbIdentification;
    property bCancel:Boolean read FbCancel write FbCancel;
    property WithSynchro: Boolean read FWithSynchro write FWithSynchro;
    property rCode: FTRAPI_RESULT read FrCode write FrCode;
    property CurrentStateFP: RCurrentStateFp read FCurrentStateFp;
    property HaveSample:Boolean read FHaveSample write FHaveSample;
    property MyEvent : THandle read FMyEvent write FMyEvent;
    property Sample:FTR_DATA read FSample;
    property OnTakeOn: TNotifyEvent read FTakeOn write FTakeOn;
    property OnTakeOff: TNotifyEvent read FTakeOff write FTakeOff;
    property OnEnrollFingerPrint:TNotifyEvent read FOnEnrollFingerPrint write FOnEnrollFingerPrint;
  end;

 procedure cbFingerPrint(AContext: LongWord; AStateMask: FTR_STATE;
    ApResponse: LongWord; ASignal: FTR_SIGNAL; ApBitmap: FTR_BITMAP_PTR);stdcall;

var FPReader:TFingerPrintReader;
    nUndef:Integer;
implementation

{ TFingerPrint }


constructor TFingerPrintReader.Create(aSuspend: Boolean);
begin
  FbIdentification := True;
  FWithSynchro := True;
  inherited;
  FreeOnTerminate := False;
  FMutex := TMutex.Create();
//  FMyEvent := CreateEvent(nil,true,false,nil);
end;

destructor TFingerPrintReader.Destroy;
begin
  FMutex.Release;
  FMutex.Free;
  inherited;
end;

procedure TFingerPrintReader.DoEnrollFingerPrint;
begin
  if Assigned(FOnEnrollFingerPrint) and LockSynchro then
  begin
    FOnEnrollFingerPrint(self);
    FMutex.Release;
  end;
end;

procedure TFingerPrintReader.DoTakeOff;
begin
  if Assigned(FTakeOff) and LockSynchro then
  begin
    FTakeOff(Self);
    FMutex.Release;
  end;
end;

procedure TFingerPrintReader.DoTakeOn;
begin
  if Assigned(FTakeOn) and LockSynchro then
  begin
    FTakeOn(Self);
    FMutex.Release;
  end;
end;

procedure TFingerPrintReader.Execute;
var aValue : LongWord;
    hDevice: FTRHANDLE;
    t1: Int64;
begin

  bCancel     := False;
  FHaveSample := False;
  aValue := 1;

  FtrInit;
  // Init не прошел
  if bCancel then
  begin
//    SetEvent(FMyEvent);
    Exit;
  end;

  rCode := FTRSetParam( 4, aValue );
  if ( rCode <> FTR_RETCODE_OK ) then
  begin
    bCancel := True;
    Exit;
  end;
  rCode := FTRSetParam( FTR_PARAM_CB_CONTROL, LongWord(Addr(CbFingerPrint)) );
  if (rCode <> FTR_RETCODE_OK ) then
  begin
    bCancel := True;
    Exit;
  end;


  rCode := FTRGetParam( FTR_PARAM_MAX_TEMPLATE_SIZE, @FSample.dwSize );
  if( rCode = FTR_RETCODE_OK ) then
  try
  begin
    while not bCancel and not Terminated do
    begin
      getMem(FSample.pData,FSample.dwSize);
      try
        if FbIdentification then
        begin
          FHaveSample := False;
          rCode := FTREnroll(0, FTR_PURPOSE_IDENTIFY, @FSample );
        end
        else
          if not FHaveSample then
          begin
            rCode := FTREnroll(0, FTR_PURPOSE_ENROLL, @FSample );
          end;
        FHaveSample := True;
        if FwithSynchro then
           Synchronize(DoEnrollFingerPrint)
        else
          DoEnrollFingerPrint;

        if not bCancel then
        begin
          t1 := GetTickCount;
          //Sleep(2000);
          hDevice := ftrScanOpenDevice;
          try
            while ftrScanIsFingerPresent(hDevice,nil)=1 do
            begin
              Sleep(10);
             if GetTickCount - t1 > 2000 then
                Break;
            end;
          finally
            FtrScanCloseDevice(hDevice);
          end;
        end;
      finally
        if Assigned(FSample.pData) then
      	   FreeMem(FSample.pData);
        if not FbIdentification then
           bCancel := true;
      end;

    end;
  end;
  finally
    FTRTerminate();
//    SetEvent(MyEvent);
  end;
end;

procedure TFingerPrintReader.FtrInit;
begin
  rCode := FTRInitialize();
  if (rCode <> FTR_RETCODE_OK ) then
  begin
     Exit;
     bCancel := True;
  end;

end;


function TFingerPrintReader.LockSynchro: Boolean;
begin
  if Assigned(FMutex) then
    Result := FMutex.WaitFor(10)=wrSignaled
  else
    Result := True;
end;

procedure cbFingerPrint(AContext: LongWord; AStateMask: FTR_STATE;
    ApResponse:LongWord; ASignal: FTR_SIGNAL; ApBitmap: FTR_BITMAP_PTR);stdcall;
begin
   if AStateMask  = FTR_STATE_SIGNAL_PROVIDED then
   begin
      with FpReader.FCurrentstateFp do
      begin
        Context   := AContext;
        StateMask := AStateMask;
        pResponse := Apresponse;
        Signal    := ASignal;
        pBitmap   := ApBitmap;
      end;
      case ASignal of
       FTR_SIGNAL_TOUCH_SENSOR:
           begin
             begin
               FpReader.DoTakeOn();
             end
           end;
       FTR_SIGNAL_TAKE_OFF: begin
                FpReader.DoTakeOff();
       end;
      end;
   end
   else
   begin
      case ASignal of
        FTR_SIGNAL_UNDEFINED:begin
                  Inc(nUndef);
        end;

      end;
   end;
   if ( not FPreader.bCancel ) and ( not FPreader.Terminated) then
   begin
      PLongWord(ApResponse)^ := FTR_CONTINUE;
   end
   else
   begin
      PLongWord(ApResponse)^ := FTR_CANCEL;
      PostMessage(FPreader.Handle,WM_CLOSE,0,0);
//      SetEvent(FPReader.MyEvent);
   end;
end;


Initialization;
  nUndef := 0;
end.
