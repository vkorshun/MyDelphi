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
  ServerDocSqlManager in '..\COMMON\INTERFACE\ServerDocSqlManager.pas',
  DmRtcTable in '..\COMMON\DmRtcTable.pas' {RtcTableDm: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRtcCustomDm, RtcCustomDm);
  Application.CreateForm(TRtcCommonFunctionsDm, RtcCommonFunctionsDm);
  Application.CreateForm(TLedaPravoSrvFm, LedaPravoSrvFm);
  Application.CreateForm(TRtcTableDm, RtcTableDm);
  //  Application.CreateForm(TRtcObjectsDm, RtcObjectsDm);
//  Application.CreateForm(TRtcUseMonthDm, RtcUseMonthDm);
  Application.CreateForm(TMainDm, MainDm);
  RtcCommonFunctionsDm.SetRtcServer(LedaPravoSrvFm.RtcHttpServer1);
  LedaPravoSrvFm.RtcHttpServer1.Listen();
  Application.Run;
end.
