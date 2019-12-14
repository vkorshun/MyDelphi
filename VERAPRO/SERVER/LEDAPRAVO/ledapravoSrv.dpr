program ledapravoSrv;

uses
  Vcl.Forms,
  FmLedapravoSrv in 'FmLedapravoSrv.pas' {Form5},
  commoninterface in '..\COMMON\INTERFACE\commoninterface.pas',
  dmrtccommonfunctions in '..\COMMON\dmrtccommonfunctions.pas' {RtcCommonFunctionsDm},
  DmRtcCustom in '..\COMMON\DmRtcCustom.pas' {RtcCustomDm: TDataModule},
  DmRtcObjects in '..\COMMON\DmRtcObjects.pas' {RtcObjectsDm: TDataModule},
  DmRtcUseMonth in '..\COMMON\DmRtcUseMonth.pas' {RtcUseMonthDm: TDataModule},
  uRtcDmList in '..\COMMON\uRtcDmList.pas',
  fbdatabase in '..\..\COMPONENTS\FIBPROVIDER\fbdatabase.pas',
  DmMain in '..\COMMON\DmMain.pas' {MainDm: TDataModule},
  SettingsStorage in '..\..\..\LIB\SettingsStorage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TRtcCustomDm, RtcCustomDm);
  Application.CreateForm(TRtcObjectsDm, RtcObjectsDm);
  Application.CreateForm(TRtcUseMonthDm, RtcUseMonthDm);
  Application.CreateForm(TMainDm, MainDm);
  Application.Run;
end.
