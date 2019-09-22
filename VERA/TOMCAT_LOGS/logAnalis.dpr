program logAnalis;

uses
  Vcl.Forms,
  FmAnalis in 'FmAnalis.pas' {Form3},
  FmMain in 'FmMain.pas' {MainFm},
  menustructure in '..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\LIB\uLog.pas',
  fmhopedialogform in '..\..\LIB\FORMS\fmhopedialogform.pas',
  fmhopeform in '..\..\LIB\FORMS\fmhopeform.pas' {HopeFormFm},
  FmSelectDbAlias in '..\..\LIB\FORMS\FmSelectDbAlias.pas',
  FrameTab in '..\VERA-DESKTOP\COMMON\TABS\FrameTab.pas' {TabFrame: TFrame},
  tabManagerPanel in '..\VERA-DESKTOP\COMMON\TABS\tabManagerPanel.pas',
  uconsts in 'uconsts.pas',
  FibUtilTab in 'FibUtilTab.pas' {TabFibUtil: TFrame},
  DmFibUtilTab in 'DmFibUtilTab.pas' {FibUtilTabDm: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
