unit ServerMikkoEntrance;

interface

uses
  SysUtils, Classes,
  SvcMgr, IniFiles, Monitor,
   rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv, rtcLog;

type
  TServerMikkoEntrance1 = class(TService)
    HttpServerMikko: TRtcHttpServer;
    RtcDataProvider1: TRtcDataProvider;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure HttpServerMikkoClientDisconnect(Sender: TRtcConnection);
    procedure HttpServerMikkoListenLost(Sender: TRtcConnection);
    procedure RtcDataProvider1CheckRequest(Sender: TRtcConnection);
    procedure RtcDataProvider1DataReceived(Sender: TRtcConnection);
  private
    { Private declarations }
    dm : TDataModule;//TDmEntranceMethodsMikko;
    procedure DoListen;
  protected
    function DoStop: Boolean; override;
    function DoPause: Boolean; override;
    function DoContinue: Boolean; override;
    procedure DoInterrogate; override;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  ServerMikkoEntrance1: TServerMikkoEntrance1;

implementation

uses Windows,Dm_EntranceMethodsMikko, dm_personalentrance, SuperObject;

{$R *.dfm}


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServerMikkoEntrance1.Controller(CtrlCode);
end;

function TServerMikkoEntrance1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TServerMikkoEntrance1.HttpServerMikkoClientDisconnect(Sender: TRtcConnection);
begin
   TDmEntranceMethodsMikko(dm).DeleteDmEntrance(Sender);
  XLog('Disconnected');

end;

procedure TServerMikkoEntrance1.HttpServerMikkoListenLost(Sender: TRtcConnection);
begin
   TDmEntranceMethodsMikko(dm).DeleteDmEntrance(Sender);
   XLog('Lost');
end;

procedure TServerMikkoEntrance1.RtcDataProvider1CheckRequest(Sender: TRtcConnection);
begin
  with TRtcDataServer(Sender) do
  begin
    Xlog('QUERY - '+Request.Query.Text);
      XLog( 'File name - '+  Request.Filename+' '+IntToStr(Request.ItemCount)+' '+Request.ItemValue[0]);
    Xlog('AAQUERY - '+Request.Method+' '+Request.Params.Text);

     if UpperCase(Request.FileName)='/PERSONALENTRANCE'  then
       Accept; // Ac
  end;
end;

procedure TServerMikkoEntrance1.RtcDataProvider1DataReceived(Sender: TRtcConnection);
var i: integer;
    _func: String;
    _user : String;
    _password: String;
    _dm: TDmPersonalEntrance;
    _body: String;
    _obj: ISuperObject;
begin
  with TRtcDataServer(Sender) do
  begin
    if UpperCase(Request.FileName)='/PERSONALENTRANCE'  then
    begin
      _body := Read;
      _obj := SO(_body);

      _func := _obj.S['func'];
      _user := _obj.S['username'];
      _password := MIME_Decode(_obj.S['password']);
      if SameText(_func,'getCurrentState') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.GetCurrentState(_user,_password).AsJson());
        finally
          _dm.Free;
        end;
      end;
      if SameText(_func,'getCurrentStatus') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.GetCurrentStatus(_user,_password).AsJson());
        finally
          _dm.Free;
        end;
      end;
      if SameText(_func,'setCurrentStatus') then
      begin
        _dm := TDmPersonalEntrance.Create(self);
        try
          Write(_dm.SetCurrentStatus(_user,_password,True).AsJson());
        finally
          _dm.Free;
        end;
      end;
    end;
  end;
end;

function TServerMikkoEntrance1.DoContinue: Boolean;
begin
  Result := inherited;
  HTTPServerMikko.Listen;
  XLog('Continue');
end;

procedure TServerMikkoEntrance1.DoInterrogate;
begin
  inherited;
end;

procedure TServerMikkoEntrance1.DoListen;
var FIni: TIniFile;
//    dm :TDmEntranceMethodsMikko;
begin
  //txtMonitor(AppFileName);
  FIni := TIniFile.Create(ChangeFileExt(AppFilename,'.ini')  );
  //txtMonitor(FIni.ReadString('SET','PORT',''));
  HTTPServerMikko.ServerPort := String(FIni.ReadString('SET','PORT',''));
  FIni.Free;

  dm := TDmEntranceMethodsMikko.Create(self);
  TDmEntranceMethodsMikko(dm).RtcDataServerLink1.Server := HTTPServerMikko;

  HTTPServerMikko.Listen();
  XLog('Started');

end;

function TServerMikkoEntrance1.DoPause: Boolean;
begin
  HTTPServerMikko.StopListen;
  Result := inherited;
  XLog('Pause');
end;

function TServerMikkoEntrance1.DoStop: Boolean;
begin
  HTTPServerMikko.StopListen;
  Result := inherited;
  XLog('Stoped');
end;

procedure TServerMikkoEntrance1.ServiceStart(Sender: TService; var Started: Boolean);
begin
  //HTTPServerMikko.Listen;
  RTC_LOGS_LIVE_DAYS := 7;
  StartLog;
  DoListen;
  //Started := True;
end;
end.

