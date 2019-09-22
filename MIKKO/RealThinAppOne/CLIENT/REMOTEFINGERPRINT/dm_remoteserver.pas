unit dm_remoteserver;

interface

uses
  SysUtils, Classes, rtcFunction, rtcConn, rtcDataCli, rtcHttpCli, rtcDB, rtcInfo, rtcCliModule, IniFiles,
  Dialogs, Windows,SyncObjs,Forms;

type
  TDmRemoteServer = class(TDataModule)
    RtcClientModule1: TRtcClientModule;
    RtcDataSetMonitor1: TRtcDataSetMonitor;
    RtcHttpClient1: TRtcHttpClient;
    RtcResult1: TRtcResult;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    connect_handle: Integer;
    FIni: TIniFile;
    Fkodentrance: Integer; //рабочее местож
    hSignal: THandle;
    procedure SetConnect;
  public
    { Public declarations }
    function GetKodkliByFinger(UserID: String; aData: RtcByteArray; var rCode: Integer): TRtcRecord;
    //function GetKodkliByFinger( UserID:String; aData:TBytes;var  rCode:Integer):Integer;

    function Lock:Boolean;
    procedure UnLock;

    ///<summary> Проверка связи </summary>
    function CheckConnect:Integer;
    procedure RestoreConnect;

    function RtcConnect(const ausername, apassword:String; akodentrance:Integer):Integer;
    procedure TryConnect;
    ///<summary> Возвращает результат запроса cQuery </summary>
    function QueryValue(const cQuery:String):String;

    property kodentrance: Integer read Fkodentrance;
  end;

var
  DmRemoteServer: TDmRemoteServer;

implementation

{$R *.dfm}

{ TDmRemoteServer }

function TDmRemoteServer.CheckConnect: Integer;
var mResult: TRtcValue;
begin
  with RtcClientModule1 do
  begin
    with Prepare('CheckConnect') do
    begin
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Result := -1 //Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asInteger;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TDmRemoteServer.DataModuleCreate(Sender: TObject);
begin
  FIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  SetConnect;
  hSignal := CreateSemaphore(nil,1,1,nil);
end;


function TDmRemoteServer.GetKodkliByFinger(UserID: String; aData: RtcByteArray; var rCode: Integer): TRtcRecord;
var mResult: TRtcValue;
//    bs: TBytesStream;
    i: integer;
begin
  Result := nil;
//  bs := TBytesStream.Create;
//  bs.SetSize(length(adata));
//  for I := 0 to bs.Size-1 do
//    bs.Bytes[i] := adata[i];
  with RtcClientModule1 do
  begin
    with Prepare('GetKodkliByFinger') do
    begin
      Param.asWideString['UserId'] := UserId;
      Param.asByteArray['adata'] := Mime_EncodeEx(aData);
      Param.asInteger['rCode'] := rCode;

      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
        begin
          Result := TRtcRecord(mResult.copyOf);
          rCode := 0;
        end;
      finally
        FreeAndNil(mResult);
//        FreeAndNil(bs);
      end;
    end;
  end;

end;


{* function TDmRemoteServer.GetKodkliByFinger(UserID: String; aData: TBytes; var rCode: Integer): Integer;
var mResult: TRtcValue;
    bs: TBytesStream;
    i: integer;
begin
  Result := 0;
  bs := TBytesStream.Create;
  bs.SetSize(length(adata));
  for I := 0 to bs.Size-1 do
    bs.Bytes[i] := adata[i];
  with RtcClientModule1 do
  begin
    with Prepare('GetKodkliByFinger') do
    begin
      Param.asWideString['UserId'] := UserId;
      Param.asByteStream['adata'] := TStream(bs);
      Param.asInteger['rCode'] := rCode;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
        begin
          rCode := result;
          Result := mResult.asInteger;
        end;
      finally
        FreeAndNil(mResult);
        FreeAndNil(bs);
      end;
    end;
  end;
end; *}

function TDmRemoteServer.Lock: Boolean;
begin
  TryConnect;
  Result :=  WaitForSingleObject(hSignal, 100)=WAIT_OBJECT_0;
end;

function TDmRemoteServer.QueryValue(const cQuery: String): String;
var mResult: TRtcValue;
begin
  with RtcClientModule1 do
  begin
    with Prepare('QueryValue') do
    begin
      Param.asWideString['cQuery'] := cQuery;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          Raise Exception.Create('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asWideString;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TDmRemoteServer.RestoreConnect;
begin
  RtcHttpClient1.Disconnect;
  SetConnect;
end;

function TDmRemoteServer.RtcConnect(const ausername, apassword: String; akodentrance: Integer): Integer;
var mResult: TRtcValue;
begin
  Result := -1;
  with RtcClientModule1 do
  begin
    with Prepare('Connect') do
    begin
      Param.AsWideString['username'] := aUsername;
      Param.AsWideString['password'] := apassword;
      Param.asInteger['kodentrance'] := akodentrance;
      mResult := Execute(False);
      try
        if mResult.isType=rtc_Exception then
          ShowMessage('Server-side exception :'+#13#10+mResult.asException)
        else
          Result := mResult.asInteger;
      finally
        FreeAndNil(mResult);
      end;
    end;
  end;
end;

procedure TDmRemoteServer.SetConnect;
begin
  with RtcHttpClient1 do
  begin
    ServerAddr := FIni.ReadString('SERVER','HostName','localhost');
    ServerPort := FIni.ReadString('SERVER','Port','3039');
    Fkodentrance := FIni.ReadInteger('SET','kodentrance',-1);
    Connect();
    connect_handle := RtcConnect('vkorshun','enterprize',Fkodentrance) ;
  end;

end;

procedure TDmRemoteServer.TryConnect;
begin
  if CheckConnect=-1 then
    RestoreConnect;

end;

procedure TDmRemoteServer.UnLock;
begin
  ReleaseSemaphore(hSignal,1,nil);
end;

end.
