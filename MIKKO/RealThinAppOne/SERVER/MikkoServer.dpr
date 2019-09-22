program MikkoServer;

uses
  SvcMgr,
  ServerMikko in 'ServerMikko.pas' {ServerMikko1: TService},
  dm_mikkoads in '..\..\COMMON\dm_mikkoads.pas' {DmMikkoAds: TDataModule},
  mikko_consts in '..\..\COMMON\mikko_consts.pas',
  fm_login in '..\..\COMMON\fm_login.pas' {FmLogin},
  dm_entrance in 'dm_entrance.pas' {DmEntrance: TDataModule},
  fasapi in '..\CLIENT\FUTRONIC\fasapi.pas',
  dm_client in '..\..\COMMON\dm_client.pas' {DmClient: TDataModule},
  dm_EntranceMethodsMikko in 'dm_EntranceMethodsMikko.pas' {DmEntranceMethodsMikko: TDataModule};

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TServerMikko1, ServerMikko1);
  Application.CreateForm(TDmEntranceMethodsMikko, DmEntranceMethodsMikko);
  //  Application.CreateForm(TDmMikkoAds, DmMikkoAds);
//  Application.CreateForm(TDmClient, DmClient);
  //  Application.CreateForm(TFmLogin, FmLogin);
//  Application.CreateForm(TDmEntrance, DmEntrance);
  Application.Run;
end.

