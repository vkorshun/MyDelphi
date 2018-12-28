program flexoprint_dt;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {Form3},
  DmMain in '..\..\COMMON\DmMain.pas' {MainDm: TDataModule},
  menustructure in '..\..\..\..\LIB\menustructure.pas',
  SettingsStorage in '..\..\..\..\LIB\SettingsStorage.pas',
  uLog in '..\..\..\..\LIB\uLog.pas',
  fmhopedialogform in '..\..\..\..\LIB\FORMS\fmhopedialogform.pas' {HopeDialogFormFm},
  fmLogin in '..\..\..\..\LIB\FORMS\fmLogin.pas' {LoginFm},
  FmSelectDbAlias in '..\..\..\..\LIB\FORMS\FmSelectDbAlias.pas' {SelectDbAliasFm},
  fmhopeform in '..\..\..\..\LIB\FORMS\fmhopeform.pas' {HopeFormFm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainDm, MainDm);

  if MainDm.selectAlias and TLoginFm.Login then
    Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
