unit ServerMikko;

interface

uses
  SysUtils, Classes,
  SvcMgr, IniFiles, Monitor,
   rtcInfo, rtcConn, rtcDataSrv, rtcHttpSrv;

type
  TServerMikkoEntrance1 = class(TService)
    HttpServerMikko: TRtcHttpServer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    { Private declarations }
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

uses Windows;

{$R *.dfm}


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServerMikkoEntrance1.Controller(CtrlCode);
end;

function TServerMikkoEntrance1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function TServerMikkoEntrance1.DoContinue: Boolean;
begin
  Result := inherited;
  HTTPServerMikko.Listen;
end;

procedure TServerMikkoEntrance1.DoInterrogate;
begin
  inherited;
end;

procedure TServerMikkoEntrance1.DoListen;
var FIni: TIniFile;
begin
  //txtMonitor(AppFileName);
  FIni := TIniFile.Create(ChangeFileExt(AppFilename,'.ini')  );
  //txtMonitor(FIni.ReadString('SET','PORT',''));
  HTTPServerMikko.ServerPort := String(FIni.ReadString('SET','PORT',''));
//  txtMonitor(HTTPServerMikko.ServerPort);
  FIni.Free;
  HTTPServerMikko.Listen();
end;

function TServerMikkoEntrance1.DoPause: Boolean;
begin
  HTTPServerMikko.StopListen;
  Result := inherited;
end;

function TServerMikkoEntrance1.DoStop: Boolean;
begin
  HTTPServerMikko.StopListen;
  Result := inherited;
end;

procedure TServerMikkoEntrance1.ServiceStart(Sender: TService; var Started: Boolean);
begin
  //HTTPServerMikko.Listen;
//  txtMonitor('statrt');
  DoListen;
//  txtMonitor('stop');
  //Started := True;
end;
end.

