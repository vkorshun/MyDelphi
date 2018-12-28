program vera_server;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {MainFm},
  DmMain in 'DmMain.pas' {MainDm: TDataModule},
  SettingsStorage in '..\LIB\SettingsStorage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainDm, MainDm);
  Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
