program ledapravoSrv;

uses
  Vcl.Forms,
  FmLedapravoSrv in 'FmLedapravoSrv.pas' {LedaPravoSrvFm},
  commoninterface in '..\COMMON\INTERFACE\commoninterface.pas',
  DmRtcCommonFunctions in '..\COMMON\DmRtcCommonFunctions.pas' {RtcCommonFunctionsDm},
  DmRtcCustom in '..\COMMON\DmRtcCustom.pas' {RtcCustomDm: TDataModule},
  DmRtcObjects in '..\COMMON\DmRtcObjects.pas' {RtcObjectsDm: TDataModule},
  DmRtcUseMonth in '..\COMMON\DmRtcUseMonth.pas' {RtcUseMonthDm: TDataModule},
  uRtcDmList in '..\COMMON\uRtcDmList.pas',
  fbapidatabase in '..\..\COMPONENTS\FIBPROVIDER\fbapidatabase.pas',
  DmMain in '..\COMMON\DmMain.pas' {MainDm: TDataModule},
  SettingsStorage in '..\..\..\LIB\SettingsStorage.pas',
  fbapiquery in '..\..\COMPONENTS\FIBPROVIDER\fbapiquery.pas',
  ClientDocSqlManager in '..\COMMON\INTERFACE\ClientDocSqlManager.pas',
  DmRtcTable in '..\COMMON\DmRtcTable.pas' {RtcTableDm: TDataModule},
  DmSrvDoc in '..\COMMON\DmSrvDoc.pas' {SrvDocDm: TDataModule},
  SQLTableProperties in '..\COMMON\INTERFACE\SQLTableProperties.pas',
  ServerDocSqlManager in '..\COMMON\INTERFACE\ServerDocSqlManager.pas',
  QueryUtils in '..\COMMON\INTERFACE\QueryUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRtcCustomDm, RtcCustomDm);
  Application.CreateForm(TRtcCommonFunctionsDm, RtcCommonFunctionsDm);
  Application.CreateForm(TRtcObjectsDm, RtcObjectsDm);
//  Application.CreateForm(TMainDm, MainDm);
  Application.CreateForm(TLedaPravoSrvFm, LedaPravoSrvFm);
//  Application.CreateForm(TRtcTableDm, RtcTableDm);
 // Application.CreateForm(TSrvDocDm, SrvDocDm);
//  Application.CreateForm(TRtcUseMonthDm, RtcUseMonthDm);
  RtcCommonFunctionsDm.SetRtcServer(LedaPravoSrvFm.RtcHttpServer1);
  LedaPravoSrvFm.RtcHttpServer1.Listen();
  Application.Run;
end.
