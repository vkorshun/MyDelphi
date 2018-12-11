program vera_client;

uses
  Vcl.Forms,
  FmMain in 'FmMain.pas' {MainFm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
