program ledapravo;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {MainFm},
  AppManager in '..\..\COMMON\AppManager.pas',
  systemconsts in '..\..\COMMON\systemconsts.pas',
  FrameTab in '..\..\COMMON\TABS\FrameTab.pas' {TabFrame: TFrame},
  tabManagerPanel in '..\..\COMMON\TABS\tabManagerPanel.pas',
  menustructure in '..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\LIB\uLog.pas',
  RtcQueryDataSet in '..\..\COMMON\RTC\RtcQueryDataSet.pas',
  RtcSqlQuery in '..\..\COMMON\RTC\RtcSqlQuery.pas',
  commoninterface in '..\..\SERVER\COMMON\INTERFACE\commoninterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
